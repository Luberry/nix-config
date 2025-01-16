
export NPM_REGISTRY_URL="https://nexus.internal-prod.imubit.com/repository/npm-group/"
export PIP_INDEX_URL="https://nexus.internal-prod.imubit.com/repository/pypi-internal/simple"
export PIP_TRUSTED_HOST="nexus.internal-prod.imubit.com"


function container_ip {
    local container_name="$1"
    # echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_name")
    echo 127.0.0.1
}
function is_container_running {
    local CONTAINER_NAME="$1"
    if [[ "$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)" == "true" ]]; then
        echo "Container ${CONTAINER_NAME} already running"
        return
    elif [[ "$(docker inspect -f '{{.State.Status}}' $CONTAINER_NAME 2>/dev/null)" == "exited" ]]; then
        docker start $CONTAINER_NAME
        echo "Container ${CONTAINER_NAME} started"
        return
    fi
    false
}
export FLASK_APP=~/dlpc/libs/flask-server/flask_server/app/server.py
function start_db {
    local IMAGE="postgres:15"
    local POSTGRES_USER="postgres"
    local POSTGRES_DB="dlpc_db"
    local POSTGRES_PASSWORD="postgres"
    local CONTAINER_NAME="dlpc_db_container"
    if ! is_container_running $CONTAINER_NAME; then
        rm -rf ~/dlpc-db/data
        docker run \
        -e POSTGRES_DB=$POSTGRES_DB \
        -e POSTGRES_USER=$POSTGRES_USER \
        -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
        -e PGDATABASE=$POSTGRES_DB \
        -e PGUSER=$POSTGRES_USER \
        -e PGPASSWORD=$POSTGRES_PASSWORD \
	-p 5432:5432 \
  -v ~/dlpc-db:/var/lib/postgresql \
        -it -d \
        --name $CONTAINER_NAME \
        "$IMAGE" &> /dev/null
        echo "Created database container ${CONTAINER_NAME}"
    fi
    DB_IP="$(container_ip $CONTAINER_NAME)" && \
    export DATABASE_URL="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@${DB_IP}:5432/$POSTGRES_DB"?application_name={app_name}
    echo "DB UP AT: $DATABASE_URL"
    if ! [[ $PYTHONPATH =~ "$PWD" ]]; then
        export PYTHONPATH=$PWD:$PYTHONPATH
    fi
    echo "PYTHONPATH is $PYTHONPATH"
    mdb
}
function get_db_url {
    local IMAGE="postgres:15"
    local POSTGRES_USER="postgres"
    local POSTGRES_DB="dlpc_db"
    local POSTGRES_PASSWORD="postgres"
    local CONTAINER_NAME="dlpc_db_container"
    local DB_IP="$(container_ip $CONTAINER_NAME)"
    export DATABASE_URL="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@${DB_IP}:5432/$POSTGRES_DB"?application_name={app_name}
}
get_db_url
function restart_db {
  docker rm -f dlpc_db_container
  start_db
}

function seed_db {
  cwd=$(pwd)
  cd ~/dlpc/projects/dlpc-controller/
  poetry run python ./tests/customer/randomized_db_data.py
  docker exec -it dlpc_db_container psql -c "update tsr_imubit_anonymous_reformer_sp set wait_sp=914"
  cd $cwd
}

function start_redis {
    local CONTAINER_NAME="redis"
    local IMAGE="bitnami/redis:latest"
    if ! is_container_running $CONTAINER_NAME; then
        docker run \
            --name $CONTAINER_NAME -e ALLOW_EMPTY_PASSWORD=yes\
        -p 6379:6379 \
        --rm -it -d \
        "$IMAGE" &> /dev/null
        echo "Created redis container ${CONTAINER_NAME}"
    fi
    export REDIS_SERVER_URL=$(container_ip $CONTAINER_NAME)
    echo "redis UP AT: $REDIS_SERVER_URL"
}
export AWS_PROFILE=211816962214_elevated-dev-stage-access
alias external_stage='aws eks update-kubeconfig --region us-east-1 --name imubit_aws_external_stage --profile 943140961950_elevated-dev-stage-access'
alias internal_stage='aws eks update-kubeconfig --region us-east-1 --name imubit_aws_internal_stage --profile 211816962214_elevated-dev-stage-access'
alias external_prod='aws eks update-kubeconfig --region us-east-1 --name imubit_aws_external_prod --profile 644671406535_elevated-dev-stage-access'
alias kbapps='kubectl -nimubit-apps'
alias as='aws sso login --profile'
	export ITFS_SSH_PORT=10005
	export ITFS_HOSTNAME=127.0.0.1
