#  What is gRPC

**gRPC (Google Remote Procedure Call)** is a **high-performance communication framework** used for **service-to-service communication**.

It was developed by Google.

gRPC allows a client to **call functions on a remote server as if they were local functions**.

Example idea:

```
Client calls function → Server executes function → Response returned
```

Instead of using HTTP REST endpoints like:

```
GET /products
POST /orders
```

gRPC uses **remote procedure calls (RPC)** like:

```
GetProduct()
CreateOrder()
UpdateInventory()
```

---

#  gRPC Architecture

Workflow:

```
Client Request
     ↓
Protocol Buffer Encoding
     ↓
HTTP/2 Transport
     ↓
Server Receives Request
     ↓
Service Method Execution
     ↓
Response Serialized
     ↓
Return to Client
```

## 1.Client Request

The client calls a remote method (e.g., CreateProduct()).

## 2. Protocol Buffer Encoding

The request data is converted into a compact binary format using Protocol Buffers.

**.proto files define the API contract.**


`service ProductService` {
  `rpc CreateProduct(ProductRequest) returns (ProductResponse);`
}

**They describe:**

**services: A service defines a collection of RPC functions (methods) that the client can call on the server.**

`service ProductService` {
  `rpc GetProduct(ProductRequest) returns (ProductResponse);`
}

**methods: A method is a remote function inside a service that the client can call.**

rpc CreateProduct (CreateProductRequest) returns (ProductResponse);

* request and response messages: Messages define the structure of the data sent between client and server.

## 3. HTTP/2 Transport

The encoded message is sent through HTTP/2, which supports:

* multiplexing

* streaming

* faster communication.

## 4. Server Receives Request

The server receives the binary message and decodes it.

## 5. Service Method Execution

The requested service method runs on the server.

## 6. Response Serialized

The server converts the response into protobuf binary format.

## 7. Return to Client

The response is sent back to the client.

---

# Types of gRPC Communication

gRPC supports **four communication types**.

---

##  Unary RPC
In Unary RPC, the client sends one request, and the server returns one response.

```
Client  ─── Request ───▶ Server
Client  ◀── Response ─── Server
```

Example

Get product details.

Client sends:

GetProduct(productid=101)

Server returns:

Product name: Laptop
Price: 800

`service ProductService` {
  `rpc GetProduct(ProductRequest) returns (ProductResponse);`
}

---

##  Server Streaming
Here, the client sends one request, but the server sends multiple responses (a stream).
Client sends request → server sends multiple responses.

```
Client  ─── Request ───▶ Server
Client  ◀── Response 1 ─ Server
Client  ◀── Response 2 ─ Server
Client  ◀── Response 3 ─ Server
```

Example:

```
Example

Listing products from a catalog.

Client:

ListProducts()

Server responses:

Product 1
Product 2
Product 3
Product 4
```

`service ProductService` {
  `rpc ListProducts(ProductRequest) returns (stream ProductResponse);`
}

stream means multiple responses will be sent.

---

##  Client Streaming

In Client Streaming, the client sends multiple messages, and the server returns one final response after receiving everything.
Client sends multiple messages → server sends one response.

```
Client  ─── Data 1 ───▶
Client  ─── Data 2 ───▶
Client  ─── Data 3 ───▶ Server
Client  ◀── Final Response ───
```

```
Example

Uploading inventory data.

Client sends:

Product 1
Product 2
Product 3
Product 4

Server response:

Upload complete. 4 items added.

 `service InventoryService` {
  `rpc UploadInventory(stream Product) returns (UploadStatus);`
}
```

---

## Bidirectional Streaming

In Bidirectional Streaming, both client and server send messages simultaneously.
Both sides keep sending data independently.


```
Client  ─── Data 1 ───▶
Server  ◀── Data A ───
Client  ─── Data 2 ───▶
Server  ◀── Data B ───
Client  ─── Data 3 ───▶
Server  ◀── Data C ───
```

Example:

```
Real-time inventory updates
service InventoryService {
  rpc LiveInventory(stream InventoryRequest) returns (stream InventoryResponse);
}
```

---

# gRPC Workflow (Step-by-Step)

Example: **Get Product**

### Step 1
The client application calls a function using the gRPC client stub.

Client calls:

```
GetProduct(id=101)

```

### Step 2

Client stub serializes request into **protobuf binary**.

Example message defined in .proto:

message ProductRequest {
  int32 id = 1;
}

The request:

id = 101

is converted into compact binary format.

### Step 3

The serialized binary data is sent to the server using HTTP/2.

* Multiplexing (multiple requests on one connection)

* Faster communication

* Streaming support

### Step 4

Server receives request.

The server then:

Decodes the protobuf message

Identifies which service method should handle the request

service ProductService {
  rpc GetProduct(ProductRequest) returns (ProductResponse);
}

### Step 5

Now the actual service implementation runs.

Example server code:

def GetProduct(self, request):
    product = database.get_product(request.id)
    return product

Here the server executes the business logic.


### Step 6

The server retrieves the product from the database.

Example:

SELECT * FROM products WHERE id = 101

Database returns:

Name: Laptop
Price: 800
Stock: 25

### Step 7

The server creates a response message.

Example response structure:

message ProductResponse {
  string name = 1;
  float price = 2;
}

The response is then serialized into protobuf binary format.

### Step 8

The response travels back via HTTP/2.

The client stub automatically converts the binary data into an object.

Client receives:

product.name
product.price

Example output:

Laptop
800


---

# gRPC in Microservices

gRPC is widely used for **internal microservice communication**.

Example architecture:

```
API Gateway
      ↓
User Service (gRPC)
Product Service (gRPC)
Order Service (gRPC)
Inventory Service (gRPC)
```

REST is used for **external clients**, gRPC for **internal services**.

---
# Advantages of gRPC

Very fast communication
Smaller payloads
Strong schema
Streaming support
Auto code generation
Ideal for microservices

---


