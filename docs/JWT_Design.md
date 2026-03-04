
# Inventory Managemenht System – JWT Authentication & Claims Design

---

# 1️ Overview

 Inventory uses **JSON Web Tokens (JWT)** for authentication and authorization.

JWT is used to:

* Authenticate users
* Identify user role
* Enforce role-based access control (RBAC)
* Secure REST, GraphQL, and gRPC APIs

---

# 2️ Why JWT?

| Feature        | Benefit                           |
| -------------- | --------------------------------- |
| Stateless      | No server session storage         |
| Self-contained | Token carries user information    |
| Scalable       | Works well in distributed systems |
| Secure         | Signed using secret/private key   |

---

# 3️ JWT Structure

A JWT consists of three parts:

```
HEADER.PAYLOAD.SIGNATURE
```

Example:

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.
eyJzdWIiOiIxMjMiLCJyb2xlIjoiQURNSU4ifQ.
signature
```

---

# 4️ Header

```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

* `alg`: Signing algorithm (HMAC SHA256)
* `typ`: Token type

---

# 5️ Payload (Claims)

 Inventory uses:

 {
  "sub": "user_123",
  "email": "admin@invtry.com",
  "role": "ADMIN",
  "iat": 1710000000,
  "exp": 1710003600,
  "iss": "invtry-api"
}

### Standard Claims

### Custom Claims (Application-Specific)

### Signing Algorithm

* For development:

* HS256 (HMAC SHA-256)

* For production (recommended):

* RS256 (Public/Private key pair)

* Benefits of RS256:

* More secure

* Microservice-friendly

* Public key distribution possible

---

# 6️ Standard Claims Used

| Claim | Description              |
| ----- | ------------------------ |
| iss   | Issuer                   |
| sub   | Subject (User ID)        |
| iat   | Issued At                |
| exp   | Expiration Time          |
| jti   | JWT ID (unique token ID) |

---

# 7️ Application-Specific Claims (Important)

These are relevant to  Inventory.

| Claim       | Purpose                      |
| ----------- | ---------------------------- |
| userId      | Unique user identifier       |
| email       | User email                   |
| role        | Role (ADMIN, MANAGER, STAFF) |
| permissions | Optional fine-grained access |
| tokenType   | Access or Refresh            |

---

# 8️ Final JWT Payload Structure

Example Access Token:

```json
{
  "iss": " Inventory-api",
  "sub": "user_123",
  "userId": "user_123",
  "email": "admin@Inventory.com",
  "role": "ADMIN",
  "permissions": [
    "USER_READ",
    "USER_WRITE",
    "PRODUCT_MANAGE",
    "ORDER_MANAGE",
    "INVENTORY_SYNC"
  ],
  "tokenType": "ACCESS",
  "iat": 1710000000,
  "exp": 1710003600,
  "jti": "unique-token-id-456"
}
```

---

# 9️ Role-Based Authorization Mapping

 Inventory uses RBAC.

| Role    | Permissions                  |
| ------- | ---------------------------- |
| ADMIN   | Full system access           |
| MANAGER | Manage products & categories |
| STAFF   | View products, create orders |

* Authorization Flow

* JWT validated

* Extract role claim

* Middleware checks required role

* If unauthorized → 403 Forbidden


---

## ADMIN

* Full access
* Manage users
* Manage products
* Start inventory sync
* View all jobs

---

## MANAGER

* Manage products
* Manage categories
* View orders
* Start inventory sync

---

## STAFF

* View products
* Create orders
* View own orders only

---

# 10 Access Token vs Refresh Token

Inventory uses:

### Access Token

* Short-lived (15–60 minutes)
* Used for API calls

---

### Refresh Token

* Long-lived (7–30 days)
* Used to generate new access token
* Stored securely (HTTP-only cookie recommended)

---

# 11 Token Expiry Strategy

Example:

| Token Type    | Expiry     |
| ------------- | ---------- |
| Access Token  | 30 minutes |
| Refresh Token | 7 days     |

If access token expires:

1. Client calls `/auth/refresh`
2. New access token issued

---

# 12 Authentication Flow

### Login

1. User sends email + password
2. Server verifies credentials
3. Server generates:

   * Access Token
   * Refresh Token
4. Tokens returned to client

---

### API Request

1. Client sends:

```
Authorization: Bearer <access_token>
```

2. Server:

   * Verifies signature
   * Checks expiration
   * Extracts role
   * Applies authorization

---

# 13 JWT in REST, GraphQL & gRPC

---

## REST

Header:

```
Authorization: Bearer <token>
```

* Middleware:

Verify signature

Check expiration

Attach user to request context

---

## GraphQL

Same header used.

context: ({ req }) => {
  const token = req.headers.authorization
}

Resolvers check:

user role

user ID
Token validated in GraphQL context.

---

## gRPC

Token sent via metadata:

```
authorization: Bearer <token>
```

Validated in:

gRPC interceptor

Role applied at service level

---

# 14 Security Considerations

StockSphere enforces:

* Strong secret key
* HTTPS only
* Short access token lifetime
* Refresh token rotation
* jti for token revocation
* Blacklist mechanism (optional)
* Avoid storing sensitive data in payload

---

# 15 Token Revocation Strategy

Options:

* Maintain token blacklist using `jti`
* Revoke refresh token on logout
* Rotate refresh tokens

Recommended approach:

* Store refresh tokens in database
* Invalidate on logout
* Check `jti` on sensitive operations

---

# 16 Sample Middleware Logic (Conceptual)

1. Extract token
2. Verify signature
3. Check expiration
4. Extract role
5. Attach user to request context

---

# 17 Failure Scenarios

| Scenario          | Response         |
| ----------------- | ---------------- |
| Token missing     | 401 Unauthorized |
| Token expired     | 401 Unauthorized |
| Invalid signature | 401 Unauthorized |
| Role insufficient | 403 Forbidden    |

* Error Responses

* 401 Unauthorized
{
  "error": "Invalid or expired token"
}

* 403 Forbidden
{
  "error": "Insufficient permissions"
}

---

# 18 Why This JWT Design is Production Ready

* Includes both standard & custom claims
* Supports role-based access
* Compatible with REST, GraphQL, gRPC
* Supports refresh mechanism
* Supports token revocation
* Scalable across microservices

---

# 19 Example Encoded Token Flow

User logs in:

```
POST /auth/login
```

Response:

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```



---

