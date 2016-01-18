#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------

FROM alpine:3.2
MAINTAINER Marc Villacorta Morera <marc.villacorta@gmail.com>

#------------------------------------------------------------------------------
# Environment variables:
#------------------------------------------------------------------------------

ENV PORTUS_VERSION="2.0.0" \
    NOKOGIRI_USE_SYSTEM_LIBRARIES="1"

#------------------------------------------------------------------------------
# Install:
#------------------------------------------------------------------------------

RUN apk add --update -t deps git ruby-mini_portile gcc make musl-dev \
    libxml2-dev libxslt-dev mariadb-dev \
    && apk add bash ruby-bundler ruby-dev nodejs tzdata libxslt mariadb-libs mariadb-client \
    && echo 'gem: --verbose --no-document' > /etc/gemrc; cd /tmp \
    && git clone https://github.com/SUSE/Portus.git .; mkdir /portus \
    && git archive ${PORTUS_VERSION} | tar -xC /portus; cd /portus \
    && bundle install --retry=3 \
    && apk del --purge deps; rm -rf /tmp/* /var/cache/apk/*

#------------------------------------------------------------------------------
# Populate root file system:
#------------------------------------------------------------------------------

ADD rootfs /

#------------------------------------------------------------------------------
# Expose ports and entrypoint:
#------------------------------------------------------------------------------

WORKDIR /portus
EXPOSE 80
ENTRYPOINT ["/init"]
