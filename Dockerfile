#Dockerfile to encapsulate both terraform and blast-radius
#
#How-to build docker image (from working-directory having blast-radius source)
#  docker build -t blast-radius .
#
#How-to run docker container (from working-directory having *.tf files)
#  By default, the --serve arg is passed internally to blast-radius
#
#  Syntax to run in foreground (to stop: ^C):
#    docker run -it --rm -p 5000:5000 -v $(pwd):/workdir blast-radius
#
# Syntax to run detached (to stop: docker rm -f blast1):
#    docker run -d --name blast1 -p 5000:5000 -v $(pwd):/workdir blast-radius

#Implementation notes
# Using ubuntu (rather than alpine) base image due to problems with graphviz fonts on alpine

FROM ubuntu:18.04

#expose blast-radius port
EXPOSE 5000

#install graphviz and py dependencies
RUN apt-get update \
    && apt-get install -y  \
    curl \
    git \
    graphviz  \
    python3 \
    python3-pip \
    python3-ply \
    jq \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .

#create blast-radius package from source
#set up entrypoint script
RUN pip3 install -e . \
    && chmod +x ./docker-entrypoint.sh

#define default terraform version in environment var
ENV TF_VERSION "0.11.14"

#install terraform
RUN chmod +x ./docker-build.sh \
    && ./docker-build.sh /src

#set up runtime workdir for tf files
WORKDIR /workdir
ENTRYPOINT ["/src/docker-entrypoint.sh"]
CMD ["--serve"]
