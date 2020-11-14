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


create extension "uuid-ossp";


create function random_between(low integer, high integer) returns integer
    strict
    language plpgsql
as
$$
BEGIN
   RETURN floor(random()* (high-low + 1) + low);
END;
$$;

alter function random_between(integer, integer) owner to postgres;

create function random_string() returns character varying
    strict
    language plpgsql
as
$$
DECLARE
    _str VARCHAR(255) := '';
    _str_start INTEGER := 0;
    _str_end INTEGER := 0;
BEGIN
    _str := REPLACE(uuid_generate_v1 ()::TEXT, '-','');
    _str_start := random_between(1,LENGTH(_str) - 3);
    _str_end := random_between(_str_start,LENGTH(_str));
   RETURN SUBSTRING(_str, _str_start, _str_end);
END;
$$;

alter function random_string() owner to postgres;

create function random_timestamp(_from_date timestamp without time zone, _to_date timestamp without time zone) returns timestamp without time zone
    strict
    language plpgsql
as
$$
BEGIN
   RETURN _from_date + random() * ( _to_date - _from_date);
END;
$$;

alter function random_timestamp(timestamp, timestamp) owner to postgres;




create procedure pr_delete_actions(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _actions_ids INTEGER[] := (SELECT ARRAY_AGG(DISTINCT a.id)
                                FROM actions a
                                WHERE a.id NOT IN (SELECT ua.user_id FROM users_actions ua WHERE ua.user_id IS NOT NULL)
                            );
    _deleted_id INTEGER := 0;
BEGIN

 WHILE NOW() < _to_date LOOP
     DELETE FROM actions a
     WHERE a.id = _actions_ids[random_between(0, array_length(_actions_ids, 1))]
     RETURNING id INTO _deleted_id
     ;
     COMMIT;
     RAISE NOTICE 'delete_action - id=%', _deleted_id;
     PERFORM pg_sleep(_sleep_seconds);
 END LOOP;

END;
$$;

alter procedure pr_delete_actions(double precision, integer) owner to postgres;

create procedure pr_delete_roles(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _roles_ids INTEGER[] := (SELECT ARRAY_AGG(DISTINCT r.id)
                                FROM roles r
                                WHERE r.id NOT IN (SELECT ur.role_id FROM users_roles ur WHERE ur.role_id IS NOT NULL)
                            );
    _deleted_id INTEGER := 0;
BEGIN

 WHILE NOW() < _to_date LOOP
     DELETE FROM roles r
     WHERE r.id = _roles_ids[random_between(0, array_length(_roles_ids, 1))]
     RETURNING id INTO _deleted_id
     ;
     COMMIT;
     RAISE NOTICE 'delete_roles - id=%', _deleted_id;
     PERFORM pg_sleep(_sleep_seconds);
 END LOOP;

END;
$$;

alter procedure pr_delete_roles(double precision, integer) owner to postgres;

create procedure pr_delete_users(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _users_ids INTEGER[] := (SELECT ARRAY_AGG( DISTINCT u.id)
                                FROM users u
                                WHERE u.id NOT IN (SELECT ur.user_id FROM users_roles ur WHERE ur.user_id IS NOT NULL)
                                  AND u.id NOT IN (SELECT ua.user_id FROM users_actions ua WHERE ua.user_id IS NOT NULL));
    _deleted_id INTEGER := 0;
BEGIN

 WHILE NOW() < _to_date LOOP
     DELETE FROM users u
     WHERE u.id = _users_ids[random_between(0, array_length(_users_ids, 1))]
     RETURNING id INTO _deleted_id
     ;
     COMMIT;
     RAISE NOTICE 'delete_users - id=%', _deleted_id;
     PERFORM pg_sleep(_sleep_seconds);
 END LOOP;

END;
$$;

alter procedure pr_delete_users(double precision, integer) owner to postgres;

create procedure pr_delete_users_actions(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _users_actions_ids INTEGER[] := (SELECT ARRAY_AGG(a.id)
                                        FROM users_actions a
                                    );
    _deleted_id INTEGER := 0;
BEGIN

 WHILE NOW() < _to_date LOOP
     DELETE FROM users_actions usact
     WHERE usact.id = _users_actions_ids[random_between(0, array_length(_users_actions_ids, 1))]
     RETURNING id INTO _deleted_id
     ;
     COMMIT;
     RAISE NOTICE 'delete_users_actions - id=%', _deleted_id;
     PERFORM pg_sleep(_sleep_seconds);
 END LOOP;

END;
$$;

alter procedure pr_delete_users_actions(double precision, integer) owner to postgres;

create procedure pr_delete_users_roles(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _user_ids INTEGER[] := (SELECT ARRAY_AGG(DISTINCT u.user_id)
                                FROM users_roles u
                            );
    _user_id INTEGER := (SELECT _user_ids[random_between(0, array_length(_user_ids, 1))]);
    _role_ids INTEGER[] := (SELECT ARRAY_AGG(DISTINCT u.role_id)
                                FROM users_roles u
                                WHERE u.user_id = _user_id
                            );
    _role_id INTEGER := (SELECT _role_ids[random_between(0, array_length(_role_ids, 1))]);
BEGIN

 WHILE NOW() < _to_date LOOP
     DELETE FROM users_roles ur
     WHERE ur.user_id = _user_id
       AND ur.role_id = _role_id
     ;
     COMMIT;
     RAISE NOTICE 'delete_users_roles - user_id=%, role_id=%', _user_id, _role_id;
     PERFORM pg_sleep(_sleep_seconds);
 END LOOP;

END;
$$;

alter procedure pr_delete_users_roles(double precision, integer) owner to postgres;

create procedure pr_inserts_actions(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _inserted_id INTEGER := 0;
BEGIN

    WHILE NOW() < _to_date LOOP
        INSERT INTO actions (name)
        VALUES
        (random_string())
        RETURNING id INTO _inserted_id
        ;
        COMMIT;
        RAISE NOTICE 'inserts_actions - id=%', _inserted_id;
        PERFORM pg_sleep(_sleep_seconds);
    END LOOP;

END;
$$;

alter procedure pr_inserts_actions(double precision, integer) owner to postgres;

create procedure pr_inserts_persons(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _inserted_id INTEGER := 0;
BEGIN

    WHILE NOW() < _to_date LOOP

        INSERT INTO persons (firstname, lastname, birthdate, gender)
        VALUES
        (random_string(),
         random_string(),
         random_timestamp('1940-01-01'::TIMESTAMP WITHOUT TIME ZONE, '2019-01-01'::TIMESTAMP WITHOUT TIME ZONE),
         random_between(1, 2)
         )
        RETURNING id INTO _inserted_id
         ;
        COMMIT;
        RAISE NOTICE 'inserts_persons - id=%', _inserted_id;
        PERFORM pg_sleep(_sleep_seconds);
    END LOOP;

END;
$$;

alter procedure pr_inserts_persons(double precision, integer) owner to postgres;

create procedure pr_inserts_roles(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _inserted_id INTEGER := 0;
BEGIN

    WHILE NOW() < _to_date LOOP
        INSERT INTO roles ( name)
        VALUES
        (random_string())
        RETURNING id INTO _inserted_id
        ;
        COMMIT;
        RAISE NOTICE 'inserts_roles - id=%', _inserted_id;
        PERFORM pg_sleep(_sleep_seconds);
    END LOOP;

END;
$$;

alter procedure pr_inserts_roles(double precision, integer) owner to postgres;

create procedure pr_inserts_users(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _persons_ids INTEGER[] := (SELECT ARRAY_AGG(DISTINCT p.id)
                                FROM persons p
                            );
    _person_id INTEGER := (SELECT _persons_ids[random_between(0, array_length(_persons_ids, 1))]);
    _inserted_id INTEGER := 0;
BEGIN

    WHILE NOW() < _to_date LOOP

        INSERT INTO users (username, password, person_id)
        VALUES
        (random_string(),
         random_string(),
         _person_id
         )
        RETURNING id INTO _inserted_id
        ;
        COMMIT;
        RAISE NOTICE 'inserts_users - id=%', _inserted_id;
        PERFORM pg_sleep(_sleep_seconds);
    END LOOP;

END;
$$;

alter procedure pr_inserts_users(double precision, integer) owner to postgres;

create procedure pr_inserts_users_actions(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _users_ids INTEGER[] := (SELECT ARRAY_AGG(DISTINCT u.id)
                                FROM users u
                            );
    _user_id INTEGER := (SELECT _users_ids[random_between(0, array_length(_users_ids, 1))]);
    _actions_ids INTEGER[] := (SELECT ARRAY_AGG(DISTINCT a.id)
                                FROM actions a
                            );
    _action_id INTEGER := (SELECT _actions_ids[random_between(0, array_length(_actions_ids, 1))]);
    _inserted_id INTEGER := 0;
BEGIN

    WHILE NOW() < _to_date LOOP
        INSERT INTO users_actions ( user_id, action_id, action_date)
        VALUES
        (_user_id,
         _action_id,
         NOW()
        )
        RETURNING id INTO _inserted_id
        ;
        COMMIT;
        RAISE NOTICE 'inserts_users_actions - id=%', _inserted_id;
        PERFORM pg_sleep(_sleep_seconds);
    END LOOP;

END;
$$;

alter procedure pr_inserts_users_actions(double precision, integer) owner to postgres;

create procedure pr_inserts_users_roles(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _users_ids INTEGER[] := (SELECT ARRAY_AGG(DISTINCT u.id)
                                FROM users u
                            );
    _user_id INTEGER := (SELECT _users_ids[random_between(0, array_length(_users_ids, 1))]);
    _roles_ids INTEGER[] := (SELECT ARRAY_AGG(DISTINCT r.id)
                                FROM roles r
                            );
    _role_id INTEGER := (SELECT _roles_ids[random_between(0, array_length(_roles_ids, 1))]);
BEGIN

    WHILE NOW() < _to_date LOOP
        INSERT INTO users_roles (user_id, role_id)
        VALUES
        (_user_id,
         _role_id
        );
        COMMIT;
        RAISE NOTICE 'inserts_users_roles - _user_id=%, _role_id=%', _user_id, _role_id;
        PERFORM pg_sleep(_sleep_seconds);
    END LOOP;

END;
$$;

alter procedure pr_inserts_users_roles(double precision, integer) owner to postgres;

create procedure pr_update_actions(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _updated_id INTEGER := 0;
BEGIN

 WHILE NOW() < _to_date LOOP
     UPDATE actions act
         SET name = random_string()
     WHERE act.id = random_between((SELECT MIN(a.id) FROM actions a), (SELECT MAX(a.id) FROM actions a))
     RETURNING id INTO _updated_id
     ;
     COMMIT;
        RAISE NOTICE 'update_actions - id=%', _updated_id;
     PERFORM pg_sleep(_sleep_seconds);
 END LOOP;

END;
$$;

alter procedure pr_update_actions(double precision, integer) owner to postgres;

create procedure pr_update_persons(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _updated_id INTEGER := 0;
BEGIN

 WHILE NOW() < _to_date LOOP
     UPDATE persons pers
         SET firstname = random_string(),
             lastname = random_string(),
             birthdate = random_timestamp('1940-01-01'::TIMESTAMP WITHOUT TIME ZONE, '2020-01-01'::TIMESTAMP WITHOUT TIME ZONE),
             gender = random_between(1,2)
     WHERE pers.id = random_between((SELECT MIN(p.id) FROM persons p), (SELECT MAX(p.id) FROM persons p))
     RETURNING id INTO _updated_id
     ;
     COMMIT;
     RAISE NOTICE 'update_persons - id=%', _updated_id;
     PERFORM pg_sleep(_sleep_seconds);
 END LOOP;

END;
$$;

alter procedure pr_update_persons(double precision, integer) owner to postgres;

create procedure pr_update_roles(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _updated_id INTEGER := 0;
BEGIN

 WHILE NOW() < _to_date LOOP
     UPDATE roles ro
         SET name = random_string()
     WHERE ro.id = random_between((SELECT MIN(r.id) FROM roles r), (SELECT MAX(r.id) FROM roles r))
     RETURNING id INTO _updated_id
     ;
     COMMIT;
     RAISE NOTICE 'update_roles - id=%', _updated_id;
     PERFORM pg_sleep(_sleep_seconds);
 END LOOP;

END;
$$;

alter procedure pr_update_roles(double precision, integer) owner to postgres;

create procedure pr_update_users(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _persons_ids INTEGER[] := (SELECT ARRAY_AGG(DISTINCT p.id)
                                FROM persons p
                            );
    _person_id INTEGER := (SELECT _persons_ids[random_between(0, array_length(_persons_ids, 1))]);
    _updated_id INTEGER := 0;
BEGIN

 WHILE NOW() < _to_date LOOP
     UPDATE users us
         SET username = random_string(),
             password = random_string(),
             person_id = _person_id
     WHERE us.id = random_between((SELECT MIN(u.id) FROM users u), (SELECT MAX(u.id) FROM users u))
     RETURNING id INTO _updated_id
     ;
     COMMIT;
     RAISE NOTICE 'update_users - id=%', _updated_id;
     PERFORM pg_sleep(_sleep_seconds);
 END LOOP;

END;
$$;

alter procedure pr_update_users(double precision, integer) owner to postgres;

create procedure pr_update_users_actions(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _actions_ids INTEGER[] := (SELECT ARRAY_AGG(DISTINCT a.id)
                                FROM actions a
                            );
    _action_id INTEGER := (SELECT _actions_ids[random_between(0, array_length(_actions_ids, 1))]);
    _users_ids INTEGER[] := (SELECT ARRAY_AGG(DISTINCT u.id)
                                FROM users u
                            );
    _user_id INTEGER := (SELECT _users_ids[random_between(0, array_length(_users_ids, 1))]);
    _updated_id INTEGER := 0;
BEGIN

 WHILE NOW() < _to_date LOOP
     UPDATE users_actions usact
         SET user_id = _user_id,
             action_id = _action_id,
             action_date = random_timestamp( (SELECT MIN(ua.action_date:: timestamp without time zone) FROM users_actions ua), NOW()::timestamp without time zone)
     WHERE usact.id = random_between((SELECT MIN(ua.id) FROM users_actions ua), (SELECT MAX(ua.id) FROM users_actions ua))
     RETURNING id INTO _updated_id
     ;
     COMMIT;
     RAISE NOTICE 'update_users_actions - id=%', _updated_id;
     PERFORM pg_sleep(_sleep_seconds);
 END LOOP;

END;
$$;

alter procedure pr_update_users_actions(double precision, integer) owner to postgres;

create procedure pr_update_users_roles(_sleep_seconds double precision, _duration_min integer)
    language plpgsql
as
$$
DECLARE
    _to_date TIMESTAMP := NOW()+ (_duration_min::TEXT || ' MINUTES')::INTERVAL;
    _roles_ids INTEGER[] := (SELECT ARRAY_AGG(DISTINCT r.id)
                                FROM roles r
                            );
    _role_id INTEGER := (SELECT _roles_ids[random_between(0, array_length(_roles_ids, 1))]);
    _users_ids INTEGER[] := (SELECT ARRAY_AGG(DISTINCT u.id)
                                FROM users u
                            );
    _user_id INTEGER := (SELECT _users_ids[random_between(0, array_length(_users_ids, 1))]);
BEGIN

 WHILE NOW() < _to_date LOOP
     UPDATE users_roles usro
         SET user_id = random_between((SELECT MIN(u.id) FROM users u), (SELECT MAX(u.id) FROM users u)),
             role_id = random_between((SELECT MIN(r.id) FROM roles r), (SELECT MAX(r.id) FROM roles r))
     WHERE usro.user_id = _user_id
       AND usro.role_id = _role_id
     ;
     COMMIT;
     RAISE NOTICE 'update_users_roles - user_id=%, role_id=%', _user_id, _role_id;
     PERFORM pg_sleep(_sleep_seconds);
 END LOOP;

END;
$$;

alter procedure pr_update_users_roles(double precision, integer) owner to postgres;
