# Graph Node Service

A microservice for managing graph-based nodes that support spatial queries and path tracing. Each node stores content, links to a previous node, and forms part of a tree or DAG structure that can be queried by ID, parent, or spatial region.

Kiss_repository is used to store the nodes.

---

## 🌐 Overview

This service provides a REST API to:

- Create and manage nodes
- Trace ancestry back to the root
- Retrieve child nodes
- Query by `spatialHash` prefix (similar to Geohash)
- Maintain path-based and spatial data relationships

---

## 🧩 Node Structure

Each node includes:

| Field        | Description                                     |
|--------------|-------------------------------------------------|
| `id`         | Unique node identifier                          |
| `root`       | ID of the root node of this graph               |
| `previous`   | ID of the parent node (or null for root)        |
| `spatialHash`| A spatial prefix string for regional lookup     |
| `content`    | Arbitrary JSON object representing the payload  |

---

## 📖 API Endpoints

| Method | Path                           | Description                                |
|--------|--------------------------------|--------------------------------------------|
| POST   | `/nodes`                       | Create a new node                          |
| GET    | `/nodes/{id}`                  | Get node by ID                             |
| PATCH  | `/nodes/{id}`                  | Update `spatialHash` or `content`          |
| DELETE | `/nodes/{id}`                  | Delete node (error if it has children)     |
| GET    | `/nodes/{id}/children`         | List direct children of a node             |
| GET    | `/nodes/{id}/trace`            | Trace node path back to root               |
| GET    | `/nodes/spatial/{prefix}`      | Query all nodes starting with `spatialHash`|

See [graph-node-api.yaml](./graph-node-api.yaml) for full OpenAPI documentation.

---


## 🛠 Use Cases

- Building decision trees or story graphs
- Dependency resolution graphs
- Knowledge graphs with structured and spatial components


## 📄 License

MIT License – feel free to adapt and extend.

