FROM debian:jessie

MAINTAINER Sulaeman <me@sulaeman.com>

ENV MONGODB_VERSION=1.2.3 \
    HHVM_VERSION=3.18

# Add the necessary keys
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449

# Add to repository sources list
RUN echo deb http://dl.hhvm.com/debian jessie-lts-${HHVM_VERSION} main | tee /etc/apt/sources.list.d/hhvm.list

# Install dependencies, HHVM MongoDB Driver, Install Composer and make it available in the PATH, and clean up
RUN apt-get update \
  && apt-get install -y \
    rsyslog \
    cron \
    libmagickwand-dev \
    libcurl4-openssl-dev \
    libpq-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libxslt1-dev \
    supervisor \
    wget \
    imagemagick \
    hhvm hhvm-dev \
  && wget -P /tmp/ https://github.com/mongodb/mongo-hhvm-driver/releases/download/${MONGODB_VERSION}/hhvm-mongodb-${MONGODB_VERSION}.tgz \
  && mkdir /tmp/hhvm-mongodb && cd /tmp/hhvm-mongodb \
  && tar -xvzf /tmp/hhvm-mongodb-${MONGODB_VERSION}.tgz \
  && cd /tmp/hhvm-mongodb/hhvm-mongodb-${MONGODB_VERSION} \
  && hphpize && cmake . && make configlib \
  && make -j 4 \
  && make install \
  && rm /tmp/hhvm-mongodb-${MONGODB_VERSION}.tgz \
  && rm -Rf /tmp/hhvm-mongodb \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
  && apt-get update \
  && apt-get purge -y --auto-remove \
    libmagickwand-dev \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libxslt1-dev \
    wget \
    hhvm-dev \
  && rm -rf /var/lib/apt/lists/*

COPY docker-startup.sh /docker-startup.sh
RUN chmod +x /docker-startup.sh

RUN usermod -u 1000 www-data

RUN chown www-data:1000 /var/run/hhvm

WORKDIR /var/www

EXPOSE 9001

CMD ["sh", "/docker-startup.sh"]
