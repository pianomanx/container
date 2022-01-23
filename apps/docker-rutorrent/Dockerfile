ARG VERSION
FROM ghcr.io/crazy-max/rtorrent-rutorrent:${VERSION}

COPY ./apps/docker-rutorrent/root/04-overwrite.sh /etc/cont-init.d/04-overwrite.sh
RUN chmod a+x /etc/cont-init.d/04-overwrite.sh && mv /etc/cont-init.d/04-create-services.sh /etc/cont-init.d/05-create-services.sh

VOLUME [ "/data" ]
ENTRYPOINT [ "/init" ]

HEALTHCHECK --interval=30s --timeout=20s --start-period=10s \
CMD /usr/local/bin/healthcheck
