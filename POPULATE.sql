-- Insert data into customer table
INSERT INTO customer (name, phone, address, type) VALUES 
('Ravi Kumar', '9876543210', '123 MG Road, Bengaluru, Karnataka', 'residential'),
('Anita Sharma', '8765432109', '45 Residency Road, Bengaluru, Karnataka', 'commercial'),
('Suresh Reddy', '7654321098', '67 Brigade Road, Bengaluru, Karnataka', 'industrial'),
('Priya Menon', '6543210987', '12 Koramangala, Bengaluru, Karnataka', 'residential'),
('Vikram Joshi', '5432109876', '89 Indiranagar, Bengaluru, Karnataka', 'commercial');

-- Insert data into accounts table
INSERT INTO accounts (customer_id, status, last_payment_date) VALUES 
(1, 'active', '2024-06-15'),
(2, 'active', '2024-06-10'),
(3, 'inactive', '2024-05-05'),
(4, 'active', '2024-06-20'),
(5, 'inactive', '2024-04-25');

-- Insert data into tariffs table
INSERT INTO tariffs (type, rate) VALUES 
('residential', 5.00),
('commercial', 8.50),
('industrial', 10.75);

-- Insert data into usage table
INSERT INTO `usage` (customer_id, units_used) VALUES 
(1, 150),
(2, 300),
(3, 500),
(4, 200),
(5, 350);

-- Insert data into billing table
INSERT INTO billing (customer_id, amount, due_date) VALUES 
(1, 750.00, '2024-07-25'),
(2, 2550.00, '2024-07-25'),
(3, 5375.00, '2024-07-25'),
(4, 1000.00, '2024-07-25'),
(5, 2975.00, '2024-07-25');
