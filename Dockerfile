FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libpcre3 \
    libpcre3-dev \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    gettext-base \
    dos2unix \
    curl 

# download nginx
RUN wget http://nginx.org/download/nginx-1.25.1.tar.gz \
    && tar -zxvf nginx-1.25.1.tar.gz

# download kaltura module
RUN wget https://github.com/kaltura/nginx-vod-module/archive/refs/tags/1.33.tar.gz \
    && tar -zxvf 1.33.tar.gz 

RUN cd nginx-1.25.1 \
    && ./configure \
    --add-module=/nginx-vod-module-1.33 \
    --prefix=/etc/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/run/nginx.pid \
    --sbin-path=/usr/sbin/nginx \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_stub_status_module \
    --with-http_realip_module \
    --with-file-aio \
    --with-threads \
    --with-stream \
    --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic' \
    && make \
    && make install

WORKDIR /nginx
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./nginx.service /lib/systemd/system/nginx.service

CMD [ "systemctl", "start","nginx.service " ]