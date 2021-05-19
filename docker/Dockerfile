FROM python:3.8-slim

EXPOSE 8444
EXPOSE 8447

ENV CHIA_MODE="farmer"
ENV CHIA_KEYS="generate"
ENV CHIA_PLOTS="/plots"
ENV CHIA_FARMER_ADDRESS=""
ENV CHIA_FARMER_PORT=""
ENV CHIA_FARMER_CA=""
ENV CHIA_LOGLEVEL="WARNING"

RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists*

RUN python -m pip install --no-cache-dir git+https://github.com/Chia-Network/chia-blockchain.git

COPY ./docker/docker-entrypoint.sh /

RUN mkdir /config && \
    mkdir /plots && \
    ln -s /config ~/.chia && \
    chmod +x /docker-entrypoint.sh

VOLUME [ "/config" ]
VOLUME [ "/plots" ]

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/sh", "-c", "while true; do sleep 30; done;"]