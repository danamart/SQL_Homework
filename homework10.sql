USE sakila;

/*1a.Display the first and last names of all actors from the table actor.
1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.*/

SELECT first_name, last_name FROM actor;

SELECT UPPER(CONCAT(first_name, " ", last_name))AS 'Actor Name' FROM actor;

/*2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
2b. Find all actors whose last name contain the letters GEN:
2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:*/

SELECT actor_id, first_name, last_name FROM Actor WHERE first_name='Joe';

SELECT * FROM actor WHERE last_name LIKE '%GEN%';

SELECT * FROM actor WHERE last_name LIKE '%LI%' ORDER BY last_name, first_name;

SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

/*3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
so create a column in the table actor named description and use the data type BLOB (Make sure to research the 
type BLOB, as the difference between it and VARCHAR are significant).
3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.*/

ALTER TABLE actor
ADD COLUMN description BLOB null DEFAULT null;

SELECT * FROM actor;

 ALTER TABLE actor
 DROP COLUMN description;

/*4a. List the last names of actors, as well as how many actors have that last name.
4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single 
query, if the first name of the actor is currently HARPO, change it to GROUCHO.*/

SELECT DISTINCT last_name, COUNT(last_name) AS 'name_count' FROM actor GROUP BY last_name;

SELECT DISTINCT last_name, COUNT(last_name) AS 'name_count' FROM actor GROUP BY last_name HAVING name_count >=2;

UPDATE actor SET first_name = 'HARPO' WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

SELECT * FROM actor;

UPDATE actor SET first_name = 'GROUCHO' WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

/*5a. You cannot locate the schema of the address table. Which query would you use to re-create it?*/

SHOW CREATE TABLE address;

/*6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
6d. How many copies of the film Hunchback Impossible exist in the inventory system?
6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:*/

SELECT s.first_name, s.last_name, a.address
			FROM staff s JOIN address a ON (s.address_id=a.address_id);

SELECT s.first_name, s.last_name, SUM(p.amount) AS 'Total'
			FROM staff s JOIN payment p ON (s.staff_id=p.staff_id)
            WHERE p.payment_date LIKE '2005-08%'
			GROUP BY p.staff_id;
            
SELECT f.title, COUNT(fa.actor_id) AS 'Total Actors'
			FROM film f INNER JOIN film_actor fa ON (f.film_id=fa.film_id)
            GROUP BY f.title;
            
SELECT f.title, COUNT(i.inventory_id) AS 'Total Copies'
			FROM film f INNER JOIN inventory i ON (f.film_id=i.film_id)
            WHERE f.title = 'Hunchback Impossible';
            
SELECT c.last_name, c.first_name, SUM(p.amount) AS 'Total Paid'
			FROM customer c JOIN payment p ON (c.customer_id=p.customer_id)
            GROUP BY c.customer_id ORDER BY c.last_name;
            
/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have 
also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
7b. Use subqueries to display all actors who appear in the film Alone Trip.
7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins
 to retrieve this information.
7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
7e. Display the most frequently rented movies in descending order.*/

SELECT title FROM film 
WHERE language_id IN
(
			SELECT language_id
            FROM language
            WHERE name='English'
 )
 AND (title LIKE 'K%') OR (title LIKE 'Q%');
 
 SELECT last_name, first_name
 FROM actor
 WHERE actor_id IN
 (
			SELECT actor_id FROM film_actor
            WHERE film_id IN
            (
						SELECT film_id FROM film
                        WHERE title='Alone Trip'
			)
);


SELECT c.last_name, c.first_name, c.email
FROM customer c JOIN customer_list cl ON c.customer_id=cl.ID
WHERE cl.country = 'Canada';

SELECT title
FROM film
WHERE film_id IN 
(
			SELECT film_id
			FROM film_category
			WHERE category_id IN 
            (
					SELECT category_id
					FROM category
					WHERE name = 'Family'
			)
);


SELECT film.title, COUNT(*) AS 'Rent Frequency'
FROM film, inventory, rental
WHERE film.film_id = inventory.film_id AND rental.inventory_id = inventory.inventory_id
GROUP BY inventory.film_id ORDER BY COUNT(*) DESC;

/*7f. Write a query to display how much business, in dollars, each store brought in.
7g. Write a query to display for each store its store ID, city, and country.
7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables:
 category, film_category, inventory, payment, and rental.)*/
 
 SELECT s.store_id, SUM(p.amount) AS 'Total Store Sales'
 FROM staff s JOIN payment p ON (s.staff_id=p.staff_id)
 GROUP BY s.store_id;
 
 SELECT s.store_id, c.city, co.country
 FROM store s, address a, city c, country co
 WHERE s.address_id=a.address_id AND a.city_id=c.city_id AND c.country_id=co.country_id
 GROUP BY s.store_id;
 
 SELECT name, SUM(p.amount) AS 'Gross Revenue'
 FROM category c JOIN film_category fc ON c.category_id = fc.category_id
 JOIN inventory i ON i.film_id = fc.film_id
 JOIN rental r ON r.inventory_id = i.inventory_id
 JOIN payment p ON p.rental_id = r.rental_id
 GROUP BY name ORDER BY 'Gross Revenue' DESC LIMIT 5;

 
/*8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
8b. How would you display the view that you created in 8a?
8c. You find that you no longer need the view top_five_genres. Write a query to delete it.*/

CREATE VIEW v_top_five_genres AS
 SELECT name, SUM(p.amount) AS 'Gross Revenue'
 FROM category c JOIN film_category fc ON c.category_id = fc.category_id
 JOIN inventory i ON i.film_id = fc.film_id
 JOIN rental r ON r.inventory_id = i.inventory_id
 JOIN payment p ON p.rental_id = r.rental_id
 GROUP BY name ORDER BY 'Gross Revenue' DESC LIMIT 5;
 
 Select * FROM v_top_five_genres;
 
 DROP VIEW v_top_five_genres;
 
 






