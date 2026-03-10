# GraphQL_API_Design.md (Documentation Only Version)

## 1. Overview

The Inventory system exposes a **GraphQL API** to manage core business entities such as users, categories, products, orders, and inventory jobs.

GraphQL provides a flexible API layer that allows clients to request only the data they need, reducing unnecessary data transfer and improving performance.

The GraphQL API follows a **single endpoint architecture** where all operations are performed through a single HTTP endpoint.

Key benefits include:

* Flexible data fetching
* Reduced over-fetching and under-fetching
* Strong schema-based type system
* Efficient nested data retrieval
* Simplified client-server communication

---

## 2. GraphQL Endpoint

All GraphQL requests are handled through a **single endpoint**.

Endpoint:

```
POST /graphql
```

Base URL example:

```
http://localhost:4000/graphql
```

Clients send GraphQL queries and mutations as JSON payloads in HTTP POST requests.

---

## 3. Authentication Strategy

Authentication for the GraphQL API is implemented using **JWT (JSON Web Tokens)**.

After a user successfully logs in, the server issues a JWT token that must be included in subsequent API requests.

The token is sent through the HTTP Authorization header using the Bearer token format.

Authentication flow:

1. The user logs in through the authentication service.
2. The server generates a JWT token.
3. The client stores the token.
4. Each GraphQL request includes the token in the Authorization header.
5. Middleware verifies the token and extracts the user information.

If the token is invalid or missing, the request is rejected.

---

## 4. GraphQL Core Concepts

**GraphQL Schema**

The schema defines the structure of the API.

`type Product` { 
 `id: ID!`
 `name: String!`
 `price: Float!`
 `category: Category`
}`

**!* required fields**

**Query Type (Data Fetching)**

Queries are used to read data.

Example:

`query` {
 `products` {
  `id`
 ` name`
  `price`
 }
}

**Server response:**

{
 `"data":`{
  `"products":`[
   {
    `"id":"1",`
    `"name":"Laptop",`
    `"price":1000`
   }
  ]
 }
}

---

## 5. Core Entities

The GraphQL API manages several key entities within the inventory system.

### Users

Users represent system participants such as administrators, managers, and staff members.

User records store information such as:

* User identifier
* Name
* Email
* Role
type User {
  id: ID
  name: String
  email: String
  role: UserRole
}

User roles determine the level of access to the system.

---

### Categories

Categories group products into logical classifications.

Each category includes:

* Categoryid
* name
* description

type Category {
  Categoryid: ID
  name: String
  description: String
}

Categories help organize products within the inventory system.

---

### Products

Products represent items available in the inventory.

Product records contain:

* Productid
* Name
* SKU 
* Price
* Quantity


type Product {
  Productid: ID
  name: String
  sku: String
  price: Float
  quantity: Int
}
Products are linked to categories and may be included in customer orders.

---

### Orders

Orders represent purchase transactions created by users.

Each order contains:

* Orderid
* TotalAmount
* Orderstatus

type Order {
  orderid: ID
  totalAmount: Float
  status: OrderStatus
}

Orders move through various states such as pending, processing, shipped, or completed.

---

### Order Items

Order items represent individual products within an order.

Each item contains:

* Product reference
* Quantity ordered
* Price at the time of purchase

This structure allows a single order to contain multiple products.

---

## 6. Query Design

Queries are used to retrieve data from the system.

The GraphQL API provides queries for:

* Retrieving the current authenticated user
* Listing users
* Fetching categories
* Fetching products
* Fetching products by category
* Retrieving orders
* Checking background job status

query {
  products {
    id
    name
    price
  }
}

Queries support nested data retrieval, allowing clients to fetch related data within a single request.

---

## 7. Mutation Design

Mutations are used to modify data within the system.

The GraphQL API supports mutations for:

* Creating users
* Updating users
* Deleting users
* Creating categories
* Updating categories
* Deleting categories
* Creating products
* Updating products
* Deleting products
* Creating orders
* Updating order status
* Starting inventory synchronization jobs

mutation {
 createProduct(
   name:"Laptop"
   price:1000
 ) {
   id
   name
 }
}

{
 "data": {
  "createProduct": {
   "id":"123",
   "name":"Laptop"
  }
 }
}

**What this means**

* mutation → Used to change data (create, update, delete).

* createProduct → A function defined in the GraphQL API.

* name and price → Input parameters.

* id, name → Fields we want returned in the response.


Mutations ensure that data updates follow controlled workflows and validation rules.

---

## 8. Nested Resource Design

GraphQL allows clients to request related data in a single query.

Instead of making multiple API calls to retrieve related resources, the client can request nested objects directly from the server.

For example, when retrieving a category, the client can also request all products associated with that category within the same query.

This significantly reduces the number of network requests required.

query {
 user(id: 1) {
   name
   email
   order {
     orderid
   }
   products {
     productid
     name
     price
   }
 }
}

**GraphQL Response**
{
  "data": {
    "user": {
      "name": "Bob",
      "email": "Bob@email.com",
      "order": {
        "orderid": "ORD101"
      },
      "products": [
        {
          "productid": "P1",
          "name": "Laptop",
          "price": 1000
        },
        {
          "productid": "P2",
          "name": "Mouse",
          "price": 20
        }
      ]
    }
  }
}
---

## 9. Error Handling Strategy

GraphQL returns structured error responses when operations fail.

Errors include:

* A human-readable error message
* An error code describing the issue
* Additional metadata for debugging

{
 "errors":[
  {
   "message":"Product not found"
  }
 ]
}
Common error categories include:

* Authentication errors
* Authorization failures
* Invalid input data
* Resource not found
* Internal server errors

This consistent error format makes it easier for clients to handle failures.

---

## 10. System Architecture Flow

The GraphQL request flow follows these steps:

Client Application → GraphQL Endpoint → Authentication Middleware → Resolvers → Service Layer → PostgreSQL Database

The resolver layer translates GraphQL operations into service calls that interact with the database.

Client Application
↓
GraphQL Endpoint
↓
Authentication Middleware
↓
Resolvers
↓
Service Layer
↓
PostgreSQL Database

Resolvers translate GraphQL operations into database queries.



### Step 1 — Client Sends Query

Example: A user wants to fetch name and email.

`query` {
  `user(id: 1)` {
    `name`
    `email`
  }
}

* The request goes to:

`POST /graphql`


{
 ` "query": "query { user(id:1) { name email } }"`
}

* So the client only asks for the fields it needs.



### Step 2 — GraphQL API Receives Request

 The request hits the GraphQL endpoint.

**Example endpoint:**

http://localhost:3000/graphql

**The GraphQL server:**

* Receives the query

* Parses it

* Sends it to the schema validator

### Step 3 — Schema Validation

GraphQL checks if the query matches the schema.

`type User` {
 ` userid: ID`
  `name: String`
 ` email: String`
}

`type Query` {
  `user(id: ID): User`
}


**GraphQL checks:**

* Does user query exist?

* Does User type exist?

* Are name and email valid fields?


**If the query is invalid:**

`query` {
 ` userid(id: 1) `{
    `name,`
   ` email`

  }
}

**Error:**

**`Cannot query field "userid" on type "User"`**


### Step 4 — Resolver Execution

**A resolver is a function that resolves a field in a GraphQL query by fetching the required data from a database, API.**

### Step 5 — Database Query

**Resolver fetches data from the database.**

{
  `"id": 1,`
  `"name": "Bob",`
  `"email": "Bob@email.com"`
}

### Step 6 — GraphQL Builds Response

**GraphQL removes unnecessary fields and only returns what the client asked.**

Client asked:

`name`
`email`


{
 `"data":` {
   ` "user":` {
     ` "name": "Bob",`
     ` "email": "Bob@email.com"`
    }
  }
}



---

