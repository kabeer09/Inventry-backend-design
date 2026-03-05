-- Create Users Table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    role VARCHAR(50) DEFAULT 'staff',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Products Table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Inventory Jobs Table
CREATE TABLE jobs (
    id SERIAL PRIMARY KEY,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed Users
INSERT INTO users (name, email, role) VALUES
('Admin User', 'admin@inventory.com', 'admin'),
('Manager', 'manager@inventory.com', 'manager');

-- Seed Products
INSERT INTO products (name, sku, quantity, price) VALUES
('Laptop', 'LAP-1001', 20, 55000.00),
('Mouse', 'MOU-2001', 100, 800.00),
('Keyboard', 'KEY-3001', 80, 1200.00);

-- Seed Job
INSERT INTO jobs (status) VALUES ('completed');