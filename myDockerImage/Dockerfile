FROM ubuntu
RUN apt-get update
RUN apt-get install -y nodejs
COPY server.js /
CMD ["/usr/bin/node", "server.js"]
