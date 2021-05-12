FROM python:3.8 as stage

FROM stage as builder

RUN mkdir /install
WORKDIR /install

ARG VERSION
RUN pip install --prefix=/install --no-warn-script-location chia-blockchain==$VERSION

FROM stage

EXPOSE 8444
EXPOSE 8447

ENV CHIA_MODE="farmer"
ENV CHIA_KEYS="generate"
ENV CHIA_PLOTS="/plots"
ENV CHIA_FARMER_ADDRESS=""
ENV CHIA_FARMER_PORT=""
ENV CHIA_FARMER_CA=""
ENV CHIA_LOGLEVEL="WARNING"

COPY --from=builder /install /usr/local
COPY ./docker/docker-entrypoint.sh /

RUN mkdir /config && \
    mkdir /plots && \
    ln -s /config ~/.chia && \
    chmod +x /docker-entrypoint.sh

VOLUME [ "/config" ]
VOLUME [ "/plots" ]

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/sh", "-c", "while true; do sleep 30; done;"]