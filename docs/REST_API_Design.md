

# REST API Design — Inventory Management System

This REST API manages an inventory system for products, suppliers, and orders.
It supports standard CRUD operations, nested resources, partial and full updates, and handles long-running jobs such as bulk product processing.

---

## 1. Overview

* **Base URL:** `api/v1`
* **Future URL:** `api/v2`
* **Format:** JSON
* **Authentication:** JWT Bearer Token (except login/signup)
* **Supports:** CRUD operations, nested resources, search, partial updates, long-running jobs

---

## 2. Resource Structure

| Resource      | Description               |
| ------------- | ------------------------- |
| `/categories` | Manage product categories |
| `/products`   | Manage products           |
| `/inventory`  | Manage product stock      |
| `/users`      | Manage system users       |
| `/orders`     | Manage orders             |
| `/orderitems` | Products inside an order  |

---

## 3. URL Structure

```
/api/v1/users
/api/v1/categories
/api/v1/products
/api/v2/products
/api/v1/inventory
/api/v1/orders
/api/v1/orders/{orderId}/items

```

---

## 3.1 API URL Structure & Methods

### 3.1.1 Users

| Action         | Method | Endpoint            |
| -------------- | ------ | ------------------- |
| List Users     | GET    | `/users`            |
| Get User       | GET    | `/users/{id}`       |
| Search Users   | GET    | `/users?role=admin` |
| Create User    | POST   | `/users`            |
| Full Update    | PUT    | `/users/{id}`       |
| Partial Update | PATCH  | `/users/{id}`       |
| Delete User    | DELETE | `/users/{id}`       |

---

### 3.1.2 Categories

| Action           | Method | Endpoint                       |
| ---------------- | ------ | ------------------------------ |
| List Categories  | GET    | `/categories`                  |
| Get Category     | GET    | `/categories/{id}`             |
| Search           | GET    | `/categories?name=electronics` |
| Create           | POST   | `/categories`                  |
| Update (Full)    | PUT    | `/categories/{id}`             |
| Update (Partial) | PATCH  | `/categories/{id}`             |
| Delete           | DELETE | `/categories/{id}`             |

---

### 3.1.3 Products

| Action           | Method | Endpoint                 |
| ---------------- | ------ | ------------------------ |
| List Products    | GET    | `/products`              |
| Get Product      | GET    | `/products/{id}`         |
| Search           | GET    | `/products?categoryId=2` |
| Create           | POST   | `/products`              |
| Update (Full)    | PUT    | `/products/{id}`         |
| Update (Partial) | PATCH  | `/products/{id}`         |
| Delete           | DELETE | `/products/{id}`         |

---

### 3.1.4 Orders

| Action      | Method | Endpoint                 |
| ----------- | ------ | ------------------------ |
| List Orders | GET    | `/orders`                |
| Get Order   | GET    | `/orders/{id}`           |
| Search      | GET    | `/orders?status=SHIPPED` |
| Create      | POST   | `/orders`                |
| Update      | PUT    | `/orders/{id}`           |
| Delete      | DELETE | `/orders/{id}`           |

---

### 3.1.5 Nested Resource — Order Items

| Action      | Method | Endpoint                           |
| ----------- | ------ | ---------------------------------- |
| List Items  | GET    | `/orders/{orderId}/items`          |
| Get Item    | GET    | `/orders/{orderId}/items/{itemId}` |
| Add Item    | POST   | `/orders/{orderId}/items`          |
| Update Item | PATCH  | `/orders/{orderId}/items/{itemId}` |
| Delete Item | DELETE | `/orders/{orderId}/items/{itemId}` |

* **Swagger will document:**

`Users`
`GET /users`
`POST /users`
`GET /users/{id}`
`PATCH /users/{id}`
`DELETE /users/{id}`


`Products`
 `GET /products`
 `POST /products`
 `GET /products/{id}`
 `PATCH /products/{id}`
 `DELETE /products/{id}`


`Orders`
`GET /orders`
`POST /orders`
`GET /orders/{id}`

Swagger shows all these in a structured UI

---

## 4. Request / Response Contract

### Create Product

**POST** `/products`

**Request Body:**

```json
{
  "name": "Wireless Mouse",
  "description": "Bluetooth enabled mouse",
  "price": 599.99,
  "categoryId": 2,
  "sku": "WM-2026"
}
```

**Response:**

* Status: `201 Created`

---

### Get Product

**GET** `/products/10`

**Response:**

```json
{
  "id": 10,
  "name": "Wireless Mouse",
  "description": "Bluetooth enabled mouse",
  "price": 599.99,
  "categoryId": 2,
  "sku": "WM-2026"
}
```

* Status: `200 OK`

---

### Partial Update (PATCH)

**PATCH** `/products/10`

**Request Body:**

```json
{
  "price": 549.99
}
```

**Response:**

```json
{
  "message": "Product updated successfully"
}
```

* Status: `200 OK`

---

### Full Update (PUT)

**PUT** `/products/10`

**Request Body:**

```json
{
  "name": "Wireless Mouse V2",
  "description": "Updated model",
  "price": 649.99,
  "categoryId": 2,
  "sku": "WM-2026-V2"
}
```

* Status: `200 OK`

---

## 5. Error Response Format

```json
{
  "status": 400,
  "error": "Bad Request",
  "message": "Price must be greater than 0",
  "path": "/products"
}
```

---

## 6. Partial vs Full Update

| Method | Behavior                                       |
| ------ | ---------------------------------------------- |
| PUT    | Replaces entire resource. All fields required. |
| PATCH  | Updates only provided fields.                  |

**Example:**

* PUT missing `price` → 400
* PATCH with only `price` → 200

---

## 7. How to Make Search URLs

Use query parameters:

```
GET /api/v1/products?categoryId=2
GET /api/v1/products?minPrice=500
GET /api/v1/products?categoryId=2&minPrice=500
```

Format: `?key=value&key=value`

---

## 8. Nested Resource URLs

```
GET /api/v1/orders/5/items
POST /api/v1/orders/5/items
DELETE /api/v1/orders/5/items/10
```

Structure: `/parent/{parentId}/child/{childId}`

---

## 9. Search & Filtering

Example: Search products by name or SKU:

```
GET /products?search=laptop&categoryid=uuid-cat-1&price=500
```

---

## 10. Error Codes

| Status Code | Meaning                            |
| ----------- | ---------------------------------- |
| 200         | Success                            |
| 204         | Success, no content                |
| 400         | Bad request (invalid input)        |
| 401         | Unauthorized (JWT missing/invalid) |
| 403         | Forbidden (role-based access)      |
| 404         | Resource not found                 |
| 409         | Conflict (duplicate entry)         |
| 500         | Internal server error              |


## 11 API Versioning Strategy (v1 → v2 Evolution)

* API Versioning is a technique used to manage changes in an API without breaking existing applications.  
* The Inventory Management System uses **URL-based versioning** for clarity and simplicity.

### Why API Versioning Is Important

* Without versioning:

- You change the API.

- Existing mobile apps or frontend apps break.

- Users experience errors.

* With versioning:

- Old clients keep using v1

- New clients can use v2

*This keeps the system stable and backward compatible.*

* URL-Based Versioning

- Your system uses URL versioning, which is the most common and easiest method.

- The version number is included in the URL.

*Example structure:*

/api/v1/
/api/v2/

* Example Endpoints

* **Version 1 (Current API)**

GET  /api/v1/products
POST /api/v1/products
GET  /api/v1/products/{id}

* Example request:

GET /api/v1/products/101

This returns product information.


* **Version 2 (Future API)**

GET  /api/v2/products
POST /api/v2/products
GET  /api/v2/products/{id}

* Example request:

GET /api/v2/products/101

Version 2 may include new features or changes.

* **Example Difference Between v1 and v2**

**v1 Response**
{
  `"productid": "P101",`
  `"name": "Laptop",`
  `"price": 50000`
}


**v2 Response (Improved)**

{
  `"productid": "P101",`
  `"name": "Laptop",`
  `"price": 50000,`
  `"currency": "INR",`
  `"stock": 120`
}

The Inventory Management System uses **URL-based versioning** to support API evolution from **v1 to v2** while maintaining backward. compatibility and ensuring stable integrations for existing clients.

---

## 12. OpenAPI (Swagger) 

* **What Swagger Is (Simple Meaning)**

- Swagger is a tool that helps you describe, document, and test your APIs.

* Think of Swagger as a manual + testing tool for your API.

* **Without Swagger:**

- Developers must read backend code to understand APIs.

* **With Swagger:**

- Developers see all APIs in one interface

* Example API list in Swagger:

`GET    /api/v1/products`
`POST   /api/v1/products`
`GET    /api/v1/products/{id}`
`DELETE /api/v1/products/{id}`

* **Why Swagger Is Used**

* When an API grows large (like your Inventory System), it becomes hard to remember:

- endpoints

- request format

- response format

- parameters

**Swagger solves this.**

* Example Problem Without Swagger

**The developer opens documentation and sees:**

`POST /products`

Request body:

{
  "name": "Wireless Mouse",
  "price": 599.99,
  "categoryId": 2,
  "sku": "WM-2026"
}


Everything is automatically documented.

* **What Swagger Actually Does**

Swagger helps with three main things:

| Feature         | Explanation                   |
| --------------- | ----------------------------- |
| Documentation   | Shows all APIs clearly        |
| Testing         | Run API requests from browser |
| Standard format | Uses OpenAPI specification    |


* **Example of Swagger Documentation**

* Example API:

`GET /api/v1/products`

`Swagger shows:`

`Endpoint`

`GET /products`

Response
[
  {
    "id": 10,
    "name": "Wireless Mouse",
    "price": 599.99
  }
]

---

































