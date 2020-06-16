# syntax=docker/dockerfile:experimental
FROM alpine:3.12 as bld
ARG CMARK_VER

RUN --mount=type=cache,target=/var/cache/apk \
    ln -vs /var/cache/apk /etc/apk/cache \
    && apk add --virtual .build-deps \
       build-base cmake

WORKDIR = /home
ADD https://github.com/commonmark/cmark/archive/${CMARK_VER}.tar.gz ./cmark.tar.gz
RUN echo    ' - install cmark' \
    && echo '   ---------------' \
    && tar -C /tmp -xf ./cmark.tar.gz \
    && cd /tmp/cmark-${CMARK_VER} \
    && cmake \
    && make install \
    && cd /home \
    && rm -f ./cmark.tar.gz \
    && rm -r /tmp/cmark-${CMARK_VER} \
    && echo '---------------------------' \
    && echo ' -  FINISH ' \
    && echo '   --------' \
    && echo ' -  remove apk install deps' \
    && apk del .build-deps \
    && echo '---------------------------'

FROM alpine:3.12
COPY --from=bld /usr/local /usr/local
ENTRYPOINT ["/usr/local/bin/cmark"]


