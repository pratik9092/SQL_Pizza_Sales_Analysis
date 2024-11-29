create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id));

create table order_details (
order_id int not null,
order_details_id int not null,
pizza_id text,
quantity int not null,
primary key (order_details_id));

create table pizza_types_1 (
pizza_type_id text,
name text,
category text,
ingredients text);

create table pizzas (
pizza_id text,
pizza_type_id text,
size text,
price float);



-- Queries

-- 1) Retrieve the total number of orders placed.

SELECT
	count(order_id) AS total_orders
FROM
	orders;

-- 2) Calculate the total revenue generated from pizza sales.

SELECT
	ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_revenue
FROM
	order_details
	JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id


-- 3) Identify the highest-priced pizza.

SELECT
	pizza_types_1.name,
	pizzas.price
FROM
	pizza_types_1
	JOIN pizzas ON pizza_types_1.pizza_type_id = pizzas.pizza_type_id
ORDER BY
	pizzas.price DESC
LIMIT 1;

-- 4) Identify the most common pizza size ordered.

-- SELECT quantity, count(order_details_id)
-- FROM order_details GROUP BY	quantity;

SELECT
	pizzas.size,
	COUNT(order_details.order_details_id) AS order_count
FROM
	pizzas
	JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY
	pizzas.size
ORDER BY
	order_count DESC
LIMIT 1;

-- 5) List the top 5 most ordered pizza types along with their quantities.

SELECT
	pizza_types_1.name,
	sum(order_details.quantity) AS quantity
FROM
	pizza_types_1
	JOIN pizzas ON pizza_types_1.pizza_type_id = pizzas.pizza_type_id
	JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY
	pizza_types_1.name
ORDER BY
	quantity DESC
LIMIT 5;


-- 6) Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT
	pizza_types_1.category,
	SUM(order_details.quantity) AS quantity
FROM
	pizza_types_1
	JOIN pizzas ON pizza_types_1.pizza_type_id = pizzas.pizza_type_id
	JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY
	pizza_types_1.category
ORDER BY
	quantity DESC;

-- 7) Determine the distribution of orders by hour of the day.

SELECT
	HOUR(order_time) AS hour_basis,
	COUNT(order_id) AS count_order
FROM
	orders
GROUP BY
	hour_basis;

-- 8) Join relevant tables to find the category-wise distribution of pizzas.

SELECT
	category,
	COUNT(name)
FROM
	pizza_types_1
GROUP BY
	category;

-- 9) Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT
	ROUND(AVG(quantity), 0) as avg_pizza_ordered_per_day
FROM (
	SELECT
		orders.order_date,
		SUM(order_details.quantity) AS quantity
	FROM
		orders
		JOIN order_details ON orders.order_id = order_details.order_id
	GROUP BY
		orders.order_date) AS order_quantuty;

-- 10) Determine the top 3 most ordered pizza types based on revenue.

SELECT
	pizza_types_1.name,
	SUM(order_details.quantity * pizzas.price) AS revenue
FROM
	pizza_types_1
	JOIN pizzas ON pizza_types_1.pizza_type_id = pizzas.pizza_type_id
	JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY
	pizza_types_1.name
ORDER BY
	revenue DESC
LIMIT 3;

-- 11) Analyze the cumulative revenue generated over time.

SELECT
	order_date,
	SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM (
	SELECT
		orders.order_date,
		ROUND(SUM(order_details.quantity * pizzas.price), 2) AS revenue
	FROM
		order_details
		JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
		JOIN orders ON orders.order_id = order_details.order_id
	GROUP BY
		orders.order_date) AS sales;

-- 12) Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT
	category,
	name,
	revenue
FROM (
	SELECT
		category,
		name,
		revenue,
		RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
	FROM (
	SELECT
		pizza_types_1.category,
		pizza_types_1.name,
		ROUND(SUM(order_details.quantity * pizzas.price), 2) AS revenue
	FROM
		pizza_types_1
		JOIN pizzas ON pizza_types_1.pizza_type_id = pizzas.pizza_type_id
		JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
	GROUP BY
		pizza_types_1.category,
		pizza_types_1.name) AS a) AS b
WHERE
	rn <= 3;