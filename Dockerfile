FROM debian:bullseye-slim AS build

ARG sqlite3_version=3390000

RUN \
   apt update && \
   apt install -y wget build-essential

# Download latest release
RUN \
  wget \
    -O sqlite.tar.gz \
    https://www.sqlite.org/2022/sqlite-autoconf-${sqlite3_version}.tar.gz && \
  tar xvfz sqlite.tar.gz && \
  mv sqlite-autoconf-${sqlite3_version} /opt/sqlite3


# Configure and make SQLite3 binary
RUN \
  cd /opt/sqlite3 && \
  ./configure && \
  make && \
  make install \
  && \
  sqlite3 --version && \
  which sqlite3

FROM python:3.8-bullseye

COPY --from=build /usr/local/bin/sqlite3 /usr/bin/sqlite3
COPY --from=build /opt/sqlite3 /opt/sqlite3
ENV LD_LIBRARY_PATH="/opt/sqlite3/.libs"


ARG UNAME=admin
ARG UID=1000
ARG GID=1000

VOLUME /app
WORKDIR /app
ENV PATH="/app:${PATH}"

RUN pip install --no-cache-dir sqlite-web

RUN groupadd -g $GID -o $UNAME
RUN useradd -m -l -u $UID -g $GID -o -s /bin/bash $UNAME
RUN chown -R $UID:$GID /app
USER $UNAME

EXPOSE 8080

CMD sqlite_web -H 0.0.0.0 -x $SQLITE_DATABASE
