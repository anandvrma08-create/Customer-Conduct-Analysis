SELECT * from customer_shop limit 20;

-- TOTAL REVENUE GEN BY MALE VS FEMALE
select gender,sum(purchase_amount) from customer_shop GROUP BY gender;

-- WHICH CUSTOMER USED DISCOUNT BUT STILL SPENT MORE THAN AVERAGE PURCHASE AMOUNT
create view  customer_spent_more as (
SELECT * from customer_shop where 
purchase_amount >(SELECT AVG(purchase_amount) from customer_shop) and discount_applied ="Yes");
SELECT* from customer_spent_more;
SELECT count(*) from customer_spent_more;   --COUNT ALSO

--  TOP 5 PRODUCT WITH HIGHEST AVERAGE REVIEW RATING
SELECT item_purchased,review_rating from customer_shop where 
    review_rating>(SELECT avg(review_rating) from customer_shop) ORDER BY review_rating DESC limit 5;
    
SELECT item_purchased,ROUND(avg(review_rating),2)as avg_rating from customer_shop 
GROUP BY item_purchased order by avg_rating  DESC limit 5;

-- COMPARE AVERAGE PURCHANSE AMOUNT IN EXPRESS AND STANDARD SHIPPING
SELECT shipping_type,SUM(purchase_amount) from customer_shop 
where shipping_type in ("Express", "Standard")
 group BY shipping_type;

--  AVERAGE SPEND AND TOTAL REVENUE BY SUBSCRIBED CUSTOMER AND NON-SUBSCRIBED CUSTOMER
SELECT subscription_status,COUNT(customer_id),avg(purchase_amount) as avg_spent,SUM(purchase_amount) as revenue 
FROM customer_shop GROUP BY subscription_status;

-- top 5 products have highest percentage of purchace and also have discount applied
SELECT item_purchased,COUNT(item_purchased) as item_count,
(COUNT(item_purchased)/(SELECT count(*) from customer_shop where discount_applied="Yes"))*100
from customer_shop 
where discount_applied="Yes" GROUP BY item_purchased
order by item_count desc 
limit 5;

-- Customer Segrigation into New,Returning And Loyal
with cte as
(SELECT customer_id,previous_purchases,
CASE 
    WHEN previous_purchases=1 THEN 'New'
    WHEN previous_purchases BETWEEN 2 and 10 THEN 'Returning'
    ELSE  'Loyal'
    END AS customer_type
from customer_shop)
SELECT customer_type,COUNT(*) from cte GROUP BY customer_type;

-- Top 3 Products In Each Category By Revenue
with cte as (
    SELECT category,item_purchased,SUM(purchase_amount),
    DENSE_RANK() OVER(PARTITION BY category ORDER BY SUM(purchase_amount) DESC) as rn
    from customer_shop GROUP BY category,item_purchased
)
SELECT * FROM cte WHERE rn<=3;

--  By Count
with cte as (
    SELECT category,item_purchased,
    COUNT(customer_id) as item_count,
    DENSE_RANK() OVER(PARTITION BY category ORDER BY COUNT(customer_id) DESC)
    from customer_shop GROUP BY category,item_purchased
)
SELECT category,item_purchased,item_count FROM cte ;


-- Repeat buyers Subscription Trend
SELECT subscription_status,COUNT(customer_id) as freuquent_buyers
FROM customer_shop where purchace_frequency_days>5
GROUP BY subscription_status;

