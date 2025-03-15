/* ### Challenge
Creating a Customer Summary Report

In this exercise, you will create a customer summary report that summarizes key information about customers in the 
Sakila database, including their rental history and payment details. The report will be generated using a combination
 of views, CTEs, and temporary tables.

Step 1: Create a View
First, create a view that summarizes rental information for each customer. The view should include the 
customer's ID, name, email address, and total number of rentals (rental_count).*/
USE sakila;

/*# get info from customer table
SELECT customer_id AS customer_id,
		CONCAT(a.first_name,' ', a.last_name) AS name,
        email AS email_add
FROM customer;

#join with rental_count
SELECT COUNT(*) 
FROM rental
GROUP BY customer_id;*/

#create view
CREATE VIEW customer_rentals AS
SELECT c.customer_id AS customer_id,
		CONCAT(c.first_name,' ', c.last_name) AS name,
        email AS email_add,
        rent.n_rent AS rental_count
FROM customer c
INNER JOIN (SELECT COUNT(*) AS n_rent,
			r.customer_id AS customer_id
			FROM rental r
			GROUP BY customer_id) AS rent
ON rent.customer_id = c.customer_id
ORDER BY rental_count DESC;


/*Step 2: Create a Temporary Table
Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
The Temporary Table should use the rental summary view created in Step 1 to join with the payment table
and calculate the total amount paid by each customer.*/
/*#calculate amounts paid per customer in customer table
SELECT p.customer_id AS customer_id,
	SUM(amount) AS cust_sum 
FROM payment p
GROUP BY p.customer_id;*/

CREATE TEMPORARY TABLE 	customer_expenses
SELECT cust.customer_id AS customer_id,
		cust.name AS name,
        cust.email_add AS email,
        cust.rental_count AS rental_count,
        pay.cust_sum AS total_paid
FROM customer_rentals AS cust
LEFT JOIN (SELECT p.customer_id AS customer_id,
		SUM(amount) AS cust_sum 
		FROM payment p
        GROUP BY customer_id) AS pay          # group by should be inside the subquery because we want to group the data that is in this able and only after that we will join
ON pay.customer_id = cust.customer_id;



/*Step 3: Create a CTE and the Customer Summary Report
Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
The CTE should include the customer's name, email address, rental count, and total amount paid.*/
WITH cte_customers_amounts AS 
	(SELECT * 
	FROM customer_expenses)
;

SELECT * FROM customer_expenses;
/*Next, using the CTE, create the query to generate the final customer summary report, which should include: 
customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived 
column from total_paid and rental_count.*/

WITH cte_customers_amounts AS 
	(SELECT * 
	FROM customer_expenses)

SELECT name AS customer_name,
		email,
        rental_count,
        total_paid,
        ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM cte_customers_amounts ;