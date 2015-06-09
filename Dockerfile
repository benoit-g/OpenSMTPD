FROM        debian:latest
MAINTAINER  Benoit <benoit@terra-art.net>

# Set Environement variables
ENV         LC_ALL=C
ENV         DEBIAN_FRONTEND=noninteractive
ENV         OpenSMTPD_VERSION=latest

# Update package repository and install packages
RUN         apt-get -y update && \
            apt-get -y install automake autoconf bison libssl-dev libevent-dev libtool wget && \
            apt-get clean && \
            rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Fetch the latest software version from the official website if needed
RUN         test ! -x /usr/local/sbin/smtpd && \
            mkdir /var/empty && /
            useradd -c "SMTP Daemon" -d /var/empty -s /sbin/nologin _smtpd && \
            useradd -c "SMTPD Queue" -d /var/empty -s /sbin/nologin _smtpq && \
            wget https://www.opensmtpd.org/archives/libasr-${OpenSMTPD_VERSION}.tar.gz && \
            tar xvzf libasr-${OpenSMTPD_VERSION}.tar.gz && \
            cd libasr* && \
            ./configure && \
            make && \
            make install &&
            cd .. && \
            wget https://www.opensmtpd.org/archives/opensmtpd-portable-${OpenSMTPD_VERSION}.tar.gz && \
            tar xvzf opensmtpd-portable-${OpenSMTPD_VERSION}.tar.gz && \
            cd opensmtpd* && \
            ./configure && \
            make && \
            make install && \
            mkdir -p /etc/mail && \
            ln -ls /etc/aliases /etc/mail/aliases

# Add configuration files. User can provides customs files using -v in the image startup command line.
COPY        smtpd.conf /etc/mail/smtpd.conf

# Expose SMTP port
EXPOSE      25

# Last but least, unleach the daemon!
ENTRYPOINT  ["/usr/local/sbin/smtpd", "-d", "-f", "/etc/mail/smtpd.conf"]
