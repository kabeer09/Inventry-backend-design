
# Inventory – GraphQL API Design Documentation

---

# 1️ Overview

Inventory provides a **GraphQL API** to manage:

* Users 
* Categories
* Products
* Orders
* Order Items
* Inventory
* Background Jobs

GraphQL enables:

* Flexible data fetching
* Reduced over-fetching
* Strong type system
* Single endpoint architecture

---

# 2️ GraphQL Endpoint

```
POST: /graphql

```

All queries and mutations are sent to:

```
http://localhost:4000/graphql
```

---

# 3️ Authentication Strategy

Authentication is handled using:

* JWT Bearer Token
* Sent via HTTP Header:

```
Authorization: Bearer <access_token>
```

### Auth Flow

1. User logs in via REST `graphql/auth/login`
2. Receives JWT
3. JWT sent with GraphQL requests
4. GraphQL context extracts and validates user

---

# 4️ GraphQL Schema Design

The schema consists of:

Scalars

Enums

Object Types

Input Types

Queries

Mutations

---

# 5️ Core Types

---

## 5.1 User

```graphql
type User {
  Userid: ID!
  name: String!
  email: String!
  role: UserRole!
  
}
```

### Enum

```graphql
enum UserRole {
  ADMIN
  MANAGER
  STAFF
}
```

---

## 5.2 Category

```graphql
type Category {
  Categoryid: ID!
  name: String!
  description: String
  products: [Product!]!
  
}
```

---

## 5.3 Product

```graphql
type Product {
  Productid: ID!
  name: String!
  sku: String!
  price: Float!
  quantity: Int!
  category: Category!
}
```

---

## 5.4 Order

```graphql
type Order {
  Orderid: ID!
  user: User!
  items: [OrderItem!]!
  totalAmount: Float!
  status: OrderStatus!
  
}
```

### Enum

```graphql
enum OrderStatus {
  PENDING
  PROCESSING
  SHIPPED
  CANCELLED
  DELIVERED
}
```

---

## 5.5 OrderItem

```graphql
type OrderItem {
  OrderItemid: ID!
  product: Product!
  quantity: Int!
  price: Float!
}
```

---

## 5.6 InventoryJob (Long Running Process)

```graphql
type InventoryJob {
  id: ID!
  status: JobStatus!

}
```

```graphql
enum JobStatus {
  QUEUED
  RUNNING
  COMPLETED
  FAILED
}
```

---

# 6️ Query Design

All read operations.

---

## 6.1 User Queries

```graphql
type Query {
  me: User
  users: [User!]!
  user(id: ID!): User
}
```

---

## 6.2 Category Queries

```graphql
type Query {
  categories: [Category!]!
  category(id: ID!): Category
}
```

---

## 6.3 Product Queries

```graphql
type Query {
  products: [Product!]!
  product(id: ID!): Product
  productsByCategory(categoryId: ID!): [Product!]!
}
```

---

## 6.4 Order Queries

```graphql
type Query {
  orders: [Order!]!
  order(id: ID!): Order
}
```

---

## 6.5 Job Query (Long Running)

```graphql
type Query {
  inventoryJob(id: ID!): InventoryJob
}
```

---

# 7️ Mutation Design

All write operations.

---

## 7.1 User Mutations

```graphql
type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  deleteUser(id: ID!): Boolean!
}
```

### Inputs

```graphql
input CreateUserInput {
  name: String!
  email: String!
  password: String!
  role: UserRole!
}
```

```graphql
input UpdateUserInput {
  name: String
  email: String
  role: UserRole
}
```

> GraphQL naturally supports **partial updates** because fields are optional in UpdateUserInput.

---

## 7.2 Category Mutations

```graphql
type Mutation {
  createCategory(input: CreateCategoryInput!): Category!
  updateCategory(id: ID!, input: UpdateCategoryInput!): Category!
  deleteCategory(id: ID!): Boolean!
}
```

---

## 7.3 Product Mutations

```graphql
type Mutation {
  createProduct(input: CreateProductInput!): Product!
  updateProduct(id: ID!, input: UpdateProductInput!): Product!
  deleteProduct(id: ID!): Boolean!
}
```

---

## 7.4 Order Mutations

```graphql
type Mutation {
  createOrder(input: CreateOrderInput!): Order!
  updateOrderStatus(id: ID!, status: OrderStatus!): Order!
}
```

---

## 7.5 Inventory Job Mutation (Long Running Process)

```graphql
type Mutation {
  startInventorySync: InventoryJob!
}
```

### Workflow

1. Client calls `startInventorySync`
2. Returns job ID
3. Client polls `inventoryJob(id)`
4. Status transitions:

   * QUEUED → RUNNING → COMPLETED

---

# 8️ Nested Resource Design

GraphQL eliminates traditional nested REST routes like:

```
/categories/:id/products
```

Instead, nested resources are resolved via type relations:

```graphql
query {
  category(id: "1") {
    id
    name
    products {
      id
      name
      price
    }
  }
}
```

---

# 9️ Pagination Strategy

For scalability:

```graphql
type ProductConnection {
  items: [Product!]!
  totalCount: Int!
  hasNextPage: Boolean!
}
```

Query:

```graphql
products(limit: Int!, offset: Int!): ProductConnection!
```

---

# 10 Error Handling Strategy

GraphQL returns:

```json
{
  "data": null,
  "errors": [
    {
      "message": "Unauthorized",
      "extensions": {
        "code": "UNAUTHENTICATED"
      }
    }
  ]
}
```

Standard error codes:

* UNAUTHENTICATED
* FORBIDDEN
* NOT_FOUND
* BAD_USER_INPUT
* INTERNAL_SERVER_ERROR

---

# 1️1️ Authorization Rules

| Role    | Permissions                  |
| ------- | ---------------------------- |
| ADMIN   | Full access                  |
| MANAGER | Manage products & categories |
| STAFF   | Read-only + create orders    |

Authorization enforced in resolvers using JWT role claim.

---

# 1️2️ GraphQL vs REST in Inventory

| Feature       | REST           | GraphQL       |
| ------------- | -------------- | ------------- |
| Endpoint      | Multiple       | Single        |
| Over-fetching | Possible       | Avoided       |
| Nested data   | Multiple calls | Single query  |
| Versioning    | v1/v2          | Evolve schema |

---

# 1️3️ Security Considerations

* Query depth limiting
* Query complexity limiting
* Rate limiting
* JWT verification middleware
* Disable introspection in production

---

# 1️4️ Final Architecture Flow

Client → `/graphql` → Auth Middleware → Resolvers → Services → PostgreSQL

---

# 15 Performance & Security

* Security measures:

* Query depth limiting

* Query complexity limiting

* Rate limiting

* Disable introspection in production

* JWT validation middleware


# 16 Versioning Strategy

* Unlike REST (/v1), GraphQL evolves via:

* Adding new fields

* Deprecating old fields

* Maintaining backward compatibility

Example:

type Product {
  price: Float @deprecated(reason: "Use priceWithTax instead")
}



---