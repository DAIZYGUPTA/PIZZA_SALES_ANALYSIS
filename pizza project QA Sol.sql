-- PIZZA PROJECT SOLUTIONS
-- /------/-------/--------/--------/---------/-------/--------/--------/--------/----/
-- /------/-------/--------/--------/---------/-------/--------/--------/--------/----/
-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_orders
FROM
    orders;
    
-- /------/-------/--------/--------/---------/-------/--------/--------/--------/----/

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(quantity * price), 2) AS Revenue
FROM
    order_details
        INNER JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
-- /------/-------/--------/--------/---------/-------/--------/--------/--------/----/

-- Identify the highest-priced pizza.

SELECT 
    name, price
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- /------/-------/--------/--------/---------/-------/--------/--------/--------/----/

-- Identify the most common pizza size ordered.

SELECT 
    size, COUNT(quantity) AS Total_quantity
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY COUNT(quantity) DESC;

-- /------/-------/--------/--------/---------/-------/--------/--------/--------/----/

-- List the top 5 most ordered pizza types along with their quantities.

 SELECT 
    name, COUNT(quantity) AS Total_Quantity
FROM
    pizzas
        INNER JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY name
ORDER BY COUNT(quantity) DESC
LIMIT 5;

-- /------/-------/--------/--------/---------/-------/--------/--------/--------/----/

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    category, COUNT(quantity) AS Total_Qty
FROM
    pizzas
        INNER JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY category
ORDER BY COUNT(quantity) DESC;

-- /------/-------/--------/--------/---------/-------/--------/--------/--------/----/

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);

-- /------/-------/--------/--------/---------/-------/--------/--------/--------/----/

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(order_details.pizza_id) AS pizza_count
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        INNER JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY category
ORDER BY pizza_count DESC;

-- /------/-------/--------/--------/---------/-------/--------/--------/--------/----/

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    AVG(total_pizza_per_day)
FROM
    (SELECT 
        DATE(order_date) AS dt, SUM(quantity) AS total_pizza_per_day
    FROM
        orders
    JOIN order_details ON order_details.order_id = orders.order_id
    GROUP BY dt
    ORDER BY dt) AS Sum_orders;

-- /------/-------/--------/--------/---------/-------/--------/--------/--------/----/

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_type_id, SUM(quantity * price) AS revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_type_id
ORDER BY revenue DESC
LIMIT 3;

-- /------/-------/--------/--------/---------/-------/--------/--------/--------/----/

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT rp.category, 
       rp.pizza_name, 
       rp.total_revenue,
       (rp.total_revenue / (SELECT SUM(od.quantity * p.price) 
                            FROM order_details od
                            JOIN pizzas p ON od.pizza_id = p.pizza_id)) * 100 AS percentage_contribution
FROM (
    SELECT pt.category, 
           p.pizza_type_id, 
           pt.name AS pizza_name,
           SUM(od.quantity * p.price) AS total_revenue
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, p.pizza_type_id, pt.name
) AS rp
ORDER BY percentage_contribution DESC;

-- /------/-------/--------/--------/---------/-------/--------/--------/--------/----/

-- Analyze the cumulative revenue generated over time.

SELECT DATE(o.order_date) AS order_date, 
       SUM(od.quantity * p.price) AS daily_revenue,
       SUM(SUM(od.quantity * p.price)) OVER (ORDER BY DATE(o.order_date)) AS cumulative_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY DATE(o.order_date)
ORDER BY order_date;

-- /------/-------/--------/--------/---------/-------/--------/--------/--------/----/

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT category, name, revenue FROM
(SELECT  category, name, revenue, RANK() OVER(partition by category ORDER BY revenue) AS Rank_no FROM
(SELECT name, category ,  SUM(quantity * price) AS revenue 
FROM pizza_types 
JOIN pizzas ON 
pizza_types.pizza_type_id = pizzas.pizza_type_id 
JOIN order_details ON
pizzas.pizza_id = order_details.pizza_id
GROUP BY category , name ) AS a
) AS b
WHERE Rank_no <=3;

-- /------/-------/--------/--------/---------/-------/--------/--------/--------/----/
