-- 1️ What is the total revenue generated from all delivered orders?
SELECT 
    SUM(price + freight_value) AS TotalRevenue
FROM 
    Orders o
JOIN 
    OrderItems oi ON o.order_id = oi.order_id
WHERE 
    o.order_status = 'delivered';



-- 2️ What is the monthly revenue trend based on delivered orders?
SELECT 
    FORMAT(order_purchase_timestamp, 'yyyy-MM') AS OrderMonth,
    SUM(price + freight_value) AS TotalRevenue
FROM 
    Orders o
JOIN 
    OrderItems oi ON o.order_id = oi.order_id
WHERE 
    o.order_status = 'delivered'
GROUP BY 
    FORMAT(order_purchase_timestamp, 'yyyy-MM')
ORDER BY 
    OrderMonth;



-- 3️ Which are the top 10 product categories by total revenue?
SELECT 
    p.product_category_name,
    SUM(oi.price + oi.freight_value) AS TotalRevenue
FROM 
    Orders o
JOIN 
    OrderItems oi ON o.order_id = oi.order_id
JOIN 
    Products p ON oi.product_id = p.product_id
WHERE 
    o.order_status = 'delivered'
GROUP BY 
    p.product_category_name
ORDER BY 
    TotalRevenue DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;



-- 4️ What is the average delivery time (in days) by product category?
SELECT 
    p.product_category_name,
    AVG(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS AvgDeliveryDays
FROM 
    Orders o
JOIN 
    OrderItems oi ON o.order_id = oi.order_id
JOIN 
    Products p ON oi.product_id = p.product_id
WHERE 
    o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 
    p.product_category_name
ORDER BY 
    AvgDeliveryDays;



-- 5️ Which are the top 10 cities contributing the most to total revenue?
SELECT 
    c.customer_city,
    c.customer_state,
    SUM(oi.price + oi.freight_value) AS TotalRevenue
FROM 
    Orders o
JOIN 
    Customers c ON o.customer_id = c.customer_id
JOIN 
    OrderItems oi ON o.order_id = oi.order_id
WHERE 
    o.order_status = 'delivered'
GROUP BY 
    c.customer_city, c.customer_state
ORDER BY 
    TotalRevenue DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;



-- 6️ What is the total revenue and order count for each payment type?
SELECT 
    payment_type,
    COUNT(*) AS OrderCount,
    SUM(payment_value) AS TotalRevenue
FROM 
    OrderPayments
GROUP BY 
    payment_type
ORDER BY 
    TotalRevenue DESC;



-- 7️ How many customers placed only one order?
SELECT 
    OrderCount,
    COUNT(DISTINCT customer_id) AS CustomerCount
FROM (
    SELECT 
        customer_id, 
        COUNT(order_id) AS OrderCount
    FROM 
        Orders
    GROUP BY 
        customer_id
) t
GROUP BY 
    OrderCount
ORDER BY 
    OrderCount;



-- 8️ What is the average revenue per order and per customer?
WITH OrderRevenue AS (
    SELECT 
        o.order_id,
        o.customer_id,
        SUM(oi.price + oi.freight_value) AS Revenue
    FROM 
        Orders o
    JOIN 
        OrderItems oi ON o.order_id = oi.order_id
    WHERE 
        o.order_status = 'delivered'
    GROUP BY 
        o.order_id, o.customer_id
)
SELECT 
    AVG(Revenue) AS AvgRevenuePerOrder,
    SUM(Revenue) / COUNT(DISTINCT customer_id) AS AvgRevenuePerCustomer
FROM 
    OrderRevenue;



-- 9️ Which are the top 10 sellers by total revenue?
SELECT 
    s.seller_id,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    SUM(oi.price + oi.freight_value) AS TotalRevenue
FROM 
    Orders o
JOIN 
    OrderItems oi ON o.order_id = oi.order_id
JOIN 
    Sellers s ON oi.seller_id = s.seller_id
WHERE 
    o.order_status = 'delivered'
GROUP BY 
    s.seller_id
ORDER BY 
    TotalRevenue DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;



-- 🔟 What is the average fulfillment time (days) by seller?
SELECT 
    s.seller_id,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    AVG(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS AvgFulfillmentDays
FROM 
    Orders o
JOIN 
    OrderItems oi ON o.order_id = oi.order_id
JOIN 
    Sellers s ON oi.seller_id = s.seller_id
WHERE 
    o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 
    s.seller_id
ORDER BY 
    AvgFulfillmentDays;
