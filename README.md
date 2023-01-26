
# quickstart
A fast way to get DIM running in a local docker environment.



# To launch the FastAPI backend
```
./launch_backend.sh
```
> This creates a backend_launch.log

The FastAPI backend will be available at **http://localhost:7000**



# To launch the Vue frontend
```
./launch_frontend.sh
```
> This creates a frontend_launch.log

The frontend will be available at **http://localhost:5173**



# Description
These scripts will perform a git clone (of dev branches) of either the backend/frontend repos. It will also launch corresponding docker containers. This means both 'git' and 'docker' should be available from your terminal.

These script will exit if environment files (`.env`) are not found in their corresponding folders. For example:
```
    backend/.env
    frontend/.env
```

After providing the appropriate .env files, you can relaunch either script.



# Backend Management
The backend containers are defined in ```docker-compose.yml```. These containers are:
* fastapi_container
* pgdatabase_container
* pgadmin4_container

A docker-compose file allows for simple management by navigating to the top-level quickstart folder and using the following commands:

```
    docker compose up 
    docker compose down
```



# Postgres Management
A shared folder (i.e.., a docker volume) is created on the local filesystem to store postgres data and thus, your database data will continue to persist even after the postgres container is stopped or deleted. The pgadmin tool, used for web based database administration, is available at **http://localhost:5050**

The credentials to log into pgadmin are defined in the `docker-compose.yml` under the keys `PGADMIN_DEFAULT_EMAIL` and `PGADMIN_DEFAULT_PASSWORD`.



# Frontend Management
The frontend container (vue_container) is managed by regular docker. The frontend container can be managed by navigating to quickstart/frontend/ and using the following commands:

```
    docker run --name vue_container -p 5173:5173 -d vue
    docker stop vue_container
```



# Future Improvements
We can consider setting up these containers in such a way where debugging using a host IDE is possible. This usually involves using docker volumes inconjunction with remote debugging capabilities.
