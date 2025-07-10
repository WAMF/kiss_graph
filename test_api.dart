import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final client = HttpClient();
  
  try {
    // Test 1: Create a root node
    print('Creating root node...');
    final createRequest = await client.postUrl(Uri.parse('http://localhost:8080/nodes'));
    createRequest.headers.contentType = ContentType.json;
    createRequest.write(jsonEncode({
      'previous': null,
      'spatialHash': 'abc123',
      'content': {'name': 'Root Node', 'value': 100}
    }));
    
    final createResponse = await createRequest.close();
    final createBody = await createResponse.transform(utf8.decoder).join();
    final rootNode = jsonDecode(createBody);
    print('Root node created: $createBody');
    
    // Test 2: Get the root node
    print('\nGetting root node...');
    final getRequest = await client.getUrl(Uri.parse('http://localhost:8080/nodes/${rootNode['id']}'));
    final getResponse = await getRequest.close();
    final getBody = await getResponse.transform(utf8.decoder).join();
    print('Retrieved node: $getBody');
    
    // Test 3: Create a child node
    print('\nCreating child node...');
    final childRequest = await client.postUrl(Uri.parse('http://localhost:8080/nodes'));
    childRequest.headers.contentType = ContentType.json;
    childRequest.write(jsonEncode({
      'previous': rootNode['id'],
      'spatialHash': 'abc124',
      'content': {'name': 'Child Node', 'value': 50}
    }));
    
    final childResponse = await childRequest.close();
    final childBody = await childResponse.transform(utf8.decoder).join();
    final childNode = jsonDecode(childBody);
    print('Child node created: $childBody');
    
    // Test 4: Get children of root node
    print('\nGetting children of root node...');
    final childrenRequest = await client.getUrl(Uri.parse('http://localhost:8080/nodes/${rootNode['id']}/children'));
    final childrenResponse = await childrenRequest.close();
    final childrenBody = await childrenResponse.transform(utf8.decoder).join();
    print('Children: $childrenBody');
    
    // Test 5: Trace from child to root
    print('\nTracing from child to root...');
    final traceRequest = await client.getUrl(Uri.parse('http://localhost:8080/nodes/${childNode['id']}/trace'));
    final traceResponse = await traceRequest.close();
    final traceBody = await traceResponse.transform(utf8.decoder).join();
    print('Trace: $traceBody');
    
    // Test 6: Spatial query
    print('\nSpatial query for "abc"...');
    final spatialRequest = await client.getUrl(Uri.parse('http://localhost:8080/nodes/spatial/abc'));
    final spatialResponse = await spatialRequest.close();
    final spatialBody = await spatialResponse.transform(utf8.decoder).join();
    print('Spatial results: $spatialBody');
    
    print('\nAll tests completed successfully!');
    
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}