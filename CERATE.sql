-- Create the customer table
CREATE TABLE customer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    address VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL
);

-- Create the accounts table
CREATE TABLE accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    status VARCHAR(20) DEFAULT 'active',
    last_payment_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE CASCADE
);

-- Create the tariffs table
CREATE TABLE tariffs (
    type VARCHAR(50) PRIMARY KEY,
    rate DECIMAL(10, 2) NOT NULL
);

-- Create the usage table
CREATE TABLE `usage` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    units_used INT NOT NULL DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE CASCADE
);

-- Create the billing table
CREATE TABLE billing (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(10, 2) NOT NULL,
    due_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE NO ACTION
);