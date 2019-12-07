FROM alpine:edge
MAINTAINER "Peter Simoncic"

ARG USER_ID
ARG GROUP_ID

RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk --no-cache upgrade && \
    apk add --no-cache bash shadow nano curl supervisor unit unit-php7 \
        php7-common \
        php7-pecl-imagick \
        php7-mysqli \
        php7-pecl-apcu \
        php7-bz2 \
        php7-opcache \
        php7-intl \
        php7-json \
        php7-gettext \
        php7-bcmath \
        php7-dom \
        php7-mbstring \
        php7-openssl \
        php7-xml \
        php7-gd \
        php7-exif \
        php7-amqp \
        php7-tokenizer \
        php7-zip \
        php7-curl \
        php7-zlib \
        php7-iconv \
        php7-simplexml \
        php7-xmlwriter \
        php7-pdo \
        php7-phar \
        php7-session \
        php7-pdo_mysql \
        php7-pecl-redis \
        php7-pecl-mongodb@testing \
        php7-pecl-uuid@testing \
        php7-ctype


COPY docker-entrypoint.sh /usr/local/bin/
RUN mkdir -p /docker-entrypoint.d/ /var/www/

# forward log to docker log collector
RUN ln -sf /dev/stdout /var/log/unit.log
RUN adduser -D -s /bin/bash -u 1000 user &&\
    chown -R user:user /var/www/

RUN if [ ${USER_ID:-1000} -ne 1000 ] && [ ${GROUP_ID:-1000} -ne 1000 ]; then \
    userdel -f user &&\
    if getent group user ; then groupdel user; fi &&\
    groupadd -g ${GROUP_ID} user &&\
    useradd -l -u ${USER_ID} -g user user &&\
    install -d -m 0755 -o user -g user /home/user &&\
    chown --changes --silent --no-dereference --recursive \
          --from=1000:1000 ${USER_ID}:${GROUP_ID} \
        /home/user \
        /var/www \
;fi

STOPSIGNAL SIGTERM

WORKDIR /var/www/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["unitd","--user", "user", "--group", "user", "--no-daemon", "--control", "unix:/var/run/control.unit.sock"]