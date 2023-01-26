#!/bin/bash

# Misc script variables
BACKEND_LOG=backend_launch.log

# Delete older backend logs in the current folder
if [ -f $BACKEND_LOG ]; then
    echo "Deleting existing backend launch logs." | tee -a $BACKEND_LOG
    rm $BACKEND_LOG
fi

# Verify git is installed
git --version 2>&1 >/dev/null
GIT_NOT_FOUND=$?
if [ $GIT_NOT_FOUND -ne 0 ]; then
    echo "This script requires that git be available at the command line. Quitting initialization..." | tee -a $BACKEND_LOG
    exit 1
fi

# Verify docker is available
docker --version 2>&1 >/dev/null
DOCKER_NOT_FOUND=$?
if [ $DOCKER_NOT_FOUND -ne 0 ]; then
    echo "This script requires that docker be available at the command line. Quitting initialization..." | tee -a $BACKEND_LOG
    exit 1
fi

# Check if we need to perform a git clone for the backend
if [ -d "backend/" ]; then
    echo "A backend folder already exists in the current directory. Skipping git clone." | tee -a $BACKEND_LOG
else
    echo "Cloning the backend dev repository..."
    # Clone the backend repo
    git clone -b dev --progress git@github.com:projectdim/backend.git 2> $BACKEND_LOG || exit 1
fi

# Check for an environment file
if [ ! -f "backend/.env" ]; then
    echo "No .env file was found in the backend project. Quitting initialization..." | tee -a $BACKEND_LOG
    exit 1
fi

# Check to see if the backend container already exists
DOCKER_FASTPI_CONTAINER_RUNNING=$(docker container ls -a | grep fastapi_container | wc -l)
if [ $DOCKER_FASTPI_CONTAINER_RUNNING -ne 0 ]; then

    while true; do
        read -p "Your backend containers may already be running. Do you wish to to relaunch the backend containers? (y/n) " yn

        case $yn in 
            [yY] ) echo "Stopping backend containers" | tee -a $BACKEND_LOG
                docker compose down >> $BACKEND_LOG 2>&1
                break;;
            [nN] ) echo "Exiting..." | tee -a $BACKEND_LOG
                exit;;
            * ) echo "Invalid Response";;
        esac
    done
fi

# Turn on containers
echo 'Launching backend containers..please wait. This may take several minutes.' | tee -a $BACKEND_LOG
docker compose up --detach >> $BACKEND_LOG 2>&1

DOCKER_COMPOSE_SUCCEEDED=$?
if [ $DOCKER_COMPOSE_SUCCEEDED -ne 0 ]; then
    echo "A failure occurred when attempt to launch the backend containers. Please check the backend log file." | tee -a $BACKEND_LOG
    exit 1
else 
    echo "Docker compose has started the backend containers. The backend is available at localhost:7000" | tee -a $BACKEND_LOG
fi