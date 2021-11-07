-- Установим расширение, нужное для UUID
create extension "uuid-ossp";

-- Создадим enum валют
create type t_currency as enum ('RUR','EUR','USD');

-- Создадим партиционированную таблицу
create table bills(
    id bigserial, -- автоинкрементный id
    uid uuid default uuid_generate_v4(), -- автогенерируемый uuid вида de5d09be-acfe-42f1-940c-f90db3c43a31
    create_dtime timestamptz default now(), -- дата счета, по ней партиционируем
    amount float8 not null, -- сумма счета
    currency t_currency not null, -- валюта счета, тип enum
    merchant_payload jsonb -- неструктурированный json от продавца
) partition by range (create_dtime); -- партиционируем по диапазону дат

-- Ограничения уникальности должны включать ключ партиционирования, чтобы обеспечить сквозную уникальность для всех партиций
-- Добавим первичный ключ
alter table bills add primary key (id, create_dtime);
-- Добавим ограничение уникальности uid
create unique index on bills(uid, create_dtime);

create index on bills(currency);

-- Создадим партиции. Руками неудобно, правда?
-- А еще можно забыть...
create table bills_p202101 partition of bills for values from ('2021-01-01') to ('2021-02-01');
create table bills_p202102 partition of bills for values from ('2021-02-01') to ('2021-03-01');
create table bills_p202103 partition of bills for values from ('2021-03-01') to ('2021-04-01');
create table bills_p202104 partition of bills for values from ('2021-04-01') to ('2021-05-01');
create table bills_p202105 partition of bills for values from ('2021-05-01') to ('2021-06-01');
create table bills_p202106 partition of bills for values from ('2021-06-01') to ('2021-07-01');
create table bills_p202107 partition of bills for values from ('2021-07-01') to ('2021-08-01');
create table bills_p202108 partition of bills for values from ('2021-08-01') to ('2021-09-01');
create table bills_p202109 partition of bills for values from ('2021-09-01') to ('2021-10-01');
create table bills_p202110 partition of bills for values from ('2021-10-01') to ('2021-11-01');
create table bills_p202111 partition of bills for values from ('2021-11-01') to ('2021-12-01');
create table bills_p202112 partition of bills for values from ('2021-12-01') to ('2022-01-01');

-- Заполним таблицу данными
insert into bills(create_dtime, amount, currency, merchant_payload)
select generate_series as timestamp, 100, 'RUR', ('{"orderId": "123"}')::jsonb
from generate_series('2021-01-01', '2021-12-31', interval '1 hour');

-- Соберем статистику после заполнения таблицы, чтобы планировщик строил корректные планы. Обычно вам это не нужно.
analyze bills;