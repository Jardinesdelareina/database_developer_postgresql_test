-- Задание 1. Выведите для каждого покупателя его адрес, город и страну проживания.
select
    concat_ws(' ', customer.last_name, customer.first_name) as full_name,
    address.address,
    city.city,
    country.country
from customer
left join address on customer.address_id = address.address_id
left join city on address.city_id = city.city_id
left join country on city.country_id = country.country_id; 


-- Задание 2. С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
-- * Доработайте запрос и выведите только те магазины, у которых количество покупателей больше 300. 
--  Для решения используйте фильтрацию по сгруппированным строкам с функцией агрегации. 
-- * Доработайте запрос, добавив в него информацию о городе магазина, фамилии и имени продавца, 
-- который работает в нём.
select 
    s.store_id as store,
    count(c.customer_id) as count_of_customers,
    ci.city,
    concat_ws(' ', st.first_name, st.last_name) as name_of_staff
from store s
left join customer c on s.store_id = c.store_id
left join address ad on ad.address_id = s.address_id
left join city ci on ci.city_id = ad.city_id
right join staff st on s.manager_staff_id = st.staff_id
group by store, ci.city, name_of_staff
having count(c.customer_id) > 300;


-- Задание 3. Выведите топ-5 покупателей, которые взяли в аренду за всё время 
-- наибольшее количество фильмов
select 
    concat_ws(' ', c.last_name, c.first_name) as full_name,
    count(f.title) as count_film
from customer c
left join rental r on r.customer_id = c.customer_id
left join inventory i on r.inventory_id = i.inventory_id
left join film f on f.film_id = i.film_id
group by full_name
order by count_film desc
limit 5;


-- Задание 4. Посчитайте для каждого покупателя 4 аналитических показателя:
-- * количество взятых в аренду фильмов;
-- * общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа);
-- * минимальное значение платежа за аренду фильма;
-- * максимальное значение платежа за аренду фильма.
select 
    concat_ws(' ', c.last_name, c.first_name) as full_name,
    count(f.title) as count_film,
	round(sum(p.amount)) as sum_amount,
	min(p.amount) as min_amount,
	max(p.amount) as max_amount
from customer c
left join rental r on r.customer_id = c.customer_id
left join inventory i on r.inventory_id = i.inventory_id
left join film f on f.film_id = i.film_id
left join payment p on p.rental_id = r.rental_id
group by full_name;


-- Задание 5. Используя данные из таблицы городов, составьте одним запросом всевозможные 
-- пары городов так, чтобы в результате не было пар с одинаковыми названиями городов. 
-- Для решения необходимо использовать декартово произведение.
select distinct 
    c1.city as city_1, 
    c2.city as city_2
from city c1
cross join city c2
where c1.city_id <> c2.city_id;


-- Задание 6. Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) 
-- и дате возврата (поле return_date), вычислите для каждого покупателя среднее количество дней, 
-- за которые он возвращает фильмы.
select 
    concat_ws(' ', c.last_name, c.first_name) as full_name,
	avg(r.return_date - r.rental_date) as avg_days
from customer c
left join rental r on c.customer_id = r.customer_id
group by full_name;


-- Задание 7. Посчитайте для каждого фильма, сколько раз его брали в аренду, 
-- а также общую стоимость аренды фильма за всё время
select 
    f.title,
    count(r.rental_id) as count_rental,
	sum(p.amount) as sum_amount
from customer c
left join rental r on r.customer_id = c.customer_id
left join inventory i on r.inventory_id = i.inventory_id
left join film f on f.film_id = i.film_id
left join payment p on p.rental_id = r.rental_id
group by f.title;


-- Задание 8. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, 
-- которые ни разу не брали в аренду.
select 
    f.title,
    count(r.rental_id) as count_rental,
	sum(p.amount) as sum_amount
from customer c
left join rental r on r.customer_id = c.customer_id
left join inventory i on r.inventory_id = i.inventory_id
left join film f on f.film_id = i.film_id
left join payment p on p.rental_id = r.rental_id
where r.rental_id is null
group by f.title;


-- Задание 9. Посчитайте количество продаж, выполненных каждым продавцом. 
-- Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 7 300, 
-- то значение в колонке будет «Да», иначе должно быть значение «Нет».
select 
    concat_ws(' ', s.last_name, s.first_name) as full_name,
    count(r.rental_id) as count_rental,
    case when count(r.rental_id) > 7300 then 'Да' else 'Нет' end as Премия
from staff s
left join rental r on r.staff_id = s.staff_id
group by full_name;