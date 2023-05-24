source .env
docker run -it -p 23:22 --user "$UID:$GID" --mount type=bind,source="$(pwd)"/persistent_home,target=/home/$USER mate-dev-docker-ubuntu /bin/bash
