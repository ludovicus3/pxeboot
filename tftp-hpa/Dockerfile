FROM alpine:latest

ENV TFTPD_BIND_ADDRESS="0.0.0.0:1069"
ENV TFTPD_EXTRA_ARGS=""
ENV TFTPBOOT=/tftpboot

RUN apk add --no-cache tftp-hpa

COPY --chown=0:0 entrypoint.sh /

RUN addgroup --gid 101 --system tftpd && \
    adduser --uid 101 --ingroup root --no-create-home --home ${TFTPBOOT} \
            --system --shell /bin/false tftpd

RUN mkdir -p -m 755 ${TFTPBOOT}; \
    chgrp -R 0 ${TFTPBOOT}; \
    chmod -R g=u /etc/passwd /etc/group ${TFTPBOOT}; \
    chmod +x /entrypoint.sh

EXPOSE 1069/udp

VOLUME /tftpboot

ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/sbin/in.tftpd --foreground --verbose --secure --user tftpd --address "$TFTPD_BIND_ADDRESS" $TFTPD_EXTRA_ARGS $TFTPBOOT
