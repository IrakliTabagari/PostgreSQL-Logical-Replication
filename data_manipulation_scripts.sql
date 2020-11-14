-- We will intall dblink extension to run multiple procedures asyncronoysly
CREATE EXTENSION dblink;

-- Create dblink Connections for Production Server
select dblink_connect('dblink1','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink2','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink3','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink4','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink5','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink6','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink7','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink8','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink9','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink10','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink11','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink12','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink13','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink14','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink15','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink16','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink17','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');
select dblink_connect('dblink18','hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres password=123456789');

-- Run all 18 "INSERT", "UPDATE" and "DELETE" scripts below at a time in one console
-- Procedures will execute Asyncronously by "dblink_send_query()" to INSERT, UPDATE and DELETE records in tables
-- INSERT
select * from dblink_send_query('dblink1','CALL public.pr_inserts_persons(10,10);');
select * from dblink_send_query('dblink2','CALL public.pr_inserts_users(5, 10);');
select * from dblink_send_query('dblink3','CALL public.pr_inserts_roles(20, 10);');
select * from dblink_send_query('dblink4','CALL public.pr_inserts_users_roles(30, 10);');
select * from dblink_send_query('dblink5','CALL public.pr_inserts_actions(30, 10);');
select * from dblink_send_query('dblink6','CALL public.pr_inserts_users_actions(1, 10);');
-- UPDATE
select * from dblink_send_query('dblink7','CALL public.pr_update_persons(5, 10);');
select * from dblink_send_query('dblink8','CALL public.pr_update_users(3, 10);');
select * from dblink_send_query('dblink9','CALL public.pr_update_roles(20, 10);');
select * from dblink_send_query('dblink10','CALL public.pr_update_users_roles(35, 10);');
select * from dblink_send_query('dblink11','CALL public.pr_update_actions(40, 10);');
select * from dblink_send_query('dblink12','CALL public.pr_update_users_actions(5, 10);');
-- DELETE
select * from dblink_send_query('dblink13','CALL public.pr_delete_persons(45, 10);');
select * from dblink_send_query('dblink14','CALL public.pr_delete_users(30, 10);');
select * from dblink_send_query('dblink15','CALL public.pr_delete_roles(50, 10);');
select * from dblink_send_query('dblink16','CALL public.pr_delete_users_roles(45, 10);');
select * from dblink_send_query('dblink17','CALL public.pr_delete_actions(45, 10);');
select * from dblink_send_query('dblink18','CALL public.pr_delete_users_actions(5, 10);');

-- Disconnect dblink connections
SELECT dblink_disconnect('dblink1');
SELECT dblink_disconnect('dblink2');
SELECT dblink_disconnect('dblink3');
SELECT dblink_disconnect('dblink4');
SELECT dblink_disconnect('dblink5');
SELECT dblink_disconnect('dblink6');
SELECT dblink_disconnect('dblink7');
SELECT dblink_disconnect('dblink8');
SELECT dblink_disconnect('dblink9');
SELECT dblink_disconnect('dblink10');
SELECT dblink_disconnect('dblink11');
SELECT dblink_disconnect('dblink12');
SELECT dblink_disconnect('dblink13');
SELECT dblink_disconnect('dblink14');
SELECT dblink_disconnect('dblink15');
SELECT dblink_disconnect('dblink16');
SELECT dblink_disconnect('dblink17');
SELECT dblink_disconnect('dblink18');


-- SELECT counts from tables to monitor whats going on
SELECT (SELECT COUNT(*) FROM persons) AS persons,
       (SELECT COUNT(*) FROM users) AS users,
       (SELECT COUNT(*) FROM roles) AS roles,
       (SELECT COUNT(*) FROM users_roles) AS users_roles,
       (SELECT COUNT(*) FROM actions) AS actions,
       (SELECT COUNT(*) FROM users_actions) AS users_actions
;
