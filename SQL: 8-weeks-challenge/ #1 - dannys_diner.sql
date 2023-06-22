CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');




-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, SUM(mn.price) AS total_amount
FROM dannys_diner.sales AS s
JOIN dannys_diner.members AS mm ON s.customer_id = mm.customer_id
JOIN dannys_diner.menu AS mn ON s.product_id = mn.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;


-- 2. How many days has each customer visited the restaurant?

SELECT s.customer_id, COUNT(s.order_date) AS days_visited
FROM dannys_diner.sales s
GROUP BY t.customer_id
ORDER bY t.customer_id;

-- 3. What was the first item from the menu purchased by each customer?

WITH cte AS (
  	SELECT DISTINCT s.customer_id, mn.product_name,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date, mn.product_name) AS r
	FROM dannys_diner.sales AS s
	JOIN dannys_diner.menu AS mn ON s.product_id = mn.product_id
  )
SELECT customer_id, product_name
FROM cte
WHERE r = 1
ORDER BY customer_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT mn.product_name, COUNT(s.product_id) AS total_sell_count
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS mn ON s.product_id = mn.product_id
GROUP BY mn.product_name
LIMIT 1;

-- 5. Which item was the most popular for each customer?

SELECT s.customer_id, mn.product_name, COUNT(s.product_id) AS total_sell_count
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS mn ON s.product_id = mn.product_id
GROUP BY s.customer_id, mn.product_name
ORDER BY COUNT(s.product_id) DESC
LIMIT 3;

-- 6. Which item was purchased first by the customer after they became a member?

SELECT customer_id, product_name, order_date 
FROM (
  SELECT s.customer_id, mn.product_name, s.order_date
  , RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) as rnk
  FROM dannys_diner.sales s
  JOIN dannys_diner.menu mn ON s.product_id = mn.product_id
  JOIN dannys_diner.members mm ON s.customer_id = mm.customer_id
  WHERE mm.join_date <= s.order_date
  GROUP BY s.customer_id, mn.product_name, s.order_date
) t
WHERE rnk =1;

-- 7. Which item was purchased just before the customer became a member?

SELECT customer_id, product_name, order_date
FROM (
  SELECT s.customer_id, mn.product_name, s.order_date
  , RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC, s.product_id DESC) as rnk
  FROM dannys_diner.sales s
  JOIN dannys_diner.menu mn ON s.product_id = mn.product_id
  JOIN dannys_diner.members mm ON s.customer_id = mm.customer_id
  WHERE mm.join_date > s.order_date
  GROUP BY s.customer_id, mn.product_name, s.order_date, s.product_id
  ) t
WHERE rnk = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(s.order_date) AS total_items, SUM(mn.price) AS amount_spent
FROM dannys_diner.sales s
  JOIN dannys_diner.menu mn ON s.product_id = mn.product_id
  JOIN dannys_diner.members mm ON s.customer_id = mm.customer_id
WHERE mm.join_date > s.order_date
GROUP BY s.customer_id
ORDER BY s.customer_id;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT customer_id, SUM(points) as total_points
FROM (
    SELECT s.customer_id,
    CASE
        WHEN mn.product_name = 'sushi' THEN mn.price*10*2
        ELSE mn.price*10
    END AS points
    FROM dannys_diner.sales s
    	JOIN dannys_diner.menu mn ON s.product_id = mn.product_id
  ) t
GROUP BY customer_id
ORDER BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


WITH cte AS (
SELECT s.customer_id, EXTRACT(month from s.order_date) as mnth,
    CASE
        WHEN s.order_date <= mm.join_date THEN mn.price*2
        WHEN s.order_date >= mm.join_date + INTERVAL '7 day' THEN mn.price*2
        ELSE mn.price*1
    END AS points
    FROM dannys_diner.sales s
    	JOIN dannys_diner.menu mn ON s.product_id = mn.product_id
    	JOIN dannys_diner.members mm ON s.customer_id = mm.customer_id
)
SELECT customer_id, SUM(points) AS total_points
FROM cte
WHERE mnth = 1
GROUP BY customer_id
ORDER BY customer_id;


-- Bonus:

-- Part 1:

SELECT s.customer_id, s.order_date, mn.product_name, mn.price,
CASE
	WHEN mm.join_date > s.order_date THEN 'N'
    WHEN mm.join_date is NULL THEN 'N'
	ELSE 'Y'
END AS member
FROM dannys_diner.sales s
  		 JOIN dannys_diner.menu mn ON s.product_id = mn.product_id
   	LEFT JOIN dannys_diner.members mm ON s.customer_id = mm.customer_id
ORDER BY s.customer_id, s.order_date;


-- Part 2:


WITH cte AS (
  SELECT s.customer_id, s.order_date, mn.product_name, mn.price, mm.join_date,
	CASE
		WHEN mm.join_date > s.order_date THEN 'N'
	    WHEN mm.join_date is NULL THEN 'N'
		ELSE 'Y'
	END AS member
	FROM dannys_diner.sales s
	  		 JOIN dannys_diner.menu mn ON s.product_id = mn.product_id
	   	LEFT JOIN dannys_diner.members mm ON s.customer_id = mm.customer_id
	ORDER BY s.customer_id, s.order_date
  )
  
SELECT customer_id, order_date, product_name, price, member, 
CASE
	WHEN join_date is NULL THEN NULL
	WHEN member = 'N' THEN NULL
	ELSE RANK() OVER (PARTITION BY customer_id ORDER BY order_date)
END AS ranking
FROM cte;
