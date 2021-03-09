/*The purchase funnel is:

Take the Style Quiz → Home Try-On → Purchase the Perfect Pair of Glasses

During the Home Try-On stage, we will be conducting an A/B Test:

50% of the users will get 3 pairs to try on
50% of the users will get 5 pairs to try on

Let’s find out whether or not users who get more pairs to try on 
at home will be more likely to make a purchase.
*/

-- What is the number of responses for each question?
SELECT 
		s.question,
		COUNT(*) AS responses
FROM survey AS s
GROUP BY 1;


-- create a table that show all users and their behaviour on every step (either try on or purchase)
SELECT 
		quiz.user_id,
		home_try_on.number_of_pairs,
		home_try_on.user_id IS NOT NULL AS 'home_try',
		purchase.user_id IS NOT NULL AS 'purchased'
FROM quiz
LEFT JOIN home_try_on
ON quiz.user_id = home_try_on.user_id
LEFT JOIN purchase 
ON quiz.user_id = purchase.user_id;


-- compare conversion from quiz→home_try_on and home_try_on→purchase.
SELECT 
		ROUND(1.0 * COUNT(home_try_on.user_id) / COUNT(quiz.user_id),2) AS 'quiz_to_home_try',
		ROUND(1.0 * COUNT(purchase.user_id) / COUNT(home_try_on.user_id),2) AS 'home_try_to_purchase'
FROM quiz
LEFT JOIN home_try_on
ON quiz.user_id = home_try_on.user_id
LEFT JOIN purchase 
ON quiz.user_id = purchase.user_id;


-- Let’s find out whether or not users who get more pairs to try on at home will be more likely to make a purchase. 
-- calculate the difference in purchase rates between customers who had 3 number_of_pairs with ones who had 5.
WITH TEMP AS
(
SELECT 
(
SELECT 
		1.0 * COUNT(purchase.user_id) / COUNT(home_try_on.user_id) AS 'three_pairs_purchase_rate'
FROM home_try_on
LEFT JOIN purchase
ON home_try_on.user_id = purchase.user_id
WHERE home_try_on.number_of_pairs = '3 pairs'
) AS 'three_pairs_purchase_rates', 

(
SELECT 
		1.0 * COUNT(purchase.user_id) / COUNT(home_try_on.user_id) AS 'five_pairs_purchase_rate'
FROM home_try_on
LEFT JOIN purchase
ON home_try_on.user_id = purchase.user_id
WHERE home_try_on.number_of_pairs = '5 pairs'
) AS 'five_pairs_purchase_rates'

)
SELECT 
		three_pairs_purchase_rates,
		five_pairs_purchase_rates,
		CASE
			WHEN three_pairs_purchase_rates > five_pairs_purchase_rates THEN 'trying 3 pairs gives better purchase rate'
			WHEN three_pairs_purchase_rates < five_pairs_purchase_rates THEN 'trying 5 pairs gives better purchase rate'
			ELSE 'DRAW'
			END AS 'compare_result'
FROM TEMP;


-- The most common results of the style quiz.
SELECT 
		quiz.style,
		COUNT(*) AS 'total_answers'
FROM quiz
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- Which is the top selling model ?
SELECT 
		purchase.model_name,
		purchase.style,
		COUNT(*) 'purchases'
FROM purchase
GROUP BY 1
ORDER BY 3 DESC
LIMIT 1;

