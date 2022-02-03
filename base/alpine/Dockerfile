ARG VERSION
ARG TARGETPLATFORM
ARG BUILDPLATFORM

FROM alpine:${VERSION}

RUN \
    apk add --no-cache bash ca-certificates shadow

ENTRYPOINT ["/bin/bash"]
CMD ["echo", "'No can haz support yet. Chek bak l8r!'", "exit", "1337" ]
