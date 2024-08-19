#!/bin/bash -e

ALPINE_RESULT=$(docker run --pull always --rm --entrypoint /bin/sh alpine:latest -c 'cat /etc/os-release | grep VERSION_ID')
# echo 'ALPINE_RESULT = '$ALPINE_RESULT
ALPINE_VERSION=$(echo $ALPINE_RESULT | cut -d '=' -f 2)
# ALPINE_VERSION='3.20.2'
echo 'ALPINE_VERSION = '$ALPINE_VERSION

RESULT=$(docker run --rm --entrypoint /bin/sh alpine:${ALPINE_VERSION} -c '(apk update && apk add ansible-core) >/dev/null 2>&1 ; ansible --version')
# echo 'RESULT = '$RESULT
ANSIBLE_VERSION=$(echo $RESULT | grep 'ansible \[core' | cut -d ' ' -f 3 | cut -d ']' -f 1)
# ANSIBLE_VERSION='2.17.0'
echo 'ANSIBLE_VERSION = '$ANSIBLE_VERSION

DOCKER_IMAGE='simplepackages/ansible-core'
DOCKER_TAG=$ANSIBLE_VERSION

MANIFEST_RESULT=$(docker manifest inspect $DOCKER_IMAGE:$DOCKER_TAG 2>&1 || true)
# echo 'MANIFEST_RESULT = '$MANIFEST_RESULT
if [ -n "$(echo $MANIFEST_RESULT | grep 'no such manifest')" ]; then
    echo 'Building '$DOCKER_IMAGE:$DOCKER_TAG'...'
    echo

    # docker build --build-arg "ALPINE_VERSION=$ALPINE_VERSION" \
    #              --build-arg "ANSIBLE_VERSION=$ANSIBLE_VERSION" \
    #              --tag $DOCKER_IMAGE:$DOCKER_TAG \
    #              .

    docker buildx create --name multibuilder || true
    docker buildx use multibuilder
    docker buildx build --push \
                        --platform linux/amd64,linux/arm64,linux/arm/v7 \
                        --build-arg "ALPINE_VERSION=$ALPINE_VERSION" \
                        --build-arg "ANSIBLE_VERSION=$ANSIBLE_VERSION" \
                        --tag $DOCKER_IMAGE:$DOCKER_TAG \
                        --tag $DOCKER_IMAGE:latest \
                        .
elif [ -n "$(echo $MANIFEST_RESULT | grep '"digest": "sha256:')" ]; then
    echo 'Image '$DOCKER_IMAGE:$DOCKER_TAG' already exists, building aborted.'
else
    echo 'Unknown response from docker manifest inspect:'
    echo $MANIFEST_RESULT
    exit 1
fi

docker pull $DOCKER_IMAGE:$DOCKER_TAG
echo
docker image ls | grep $DOCKER_IMAGE
