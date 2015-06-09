FROM        debian:latest
MAINTAINER  Benoit <benoit@terra-art.net>

# Set Environement variables
ENV         LC_ALL=C
ENV         DEBIAN_FRONTEND=noninteractive
ENV         OPENSMTPD_VERSION=latest

# Update package repository and install packages
RUN         apt-get -y update && \
            apt-get -y install automake autoconf bison libssl-dev libevent-dev libtool wget && \
            apt-get clean
            

# Fetch the latest software version from the official website if needed
WORKDIR     /tmp
RUN         mkdir /var/empty && \
            useradd -c "SMTP Daemon" -d /var/empty -s /sbin/nologin _smtpd && \
            useradd -c "SMTPD Queue" -d /var/empty -s /sbin/nologin _smtpq && \
            wget https://www.opensmtpd.org/archives/libasr-${OPENSMTPD_VERSION}.tar.gz && \
            tar xvzf libasr-${OPENSMTPD_VERSION}.tar.gz && \
            wget https://www.opensmtpd.org/archives/opensmtpd-portable-${OPENSMTPD_VERSION}.tar.gz && \
            tar xvzf opensmtpd-portable-${OPENSMTPD_VERSION}.tar.gz && \
WORKDIR     /tmp/libasr-*
RUN         ./configure && make && make install
WORKDIR     /tmp/opensmtpd-*
RUN         ./configure && make && make install
WORKDIR     /tmp
RUN         rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add configuration files. User can provides customs files using -v in the image startup command line.
COPY        smtpd.conf /etc/mail/smtpd.conf

# Expose SMTP port
EXPOSE      25

# Last but least, unleach the daemon!
WORKDIR     /root
ENTRYPOINT  ["/usr/local/sbin/smtpd", "-d", "-f", "/etc/mail/smtpd.conf"]
