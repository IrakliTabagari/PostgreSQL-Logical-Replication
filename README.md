# PostgreSQL-Logical-Replication
PostgreSQL Logical Replication With Docker.

In this project I will show how to setup and simulate [PostgreSQL Logical Relplication](https://www.postgresql.org/docs/13/logical-replication.html).
For this we will use [Docker](https://www.docker.com/)

We will simulate scenario, where data from production database server will be transfered to reporting database server.

## 1. Install Docker 
Download and install docker on your machine from [official link](https://www.docker.com/get-started)

## 2. Pull PostgreSQL image in docker 
Open terminal and run this command to pull PostgreSQL image:
```docker
docker pull postgres
```
#### 2.1 Check installed images
Run this command in terminal:
```docker
docker image ls
```
It must show installed docker images
```docker
REPOSITORY                     TAG                  IMAGE ID            CREATED             SIZE
postgres                       latest               c96f8b6bc0d9        4 weeks ago         314MB
```

## 3. Run Containers from postgres image 
In this step we will run postgres images twice to create two containers:
1. **prod-postgres** - primary server which will be *publisher*
2. **reporting-postgres** - secondary server which will be *subscriber*

#### 3.1 Run container from postgres image as *Production* server container
```docker
docker run --detach \
    --name prod-postgres \
    --volume D:/docker_postgresql_data/prod:/var/lib/postgresql/data \
    --env POSTGRES_USER=postgres \
    --env POSTGRES_PASSWORD=123456789 \
    --env POSTGRES_DB=postgres \
    --publish 5432:5432 \
    postgres
```
#### 3.2 Run container from postgres image as *Reporting* server container
```docker
docker run --detach \
    --name reporting-postgres \
    --volume D:/docker_postgresql_data/reporting:/var/lib/postgresql/data \
    --env POSTGRES_USER=postgres \
    --env POSTGRES_PASSWORD=987654321 \
    --env POSTGRES_DB=postgres \
    --publish 5433:5432 \
    postgres
```
#### 3.3 Check running containers
Run this command to vew running containers
```docker
docker ps
```
You will see the result like this:
```docker
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
c04a0a6828c5        postgres            "docker-entrypoint.s…"   5 days ago          Up 3 hours          0.0.0.0:5433->5432/tcp   reporting-postgres
e452184fbe7b        postgres            "docker-entrypoint.s…"   5 days ago          Up 3 hours          0.0.0.0:5432->5432/tcp   prod-postgres
```

## 4. Create Tables and procedures on Productoin PostgreSQL server
Now we have to create tables on production schema

#### 4.1 Create tables
1. Connect to Production PostgreSQL Server (host=172.17.0.2 port=5432 user=postgres password=123456789 dbname=postgres)
2. Run Scripts From [production_schema.sql](https://github.com/IrakliTabagari/PostgreSQL-Logical-Replication/blob/main/production_schema.sql) file

#### 4.2 Run procedures to fill tables
1. Connect to Production PostgreSQL Server (host=172.17.0.2 port=5432 user=postgres password=123456789 dbname=postgres)
2. Run Scripts From [data_manipulation_scripts.sql](https://github.com/IrakliTabagari/PostgreSQL-Logical-Replication/blob/main/data_manipulation_scripts.sql) file

## 5. Configure PostgreSQL Servers for replication
In this step we will run scripts that will change PostgreSQL configuration parameters

#### 5.1 Production Server
1. Connect to Production PostgreSQL Server (host=172.17.0.2 port=5432 user=postgres password=123456789 dbname=postgres)
2. Change configuration parameters by running this scripts
```sql
ALTER SYSTEM SET wal_level = logical;
ALTER SYSTEM SET max_replication_slots = 5;
ALTER SYSTEM SET max_wal_senders = 10;
```
3. Crete publication
```sql
CREATE PUBLICATION alltables FOR ALL TABLES;
```
4. Create database user for replication and grant nesessary (USAGE, SELECT) privileges
```sql
CREATE USER replication_user WITH PASSWORD '111222333' REPLICATION;

GRANT USAGE ON SCHEMA public TO replication_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO replication_user;
GRANT SELECT, USAGE ON ALL SEQUENCES IN SCHEMA public TO replication_user;
```

#### 5.2 Reporting server
1. Connect to Reporting PostgreSQL Server (host=172.17.0.2 port=5433 user=postgres password=987654321 dbname=postgres)
2. Change configuration parameters by running this scripts
```sql
ALTER SYSTEM SET max_replication_slots = 5;
ALTER SYSTEM SET max_logical_replication_workers  = 10;
ALTER SYSTEM SET max_worker_processes   = 20;
```
3. Create Subscription
```sql
CREATE SUBSCRIPTION all_subscription
    CONNECTION 'host=172.17.0.2 port=5432 user=replication_user password=111222333 dbname=postgres'
    PUBLICATION alltables;
```
