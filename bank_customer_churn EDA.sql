CREATE TABLE bank.churn (
    RowNumber INT,
    CustomerId VARCHAR(255),
    Surname VARCHAR(255),
    CreditScore INT,
    Geography VARCHAR(255),
    Gender VARCHAR(10),
    Age INT,
    Tenure INT,
    Balance DECIMAL(10, 2),
    NumOfProducts INT,
    HasCrCard BOOLEAN,
    IsActiveMember BOOLEAN,
    EstimatedSalary DECIMAL(10, 2),
    Exited INT,
    Complain BOOLEAN,
    SatisfactionScore INT,
    CardType VARCHAR(255),
    PointEarned DECIMAL(10, 2)
);

select * from bank.churn;

--                          EXPLORATORY DATA ANALYSIS                    

-- Checking for Null Values 

SELECT
  SUM(CASE WHEN creditscore IS NULL THEN 1 ELSE 0 END) AS credit_null,
  SUM(CASE WHEN Exited IS NULL THEN 1 ELSE 0 END) AS exited_null,
  SUM(CASE WHEN Complain IS NULL THEN 1 ELSE 0 END) AS complain_null,
  SUM(CASE WHEN SatisfactionScore IS NULL THEN 1 ELSE 0 END) AS satisfaction_null,
  SUM(CASE WHEN CardType IS NULL THEN 1 ELSE 0 END) AS CardType_null
FROM bank.churn;


-- Checking Unique Genders 
select distinct (gender) from bank.churn;

-- Checking unique cardtype
select distinct cardtype from bank.churn; 

-- Oerview of credit score
select min(creditscore) as min_score , avg(creditscore) as avg_score, max(creditscore) as max_score
from bank.churn;

-- How many customers are below avg credit score ?
select count(*) from bank.churn
where CreditScore < 651;

-- Overview of the countries that the customer is located in 
select geography ,  count(geography) as num from bank.churn 
group by geography;


-- Overveiw of the gender of the Customers 
select gender , count(gender) from bank.churn
group by gender;

-- Overview of Age
select min(age) as min_age, round(avg(age)) as avg_age , max(age) as max_age
from bank.churn;

-- number of customers who left the bank 
select count(*) as count 
from bank.churn
where exited =1;


-- percentage of the customers who left the bank 

with cte as(
select count(*) as a , 
(
select
count(*) from 
bank.churn where
exited = 1  ) as b
from bank.churn
)
select (b/a) * 100 as churn_rate from cte;

-- Overveiw of products 
select min(NumOfProducts) as min_prod , round(avg(NumOfProducts),1) as avg_prod , max(NumOfProducts) as max_prod 
from bank.churn;



--  		                           DATA ANALYSIS


-- Does age of the customer affect the churn rate ?

WITH cte AS (
    SELECT
        CASE
            WHEN Age <= 30 THEN '<30'
            WHEN Age <= 40 THEN '30-40'
            WHEN Age <= 50 THEN '40-50'
            WHEN Age <= 60 THEN '50-60'
            ELSE '60+'
        END AS AgeGroup,
        Exited
    FROM bank.churn
),
cte2 as (
SELECT
    AgeGroup,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS Churned,
    SUM(CASE WHEN Exited = 0 THEN 1 ELSE 0 END) AS NotChurned
FROM cte
GROUP BY AgeGroup
ORDER BY AgeGroup
)
select * , round((Churned/ (churned+ NotChurned)) * 100,2) as churn_ratio
from cte2;

-- Age group 50-60 has the highest churn ratio (56.2%), followed by age group 40-50 with churn ration of 33.9% .


-- what is the relation between tenure and loyalty ?

select tenure, round((churned / (churned + not_churned))* 100,2) as churn_ratio
from
(
select tenure , 
sum( case when exited = 1 then 1 else 0 end ) as churned ,
sum( case when exited = 0 then 1 else 0 end) as not_churned
from bank.churn
group by tenure 
order by tenure
) as alias;

-- Does having a Credit Card affect the churn rate ?
with cte as(
select credit_card ,
sum(case when exited = 1 then 1 else 0 end ) as churned,
sum(case when exited = 0 then 1 else 0 end) as not_churned
from
(
select exited,
case when HasCrCard = 1 then 'Owns'
else 'Doesnt own'
end 
as Credit_card
from bank.churn) as alias
group by credit_Card
)
select * , round((churned / (churned+not_churned))*100,2) as churn_ratio
 from cte;


-- What is the influence of gender in Churn ratio?
select gender , churned , not_churned , round((churned / (churned + not_churned)) * 100,2) as churn_rate
from
(
select gender,
sum(case when exited = 1 then 1 else 0 end) churned ,
sum(case when exited = 0 then 1 else 0 end) not_churned
from 
bank.churn
group by gender
)as alias; 

-- Churn rate among the Female customer (25.07%) is more than male customers (16.47%)

-- Which country has more churn rate ?
select * , round((churned / (churned + not_churned)) * 100,2) as churn_ratio
from
(
select geography as country, 
sum(case when exited = 1 then 1 else 0 end) as churned,
sum(case when exited = 0 then 1 else 0 end) as not_churned
from bank.churn
group by geography
) as alias;

-- Germany has the most churned ratio with 32.44 % , followed by Spain at 16.67 % and France at 16.67 % 

-- Do customers who complain tend to leave the bank?
with cte as (
select exited,
 case when complain = 1 then 'Complained'
 else 'Not_complained'
 end as complains
 from bank.churn
)
select complains , churned , not_churned , round((churned / (churned + not_churned)) * 100,2) as churn_ratio
from 
(
select complains ,
sum(case when exited = 1 then 1 else 0 end) as churned,
sum(case when exited = 0 then 1 else 0 end) as not_churned
from cte
group by complains
) as alais ;

-- We  can see a very high churn ratio among the ones who have complains . 


--                                         MY FINAL COMMENTS

-- 1) Age group of  50-60 has the highest churn ratio  (56.2%), followed by the 40-50 age group (33.9%). 
-- The lowest churn rate is observed in the <30 age group (7.5%). 
-- Hence Age group influences churn rate. Older customers are more likely to churn, while younger customers are more likely to stay with the bank.


-- 2) Even though normally, older clients are more loyal and less likely to leave a bank. But In our case , 
-- there is no correlation between the tenure and churn rate as we can see that the churn rate is similar in the 
-- customers with the highest and the lowest tenure with the bank.


-- 3) The churn rate is very similar for the customer who own's and doesn't own a credit card .
--   Hence We can not determine the churn rate by ownership of credit cards .


-- 4) Female Customers tend to churn the bank more with churn ratio of 25.07 % compared to its male counterparts with 
-- churn ration of 16.47%

-- 5) Bank Customers of Germany has the highest churn rate (32.4%), followed by Spain (16.7%) and France (16.2%).

-- 6) Customers who had more explains have higher churn ratio with a whopping 99.51%


