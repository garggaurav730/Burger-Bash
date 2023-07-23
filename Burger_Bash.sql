CREATE DATABASE burger_bash;
SELECT database();
USE burger_bash;
SHOW DATABASES;
SHOW TABLES;


CREATE TABLE burger_names(
   burger_id   INTEGER  NOT NULL PRIMARY KEY 
  ,burger_name VARCHAR(10) NOT NULL
);

INSERT INTO burger_names(burger_id,burger_name) VALUES (1,'Meatlovers');
INSERT INTO burger_names(burger_id,burger_name) VALUES (2,'Vegetarian');



CREATE TABLE burger_runner(
   runner_id   INTEGER  NOT NULL PRIMARY KEY 
  ,registration_date date NOT NULL
);

INSERT INTO burger_runner VALUES (1,'2021-01-01');
INSERT INTO burger_runner VALUES (2,'2021-01-03');
INSERT INTO burger_runner VALUES (3,'2021-01-08');
INSERT INTO burger_runner VALUES (4,'2021-01-15');



CREATE TABLE runner_orders(
   order_id     INTEGER  NOT NULL PRIMARY KEY 
  ,runner_id    INTEGER  NOT NULL
  ,pickup_time  timestamp
  ,distance     VARCHAR(7)
  ,duration     VARCHAR(10)
  ,cancellation VARCHAR(23)
);

INSERT INTO runner_orders VALUES (1,1,'2021-01-01 18:15:34','20km','32 minutes',NULL);
INSERT INTO runner_orders VALUES (2,1,'2021-01-01 19:10:54','20km','27 minutes',NULL);
INSERT INTO runner_orders VALUES (3,1,'2021-01-03 00:12:37','13.4km','20 mins',NULL);
INSERT INTO runner_orders VALUES (4,2,'2021-01-04 13:53:03','23.4','40',NULL);
INSERT INTO runner_orders VALUES (5,3,'2021-01-08 21:10:57','10','15',NULL);
INSERT INTO runner_orders VALUES (6,3,NULL,NULL,NULL,'Restaurant Cancellation');
INSERT INTO runner_orders VALUES (7,2,'2021-01-08 21:30:45','25km','25mins',NULL);
INSERT INTO runner_orders VALUES (8,2,'2021-01-10 00:15:02','23.4 km','15 minute',NULL);
INSERT INTO runner_orders VALUES (9,2,NULL,NULL,NULL,'Customer Cancellation');
INSERT INTO runner_orders VALUES (10,1,'2021-01-11 18:50:20','10km','10minutes',NULL);



CREATE TABLE customer_orders(
   order_id    INTEGER  NOT NULL 
  ,customer_id INTEGER  NOT NULL
  ,burger_id    INTEGER  NOT NULL
  ,exclusions  VARCHAR(4)
  ,extras      VARCHAR(4)
  ,order_time  timestamp NOT NULL
);

INSERT INTO customer_orders VALUES (1,101,1,NULL,NULL,'2021-01-01 18:05:02');
INSERT INTO customer_orders VALUES (2,101,1,NULL,NULL,'2021-01-01 19:00:52');
INSERT INTO customer_orders VALUES (3,102,1,NULL,NULL,'2021-01-02 23:51:23');
INSERT INTO customer_orders VALUES (3,102,2,NULL,NULL,'2021-01-02 23:51:23');
INSERT INTO customer_orders VALUES (4,103,1,'4',NULL,'2021-01-04 13:23:46');
INSERT INTO customer_orders VALUES (4,103,1,'4',NULL,'2021-01-04 13:23:46');
INSERT INTO customer_orders VALUES (4,103,2,'4',NULL,'2021-01-04 13:23:46');
INSERT INTO customer_orders VALUES (5,104,1,NULL,'1','2021-01-08 21:00:29');
INSERT INTO customer_orders VALUES (6,101,2,NULL,NULL,'2021-01-08 21:03:13');
INSERT INTO customer_orders VALUES (7,105,2,NULL,'1','2021-01-08 21:20:29');
INSERT INTO customer_orders VALUES (8,102,1,NULL,NULL,'2021-01-09 23:54:33');
INSERT INTO customer_orders VALUES (9,103,1,'4','1, 5','2021-01-10 11:22:59');
INSERT INTO customer_orders VALUES (10,104,1,NULL,NULL,'2021-01-11 18:34:49');
INSERT INTO customer_orders VALUES (10,104,1,'2, 6','1, 4','2021-01-11 18:34:49');


SELECT * FROM burger_names;
SELECT * FROM burger_runner;
SELECT * FROM runner_orders;
SELECT * FROM customer_orders;



-- 1. How many burgers were ordered?
SELECT COUNT(*) AS 'No. Of Burgers Ordered'FROM runner_orders;


-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS Unique_customer_orders FROM customer_orders;


-- 3. How many successful orders were delivered by each runner?
SELECT runner_id,COUNT(*) AS Successful_orders
FROM runner_orders 
WHERE cancellation IS NULL
GROUP BY runner_id;


-- 4. How many of each type of burger was delivered?
SELECT a.burger_name,COUNT(runner_id) AS Quantity
FROM burger_names a
JOIN customer_orders c ON c.burger_id=a.burger_id
JOIN runner_orders ON runner_orders.order_id=c.order_id
WHERE cancellation IS NULL
GROUP BY burger_name;


-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT burger_name,COUNT(order_id) AS order_count,customer_id
FROM burger_names a
JOIN customer_orders b ON b.burger_id=a.burger_id
GROUP BY burger_name,customer_id
ORDER BY customer_id;


-- 6. What was the maximum number of burgers delivered in a single order?
SELECT c.order_id,COUNT(r.runner_id) AS Max_burger_count
FROM customer_orders c
JOIN runner_orders r ON r.order_id=c.order_id
WHERE cancellation IS NULL
GROUP BY c.order_id
ORDER BY Max_burger_count DESC LIMIT 1;


-- 7. For each customer, how many delivered burgers had at least 1 change and how many had no changes?
SELECT customer_id,
SUM(CASE
	WHEN exclusions!=' ' OR extras!=' ' THEN 1
    WHEN exclusions=' ' AND extras=' ' THEN 1
    ELSE 0
END) AS changes
FROM customer_orders C
JOIN runner_orders r ON C.order_id=r.order_id
WHERE cancellation IS NULL
GROUP BY c.customer_id
ORDER BY c.customer_id;


-- 8. What was the total volume of burgers ordered for each hour of the day?
SELECT EXTRACT(HOUR FROM order_time) AS hour_of_day,COUNT(order_id) AS burger_count FROM customer_orders
GROUP BY hour_of_day
ORDER BY hour_of_day;


-- 9. How many runners signed up for each 1 week period?
SELECT EXTRACT(WEEK FROM registration_date) AS registration_week,
COUNT(runner_id) AS runner_signup
FROM burger_runner
GROUP BY registration_week;

-- 10.What was the average distance travelled for each customer?
SELECT c.customer_id,AVG(distance) AS Avg_dist
FROM customer_orders c
JOIN runner_orders r ON r.order_id=c.order_id
WHERE r.duration!=0
GROUP BY c.customer_id;