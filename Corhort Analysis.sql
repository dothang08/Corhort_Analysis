/*Task 2: "Let's build a cohort chart for all customer of Electricity billing in 2017."
"Hãy xây dựng biểu đồ cohort cho tất cả khách hàng thanh toán tiền điện trong năm 2017." */
WITH table_first as (
    SELECT customer_id, order_id, transaction_date
        , MIN(MONTH(transaction_date)) OVER (PARTITION BY customer_id) as First_Month
    FROM payment_history_17 as his
    LEFT JOIN product as pro 
        ON his.product_id = pro.product_number
    WHERE message_id = 1 and sub_category = 'Electricity'
)

, table_month as (
    SELECT *
        , Month(transaction_date) - First_Month as Month_n
    FROM table_first
)

, table_retained as (
    SELECT First_Month, Month_n
        , COUNT(DISTINCT customer_id) as retained_customers
    FROM table_month
    GROUP BY First_Month, Month_n
)

, table_rentention as (
    SELECT *
        , MAX(retained_customers) OVER (PARTITION BY First_Month) as Original_Customer -- Theo nguyên tắc PARTITION BY First_Month dể lấy max
        , cast( retained_customers as decimal) / MAX(retained_customers) OVER (PARTITION BY First_Month) as pct
    FROM table_retained
)

SELECT First_Month, Original_Customer
    , "0", "1", "2","3", "4", "5","6", "7", "8","9", "10", "11"
FROM (
    SELECT First_Month, Month_n,  Original_Customer, cast( pct as decimal(10,2)) as pct
    FROM table_rentention
) as Source_table
PIVOT (
    SUM(pct) -- Lấy giá trị tương ứng
    FOR month_n IN ("0", "1", "2","3", "4", "5","6", "7", "8","9", "10", "11")
) as Pivot_logic
ORDER BY First_Month
