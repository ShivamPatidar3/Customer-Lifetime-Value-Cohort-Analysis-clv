# 📉 Customer Lifetime Value (CLV) & Cohort Retention Analysis

Hey! This is a project I built to go beyond surface-level analytics and actually answer one of the most important questions in e-commerce:

> *"How long do customers stick around — and how much are they actually worth over time?"*

Instead of just showing total revenue, I built a full **cohort analysis pipeline** that segments customers by the month they first purchased, then tracks their behaviour month-by-month. The result is an industry-standard **retention heatmap** and **CLV curve** — the kind of thing you'd see in a real business intelligence review.

The whole stack runs from a raw Kaggle CSV, through a **PostgreSQL** database with CTE-based SQL queries, ending in an interactive **Power BI** dashboard with DAX measures for retention percentages.

---

## 📊 What the dashboard covers

- **Total Revenue:** $17.74M across all cohorts
- **Average Order Value:** $54.60 per transaction
- **Retention Heatmap:** Month-by-month retention % for every acquisition cohort (2009–2011)
- **Best cohort:** 2009-12 achieved 897.9% cumulative retention over 25 months
- **Cumulative CLV Curve:** Shows exactly how long-term revenue grows per cohort — 2009-12 peaks near $0.6M
- **KPI Cards:** Total Revenue, Average Lifetime Value, Total Unique Customers at a glance

---

## 🖼️ Preview

![Dashboard Preview](CLV%20project/clv%20dashboard_preview.png)

More screenshots of the build process are in the `screenshots/` folder.

---

## 📁 What's in this repo

| File | What it is |
|---|---|
| `sql/01_create_table.sql` | Schema for the raw transactions table |
| `sql/02_clean_view.sql` | View that removes nulls, cancellations, and zero-price rows |
| `sql/03_cohort_queries.sql` | Full CTE pipeline — cohort month, order data, cohort index, final table |
| `dashboard/clv_dashboard.pbix` | The full Power BI report — open this in Power BI Desktop to explore it yourself |
| `screenshots/` | Screenshots of the dashboard and build process |

---

## 🛠️ Tools used

- **PostgreSQL** + **pgAdmin** for database setup and data ingestion
- **SQL (CTEs)** for cohort segmentation and CLV calculation
- **Power BI Desktop** for the interactive dashboard
- **DAX** for the Cohort Size and Retention % calculated measures

---

## 🧠 The SQL logic (the interesting part)

The core of this project is a 3-step CTE chain in PostgreSQL:

```sql
WITH customer_cohorts AS (
    -- Find each customer's very first purchase month
    SELECT CustomerID,
           DATE_TRUNC('month', MIN(InvoiceDate)) AS cohort_month
    FROM clean_transactions
    GROUP BY CustomerID
),
order_data AS (
    -- Tag every transaction with the customer's cohort and compute revenue
    SELECT t.CustomerID,
           DATE_TRUNC('month', t.InvoiceDate) AS order_month,
           (t.Quantity * t.UnitPrice)          AS revenue,
           c.cohort_month
    FROM clean_transactions t
    JOIN customer_cohorts c ON t.CustomerID = c.CustomerID
),
cohort_metrics AS (
    -- Calculate how many months have passed since first purchase (cohort index)
    SELECT cohort_month, order_month,
           COUNT(DISTINCT CustomerID) AS active_customers,
           SUM(revenue)               AS total_revenue,
           EXTRACT(YEAR  FROM order_month)  * 12 + EXTRACT(MONTH FROM order_month) -
          (EXTRACT(YEAR  FROM cohort_month) * 12 + EXTRACT(MONTH FROM cohort_month)) + 1
               AS cohort_index
    FROM order_data
    GROUP BY cohort_month, order_month
)
SELECT * FROM cohort_metrics;
```

And in Power BI, two DAX measures turn raw customer counts into percentages:

```dax
Cohort Size =
CALCULATE(
    MAX('final_cohort_data'[active_customers]),
    'final_cohort_data'[cohort_index] = 1
)

Retention % =
DIVIDE(
    SUM('final_cohort_data'[active_customers]),
    [Cohort Size],
    0
)
```

---

## 💬 Why I built this

I wanted hands-on practice with a real analytical workflow — not just dragging fields into a chart, but actually designing a data pipeline from scratch. Cohort analysis is one of those things that looks simple on the surface but requires you to think carefully about how time, customers, and revenue interact. Building it end-to-end in SQL before even opening Power BI made the whole thing click.

---

## 🚀 What I'd add next

- A **churn prediction model** using the cohort data as features
- **RFM segmentation** (Recency, Frequency, Monetary) layered on top
- A **country-level breakdown** to see if retention differs by region
- Scheduled **data refresh** via Power BI Service + PostgreSQL gateway

---

Feel free to open the `.pbix` file in Power BI Desktop and connect it to your own PostgreSQL instance to explore the visuals and DAX yourself!
