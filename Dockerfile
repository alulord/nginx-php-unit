FROM alpine:edge

MAINTAINER "Peter Simoncic"

RUN apk add --no-cache bash shadow nano curl unit unit-php7 php7-mysqli

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

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["unitd","--user", "user", "--group", "user", "--no-daemon", "--control", "unix:/var/run/control.unit.sock"]