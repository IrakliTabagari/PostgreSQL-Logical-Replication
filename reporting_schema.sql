create table persons
(
    id        serial not null primary key,
    firstname varchar(250),
    lastname  varchar(250),
    birthdate date,
    gender    smallint
);

create table users
(
    id        serial  not null primary key,
    username  varchar(120),
    password  varchar(500),
    person_id integer not null references persons (id)
);

create table users_roles
(
    user_id integer references users (id),
    role_id integer references roles (id)
);

create table actions
(
    id   serial not null primary key,
    name varchar(255)
);

create table users_actions
(
    id          serial not null primary key,
    user_id     integer references users (id),
    action_id   integer references actions (id),
    action_date timestamp
);


