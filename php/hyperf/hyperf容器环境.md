## 直接在hyperf镜像中执行命令
```bash
docker run --name hyperf2.0 -p 9501:9501 -v /data/wwwroot/php/hyperf2.0/:/hyperf -it --entrypoint /bin/bash hyperf/hyperf:latest
```

## dockerfile
```
FROM hyperf/hyperf:latest
LABEL maintainer="Hyperf Developers <group@hyperf.io>" version="1.0" license="MIT" app.name="Hyperf"

# --build-arg timezone=Asia/Shanghai
ARG timezone

ENV TIMEZONE=${timezone:-"Asia/Shanghai"} \
    COMPOSER_VERSION=1.9.1 \
    APP_ENV=prod

# update
RUN set -ex \
    && apk update \
    # install composer
    && cd /tmp \
    # show php version and extensions
    && php -v \
    && php -m \
    && php --ri swoole \
    #  ---------- some config ----------
    && cd /etc/php7 \
    # - config PHP
    && { \
        echo "upload_max_filesize=100M"; \
        echo "post_max_size=108M"; \
        echo "memory_limit=1024M"; \
        echo "date.timezone=${TIMEZONE}"; \
    } | tee conf.d/99_overrides.ini \
    # - config timezone
    && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    # ---------- clear works ----------
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man \
    && echo -e "\033[42;37m Build Completed :).\033[0m\n"

WORKDIR /opt/www

EXPOSE 9501

ENTRYPOINT ["php", "/opt/www/bin/hyperf.php", "start"]
```

## 构建和运行
```bash
docker build -t my_hyperf2.0:v1 .
docker run --name hyperf2.0 -p 9501:9501 -v /data/wwwroot/php/hyperf2.0/:/opt/www my_hyperf2.0:v1
```

## 监控运行
```bash
php bin/hyperf.php server:watch
```


