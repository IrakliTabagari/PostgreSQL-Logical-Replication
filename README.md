# PostgreSQL-Logical-Replication
PostgreSQL Logical Replication With Docker.

In this project I will show how to setup and simulate [PostgreSQL Logical Relplication](https://www.postgresql.org/docs/13/logical-replication.html).
For this we will use [Docker](https://www.docker.com/)

We will simulate scenario, where data from production database server will be transfered to reporting database server.

### 1. Install Docker 
Download and install docker on your machine from [official link](https://www.docker.com/get-started)

### 2. Pull PostgreSQL image in docker 
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

### 3. Run postgres image 
In this step we will run postgre images twice to create two containers:
1. prod-postgres - primary server which will be *publisher*
2. reporting-postgres - secondary server which will be *subscriber*

#### 3.1 Run image as *Production* server container
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
#### 3.2 Run image as *Reporting* server container
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
