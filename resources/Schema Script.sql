


-- Create the Category table
CREATE TABLE Category (
 category_id SERIAL PRIMARY KEY,
 category_name VARCHAR(255) NOT NULL,
 parent_category_id INT,
 FOREIGN KEY (parent_category_id) REFERENCES Category(category_id)
);
-- Create the Product table
CREATE TABLE Product (
 product_id SERIAL PRIMARY KEY,
 category_id INT,
 product_name VARCHAR(255) NOT NULL,
 product_short_description TEXT,
 product_long_description TEXT,
 price DECIMAL(10, 2) NOT NULL,
 stock_quantity INT NOT NULL,
 FOREIGN KEY (category_id) REFERENCES Category(category_id)
);
-- Create the Customer table
CREATE TABLE Customer (
 customer_id SERIAL PRIMARY KEY,
 first_name VARCHAR(50) NOT NULL,
 last_name VARCHAR(50) NOT NULL,
 email VARCHAR(100) NOT NULL UNIQUE,
 password VARCHAR(255) NOT NULL
);
-- Create the Orders table
CREATE TABLE Orders (
 order_id SERIAL PRIMARY KEY,
 customer_id INT,
 order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 total_amount DECIMAL(10, 2) NOT NULL,
 FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);
-- Create the OrderDetail table
CREATE TABLE OrderDetail(
 order_detail_id SERIAL PRIMARY KEY,
 order_id INT,
 product_id INT,
 quantity INT NOT NULL,
 unit_price DECIMAL(10, 2) NOT NULL,
 FOREIGN KEY (order_id) REFERENCES Orders(order_id),
 FOREIGN KEY (product_id) REFERENCES Product(product_id)
 );
