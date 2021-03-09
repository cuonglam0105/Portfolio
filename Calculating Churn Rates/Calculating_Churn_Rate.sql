-- Get use with data set 
SELECT *
FROM subscriptions
LIMIT 100;
	

/*Codeflix requires a minimum subscription length of 31 days, so a user can never start and end their subscription in the same month.*/	
-- Determine the range of months of data provided. Which months will you be able to calculate churn for?
SELECT 
	MIN(s.subscription_start),
	MAX(s.subscription_start)
FROM subscriptions s;
-- Answer: Month 1,2,3 is able to calculate churn for.


-- Calculate churn rate for each segment every month
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
cross_join AS
(
	SELECT *
	FROM subscriptions
	CROSS JOIN months
),
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
SELECT
	month,
	1.0 * SUM(is_canceled_30) / SUM(is_active_30) AS 'Churn_rate_segment_30',
	1.0 * SUM(is_canceled_87) / SUM(is_active_87) AS 'Churn_rate_segment_87'
FROM status
GROUP BY 1;



	