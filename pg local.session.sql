-- CREATE SEQUENCE order_detail_id_seq
--     START WITH 1
--     INCREMENT BY 1
--     MINVALUE 1
--     NO MAXVALUE
--     CACHE 1;

-- CREATE SEQUENCE order_id_seq
--     START WITH 10000
--     INCREMENT BY 1
--     MINVALUE 10000
--     NO MAXVALUE
--     CACHE 1;

-- CREATE TABLE order_details_dup (
--     order_detail_id INT PRIMARY KEY,
--     order_id INT NOT NULL,
--     product_id INT NOT NULL,
--     quantity INT NOT NULL
-- );

INSERT INTO order_details_dup 
(
    order_detail_id,
    order_id,
    product_id,
    quantity
) VALUES (
    nextval('order_detail_id_seq'),
    nextval('order_id_seq'),
    201,
    10
);

SELECT * FROM order_details_dup;
