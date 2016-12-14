FROM python:3-alpine

MAINTAINER joe <joeblack949@gmail.com>

LABEL   lang.python.version=3
LABEL   app.name=couchdiscover \
        app.version=0.2.2

COPY    dumb-init /

# VOLUME    ["/app/couchdiscover"]

# COPY    couchdiscover /app/

# RUN     apk --update add git
# RUN     pip3 install --no-cache-dir -r /app/requirements.txt
# RUN     cd /app && python3 setup.py install
RUN     pip3 install couchdiscover

ENV     ENVIRONMENT=production
ENV     LOG_LEVEL=debug

ENTRYPOINT  ["/dumb-init", "--"]
CMD         ["couchdiscover"]

# bug with docker hub automated builds when interating with root directory
# ref: https://forums.docker.com/t/automated-docker-build-fails/22831/27
# COPY    entrypoint /entrypoint
# COPY    entrypoint /tmp/
# RUN     mv /tmp/entrypoint /
