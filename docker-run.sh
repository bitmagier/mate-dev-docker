source .env
docker run -it -p 23:22 --mount type=bind,source="$(pwd)"/persistent_home,target=/home/$USER_NAME mate-dev-docker-ubuntu /bin/bash
