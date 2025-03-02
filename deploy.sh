#!/bin/bash

IMAGE="honeypress:2.0"
DOCKERFILE_PATH="Dockerfile"
REBUILD_IMAGE=false
PUBLIC_URL="http://localhost"

function show_help() {
    cat branding.txt
    echo "deploy.sh -b: Force a rebuild of the selected image, even when the image already exists."
    echo "deploy.sh -d <path>: Change the dockerfile path. Context will be still '.'. Default is 'Dockerfile'."
    echo "deploy.sh -u <url>: Set the public URL (homeurl/siteurl). The default is 'localhost:port'. If a value is provided, the port flag (-p and it's defualt) will be ignored."
    echo "deploy.sh -h: Show this message"
    exit 0
}
OPTIONS_PRESENT=false
while getopts "d:u:h:b" flag
do
    OPTIONS_PRESENT=true
    case "${flag}" in
        b) REBUILD_IMAGE=true;;
        d) DOCKERFILE_PATH=${OPTARG};;
        h) show_help;;
        u) PUBLIC_URL="${OPTARG}";;
    esac
done

# Show the help text if nothing was provided
if [[ $OPTIONS_PRESENT = false ]]; then
    show_help
fi


# Check if the docker daemon is running at all.
DOCKER_RUNNING=$(docker ps > /dev/null 2>&1)
if [[ $? -ne 0 ]];
then
  echo "Is your Docker service running? Could not connect to the service."
  exit 1
fi

compose=$(env docker-compose > /dev/null 2>&1)
if [[ $? -ne 0 ]];
then
  echo "The docker-compose command was not found."
  exit 1
fi

# Check if the docker image exists, if not build $IMAGE from $DOCKERFILE_PATH
if [[ "$(docker images -q $IMAGE 2> /dev/null)" == "" ]]; then
  # do something
  echo "The image $IMAGE is not present in the image list. Creating the image..."
  docker build . -f $DOCKERFILE_PATH -t $IMAGE
fi

if [[ "$REBUILD_IMAGE" = true ]]; then
  # do something
  echo "A rebuild for the image was requested."
  docker build . -f $DOCKERFILE_PATH -t $IMAGE
fi

WP_ADMIN_USER=$(openssl rand -base64 10 | md5sum | head -c10;echo|xargs)
WP_ADMIN_PASS=$(openssl rand -base64 10 | md5sum | head -c10;echo|xargs)

sleep 2
docker compose -f compose-for-traefik.yaml up -d

sleep 15
docker exec "honeypress_wordpress" bash -c "php /wp-cli.phar --allow-root config set WP_AUTO_UPDATE_CORE false --raw"
sleep 1
# complete WP setup
docker exec "honeypress_wordpress" bash -c "php /wp-cli.phar --allow-root core install --title='My Site' --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASS --admin_email=exampleAdmin@nowhere.org --url=$PUBLIC_URL"
sleep 1
echo "We will use $PUBLIC_URL as the siteurl and home."
docker exec "honeypress_wordpress" bash -c "php /wp-cli.phar --allow-root option set siteurl $PUBLIC_URL"
docker exec "honeypress_wordpress" bash -c "php /wp-cli.phar --allow-root option set home $PUBLIC_URL"

docker exec "honeypress_wordpress" bash -c "php /wp-cli.phar --allow-root plugin activate honeypress"
#docker exec "honeypress_wordpress" bash -c "php /wp-cli.phar --allow-root post delete 1"
# fix permissions
docker exec "honeypress_wordpress" bash -c "chown -R www-data:www-data ./logs"
docker exec "honeypress_wordpress" bash -c "chown -R www-data:www-data ./wp-content"
docker exec "honeypress_wordpress" bash -c "sed -i 's/\"admin\"/\"$WP_ADMIN_USER\"/g' ./honeypress.json" # make sure the admin is not deleted

echo "Created Honeypress URL: $PUBLIC_URL/wp-login.php Credentials: $WP_ADMIN_USER and $WP_ADMIN_PASS" 
