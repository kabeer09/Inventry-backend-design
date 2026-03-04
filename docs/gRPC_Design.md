# Inventory – gRPC Service Definition

---

# 1 Overview

StockSphere uses **gRPC** for high-performance internal communication between services.

gRPC is used for:

* Internal microservice communication
* Inventory updates
* Order processing
* Background job management
* High-throughput operations

Protocol:

* HTTP/2
* Protocol Buffers (Protobuf)
* Port: `4000`

---

# 2 Architecture Context

```
Client → REST/GraphQL API → gRPC Services → PostgreSQL
```

* REST/GraphQL acts as API gateway
* gRPC used internally between services
* Strongly typed contracts using `.proto`

---

# 3 Package & Versioning

```proto
syntax = "proto3";

package Inventory.v1;
```

Versioning strategy:

* v1 → initial release
* Future versions: `Inventory.v2`
* Maintain backward compatibility

---

# 4 Common Message Types

---

## 4.1 Empty

```proto
message Empty {}
```

---

## 4.2 Standard Response

```proto
message DeleteResponse {
  bool success = 1;
  string message = 2;
}
```

---

# 5 UserService

Handles internal user operations.

---

## Service Definition

```proto
service UserService {
  rpc CreateUser (CreateUserRequest) returns (UserResponse);
  rpc GetUser (GetUserRequest) returns (UserResponse);
  rpc ListUsers (Empty) returns (UserListResponse);
  rpc UpdateUser (UpdateUserRequest) returns (UserResponse);
  rpc DeleteUser (DeleteUserRequest) returns (DeleteResponse);
}
```

---

## Messages

```proto
message User {
  string id = 1;
  string name = 2;
  string email = 3;
  string role = 4;
  string created_at = 5;
  string updated_at = 6;
}
```

---

# 6 CategoryService

```proto
service CategoryService {
  rpc CreateCategory (CreateCategoryRequest) returns (CategoryResponse);
  rpc GetCategory (GetCategoryRequest) returns (CategoryResponse);
  rpc ListCategories (Empty) returns (CategoryListResponse);
  rpc DeleteCategory (DeleteCategoryRequest) returns (DeleteResponse);
}
```

---

# 7 ProductService

```proto
service ProductService {
  rpc CreateProduct (CreateProductRequest) returns (ProductResponse);
  rpc GetProduct (GetProductRequest) returns (ProductResponse);
  rpc ListProducts (ProductFilterRequest) returns (ProductListResponse);
  rpc UpdateProduct (UpdateProductRequest) returns (ProductResponse);
  rpc DeleteProduct (DeleteProductRequest) returns (DeleteResponse);
}
```

---

## Product Message

```proto
message Product {
  string id = 1;
  string name = 2;
  string sku = 3;
  double price = 4;
  int32 quantity = 5;
  string category_id = 6;
  string created_at = 7;
}
```

---

# 8 OrderService

```proto
service OrderService {
  rpc CreateOrder (CreateOrderRequest) returns (OrderResponse);
  rpc GetOrder (GetOrderRequest) returns (OrderResponse);
  rpc ListOrders (ListOrdersRequest) returns (OrderListResponse);
  rpc UpdateOrderStatus (UpdateOrderStatusRequest) returns (OrderResponse);
}
```

---

## Order Message

```proto
message Order {
  string id = 1;
  string user_id = 2;
  repeated OrderItem items = 3;
  double total_amount = 4;
  string status = 5;
  string created_at = 6;
}
```

---

# 9 InventoryService

Handles stock adjustment and synchronization.

---

## Unary Example

```proto
service InventoryService {
  rpc AdjustStock (AdjustStockRequest) returns (ProductResponse);
}
```

---

## Server Streaming Example (Inventory Sync)

```proto
service InventoryService {
  rpc SyncInventory (SyncRequest) returns (stream SyncProgressResponse);
}
```

### Why Streaming?

* Large inventory updates
* Real-time progress updates
* Efficient for long-running operations

---

# 10 JobService (Long Running Operations)

```proto
service JobService {
  rpc StartInventoryJob (Empty) returns (JobResponse);
  rpc GetJobStatus (GetJobRequest) returns (JobResponse);
  rpc StreamJobProgress (GetJobRequest) returns (stream JobProgressResponse);
}
```

---

## Job Message

```proto
message Job {
  string id = 1;
  string type = 2;
  string status = 3;
  string created_at = 4;
  string completed_at = 5;
}
```

---

# 11 Communication Patterns Used

| Pattern          | Used For                |
| ---------------- | ----------------------- |
| Unary            | CRUD operations         |
| Server Streaming | Inventory sync progress |
| Server Streaming | Job progress tracking   |

No client streaming required in v1.

---

# 12 Authentication

JWT passed in gRPC metadata:

```
authorization: Bearer <token>
```

Extracted in:

* gRPC interceptor
* Role-based authorization applied at service level

---

# 13 Error Handling

Standard gRPC status codes:

| Code              | Meaning           |
| ----------------- | ----------------- |
| OK                | Success           |
| INVALID_ARGUMENT  | Bad request       |
| NOT_FOUND         | Resource missing  |
| UNAUTHENTICATED   | Invalid JWT       |
| PERMISSION_DENIED | Unauthorized role |
| INTERNAL          | Server error      |

Example (conceptual):

```
status.Error(codes.NotFound, "Product not found")
```

---

# 14 Why gRPC for Inventory?

| Feature       | REST     | gRPC   |
| ------------- | -------- | ------ |
| Transport     | HTTP/1.1 | HTTP/2 |
| Payload       | JSON     | Binary |
| Speed         | Medium   | High   |
| Streaming     | Limited  | Native |
| Strong typing | Weak     | Strong |

gRPC is ideal for:

* Microservices
* High-performance internal APIs
* Background processing

---

# 15 Deployment Model

* gRPC services run inside Docker containers
* Internal communication only
* Not exposed publicly
* API Gateway handles external traffic

---

