# Calculating Churn Rates

Four months into launching Codeflix, management wants to know about subscription churn rates. It’s early on in the business and people are excited to know how the company is doing.

The marketing department is particularly interested in how the churn compares between two segments of users. They provide a dataset containing subscription data for users who were acquired through two distinct channels.

The dataset containss one SQL table, subscriptions. Within the table, there are 4 columns:

- id - the subscription id
- subscription_start - the start date of the subscription
- subscription_end - the end date of the subscription
- segment - this identifies which segment the subscription owner belongs to

Codeflix requires a minimum subscription length of 31 days, so a user can never start and end their subscription in the same month.

===========================================

Step 1: Create a temporary table of "months"
```sql
WITH months AS
(
	SELECT 
		'2017-01-01' AS 'first_day',
		'2017-01-31' AS 'last_day'
	UNION
	SELECT
		'2017-02-01' AS 'first_day',
		'2017-02-28' AS 'last_day'
	UNION
	SELECT
		'2017-03-01' AS 'first_day',
		'2017-03-31' AS 'last_day'
),
```
Step 2: Create a temporary table "cross_join" from "subscriptions" and "months"
```sql
cross_join AS
(
	SELECT *
	FROM subscriptions
	CROSS JOIN months
),
```
Step 3: Create a temporary table "status" from the "cross_join"
```sql
status AS
(
	SELECT 
		id,
		first_day AS 'month',
		segment,
		CASE
			WHEN subscription_start < first_day
				AND (subscription_end BETWEEN first_day AND last_day)
				AND (segment = '30')					
			THEN 1
			ELSE 0			
		END AS 'is_canceled_30',

		CASE
			WHEN subscription_start < first_day
				AND (subscription_end BETWEEN first_day AND last_day)
				AND (segment = '87')					
			THEN 1
			ELSE 0			
		END AS 'is_canceled_87',

				CASE
			WHEN subscription_start < first_day
				AND (subscription_end >= first_day
					OR subscription_end IS NULL)
				AND (segment = '30')	
			THEN 1
			ELSE 0
		END AS 'is_active_30',
		
				CASE
			WHEN subscription_start < first_day
				AND (subscription_end >= first_day
					OR subscription_end IS NULL)
				AND (segment = '87')	
			THEN 1
			ELSE 0
		END AS 'is_active_87'		
		
	FROM cross_join
)
```
Step 4: Calculate the churn rates for the two segments over the three month period.
```sql
SELECT
	month,
	1.0 * SUM(is_canceled_30) / SUM(is_active_30) AS 'Churn_rate_segment_30',
	1.0 * SUM(is_canceled_87) / SUM(is_active_87) AS 'Churn_rate_segment_87'
FROM status
GROUP BY 1;
```

