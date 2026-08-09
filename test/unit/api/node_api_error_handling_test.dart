import 'dart:convert';

import 'package:kiss_graph/kiss_graph.dart';
import 'package:kiss_repository/kiss_repository.dart';
import 'package:shelf_plus/shelf_plus.dart';
import 'package:test/test.dart';

/// Stands in for internal detail that a backing store can put in an error:
/// a host, a port, a user name and a password.
const String _secret = 'postgres://svc:hunter2@10.0.0.7:5432/graph';

/// A repository where every operation fails with [error].
///
/// It stands in for a real backing store that is misconfigured or unreachable.
class _FailingRepository implements Repository<Node> {
  _FailingRepository(this.error);

  final Object error;

  Never _fail() => Error.throwWithStackTrace(error, StackTrace.current);

  @override
  String? get path => 'nodes';

  @override
  Future<Node> get(String id) async => _fail();

  @override
  Stream<Node> stream(String id) => _fail();

  @override
  Future<List<Node>> query({Query query = const AllQuery()}) async => _fail();

  @override
  Stream<List<Node>> streamQuery({Query query = const AllQuery()}) => _fail();

  @override
  Future<Node> add(IdentifiedObject<Node> item) async => _fail();

  @override
  Future<Node> update(String id, Node Function(Node current) updater) async =>
      _fail();

  @override
  Future<void> delete(String id) async => _fail();

  @override
  Future<Iterable<Node>> addAll(Iterable<IdentifiedObject<Node>> items) async =>
      _fail();

  @override
  Future<Iterable<Node>> updateAll(
    Iterable<IdentifiedObject<Node>> items,
  ) async =>
      _fail();

  @override
  Future<void> deleteAll(Iterable<String> ids) async => _fail();

  @override
  IdentifiedObject<Node> autoIdentify(
    Node object, {
    Node Function(Node object, String id)? updateObjectWithId,
  }) =>
      _fail();

  @override
  Future<Node> addAutoIdentified(
    Node object, {
    Node Function(Node object, String id)? updateObjectWithId,
  }) async =>
      _fail();

  @override
  void dispose() {}
}

/// A working store where exactly one read fails with [error].
///
/// `createNode` reads the parent twice: once with [get] to find its root and
/// path, and once with [query] to count its siblings. Either read can fail for
/// a reason that is not "the parent is absent", so each is covered separately.
class _StoreWithOneFailingRead extends InMemoryRepository<Node> {
  _StoreWithOneFailingRead({
    required this.error,
    this.failGet = false,
    this.failQuery = false,
  }) : super(queryBuilder: NodeQueryBuilder(), path: 'nodes');

  final Object error;
  final bool failGet;
  final bool failQuery;

  Never _fail() => Error.throwWithStackTrace(error, StackTrace.current);

  @override
  Future<Node> get(String id) async => failGet ? _fail() : super.get(id);

  @override
  Future<List<Node>> query({Query query = const AllQuery()}) async =>
      failQuery ? _fail() : super.query(query: query);
}

/// Collects what the API sends to its server-side error sink.
class _ErrorRecorder {
  final List<Object> errors = <Object>[];
  final List<String> operations = <String>[];

  void call(Object error, StackTrace stackTrace, String operation) {
    errors.add(error);
    operations.add(operation);
  }
}

/// One route, described so the same assertions can run against all of them.
class _Route {
  const _Route(this.name, this.method, this.path, {this.body});

  final String name;
  final String method;
  final String path;
  final Object? body;

  Request request() => Request(
        method,
        Uri.parse('http://localhost:8080$path'),
        body: body == null ? null : jsonEncode(body),
        headers: body == null ? null : {'Content-Type': 'application/json'},
      );
}

const List<_Route> _allRoutes = [
  _Route('createNode', 'POST', '/nodes', body: {
    'previous': '',
    'content': {'name': 'x'}
  }),
  _Route('getNode', 'GET', '/nodes/some-id'),
  _Route('updateNode', 'PATCH', '/nodes/some-id', body: {'pathHash': '9'}),
  _Route('deleteNode', 'DELETE', '/nodes/some-id'),
  _Route('getChildren', 'GET', '/nodes/some-id/children'),
  _Route('trace', 'GET', '/nodes/some-id/trace'),
  _Route('getPathNodes', 'GET', '/nodes/path/1'),
];

void main() {
  group('NodeApiService error responses (#1)', () {
    late _ErrorRecorder recorder;

    setUp(() {
      recorder = _ErrorRecorder();
    });

    Handler appWithRepository(Repository<Node> repository) {
      final router = Router().plus;
      GraphApiConfiguration(repository: repository, onError: recorder.call)
          .setupRoutes(router);
      return router.call;
    }

    Handler appWithFailure(Object error) =>
        appWithRepository(_FailingRepository(error));

    Handler appWithInMemory() => appWithRepository(
          InMemoryRepository<Node>(
            queryBuilder: NodeQueryBuilder(),
            path: 'nodes',
          ),
        );

    // The two error shapes a backing store can raise. RepositoryException is
    // an Exception. StateError is an Error, which `on Exception` never caught.
    final failures = <String, Object>{
      'RepositoryException': RepositoryException(
        message: 'connect failed: $_secret',
      ),
      'StateError': StateError('pool exhausted at $_secret'),
    };

    for (final failure in failures.entries) {
      group('when the repository fails with ${failure.key}', () {
        for (final route in _allRoutes) {
          test('${route.name} answers 500 and leaks no detail', () async {
            final app = appWithFailure(failure.value);

            final response = await app(route.request());
            final body = await response.readAsString();

            expect(response.statusCode, equals(500));
            expect(
              jsonDecode(body),
              equals({'error': NodeApiService.internalErrorMessage}),
            );
            expect(body, isNot(contains(_secret)));
            expect(body, isNot(contains('hunter2')));
            expect(body, isNot(contains('10.0.0.7')));
          });

          test('${route.name} reports the full detail server-side', () async {
            final app = appWithFailure(failure.value);

            await app(route.request());

            expect(recorder.errors, hasLength(1));
            expect(recorder.errors.single.toString(), contains(_secret));
            expect(recorder.operations, equals([route.name]));
          });
        }
      });
    }

    group('client errors keep their status and stay generic', () {
      test('a body with empty content answers 400, not an unhandled error',
          () async {
        final app = appWithInMemory();

        final response = await app(
          Request(
            'POST',
            Uri.parse('http://localhost:8080/nodes'),
            body: jsonEncode({'previous': '', 'content': <String, dynamic>{}}),
            headers: {'Content-Type': 'application/json'},
          ),
        );
        final body = await response.readAsString();

        expect(response.statusCode, equals(400));
        expect(
          jsonDecode(body),
          equals({'error': NodeApiService.invalidRequestMessage}),
        );
        expect(body, isNot(contains('content cannot be empty')));
        expect(recorder.operations, equals(['createNode']));
      });

      test('a malformed JSON body answers 400 without the parser detail',
          () async {
        final app = appWithInMemory();

        final response = await app(
          Request(
            'POST',
            Uri.parse('http://localhost:8080/nodes'),
            body: '{"previous": ',
            headers: {'Content-Type': 'application/json'},
          ),
        );
        final body = await response.readAsString();

        expect(response.statusCode, equals(400));
        expect(
          jsonDecode(body),
          equals({'error': NodeApiService.invalidRequestMessage}),
        );
        expect(body, isNot(contains('FormatException')));
        expect(body, isNot(contains('character')));
      });

      test('an unknown parent answers 400 and does not echo the id sent',
          () async {
        final app = appWithInMemory();

        final response = await app(
          Request(
            'POST',
            Uri.parse('http://localhost:8080/nodes'),
            body: jsonEncode({
              'previous': 'no-such-parent-id',
              'content': {'name': 'x'}
            }),
            headers: {'Content-Type': 'application/json'},
          ),
        );
        final body = await response.readAsString();

        expect(response.statusCode, equals(400));
        expect(jsonDecode(body), equals({'error': 'Parent node not found'}));
        expect(body, isNot(contains('no-such-parent-id')));
      });

      Request createWithParent(String parentId) => Request(
            'POST',
            Uri.parse('http://localhost:8080/nodes'),
            body: jsonEncode({
              'previous': parentId,
              'content': {'name': 'x'}
            }),
            headers: {'Content-Type': 'application/json'},
          );

      test('a parent read that fails to connect answers 500, not 400',
          () async {
        final app = appWithRepository(
          _StoreWithOneFailingRead(
            error: RepositoryException(message: 'connect failed: $_secret'),
            failGet: true,
          ),
        );

        final response = await app(createWithParent('existing-parent'));
        final body = await response.readAsString();

        expect(response.statusCode, equals(500));
        expect(
          jsonDecode(body),
          equals({'error': NodeApiService.internalErrorMessage}),
        );
        expect(body, isNot(contains(_secret)));
        expect(body, isNot(contains('existing-parent')));
        expect(recorder.operations, equals(['createNode']));
        expect(recorder.errors.single.toString(), contains(_secret));
      });

      test('a sibling count that fails to connect answers 500, not 400',
          () async {
        final app = appWithRepository(
          _StoreWithOneFailingRead(
            error: RepositoryException(message: 'connect failed: $_secret'),
            failQuery: true,
          ),
        );

        final created = await app(
          Request(
            'POST',
            Uri.parse('http://localhost:8080/nodes'),
            body: jsonEncode({
              'previous': '',
              'content': {'name': 'parent'}
            }),
            headers: {'Content-Type': 'application/json'},
          ),
        );
        expect(created.statusCode, equals(201));
        final parentId =
            (jsonDecode(await created.readAsString()) as Map)['id'] as String;

        final response = await app(createWithParent(parentId));
        final body = await response.readAsString();

        expect(response.statusCode, equals(500));
        expect(
          jsonDecode(body),
          equals({'error': NodeApiService.internalErrorMessage}),
        );
        expect(body, isNot(contains(_secret)));
        expect(recorder.operations, equals(['createNode']));
        expect(recorder.errors.single.toString(), contains(_secret));
      });

      test('a missing node still answers 404 with a fixed message', () async {
        final app = appWithInMemory();

        final response = await app(
          Request('GET', Uri.parse('http://localhost:8080/nodes/missing-id')),
        );
        final body = await response.readAsString();

        expect(response.statusCode, equals(404));
        expect(jsonDecode(body), equals({'error': 'Node not found'}));
        expect(body, isNot(contains('missing-id')));
      });

      test('deleting a node with children still answers 409', () async {
        final app = appWithInMemory();

        final parentResponse = await app(
          Request(
            'POST',
            Uri.parse('http://localhost:8080/nodes'),
            body: jsonEncode({
              'previous': '',
              'content': {'type': 'parent'}
            }),
            headers: {'Content-Type': 'application/json'},
          ),
        );
        final parent =
            jsonDecode(await parentResponse.readAsString()) as Map<String, dynamic>;

        await app(
          Request(
            'POST',
            Uri.parse('http://localhost:8080/nodes'),
            body: jsonEncode({
              'previous': parent['id'],
              'content': {'type': 'child'}
            }),
            headers: {'Content-Type': 'application/json'},
          ),
        );

        final deleteResponse = await app(
          Request(
            'DELETE',
            Uri.parse('http://localhost:8080/nodes/${parent['id']}'),
          ),
        );
        final body = await deleteResponse.readAsString();

        expect(deleteResponse.statusCode, equals(409));
        expect(
          jsonDecode(body),
          equals({'error': NodeService.hasChildrenMessage}),
        );
      });
    });
  });
}
