-- identify cohort month

WITH customer_cohorts AS (
    SELECT 
        CustomerID,
        DATE_TRUNC('month', MIN(InvoiceDate)) AS cohort_month
    FROM clean_transactions
    GROUP BY CustomerID
),

--calculate order month and revenue

order_data AS (
    SELECT 
        t.CustomerID,
        DATE_TRUNC('month', t.InvoiceDate) AS order_month,
        (t.Quantity * t.UnitPrice) AS revenue,
        c.cohort_month
    FROM clean_transactions t
    JOIN customer_cohorts c ON t.CustomerID = c.CustomerID
),

-- calculate cohort index

cohort_metrics AS (
    SELECT 
        cohort_month,
        order_month,
        COUNT(DISTINCT CustomerID) AS active_customers,
        SUM(revenue) AS total_revenue,
        EXTRACT(YEAR FROM order_month) * 12 + EXTRACT(MONTH FROM order_month) - 
        (EXTRACT(YEAR FROM cohort_month) * 12 + EXTRACT(MONTH FROM cohort_month)) + 1 AS cohort_index
    FROM order_data
    GROUP BY cohort_month, order_month
)
SELECT * FROM cohort_metrics;