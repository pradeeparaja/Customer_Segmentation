  -- overview
SELECT
  *
FROM
  `sales.sales`
LIMIT
  10; 
  

  -- Product analysis
SELECT
InvoiceNo,
  round(SUM(UnitPrice * Quantity),2) AS Amount
FROM
  `sales.sales`
GROUP BY
  InvoiceNo
ORDER BY
  1 DESC;
  
  
   -- Country
SELECT
  Country,
  round(SUM(UnitPrice * Quantity),2) AS Amount
from `sales.sales`
group by Country;



Select Extract(month from InvoiceDate) as month,
round(SUM(UnitPrice * Quantity),2) AS Amount
from `sales.sales`
group by month;



-- Month wise analysis

Select FORMAT_DATE('%B', DATE_TRUNC(InvoiceDate ,month)) as Month ,
  round(SUM(UnitPrice * Quantity),2) AS Amount
  from `sales.sales`
  Group by Month;

-- country 

select 
Country, count(InvoiceNo) as total_orders, round(sum(quantity*UnitPrice),2) as Total_revenue
from `sales.sales`
group by Country;


select 
date(max(InvoiceDate))
from `sales.sales`;


  -- RFM

WITH rfm AS (
    SELECT
        CustomerID,
        DATE(MIN(InvoiceDate)) AS first_order_date,
        DATE(MAX(InvoiceDate)) AS last_order_date,
        COUNT(DISTINCT InvoiceNo) AS Total_orders,
        ROUND(SUM(Quantity * UnitPrice), 2) AS Total_amount
    FROM `sales.sales`
    GROUP BY CustomerID
),
rfm_segment AS (
    SELECT
        distinct CustomerID,
        DATE_DIFF(MAX_date, tbl1.last_order_date, DAY) AS Recency,
        ROUND((tbl1.Total_orders / tbl1.no_of_months), 2) AS Frequency,
        tbl1.Total_amount AS Monetary
    FROM (
        SELECT
            *,
            MAX(rfm.last_order_date) OVER() + 1 AS max_date,
            DATE_DIFF(rfm.last_order_date, rfm.first_order_date, MONTH) + 1 AS no_of_months
        FROM rfm
        JOIN `sales.sales` AS s USING(CustomerID)
    ) AS tbl1
),
final_query AS (
    SELECT 
        distinct CustomerID,
        CONCAT(R_score,'-', F_score,'-', M_score) AS RFM_STRING
    FROM (
        SELECT 
            CustomerID,
            NTILE(5) OVER (ORDER BY Recency DESC) AS R_score,
            NTILE(5) OVER (ORDER BY Frequency) AS F_score,
            NTILE(5) OVER (ORDER BY Monetary) AS M_score
        FROM rfm_segment
    ) AS subquery
)


SELECT
    distinct CustomerID,
    Recency,
    Frequency,
    Monetary,
    f.RFM_STRING,
    CASE
        WHEN RFM_STRING IN ('5-5-5', '5-5-4', '5-4-4', '5-4-5', '4-5-4', '4-5-5', '4-4-5') THEN 'Champion'
        WHEN RFM_STRING IN ('5-4-3', '4-4-4', '4-3-5', '3-5-5', '3-5-4', '3-4-5', '3-4-4', '3-3-5') THEN 'Loyal'
        WHEN RFM_STRING IN ('5-5-3', '5-5-1', '5-5-2', '5-4-1', '5-4-2', '5-3-3', '5-3-2', '5-3-1', 
                            '4-5-2', '4-5-1', '4-4-2', '4-4-1', '4-3-1', '4-5-3', '4-3-3', '4-3-2', 
                            '4-2-3', '3-5-3', '3-5-2', '3-5-1', '3-4-2', '3-4-1', '3-3-3', '3-2-3') THEN 'Potential Loyalist'
        WHEN RFM_STRING IN ('5-1-2', '5-1-1', '4-2-2', '4-2-1', '4-1-2', '4-1-1', '3-1-1') THEN 'New Customer'
        WHEN RFM_STRING IN ('5-2-5', '5-2-4', '5-2-3', '5-2-2', '5-2-1', '5-1-5', '5-1-4', '5-1-3', 
                            '4-2-5', '4-2-4', '4-1-3', '4-1-4', '4-1-5', '3-1-5', '3-1-4', '3-1-3') THEN 'Promising'
        WHEN RFM_STRING IN ('5-3-5', '5-3-4', '4-4-3', '4-3-4', '3-4-3', '3-3-4', '3-2-5', '3-2-4') THEN 'Needs Attention'
        WHEN RFM_STRING IN ('3-3-1', '3-2-1', '3-1-2', '2-2-1', '2-1-3', '2-3-1', '2-4-1', '2-5-1') THEN 'About To Sleep'
        WHEN RFM_STRING IN ('2-5-5', '2-5-4', '2-4-5', '2-4-4', '2-5-3', '2-5-2', '2-4-3', '2-4-2', 
                            '2-3-5', '2-3-4', '2-2-5', '2-2-4', '1-5-3', '1-5-2', '1-4-5', '1-4-3', 
                            '1-4-2', '1-3-5', '1-3-4', '1-3-3', '1-2-5', '1-2-4') THEN 'At Risk'
        WHEN RFM_STRING IN ('1-5-5', '1-5-4', '1-4-4', '2-1-4', '2-1-5', '1-1-5', '1-1-4', '1-1-3') THEN 'Cannot Lose Them'
        WHEN RFM_STRING IN ('3-3-2', '3-2-2', '2-3-3', '2-3-2', '2-2-3', '2-2-2', '1-3-2', '1-2-3', 
                            '1-2-2', '2-1-2', '2-1-1') THEN 'Hibernating Customer'
        WHEN RFM_STRING IN ('1-1-1', '1-1-2', '1-2-1', '1-3-1', '1-4-1', '1-5-1') THEN 'Lost Customer'
    END AS RFM_SEGMENT
FROM final_query as f
JOIN rfm_segment USING (CustomerID)
ORDER BY CustomerID








