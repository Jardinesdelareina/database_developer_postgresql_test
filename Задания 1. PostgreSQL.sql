-- Задание 1. Выведите уникальные названия городов из таблицы городов.
select distinct city from city;


-- Задание 2. Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города, 
-- названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.
select distinct city 
from city
where city like 'L%%a' and city not like '% %';


-- Задание 3. Получите из таблицы платежей за прокат фильмов информацию по платежам, 
-- которые выполнялись в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно 
-- и стоимость которых превышает 1.00. Платежи нужно отсортировать по дате платежа.
select 
    payment_id,
    customer_id,
    staff_id,
    rental_id,
    amount,
    payment_date
from payment
where 
    payment_date between '2005-06-17' and '2005-06-20' 
    and amount > 1.00
order by payment_date;


-- Задание 4. Выведите информацию о 10-ти последних платежах за прокат фильмов.
select 
    payment_id,
    customer_id,
    staff_id,
    rental_id,
    amount,
    payment_date
from payment
order by payment_date desc
limit 10;


-- Задание 5. Выведите следующую информацию по покупателям:
-- * Фамилия и имя (в одной колонке через пробел)
-- * Электронная почта
-- * Длину значения поля email
-- * Дату последнего обновления записи о покупателе (без времени)
-- Каждой колонке задайте наименование на русском языке.
select
    concat_ws(' ', last_name, first_name) as Полное_имя,
    email as Электронная_почта,
    length(email) as Длина_электронной_почты,
    last_update as Последнее_обновление_информации
from customer;


-- Задание 6. Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE. 
-- Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.
select 
    lower(concat_ws(' ', last_name, first_name)) as full_name,
    activebool
from customer
where first_name IN ('KELLY', 'WILLIE') and activebool = True;


-- Задание 7. Выведите одним запросом информацию о фильмах, у которых рейтинг “R” и стоимость 
-- аренды указана от 0.00 до 3.00 включительно, а также фильмы c рейтингом “PG-13” и стоимостью 
-- аренды больше или равной 4.00.
select
    film_id,
    title,
    rating,
    rental_rate
from film
where rating = 'R' and rental_rate <= 3.00
union
select
    film_id,
    title,
    rating,
    rental_rate
from film
where rating = 'PG-13' and rental_rate >= 4.00;


-- Задание 8. Получите информацию о трёх фильмах с самым длинным описанием фильма.
select 
    title,
    length(description) length_description
from film
order by length_description desc
limit 3;


-- Задание 9. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
-- * в первой колонке должно быть значение, указанное до @,
-- * во второй колонке должно быть значение, указанное после @
select 
    split_part(email, '@', 1) as email_before,
    split_part(email, '@', 2) as email_after
from customer;


-- Задание 10. Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
-- первая буква должна быть заглавной, остальные строчными.
select 
	upper(substring(split_part(email, '@', 1), 1, 1)) || lower(substring(split_part(email, '@', 1) from 2)) AS email_before,
	upper(substring(split_part(email, '@', 2), 1, 1)) || lower(substring(split_part(email, '@', 2) from 2)) AS email_after
from customer;