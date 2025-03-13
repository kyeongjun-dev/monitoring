FROM ubuntu:24.10
WORKDIR /app
RUN apt update -y && apt install -y wget 
COPY download-tempo-cli.sh download-tempo-cli.sh
RUN /bin/bash download-tempo-cli.sh 2.7.1
CMD echo "ubuntu is sleeping..." && sleep infinity