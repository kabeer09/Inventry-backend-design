# JWT Authentication Design Documentation

## 1. Overview

The Inventory system uses **JWT (JSON Web Tokens)** for authentication and authorization.

JWT is a compact and secure method for transmitting information between the client and the server. It allows **stateless authentication**, meaning the server **does not need to store session information**.

Key benefits of JWT authentication include:

* Stateless authentication
* Secure token-based access
* Scalability for distributed systems
* Reduced database lookups for authentication

JWT is commonly used for securing REST APIs, GraphQL APIs, and service-to-service communication.

---

# 2. Authentication Flow

The authentication process follows these steps:

1. The user sends login credentials (email and password) to the authentication endpoint.
2. The server verifies the credentials.
3. If authentication succeeds, the server generates a JWT token.
4. The client stores the token.
5. The token is included in every API request.
6. The server verifies the token before processing the request.

Authentication flow:

`Client → Login Request → Server Validation → JWT Generation → Client Stores Token → Authenticated API Requests`

---

# 3. JWT Structure

A JWT token consists of three parts separated by dots:

Header.Payload.Signature

Example token format:

```
abc123.cba321.bca231
```

Each part contains specific information.

---

## 3.1 Header()----> abc123

The header contains metadata about the token.

Example:

```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

Fields:

* **alg** → Algorithm used to sign the token
* **typ** → Token type (JWT)

---

## 3.2 Payload----> cba321

The payload contains **claims**, which are pieces of information about the user.

Example payload:

```json
{
  "userId": 101,
  "email": "user@example.com",
  "role": "ADMIN",
  "exp": 1710000000
}
```

Common claims include:

| Claim  | Description             |
| ------ | ----------------------- |
| userId | Unique user identifier  |
| email  | User email address      |
| role   | User authorization role |
| exp    | Token expiration time   |

The payload is encoded but **not encrypted**, so sensitive data should not be included.

---

## 3.3 Signature---> bca231

The signature ensures that the token has not been tampered with.

It is generated using the header, payload, and a secret key.

Example concept:

```
Signature = HMACSHA256(
  base64UrlEncode(header) + "." + base64UrlEncode(payload),
  secret_key
)
```
**In JWT (JSON Web Token), the dot (.) is used as a separator between the three parts of the token.Each part is Base64URL encoded and separated by a dot (.).**

The server verifies the signature before accepting the token.

---

# 4. Using JWT in API Requests

Once authenticated, the client includes the JWT token in the HTTP Authorization header.

Example request header:

```
Authorization: Bearer <access_token>
```

Example API request:

```
GET /api/v1/products
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

The server extracts and validates the token before executing the request.

---

# 5. Token Validation Process

When the server receives a request, the following validation steps occur:

1. Extract token from Authorization header.
2. Verify token signature using the secret key.
3. Check token expiration time.
4. Decode payload information.
5. Attach user information to the request context.

If verification fails, the request is rejected.

---

# 6. Access Token vs Refresh Token

To improve security, many systems use **two types of tokens**.

| Token         | Purpose                            |
| ------------- | ---------------------------------- |
| Access Token  | Used to access protected APIs      |
| Refresh Token | Used to generate new access tokens |

Access tokens usually have a **short expiration time**, while refresh tokens last longer.

Example:

Access token expiration → 3600 sec
Refresh token expiration → 7 days

---

# 7. Authorization Using JWT

JWT tokens also carry **role information** which allows the system to enforce authorization rules.

Example role claim:

```json
{
  "role": "ADMIN"
}
```

Example role permissions:

| Role    | Permissions                     |
| ------- | ------------------------------- |
| ADMIN   | Full system access              |
| MANAGER | Manage products and categories  |
| STAFF   | Create orders and view products |

The server checks the user role before executing protected operations.

---


# 8. Token Expiration and Renewal

JWT tokens should expire after a certain time to reduce security risks.

Example expiration policy:

Access Token → 3600 sec
Refresh Token → 7 days

When the access token expires, the client requests a new token using the refresh token.

Example flow:

**Client → Send Refresh Token → Server Validates → Issue New Access Token**

---

# 9. JWT in Inventory System Architecture

Within the Inventory system architecture, JWT is used to secure API requests.

Architecture flow:

Client Application
↓
API Request with JWT
↓
Authentication Middleware
↓
Authorization Check
↓
Service Layer
↓
Database

JWT ensures that only authenticated users can access protected resources.

---

# 10. Advantages of JWT Authentication

**Using JWT provides several advantages:**

* Stateless authentication

* No session storage needed

* Secure API communication

* Works well with microservices


These features make JWT a widely adopted authentication mechanism.

---


