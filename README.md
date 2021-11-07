### Домашнее задание по разработке БД PostgreSQL

1. Соберите докер-образ БД: `docker build -t my_db .`
2. Запустите докер-контейнер БД: `docker run --name my_db -p 5433:5432 my_db`
3. Откройте соединение в БД любым удобным вам инструментом
4. Ответьте на следующие вопросы в тесте:
5. Посмотрите план запроса `select * from bills`. Сколько партиций попало в план?
6. Посмотрите план запроса `select * from bills where create_dtime >= '2021-10-01' and create_dtime < '2021-12-01'`. Сколько партиций попало в план?
7. Посмотрите план запроса `select * from bills where currency = 'USD'`. Индекс по currency используется? Если нет, то почему?
8. Посмотрите план запроса `select * from bills where currency = 'RUR'`. Индекс по currency используется? Если нет, то почему?
9. Если предположить, что значения currency равномерно распределены, есть ли смысл в индексе по currency? Если нет, то почему?

#### Задание со звездочкой - смотрим блокировки
1. Запустите параллельно три сессии
2. Установите в вашем клиенте manual commit mode. Transaction Isolation Level оставьте Read Commited.
3. В одной сессии выполните, но не коммитьте 
`
   insert into bills(uid, create_dtime, amount, currency)
   select 'de5d09be-acfe-42f1-940c-f90db3c43a33', '2021-01-01', 100, 'RUR');
   `
4. Во второй сессии запустите этот же запрос. Увидите, что он "повис"
5. В третьей сессии выполните запрос:
`
   select * from pg_stat_activity
   join pg_locks pl on pg_stat_activity.pid = pl.pid
   where pg_stat_activity.wait_event_type = 'Lock'
   and not transactionid is null
   `
6. На выбор: закоммитьте запрос в первой сессии или в свободной сессии вызовите `select pg_cancel_backend(pid первой сессии)`