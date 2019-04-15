FROM crystallang image?

RUN mkdir /pingas
WORKDIR /pingas
# COPY shard.yml shard.lock .

# RUN shards install
COPY . .
RUN crystal build src/pingas

ENTRYPOINT ["/pingas/pingas"]
