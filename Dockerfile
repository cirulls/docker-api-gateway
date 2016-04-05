FROM centos:latest
MAINTAINER Sandro Cirulli <sandro.cirulli@oup.com>

ENV OPENRESTY_VERSION=1.9.7.4

# install system dependencies and libraries
RUN yum clean all && yum -y update
RUN yum install -y \
		    readline-devel \
		    pcre-devel \
  		    openssl-devel \
		    gcc \
		    perl \
		    make \
                    curl \
                    tar 

# install openresty at default location /usr/local/openresty
RUN curl -sSL http://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz | tar -xvz \
 && cd openresty-${OPENRESTY_VERSION} \
 && ./configure \
		 --with-luajit \
                 --with-http_iconv_module \
                 --with-ipv6 \
                 -j2 \
 && make \
 && make install 

# copy 3scale nginx configuration files
COPY conf/nginx_123456789.conf /usr/local/openresty/nginx/conf/nginx_123456789.conf
COPY conf/nginx_123456789.lua /usr/local/openresty/nginx/conf/nginx_123456789.lua

# copy SSH certificate
COPY certificates/bundle.crt /usr/local/openresty/nginx/ssl/bundle.crt
COPY certificates/certificate.key /usr/local/openresty/nginx/ssl/certificate.key

EXPOSE 80 443 

CMD ["/usr/local/openresty/nginx/sbin/nginx","-p","/usr/local/openresty/nginx/","-c","/usr/local/openresty/nginx/conf/nginx_123456789.conf"]
