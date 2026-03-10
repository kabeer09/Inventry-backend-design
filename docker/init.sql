
-- Categories Table
CREATE TABLE categories (
    categoriesid VARCHAR(150) PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

-- Users Table
CREATE TABLE users (
    userid VARCHAR(100) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    phonenumber VARCHAR(20) NOT NULL,
    address VARCHAR(255) NOT NULL
);


-- Products Table
CREATE TABLE products (
    productsid VARCHAR(150) PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    sku VARCHAR(50) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL,
    categoryid VARCHAR(150),
    CONSTRAINT fk_products_category
        FOREIGN KEY (categoryid)
        REFERENCES categories(categoriesid)
);

-- Orders Table

CREATE TABLE orders (
    ordersid VARCHAR(100) PRIMARY KEY,
    userid VARCHAR(100),
    status VARCHAR(20) NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL,
    CONSTRAINT fk_orders_user
        FOREIGN KEY (userid)
        REFERENCES users(userid)
);

-- Inventory Table

CREATE TABLE inventory (
    inventoryid VARCHAR(100) PRIMARY KEY,
    productid VARCHAR(100) UNIQUE,
    quantity INTEGER NOT NULL,
    CONSTRAINT fk_inventory_product
        FOREIGN KEY (productid)
        REFERENCES products(productsid)
);

-- Order Items Table

CREATE TABLE orderitems (
    itemsid VARCHAR(100) PRIMARY KEY,
    orderid VARCHAR(100),
    productid VARCHAR(100),
    quantity INTEGER NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    CONSTRAINT fk_orderitems_order
        FOREIGN KEY (orderid)
        REFERENCES orders(ordersid),

    CONSTRAINT fk_orderitems_product
        FOREIGN KEY (productid)
        REFERENCES products(productsid)
);


-- Categories
INSERT INTO categories (categoriesid, name) VALUES
('cat1', 'Electronics'),
('cat2', 'Accessories'),
('cat3', 'Home Appliances');


-- Users
INSERT INTO users (userid, name, email, phonenumber, address) VALUES
('user1', 'Rahul Sharma', 'rahul@example.com', '9876543210', 'Delhi, India'),
('user2', 'Anita Singh', 'anita@example.com', '9876543211', 'Mumbai, India');


-- Products
INSERT INTO products (productsid, name, sku, description, price, categoryid) VALUES
('prod1', 'Laptop', 'SKU-LAP-001', 'High performance laptop', 1000.00, 'cat1'),
('prod2', 'Wireless Mouse', 'SKU-MOU-001', 'Bluetooth mouse', 25.00, 'cat2'),
('prod3', 'Microwave Oven', 'SKU-MIC-001', 'Kitchen microwave', 200.00, 'cat3');


-- Inventory
INSERT INTO inventory (inventoryid, productid, quantity) VALUES
('inv1', 'prod1', 50),
('inv2', 'prod2', 150),
('inv3', 'prod3', 30);


-- Orders
INSERT INTO orders (ordersid, userid, status, total_amount) VALUES
('ord1', 'user1', 'CREATED', 1025.00),
('ord2', 'user2', 'CREATED', 200.00);



-- Order Items
INSERT INTO orderitems (itemsid, orderid, productid, quantity, price) VALUES
('item1', 'ord1', 'prod1', 1, 1000.00),
('item2', 'ord1', 'prod2', 1, 25.00),
('item3', 'ord2', 'prod3', 1, 200.00);