FROM python:3.14-alpine

ARG TARGETARCH
ARG TARGETOS
ARG SUPERCRONIC_VERSION=0.2.40

# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v$SUPERCRONIC_VERSION/supercronic-$TARGETOS-$TARGETARCH \
    SUPERCRONIC=supercronic-$TARGETOS-$TARGETARCH

RUN wget -q "$SUPERCRONIC_URL" \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic \
 && addgroup -S downloader && adduser -S downloader -G downloader \
 && mkdir /home/downloader/otau \
 && chown downloader:downloader /home/downloader/otau

VOLUME /home/downloader/otau

WORKDIR /home/downloader

COPY --chown=downloader:downloader --chmod=544 entrypoint.sh .
COPY --chown=downloader:downloader --chmod=544 download-ikea-firmware.sh .
COPY --chown=downloader:downloader --chmod=444 crontab .

USER downloader

# Run supercronic on container startup
ENTRYPOINT ["./entrypoint.sh"]
