-- Задание 1. Напишите SQL-запрос, который выводит всю информацию о фильмах 
-- со специальным атрибутом (поле special_features) равным “Behind the Scenes”.
select 
    title,
    description,
    release_year, 
    language_id,
    original_language_id,
    rental_duration,
    rental_rate,
    length,
    replacement_cost,
    rating,
    last_update,
    special_features,
    fulltext
from film
where 'Behind the Scenes' = any(special_features);


-- Задание 2. Напишите ещё 2 варианта поиска фильмов с атрибутом “Behind the Scenes”, 
-- используя другие функции или операторы языка SQL для поиска значения в массиве.
select 
    title,
    description,
    release_year, 
    language_id,
    original_language_id,
    rental_duration,
    rental_rate,
    length,
    replacement_cost,
    rating,
    last_update,
    special_features,
    fulltext
from film
where special_features @> array['Behind the Scenes'];

select 
    title,
    description,
    release_year, 
    language_id,
    original_language_id,
    rental_duration,
    rental_rate,
    length,
    replacement_cost,
    rating,
    last_update,
    special_features,
    fulltext
from film
where 'Behind the Scenes' in (select unnest(special_features));


-- Задание 3. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов 
-- со специальным атрибутом “Behind the Scenes”. 
-- Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в CTE.
with behing_the_scenes as (
    select 
        title
    from film
    where 'Behind the Scenes' = any(special_features)
)
select
    concat_ws(' ', c.last_name, c.first_name) as full_name,
    count(r.rental_id) as count_rental
from customer c
left join rental r on r.customer_id = c.customer_id
left join inventory i on i.inventory_id = r.inventory_id
left join film f on f.film_id = i.film_id
where f.title in (select title from behing_the_scenes)
group by full_name;


-- Задание 4. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов 
-- со специальным атрибутом “Behind the Scenes”.
-- Обязательное условие для выполнения задания: используйте запрос из задания 1, 
-- помещённый в подзапрос, который необходимо использовать для решения задания.
select
    concat_ws(' ', c.last_name, c.first_name) as full_name,
    count(r.rental_id) as count_rental
from customer c
left join rental r on r.customer_id = c.customer_id
left join inventory i on i.inventory_id = r.inventory_id
left join film f on f.film_id = i.film_id
where f.title in (select 
        title
    from film
    where 'Behind the Scenes' = any(special_features))
group by full_name;


-- Задание 5. Создайте материализованное представление с запросом из предыдущего задания 
-- и напишите запрос для обновления материализованного представления.
create materialized view behing_the_scenes as
select
    concat_ws(' ', c.last_name, c.first_name) as full_name,
    count(r.rental_id) as count_rental
from customer c
left join rental r on r.customer_id = c.customer_id
left join inventory i on i.inventory_id = r.inventory_id
left join film f on f.film_id = i.film_id
where f.title in (select 
        title
    from film
    where 'Behind the Scenes' = any(special_features))
group by full_name;

refresh materialized view behing_the_scenes;


-- Задание 6. С помощью explain analyze проведите анализ скорости выполнения запросов 
-- из предыдущих заданий и ответьте на вопросы:
-- * с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания, 
-- поиск значения в массиве происходит быстрее;
-- * какой вариант вычислений работает быстрее: с использованием CTE или с использованием подзапроса.

```
* При сравнении планов запросов первых двух заданий, самым медленным оказался запрос 
с `where 'Behind the Scenes' in (select unnest(special_features));`. unnest в подзапросе раскладывает 
массив по элементам и после этого происходит проверка, есть ли искомая строка среди имеющихся в массиве.
Манипуляции с in и массивами могут быть ресурсозатратными особенно если массивы ломятся
от количества значений. В первых двух случаях происходит прямая работа с массивами единоличными
операторами (= и @>). 

В учебных и демонстрационных примерах эти цифры несущественны (при первом вызове запроса результат
залетает в буферный кэш и при последующих вызовах результат может быть +\- одинаково быстрый) поэтому
определить, что сработало быстрее, = или @> вряд ли возможно. Разница в показателях начинает 
ощущаться на больших объемах данных.

Что касается 3 и 4 задания: в третьем задании используется CTE, результаты которого выполняются 
в каждой строке основного запроса. В то время как в 4-м задании условие применено сразу ко всей таблице
film. Поэтому в данном случае вариант с подзапросом оказался производительнее.

materialized view при создании сохраняет данные на диске, затем эти данные без каких-либо препятствий
используются в работе. У этой скорости есть цена - данные на диске нужно периодически обновлять, 
чтобы поддерживать их актуальность. Но с этим прекрасно справляются настроенные триггеры или
постгресовый cron. Так что если сравнивать запросы из 3, 4 и 5 заданий, то обращение к materialized view
однозначно побеждает:

explain analyze select * from behing_the_scenes;
Planning Time: 0.133 ms
Execution Time: 0.090 ms
(3 rows)


* Если сравнивать CTE с подзапросами из данных заданий быстрее оказался вариант с подзапросом:

CTE
Planning Time: 0.955 ms
Execution Time: 147.622 ms
(24 rows)

Подзапрос
Planning Time: 4.812 ms
Execution Time: 33.584 ms

Но это не значит, что CTE априори медленнее подзапросов. CTE выполняются только один раз в начале, 
и его результаты затем используются повторно в запросе. Подзапросы же вычисляются каждый раз 
при обращении к ним. Если запрос сложный, в котором требуется многократное использование данных 
из определенного набора, оптимальным решением будет CTE. Если запрос простой и, к тому же, 
не возвращает большой объем данных, то подзапрос будет предпочтительнее.
```


-- Задание 7. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.
with ranked_payments AS (
    select
        p.staff_id,
        p.payment_id,
        p.amount,
        p.payment_date, 
        row_number() over (partition by p.staff_id order by p.payment_date) as rn
    from payment p
)
select
    s.staff_id,
    p.amount AS first_payment_amount,
    p.payment_date AS first_payment_date
from staff s
left join ranked_payments p on s.staff_id = p.staff_id
where p.rn = 1


-- Задание 8. Для каждого магазина определите и выведите одним SQL-запросом следующие 
-- аналитические показатели:
-- * день, в который арендовали больше всего фильмов (в формате год-месяц-день);
-- * количество фильмов, взятых в аренду в этот день;
-- * день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
-- * сумму продажи в этот день.
with rentals_count AS (
    select 
        store_id, 
        rental_date, 
        count(rental_id) AS rental_count,
		sum(amount) as amount,
        row_number() over (partition by store_id order by count(rental_id) desc) as rn_count_rental,
		row_number() over (partition by store_id order by sum(amount)) as rn_sum_amount
    from (
        select
            s.store_id AS store_id,
            r.rental_id AS rental_id,
            r.rental_date::date AS rental_date,
	    p.amount as amount
        from rental r
        left join inventory i on i.inventory_id = r.inventory_id
        left join store s on s.store_id = i.store_id
        left join payment p on p.rental_id = r.rental_id
        group by s.store_id, r.rental_date, r.rental_id, p.amount
        order by s.store_id
    ) as sq
    group by store_id, rental_date
)
select store_id, rental_date, rental_count,
	(select rental_date from rentals_count rc2 
    where rc2.store_id = rc1.store_id and rn_sum_amount = 1) as date_min_sum_count,
	(select amount from rentals_count rc2 
    where rc2.store_id = rc1.store_id and rn_sum_amount = 1) as min_sum_count
from rentals_count rc1
where rn_count_rental = 1
order by store_id;
