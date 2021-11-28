FROM ubuntu:latest
RUN apt-get update && apt-get -yy install curl stunnel
ENV version="1.1.0"
RUN curl -sL -o full-service.tar.gz https://github.com/mobilecoinofficial/full-service/releases/download/v$version/mainnet-release-linux-penryn-$version.tar.gz
RUN tar xf full-service.tar.gz && rm full-service.tar.gz
WORKDIR /mainnet
COPY ./stunnel.docker.conf stunnel.conf
COPY ./run.sh .
ENTRYPOINT ["/bin/bash", "./run.sh"]
