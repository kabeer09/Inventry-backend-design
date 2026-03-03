 # INVENTRY MANAGEMENT — JWT Authentication Design

---

## 1️ Overview

Inventory uses **JWT (JSON Web Token)** for stateless authentication.

Authentication Method:

```
Authorization: Bearer <access_token>
```

JWT will be used for:

* User authentication
* Role-based access control
* Securing REST, GraphQL, and gRPC endpoints

---

## 2️ Authentication Flow

### Step 1 — Login

```
POST /api/v1/auth/login
```

Request:

```json
{
  "email": "admin@Inventory.com",
  "password": "password123"
}
```

Response:

```json
{
  "access_token": "jwt_token_here",
  "refresh_token": "refresh_token_here",
  "expires_in": 3600
}
```

---

### Step 2 — Access Protected API

```
GET /api/v1/products
Authorization: Bearer <access_token>
```

---

### Step 3 — Refresh Token

```
POST /api/v1/auth/refresh
```

Request:

```json
{
  "refresh_token": "refresh_token_here"
}
```

Response:

```json
{
  "access_token": "new_access_token",
  "expires_in": 3600
}
```

---

## 3️ JWT Structure

JWT consists of:

```
HEADER.PAYLOAD.SIGNATURE
```

---

### Header

```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

---

### Payload (Claims)

Example payload:

```json
{
  "sub": "userid",
  "email": "admin@Inventory.com",
  "role": "admin",
  "iat": 1710000000,
  "exp": 1710003600,
  "iss": "Inventory-api",
  "aud": "Inventory-clients"
}
```

---

## 4️ Standard Claims

| Claim | Meaning           |
| ----- | ----------------- |
| sub   | Subject (User ID) |
| iat   | Issued At         |
| exp   | Expiration time   |
| iss   | Issuer            |
| aud   | Audience          |

---

## 5️ Custom Claims

| Claim       | Description                       |
| ----------- | --------------------------------- |
| role        | User role (admin, manager, staff) |
| email       | User email                        |
| permissions | Optional fine-grained access      |

Example:

```json
{
  "sub": "uid",
  "role": "manager",
  "permissions": ["inventory:read", "inventory:update"]
}
```

---

## 6️ Role-Based Access Control (RBAC)

### Roles:

| Role    | Access                    |
| ------- | ------------------------- |
| admin   | Full system access        |
| manager | Manage inventory & orders |
| staff   | Read-only inventory       |

---

### Authorization Rules Example

| Endpoint         | Role Required |
| ---------------- | ------------- |
| POST /products   | admin         |
| DELETE /products | admin         |
| PATCH /inventory | manager       |
| GET /products    | staff         |

---

## 7️ Token Expiration Strategy

| Token Type    | Expiration        |
| ------------- | ----------------- |
| Access Token  | 1 hour (3600 sec) |
| Refresh Token | 7 days            |

---

## 8️ Token Storage Strategy

Client-side storage recommendation:

* Web → HTTP-only secure cookies
* Mobile → Secure storage (Keychain / Keystore)

Never store tokens in:

* Local storage (security risk)

---

## 9️ Signing Algorithm

Recommended:

```
HS256 (HMAC SHA-256)
```

Production alternative:

```
RS256 (Asymmetric keys)
```

Why RS256?

* Public/private key separation
* More secure for distributed systems

---

## 10 Security Best Practices

* Use HTTPS only
* Rotate JWT secret regularly
* Use short expiration for access tokens
* Validate issuer and audience
* Blacklist tokens on logout (optional)
* Use refresh token rotation

---

## 11 Error Responses

Invalid token:

```
401 Unauthorized
```

Expired token:

```
401 Unauthorized
{
  "error": "Token expired"
}
```

Insufficient permissions:

```
403 Forbidden
```

---

