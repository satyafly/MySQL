USE sakila;

-- Exercise 1
--- 1a. Display the first and last names of all actors from the table `actor`.

SELECT 
    first_name, last_name
FROM
    actor
WHERE
    first_name IS NOT NULL
        AND last_name IS NOT NULL;

-- 1b: Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT 
    CONCAT(UPPER(first_name), ' ', UPPER(last_name)) AS `Actor Name`
FROM
    actor;

-- Exercise 2
-- 2a: You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    first_name = 'Joe';

-- 2b: Find all actors whose last name contain the letters GEN
SELECT 
    *
FROM
    actor
WHERE
    last_name LIKE '%GEN%';

-- 2c: Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT 
    last_name, first_name
FROM
    actor
WHERE
    last_name LIKE '%LI%';

-- 2d: Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT 
    country_id, country
FROM
    country
WHERE
    country IN ('AFGHANISTAN' , 'BANGLADESH', 'CHINA');

-- Exercise 3
-- 3a: Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor ADD COLUMN middle_name VARCHAR(15) AFTER first_name;

-- 3b: Change the data type of the middle_name column to blobs.
ALTER TABLE actor MODIFY COLUMN middle_name BLOB;

-- 3c: Now delete the middle_name column.
ALTER TABLE actor DROP column middle_name;

-- Exercise 4
-- 4a: List the last names of actors, as well as how many actors have that last name.
SELECT 
    last_name, COUNT(*) AS CNT
FROM
    actor
GROUP BY last_name;

-- 4b: List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT 
    last_name, COUNT(*) AS CNT
FROM
    actor
GROUP BY last_name
HAVING CNT > 1;

-- 4c: Actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SELECT 
    *
FROM
    actor
WHERE
    first_name = 'GROUCHO'
        AND last_name = 'WILLIAMS';
UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
    first_name = 'GROUCHO'
        AND last_name = 'WILLIAMS';

-- 4d:  if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error.
SELECT 
    *
FROM
    actor
WHERE
    first_name = 'HARPO'
        AND last_name = 'WILLIAMS';

UPDATE actor 
SET 
    first_name = (CASE
        WHEN first_name = 'HARPO' THEN 'GROUCHO'
        ELSE 'MUCHO GROUCHO'
    END)
WHERE
    actor_id = 172
        AND last_name = 'WILLIAMS';

-- Exercise 5
-- 5a: You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Locate the schema of address table
SELECT 
    *
FROM
    INFORMATION_SCHEMA.TABLES
WHERE
    TABLES.TABLE_NAME = 'address';

-- Create the database if it doesnot exist
CREATE database IF NOT EXISTS sakila;

-- Exercise 6
-- 6a: Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address
SELECT 
    staff.first_name,
    staff.last_name,
    address.address,
    address.district
FROM
    staff
        INNER JOIN
    address ON STAFF.ADDRESS_ID = ADDRESS.ADDRESS_ID;

-- 6b: Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT 
    staff.first_name,
    staff.last_name,
    SUM(payment.amount) AS `Total Sum`
FROM
    payment
        INNER JOIN
    STAFF ON PAYMENT.STAFF_ID = STAFF.STAFF_ID
WHERE
    payment_date BETWEEN '2005-08-01' AND '2005-08-31'
GROUP BY staff.STAFF_ID;

-- 6c: List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT 
    FILM.TITLE, COUNT(FILM_ACTOR.FILM_ID) AS `COUNT OF ACTORS`
FROM
    FILM
        INNER JOIN
    FILM_ACTOR ON FILM.FILM_ID = FILM_ACTOR.FILM_ID
GROUP BY FILM.TITLE;

-- 6d: How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT 
    FILM.TITLE, COUNT(INVENTORY.FILM_ID) AS `COUNT`
FROM
    FILM
        INNER JOIN
    INVENTORY ON FILM.FILM_ID = INVENTORY.FILM_ID
WHERE
    FILM.TITLE = 'Hunchback Impossible';

-- 6e: Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT 
    CUSTOMER.FIRST_NAME,
    CUSTOMER.LAST_NAME,
    SUM(PAYMENT.AMOUNT) AS `TOTAL AMOUNT PAID`
FROM
    CUSTOMER
        LEFT JOIN
    PAYMENT ON CUSTOMER.CUSTOMER_ID = PAYMENT.CUSTOMER_ID
GROUP BY CUSTOMER.CUSTOMER_ID
ORDER BY CUSTOMER.LAST_NAME ASC;

-- Exercise 7
/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English
*/

SELECT 
    *
FROM
    FILM
WHERE
    (TITLE LIKE 'K%' OR TITLE LIKE 'Q%')
        AND LANGUAGE_ID = (SELECT 
            LANGUAGE_ID
        FROM
            LANGUAGE
        WHERE
            NAME = 'ENGLISH');

-- 7b: Use subqueries to display all actors who appear in the film Alone Trip.
SELECT 
    FIRST_NAME, LAST_NAME
FROM
    ACTOR
WHERE
    ACTOR_ID IN (SELECT 
            ACTOR_ID
        FROM
            FILM_ACTOR
        WHERE
            FILM_ID = (SELECT 
                    FILM_ID
                FROM
                    FILM
                WHERE
                    TITLE = 'Alone Trip'));

-- 7c: You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT 
    first_name AS `FIRST NAME`,
    last_name AS `LAST NAME`,
    email AS `E-MAIL`
FROM
    customer
        LEFT JOIN
    address ON customer.address_id = address.address_id
        LEFT JOIN
    city ON address.city_id = city.city_id
        LEFT JOIN
    country ON city.country_id = country.country_id
WHERE
    country = 'Canada';

-- 7d: Identify all movies categorized as famiy films.
SELECT 
    TITLE
FROM
    FILM
WHERE
    FILM_ID IN (SELECT 
            FILM_ID
        FROM
            FILM_CATEGORY
        WHERE
            CATEGORY_ID = (SELECT 
                    CATEGORY_ID
                FROM
                    CATEGORY
                WHERE
                    NAME = 'FAMILY'));

-- 7e: Display the most frequently rented movies in descending order.
SELECT 
    film.title, COUNT(film.film_id) AS `Count`
FROM
    rental
        LEFT JOIN
    inventory ON rental.inventory_id = inventory.inventory_id
        LEFT JOIN
    film ON inventory.film_id = film.film_id
GROUP BY film.film_id
ORDER BY `Count` DESC;

-- 7f: Write a query to display how much business, in dollars, each store brought in.
SELECT 
    CONCAT(city.city, ',', country.country) AS `Store`,
    SUM(payment.amount) AS `Total Sales`
FROM
    payment
        LEFT JOIN
    rental ON payment.rental_id = rental.rental_id
        LEFT JOIN
    inventory ON rental.inventory_id = inventory.inventory_id
        LEFT JOIN
    store ON inventory.store_id = store.store_id
        LEFT JOIN
    address ON store.address_id = address.address_id
        LEFT JOIN
    city ON address.city_id = city.city_id
        LEFT JOIN
    country ON city.country_id = country.country_id
WHERE
    store.store_id IS NOT NULL
GROUP BY store.store_id
ORDER BY `Total Sales` DESC;

-- 7g: Write a query to display for each store its store ID, city, and country.
SELECT 
    store.store_id, city.city, country.country
FROM
    store
        LEFT JOIN
    address ON store.address_id = address.address_id
        LEFT JOIN
    city ON address.city_id = city.city_id
        LEFT JOIN
    country ON city.country_id = country.country_id;

-- 7h: List the top five genres in gross revenue in descending order.
SELECT 
    category.name AS `Category`,
    SUM(payment.amount) AS `Total Sales`
FROM
    category
        LEFT JOIN
    film_category ON category.category_id = film_category.category_id
        LEFT JOIN
    inventory ON film_category.film_id = inventory.film_id
        LEFT JOIN
    rental ON inventory.inventory_id = rental.inventory_id
        LEFT JOIN
    payment ON rental.rental_id = payment.rental_id
GROUP BY category.category_id
ORDER BY `Total Sales` DESC
LIMIT 5;

-- Exercise 8
-- 8a: Create View for Top Five Genres
CREATE VIEW top_5_genres AS
    (SELECT 
        category.name AS `Category`,
        SUM(payment.amount) AS `Total Sales`
    FROM
        category
            LEFT JOIN
        film_category ON category.category_id = film_category.category_id
            LEFT JOIN
        inventory ON film_category.film_id = inventory.film_id
            LEFT JOIN
        rental ON inventory.inventory_id = rental.inventory_id
            LEFT JOIN
        payment ON rental.rental_id = payment.rental_id
    GROUP BY category.category_id
    ORDER BY `Total Sales` DESC
    LIMIT 5);

-- 8b: Display the View created in 8.1 
SELECT 
    *
FROM
    top_5_genres;

-- 8c: Query to delete the view top_5_genres
DROP VIEW top_5_genres;