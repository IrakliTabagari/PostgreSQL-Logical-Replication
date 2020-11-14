# PostgreSQL-Logical-Replication
PostgreSQL Logical Replication With Docker

In this project I will show how to setup and simulate [PostgreSQL Logical Relplication](https://www.postgresql.org/docs/13/logical-replication.html).
For this we will use [Docker](https://www.docker.com/)

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
