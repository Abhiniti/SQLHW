use sakila;
-- 1a. Display the first and last names of all actors from the table `actor`.
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select concat(first_name, ' ', last_name) as 'Actor Name' from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
select * from actor where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select last_name, first_name from actor where last_name like '%LI%';

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
alter table actor
add description BLOB;
select * from actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table actor
drop column description;
select * from actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name) from actor group by last_name having count(last_name) > 1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
select * from actor where first_name = 'Groucho' and last_name = 'Williams';
select * from actor where actor_id in (select actor_id from actor where first_name = 'Groucho' and last_name = 'Williams');
select actor_id from actor where first_name = 'Groucho' and last_name = 'Williams';
update actor
set first_name = 'HARPO' 
where actor_id = 172;
select * from actor where actor_id = 172;

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
select * from actor where first_name = 'HARPO';
select actor_id from actor where first_name = 'HARPO';
update actor
set first_name = 'GROUCHO'
where actor_id in (select actor_id where first_name = 'HARPO');
select * from actor where actor_id in (select actor_id where last_name = 'WILLIAMS');

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='address';
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select * from staff;
select * from address;
select address_id from staff;
select * from address where address_id in (select address_id from staff);
select staff.first_name, staff.last_name, address.address
from staff
inner join address
on staff.address_id = address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select * from staff;
select * from payment;
select staff_id, sum(amount) as `Total Amount` from payment
group by staff_id;
select s.first_name, s.last_name, p.`Total Amount`
from (select staff_id, sum(amount) as `Total Amount` from payment group by staff_id) p
inner join staff s
on p.staff_id=s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select * from film;
select * from film_actor;
select film_id, count(actor_id) as `Number of Actors` from film_actor
group by film_id;
select f.title, a.`Number of Actors`
from (select film_id, count(actor_id) as `Number of Actors` from film_actor group by film_id) a
inner join film f
on f.film_id=a.film_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select * from inventory;
select * from film where title = 'Hunchback Impossible';
select count(*) as 'Copies of Hunchback Impossible' from inventory where film_id in (select film_id from film where title = 'Hunchback Impossible');

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select * from payment;
select * from customer;
select customer_id, sum(amount) as `Total Amount Paid` from payment
group by customer_id;
select c.first_name, c.last_name, p.`Total Amount Paid`
from (select customer_id, sum(amount) as `Total Amount Paid` from payment group by customer_id) p
inner join customer c
on c.customer_id=p.customer_id
order by c.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select * from film;
select * from language;
select language_id from language where name = 'English';
select * from film where title like'K%' or title like 'Q%' and language_id in (select language_id from language where name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select film_id from film where title='Alone Trip';
select actor_id from film_actor where film_id in (select film_id from film where title='Alone Trip');
select first_name, last_name from actor where actor_id in (select actor_id from film_actor where film_id in (select film_id from film where title='Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select * from country where country='Canada';
select * from city;
-- first join: city to country
select c.city_id, o.country_id
from city c
inner join (select country_id from country where country='Canada') o
on c.country_id=o.country_id;
-- second join: address to first join
select a.address_id, b.city_id, b.country_id
from address a
inner join (select c.city_id, o.country_id
from city c
inner join (select country_id from country where country='Canada') o
on c.country_id=o.country_id) b
on a.city_id=b.city_id;
-- third join: customer to second join
select c.first_name, c.last_name, c.email
from customer c
inner join (select a.address_id, b.city_id, b.country_id
from address a
inner join (select c.city_id, o.country_id
from city c
inner join (select country_id from country where country='Canada') o
on c.country_id=o.country_id) b
on a.city_id=b.city_id) d
on d.address_id=c.address_id;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select category_id from category where name = 'Family';
select film_id from film_category where category_id in (select category_id from category where name = 'Family');
select title as 'Family Films' from film where film_id in (select film_id from film_category where category_id in (select category_id from category where name = 'Family'));

-- 7e. Display the most frequently rented movies in descending order.
select rental_id from rental
order by rental_date DESC;
select * from inventory;
-- first join: rental to inventory
select a.inventory_id, a.film_id, b.rental_id
from inventory a
inner join (select * from rental) b
on a.inventory_id=b.inventory_id;
-- find frequency
select c.inventory_id, c.film_id, count(*) as `Number of Rentals`
from (select a.inventory_id, a.film_id, b.rental_id
from inventory a
inner join (select * from rental) b
on a.inventory_id=b.inventory_id) c
group by inventory_id
order by `Number of Rentals` DESC;
-- join to film
select * from film;
select f.title, g.`Number of Rentals`
from film f
inner join (select c.inventory_id, c.film_id, count(*) as `Number of Rentals`
from (select a.inventory_id, a.film_id, b.rental_id
from inventory a
inner join (select * from rental) b
on a.inventory_id=b.inventory_id) c
group by inventory_id) g
on g.film_id=f.film_id
order by `Number of Rentals` DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select * from store;
select * from customer;
select * from payment;
-- first join
select a.amount, b.customer_id
from payment a
inner join customer b
on a.customer_id=b.customer_id;
-- store id to customer id
select c.store_id, sum(d.`Amount`) as 'Total Store Payment'
from customer c
inner join (select a.amount as `Amount`, b.customer_id
from payment a
inner join customer b
on a.customer_id=b.customer_id) d
on c.customer_id=d.customer_id
group by store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select store_id, address_id from store;
select * from address;
-- store id to city_id
select a.store_id, b.city_id
from store a
inner join address b
on a.address_id=b.address_id;
-- cityid to city
select * from city;
select a.store_id, b.country_id, b.city
from city b
inner join (select a.store_id, b.city_id
from store a
inner join address b
on a.address_id=b.address_id) a
on a.city_id=b.city_id;
-- city id to country
select * from country;
select b.store_id, a.country, b.city
from country a
inner join (select a.store_id, b.country_id, b.city
from city b
inner join (select a.store_id, b.city_id
from store a
inner join address b
on a.address_id=b.address_id) a
on a.city_id=b.city_id) b
on a.country_id=b.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select * from payment;
select * from rental;
select * from inventory;
select * from film_category;
select * from category;

-- first join: payment to rental
select a.amount, b.rental_id
from payment a
inner join rental b
on a.rental_id=b.rental_id;
-- 2nd join: rental to inventory
select a.`Amount`, b.inventory_id, b.film_id
from inventory b
inner join (select a.amount as `Amount`, b.rental_id, b.inventory_id
from payment a
inner join rental b
on a.rental_id=b.rental_id) a
on a.inventory_id=b.inventory_id;
-- 3rd join: inventory to film_category
select a.`Amount`, b.film_id, b.category_id
from film_category b
inner join (select a.`Amount`, b.inventory_id, b.film_id
from inventory b
inner join (select a.amount as `Amount`, b.rental_id, b.inventory_id
from payment a
inner join rental b
on a.rental_id=b.rental_id) a
on a.inventory_id=b.inventory_id) a
on a.film_id=b.film_id;
-- 4th join: film category to category
select b.name, sum(a.`Amount`) as `Category Total`
from category b
inner join (select a.`Amount`, b.film_id, b.category_id
from film_category b
inner join (select a.`Amount`, b.inventory_id, b.film_id
from inventory b
inner join (select a.amount as `Amount`, b.rental_id, b.inventory_id
from payment a
inner join rental b
on a.rental_id=b.rental_id) a
on a.inventory_id=b.inventory_id) a
on a.film_id=b.film_id) a
on a.category_id=b.category_id
group by name
order by `Category Total` DESC
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view `top_five_genres` as select b.name, sum(a.`Amount`) as `Category Total`
from category b
inner join (select a.`Amount`, b.film_id, b.category_id
from film_category b
inner join (select a.`Amount`, b.inventory_id, b.film_id
from inventory b
inner join (select a.amount as `Amount`, b.rental_id, b.inventory_id
from payment a
inner join rental b
on a.rental_id=b.rental_id) a
on a.inventory_id=b.inventory_id) a
on a.film_id=b.film_id) a
on a.category_id=b.category_id
group by name
order by `Category Total` DESC
limit 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM sakila.top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view `top_five_genres`;