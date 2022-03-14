FROM ubuntu:latest
RUN apt-get update && apt-get -yy install wget stunnel
ENV version="1.5.0"
RUN wget https://github.com/mobilecoinofficial/full-service/releases/download/v$version/linux-v$version.tar.gz -O full-service.tar.gz
RUN tar xf full-service.tar.gz && rm full-service.tar.gz
WORKDIR /linux-v$version
COPY ./run.sh .
COPY stunnel.docker.conf stunnel.conf
ENTRYPOINT ["/bin/bash", "./run.sh"]
