-- Задание 1. Сделайте запрос к таблице payment и с помощью оконных функций добавьте 
-- вычисляемые колонки согласно условиям:
-- * Пронумеруйте все платежи от 1 до N по дате
-- * Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
-- * Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, 
-- сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
-- * Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, 
-- чтобы платежи с одинаковым значением имели одинаковое значение номера.
-- Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.
select 
    customer_id,
    payment_date,
    row_number() over (order by payment_date) as payment_total_number,
    row_number() over (
        partition by customer_id 
        order by payment_date
    ) as payments_total,
    sum(amount) over (
        partition by customer_id 
        order by payment_date, amount
        rows between unbounded preceding and current row
    ) as payments_sum,
	dense_rank() over (
        partition by customer_id 
        order by amount desc, payment_date
    ) as payments_dense
from payment
order by customer_id;


-- Задание 2. С помощью оконной функции выведите для каждого покупателя стоимость платежа 
-- и стоимость платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.
select 
    customer_id,
    payment_date,
    amount,
    lag(amount, 1, 0.0) over (partition by customer_id order by payment_date) as prev_amount
from payment;


-- Задание 3. С помощью оконной функции определите, на сколько каждый следующий платеж 
-- покупателя больше или меньше текущего.
with prev_values as (
	select 
		customer_id, 
		payment_date, 
		amount,
		lag(amount, 1, 0.0) over (partition by customer_id order by payment_date) as prev_amount
	from payment
)
select 
    customer_id,
    amount,
    --prev_amount,
    --(case when (amount - prev_amount) > 0 then 'Больше' else 'Меньше' end) as difference,
	(amount - prev_amount) as diff_result
from prev_values;


-- Задание 4. С помощью оконной функции для каждого покупателя выведите данные 
-- о его последней оплате аренды.
with row_number_payment as (
	select 
        customer_id,
        payment_id,
        amount,
        payment_date,
        row_number() over (partition by customer_id order by payment_date desc) as rn
    from payment
)
select 
    customer_id,
    payment_id,
    amount,
    payment_date
from row_number_payment
where rn = 1;


-- Задание 5. С помощью оконной функции выведите для каждого сотрудника сумму продаж 
-- за август 2005 года с нарастающим итогом по каждому сотруднику 
-- и по каждой дате продажи (без учёта времени) с сортировкой по дате.
select distinct
    staff_id,
    payment_date::date as date,
    sum(amount) over (partition by staff_id, payment_date::date) as total_sales
from payment
where
    extract(year from payment_date) = 2005
    and extract(month from payment_date) = 8
order by staff_id, total_sales;


-- Задание 6. 20 августа 2005 года в магазинах проходила акция: 
-- покупатель каждого сотого платежа получал дополнительную скидку на следующую аренду. 
-- С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.
with payments_2005_08_20 as (
	select
    	customer_id,
    	row_number() over (order by payment_id) as rn
	from payment
	where payment_date::date = '2005-08-20'
)
select
    customer_id,
    rn
from payments_2005_08_20
where rn % 100 = 0;


-- Задание 7. Для каждой страны определите и выведите одним SQL-запросом покупателей, 
-- которые попадают под условия: 
-- * покупатель, арендовавший наибольшее количество фильмов; 
-- * покупатель, арендовавший фильмов на самую большую сумму; 
-- * покупатель, который последним арендовал фильм.
select
	country,
	full_name,
	count_rental,
	sum_amount,
	date_last_rental
from (select
        concat_ws(' ', c.last_name, c.first_name) as full_name,
		co.country,
		count(r.rental_id) as count_rental,
		sum(p.amount) as sum_amount,
		max(r.rental_date) as date_last_rental,
        row_number() over(partition by co.country order by count(r.rental_id) desc) as rn_rental_max,
		row_number() over(partition by co.country order by sum(p.amount) desc) as rn_rental_sum,
		row_number() over(partition by co.country order by max(r.rental_date)) as rn_rental_date
    from customer c
    left join address a on c.address_id = a.address_id
    left join city ci on a.city_id = ci.city_id
    left join country co on ci.country_id = co.country_id
    left join rental r on c.customer_id = r.customer_id
	left join payment p on c.customer_id = p.customer_id
    group by co.country, c.customer_id) as max_count_rental
where rn_rental_max = 1 and rn_rental_sum = 1 and rn_rental_date = 1;