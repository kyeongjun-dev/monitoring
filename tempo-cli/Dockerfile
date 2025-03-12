FROM busybox:latest
WORKDIR /app
COPY download-tempo-cli.sh download-tempo-cli.sh
RUN sh download-tempo-cli.sh 2.7.1
CMD echo "busybox is sleeping..." && sleep infinity