ARG VERSION
ARG TARGETPLATFORM
ARG BUILDPLATFORM

FROM alpine:${VERSION}

# hadolint ignore=DL3018
RUN \
    apk add --no-cache \
        bash \
        ca-certificates

ENTRYPOINT ["/bin/bash"]
CMD ["echo", "'No can haz support yet. Chek bak l8r!'", "exit", "1337" ]
