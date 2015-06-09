FROM        debian:latest
MAINTAINER  Benoit <benoit@terra-art.net>

# Set Environement variables
ENV         LC_ALL=C
ENV         DEBIAN_FRONTEND=noninteractive
ENV         OPENSMTPD_VERSION=latest

# Update package repository and install packages
RUN         apt-get -y update && \
            apt-get -y install automake autoconf bison libssl-dev libevent-dev libtool wget && \
            apt-get clean && \
            rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Fetch the latest software version from the official website if needed
RUN         test ! -x /usr/local/sbin/smtpd && \
            mkdir /var/empty && \
            useradd -c "SMTP Daemon" -d /var/empty -s /sbin/nologin _smtpd && \
            useradd -c "SMTPD Queue" -d /var/empty -s /sbin/nologin _smtpq

RUN         wget https://www.opensmtpd.org/archives/libasr-${OPENSMTPD_VERSION}.tar.gz
RUN         tar xvzf libasr-${OPENSMTPD_VERSION}.tar.gz
RUN         cd libasr*
RUN         ./configure
RUN         make
RUN         make install
RUN         cd ..
RUN         wget https://www.opensmtpd.org/archives/opensmtpd-portable-${OPENSMTPD_VERSION}.tar.gz
RUN         tar xvzf opensmtpd-portable-${OPENSMTPD_VERSION}.tar.gz
RUN         cd opensmtpd*
RUN         ./configure
RUN         make
RUN         make install
RUN         cd ..
RUN         rm -rf libasr* opensmtpd*

# Add configuration files. User can provides customs files using -v in the image startup command line.
COPY        smtpd.conf /etc/mail/smtpd.conf

# Expose SMTP port
EXPOSE      25

# Last but least, unleach the daemon!
ENTRYPOINT  ["/usr/local/sbin/smtpd", "-d", "-f", "/etc/mail/smtpd.conf"]
