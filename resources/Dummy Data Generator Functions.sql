
/*
this file contains fake data generator functions to insert data to the tables
the functions will generate:

10m order detail
1m order
500k customer
100k product
10k category
*/

--categories data

CREATE OR REPLACE FUNCTION insert_fake_categories(num_rows INT)
RETURNS VOID AS $$
DECLARE
    i INT;
BEGIN
    -- Insert specified number of fake categories
    FOR i IN 1..num_rows LOOP

        -- Insert the new category
        INSERT INTO Category (category_id, category_name, parent_category_id)
        VALUES (
			i,
            'Category ' || i,  -- Generating a simple name like "Category 1", "Category 2", etc.
            CASE
                WHEN i > 1 THEN i-1  -- Assign a random previous category as the parent
                ELSE NULL  -- The first category will have no parent
            END
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- calling the function
SELECT insert_fake_categories(10000);



-- customers data

CREATE OR REPLACE FUNCTION insert_fake_customers(num_rows INT)
RETURNS VOID AS $$
DECLARE
    i INT;
    random_first_name VARCHAR(50);
    random_last_name VARCHAR(50);
    random_email VARCHAR(100);
BEGIN
    -- Loop to insert the specified number of fake customers
    FOR i IN 1..num_rows LOOP
        -- Generate random names and email
        random_first_name := 'FirstName' || i;  -- Example first name
        random_last_name := 'LastName' || i;    -- Example last name
        random_email := LOWER(random_first_name || '.' || random_last_name || '@example.com');  -- Generate unique email

        -- Insert the customer into the table
        INSERT INTO Customer (customer_id, first_name, last_name, email, password)
        VALUES (
            i,
            random_first_name,
            random_last_name,
            random_email,
            'SecurePassword'
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- calling the function
SELECT insert_fake_customers(500000);


-- products data

CREATE OR REPLACE FUNCTION insert_fake_products(num_rows INT, max_category_id INT)
RETURNS VOID AS $$
DECLARE
    i INT;
    random_category_id INT;
    random_product_name VARCHAR(255);
    random_short_description TEXT;
    random_long_description TEXT;
    random_price NUMERIC(10, 2);
    random_stock_quantity INT;
BEGIN
    -- Loop to insert the specified number of fake products
    FOR i IN 1..num_rows LOOP
        -- Generate random values for the product
        random_category_id := FLOOR(1 + RANDOM() * max_category_id);  -- Random category ID between 1 and max_category_id
        random_product_name := 'Product ' || i;  -- Example product name
        random_short_description := 'Short description for product ' || i;  -- Example short description
        random_long_description := 'This is a longer description for product ' || i;  -- Example long description
        random_price := ROUND((10 + RANDOM() * 90)::NUMERIC, 2);  -- Random price between 10.00 and 100.00
        random_stock_quantity := FLOOR(1 + RANDOM() * 100);  -- Random stock quantity between 1 and 100

        -- Insert the product into the table
        INSERT INTO Product (product_id, category_id, product_name, product_short_description, product_long_description, price, stock_quantity)
        VALUES (
            i,
            random_category_id,
            random_product_name,
            random_short_description,
            random_long_description,
            random_price,
            random_stock_quantity
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- calling the function
SELECT insert_fake_products(100000, 10000);


--orders data

CREATE OR REPLACE FUNCTION insert_fake_orders(num_rows INT, max_customer_id INT)
RETURNS VOID AS $$
DECLARE
    i INT;
    random_customer_id INT;
BEGIN
    -- Loop to insert the specified number of fake orders
    FOR i IN 1..num_rows LOOP
        -- Randomly select a customer ID from the existing customers
        random_customer_id := FLOOR(1 + RANDOM() * max_customer_id);  -- Random customer ID between 1 and max_customer_id

        -- Insert the order into the table
        INSERT INTO Orders (order_id,customer_id, total_amount)
        VALUES (
            i,
            random_customer_id,
            0.00  -- Set total_amount to 0 for all orders
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;



-- calling the function

SELECT insert_fake_orders(1000000, 500000);


-- for the order_details table when need a trigger to keep the total amount of the order accurate

-- create the trigger function
CREATE OR REPLACE FUNCTION update_order_total()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the total amount for the order when a new order detail is added
    UPDATE Orders
    SET total_amount = total_amount + (NEW.quantity * NEW.unit_price)
    WHERE order_id = NEW.order_id;

    RETURN NEW;  -- Return the new row for the insert
END;
$$ LANGUAGE plpgsql;


-- create the trigger
CREATE TRIGGER trigger_update_order_total
AFTER INSERT ON OrderDetail
FOR EACH ROW
EXECUTE FUNCTION update_order_total();


-- order_details data
CREATE OR REPLACE FUNCTION insert_fake_order_details(num_rows INT, max_product_id INT)
RETURNS VOID AS $$
DECLARE
    i INT;
    random_product_id INT;
    random_quantity INT;
    random_unit_price NUMERIC(10, 2);
BEGIN
    -- Loop to insert the specified number of fake order details
    FOR i IN 1..num_rows LOOP
        -- Generate random values for OrderDetail
        random_product_id := FLOOR(1 + RANDOM() * max_product_id);  -- Random product ID between 1 and max_product_id
        random_quantity := FLOOR(1 + RANDOM() * 10);  -- Random quantity between 1 and 10
        random_unit_price := ROUND((1 + RANDOM() * 100)::NUMERIC, 2);  -- Random unit price between 1.00 and 100.00

        -- Insert the order detail into the table
        INSERT INTO OrderDetail (order_detail_id, order_id, product_id, quantity, unit_price,order_date)
        VALUES (
            i,
            1 + mod(i, 1000000),
            random_product_id,
            random_quantity,
            random_unit_price,
            TIMESTAMP '2020-01-01 00:00:00' +
            (random() * (TIMESTAMP '2024-01-01 23:59:59' - TIMESTAMP '2020-01-01 00:00:00'))::interval
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- calling the function
SELECT insert_fake_order_details(10000000, 100000);