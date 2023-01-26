#!/bin/bash

# Misc script variables
FRONTEND_LOG=frontend_launch.log

# Delete older frontend launch logs in the current folder
if [ -f $FRONTEND_LOG ]; then
    echo "Deleting existing frontend launch logs." | tee -a $FRONTEND_LOG
    rm $FRONTEND_LOG
fi


# Verify git is installed
git --version 2>&1 >/dev/null
GIT_NOT_FOUND=$?
if [ $GIT_NOT_FOUND -ne 0 ]; then
    echo "This script requires that git be available at the command line. Quitting initialization..." | tee -a $FRONTEND_LOG
    exit 1
fi

# Verify docker is available
docker --version 2>&1 >/dev/null
DOCKER_NOT_FOUND=$?
if [ $DOCKER_NOT_FOUND -ne 0 ]; then
    echo "This script requires that docker be available at the command line. Quitting initialization..." | tee -a $FRONTEND_LOG
    exit 1
fi

# Check if we need to perform a git clone for the frontend repo
if [ -d "frontend/" ]; then
    echo "A frontend folder already exists in the current directory. Skipping git clone." | tee -a $FRONTEND_LOG
else
    echo "Cloning the frontend dev repository..." | tee -a $FRONTEND_LOG
    git clone -b dev --progress git@github.com:projectdim/frontend.git 2> $FRONTEND_LOG || exit 1
fi

# Check for an environment file
if [ ! -f "frontend/.env" ]; then
    echo "No .env file was found in the frontend project. Quitting initialization..." | tee -a $FRONTEND_LOG
    exit 1
fi

# Check to see if the frontend container already exists
DOCKER_FRONTEND_CONTAINER_RUNNING=$(docker container ls -a | grep vue_container | wc -l)
if [ $DOCKER_FRONTEND_CONTAINER_RUNNING -ne 0 ]; then

    while true; do
        read -p "The frontend controller already exists and may be running. Do you wish to to recreate it? (y/n) " yn

        case $yn in 
            [yY] ) echo "Deleting existing vue_container" | tee -a $FRONTEND_LOG
                docker container stop vue_container >> $FRONTEND_LOG 2>&1
                docker container rm vue_container >> $FRONTEND_LOG 2>&1
                break;;
            [nN] ) echo "Exiting..." | tee -a $FRONTEND_LOG
                exit;;
            * ) echo "Invalid Response";;
        esac
    done
fi

# Build the frontend image
echo "Building frontend docker image with name: vue" | tee -a $FRONTEND_LOG
docker build -t vue frontend >> $FRONTEND_LOG 2>&1

DOCKER_FRONTEND_BUILD_SUCCESS=$?
if [ $DOCKER_FRONTEND_BUILD_SUCCESS -ne 0 ]; then
    echo "An error occurred building the frontend docker container. Quitting initialization..." | tee -a $FRONTEND_LOG
    exit 1
fi

echo "Lauching frontend docker container with name: vue_container" | tee -a $FRONTEND_LOG
docker run --name vue_container -p 5173:5173 -d vue >> $FRONTEND_LOG 2>&1

DOCKER_FRONTEND_RUN_SUCCESS=$?
if [ $DOCKER_FRONTEND_RUN_SUCCESS -ne 0 ]; then
    echo "An error occurred launching the frontend container. Please see the frontend log in this folder." | tee -a $FRONTEND_LOG
else
    echo "The frontend should be available at http://localhost:5173" | tee -a $FRONTEND_LOG
fi