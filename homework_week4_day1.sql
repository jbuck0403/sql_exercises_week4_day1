-- -- 1. How many actors are there with the last name ‘Wahlberg’?
SELECT COUNT(last_name)
FROM actor
WHERE last_name = 'Wahlberg';


-- 2. How many payments were made between $3.99 and $5.99?
SELECT COUNT(amount)
FROM payment
WHERE amount BETWEEN 3.99 and 5.99;


-- -- 3. What film does the store have the most of? (search in inventory)
WITH film_id_counts AS (
    SELECT film_id,
           COUNT(film_id) AS copy_count
    FROM inventory
    GROUP BY film_id
),

films_with_titles AS (
    SELECT film_id_counts.film_id,
           film_id_counts.copy_count,
           film_list.title
    FROM film_id_counts
    INNER JOIN film_list
        ON film_list.fid = film_id_counts.film_id
)

SELECT film_id,
       copy_count,
       title
FROM films_with_titles
WHERE copy_count = (SELECT MAX(copy_count) FROM films_with_titles)
ORDER BY film_id ASC;


-- 4. How many customers have the last name ‘William’?
SELECT COUNT(last_name)
FROM customer
WHERE last_name = 'William';


-- 5. What store employee (get the id) sold the most rentals?
WITH staff_sales AS (
    SELECT staff_id, COUNT(staff_id) as num_sales
    FROM rental
    GROUP BY staff_id
),

staff_info AS (
    SELECT staff_sales.staff_id,
           staff_sales.num_sales,
           staff.first_name,
           staff.last_name
    FROM staff_sales
    INNER JOIN staff
        ON staff_sales.staff_id = staff.staff_id
)

SELECT CONCAT(first_name, ' ', last_name) as employee_name, num_sales, staff_id
FROM staff_info
WHERE num_sales = (SELECT MAX(num_sales) FROM staff_info)


-- 6. How many different district names are there?
WITH unique_districts AS (
    SELECT district
    FROM address
    GROUP BY district
)

SELECT COUNT(district) AS district_count
FROM unique_districts


-- 7. What film has the most actors in it? (use film_actor table and get film_id)
WITH film_cast_size AS (
    SELECT COUNT(actor_id) AS cast_size, film_id
    FROM film_actor
    GROUP BY film_id
    ORDER BY cast_size DESC
),

films_with_titles AS (
    SELECT film_cast_size.cast_size,
           film_cast_size.film_id,
           film.title
    FROM film_cast_size
    INNER JOIN film
        ON film_cast_size.film_id = film.film_id
)

SELECT title, cast_size
FROM films_with_titles
WHERE cast_size = (SELECT MAX(cast_size) FROM films_with_titles)


-- 8. From store_id 1, how many customers have a last name ending with ‘es’? (use customer table)
SELECT COUNT(last_name)
FROM customer
WHERE last_name
    LIKE '%es' 
    AND customer.store_id = 1


-- 9. How many payment amounts (4.99, 5.99, etc.) had a number of rentals above 250 for customers
-- with ids between 380 and 430? (use group by and having > 250)
WITH rentals_above_250 AS (
    SELECT film.rental_rate,
            COUNT(1) AS num_rentals
    FROM inventory
    INNER JOIN rental
        ON inventory.inventory_id = rental.inventory_id
    INNER JOIN film
        ON inventory.film_id = film.film_id
    WHERE customer_id BETWEEN 380 and 430
    GROUP BY rental_rate
    HAVING COUNT(1) > 250
)

SELECT COUNT(rental_rate) -- num rental rates meeting parameters
FROM rentals_above_250


-- 10. Within the film table, how many rating categories are there? And what rating has the most
-- movies total?
WITH movies_with_rating AS (
    SELECT rating, COUNT(rating) AS num_with_rating
    FROM film
    GROUP BY rating
)

SELECT rating, num_with_rating, (
    SELECT COUNT(DISTINCT rating) FROM film
) AS total_rating_types
FROM movies_with_rating
WHERE num_with_rating = (SELECT MAX(num_with_rating) FROM movies_with_rating);
