use sakila;

#1A
SELECT first_name, last_name from actor;
#1B
SELECT concat(first_name, " ", last_name) as Actor_name FROM actor;
#2A
SELECT actor_id, first_name, last_name from actor 
where first_name = 'Joe';
#2B
SELECT last_name from actor where last_name like '%GEN%'
#2C
SELECT first_name, last_name from actor where last_name like '%LI%' 
order by last_name, first_name;
#2D
SELECT country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');
#3A
ALTER TABLE actor 
ADD COLUMN middle_name VARCHAR(50);
#3B
ALTER TABLE actor MODIFY middle_name BLOB;
#3C
ALTER TABLE actor DROP COLUMN middle_name;
#4A
SELECT last_name, COUNT(last_name) as "Count of Last Name" from actor
GROUP BY last_name;
#4B
SELECT last_name, COUNT(last_name) as "Count of Last Name" from actor 
GROUP BY last_name HAVING COUNT(last_name) >=2;
#4C
UPDATE actor
SET first_name = 'Harpo' 
where 'Groucho' and last_name = 'Williams';
#4D
UPDATE actor
SET first_name = 
CASE
WHEN first_name = 'Harpo'
THEN 'Groucho'
ELSE 'Mucho Groucho'
END
WHERE actor_id = 172;
#5A
SHOW CREATE TABLE sakila.address;
#6A
SELECT first_name, last_name, address from staff s
INNER JOIN address a ON s.address_id = a.address_id;
#6B
SELECT first_name, last_name, SUM(amount)
FROM staff s
INNER JOIN payment p ON s.staff_id = p.staff_id
GROUP BY p.staff_id ORDER BY last_name ASC;
#6C
SELECT title, COUNT(actor_id) from film f 
INNER JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY title;
#6D
SELECT title, COUNT(inventory_id) FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id WHERE title = "Hunchback Impossible";
#6E
SELECT last_name, first_name, SUM(amount) from payment p
INNER JOIN customer c on p.customer_id = c.customer_id
GROUP BY p.customer_id order by last_name ASC;
#7A
SELECT title from film where language_id in (select language_id from language where name = "English")
and (title LIKE "K%") OR (title LIKE "Q%");
#7B
SELECT last_name, first_name from actor 
where actor_id in (SELECT actor_id from film_actor where film_id in (SELECT film_id from film where title ="Alone Trip"));
#7C
SELECT country, last_name, first_name, email from country c
LEFT JOIN customer cu ON c.country_id = cu.customer_id where country = 'Canada';
#7D
SELECT title, category from film_list where category = 'Family';
#7E
SELECT i.film_id, f.title, count(r.inventory_id) from inventory i
INNER JOIN rental r on i.inventory_id = r.inventory_id
INNER JOIN film_text f on i.film_id = f.film_id
GROUP BY r.inventory_id order by count (r.inventory_id) DESC;
#7F
SELECT store.store_id, SUM(amount) from store
INNER JOIN staff on store.store_id = staff.store_id
INNER JOIN payment p on p.staff_id = staff.staff_id
GROUP BY store.store_id order by SUM(amount);
#7G
SELECT s.store_id, city, country from store s
INNER JOIN customer cu on s.store_id = cu.store_id
INNER JOIN staff st on s.store_id = st.store_id
INNER JOIN address a on cu.address_id = a.address_id
INNER JOIN city ci on a.city_id = ci.city_id
INNER JOIN country coun on ci.country_id = coun.country_id;
#7H
SELECT name, SUM(p.amount) from category c
INNER JOIN film_category fc INNER JOIN inventory i on i.film_id = fc.film_id
INNER JOIN rental r on r.inventory_id = i.inventory_id
INNER JOIN payment p
GROUP BY name
LIMIT 5;
#8A
SELECT name, SUM(p.amount) from category c
INNER JOIN film_category fc
INNER JOIN inventory i on i.film_id = fc.film_id
INNER JOIN rental r on r.inventory_id = i.inventory_id
INNER JOIN payment p
GROUP BY name
limit 5;
#8B
SELECT * from top_five_grossing_genres;
#8C
DROP VIEW top_five_grossing_genres;
