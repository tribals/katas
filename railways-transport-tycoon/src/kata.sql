-- Notes:
-- * all `timestamp`s in UTC;
-- * other common constraints assumed, but ommited;
-- Essential tables are `tickets` and `orders`.

create table identities (
    id serial primary key,
    type integer, -- Note: enum, eg. 0 - passport
    description jsonb
);

create table passangers (
    id serial primary key,
    -- Note: no separate colums for first/last/etc names for the sake of simplicity
    -- See: http://archive.today/PrteO
    full_name varchar(1024),
    identity_id integer references identities (id),
    birth_date timestamp,
    gender int -- Note: enum, eg. 0 - male
);

create table itineraries (
    id serial primary key
);

-- Note: geographical location, eg. city
create table locations (
    id serial primary key,
    name varchar(1024)
);

create table stations (
    id serial primary key,
    location_id integer references locations (id),
    name varchar(1024)
);

create table itinerary_stops (
    id serial primary key, -- Note: surrogate key
    itinerary_id integer references itineraries (id),
    n integer,
    station_id integer references stations (id),
    unique (n, itinerary_id, station_id)
);

create table reservations (
    id serial primary key
);

create table customers (
    id serial primary key,
    name varchar(1024)
    -- any other information needed for providing service for customers
);

create table payments (
    id serial primary key
    -- any other information related to payments, mostly depends on payment provider
);

create table coupons (
    id serial primary key
    -- a handful of marketing :D
);

create table fares (
    id serial primary key,
    rate decimal
);

create table orders (
    id serial primary key,
    price decimal,
    customer_id integer references customers (id),
    payment_id integer references payments (id),
    paid_at timestamp,
    coupon_id integer references coupons (id),
    fare_id integer references fares (id)
);

create table tickets (
    id serial primary key,
    passanger_id integer references passangers (id),
    itinerary_id integer references itineraries (id),
    departure_at timestamp,
    departure_stop_id integer references itinerary_stops (id),
    arrival_at timestamp,
    arrival_stop_id integer references itinerary_stops (id),
    reserved_at timestamp,
    reservation_id integer references reservations (id),
    ordered_at timestamp,
    order_id integer references orders (id),
    boarded_at timestamp
);

-- Let's try it
insert into itineraries values (42);

insert into locations (name) values ('Moscow') returning id;
insert into stations (location_id, name) values (1, 'Moscow Leningradsky');

insert into locations (name) values ('St.-Petersburg') returning id;
insert into stations (location_id, name) values (2, 'St.-Petersburg-Glavny');

insert into locations (name) values ('Vyshny Volochyok') returning id;
insert into stations (location_id, name) values (3, 'Vyshny Volochyok');

insert into itinerary_stops (itinerary_id, n, station_id) values (42, 0, 1);
insert into itinerary_stops (itinerary_id, n, station_id) values (42, 1, 3);
insert into itinerary_stops (itinerary_id, n, station_id) values (42, 2, 2);

-- From Moscow to St.-Petersburg!

select
    I.id iterinary,
    s.id stop_id,
    s.n stop_number,
    st.id station_id,
    st.name station_name,
    L.id location_id,
    L.name location_name
from
    itineraries I
join
    itinerary_stops s
on
    s.itinerary_id = I.id
join
    stations st
on
    s.station_id = st.id
join
    locations L
on
    st.location_id = L.id
where
    I.id = 42
order by
    s.n;

-- Note:
--   Let's add another station, say Moscow Kazansky
--   Need new itinerary, though
--   Update: no more!

insert into stations (location_id, name) values (1, 'Moscow Kazansky');

-- Let's add new itinerary, not station!

insert into locations (name) values ('Kazan') returning id;
insert into stations (location_id, name) values (4, 'Kazan-Passazhirskaya');

insert into itineraries values (73);

insert into itinerary_stops (itinerary_id, n, station_id) values (73, 0, 2);
insert into itinerary_stops (itinerary_id, n, station_id) values (73, 1, 4);
insert into itinerary_stops (itinerary_id, n, station_id) values (73, 2, 5);

-- From St.-Petersburg to Kazan!

select
    I.id iterinary,
    s.id stop_id,
    s.n stop_number,
    st.id station_id,
    st.name station_name,
    L.id location_id,
    L.name location_name
from
    itineraries I
join
    itinerary_stops s
on
    s.itinerary_id = I.id
join
    stations st
on
    s.station_id = st.id
join
    locations L
on
    st.location_id = L.id
where
    I.id = 73
order by
    s.n;
