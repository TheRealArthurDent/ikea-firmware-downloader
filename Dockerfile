FROM python:3.14-alpine

ARG TARGETARCH
ARG TARGETOS

# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.41/supercronic-$TARGETOS-$TARGETARCH \
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

# Copy files
COPY --chown=downloader:downloader --chmod=544 entrypoint.sh .
COPY --chown=downloader:downloader --chmod=544 download-ikea-firmware.sh .
COPY --chown=downloader:downloader --chmod=444 crontab .

#RUN crontab crontab

USER downloader

# Run cron on container startup
ENTRYPOINT ["./entrypoint.sh"]
