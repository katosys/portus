#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------

FROM alpine:3.4
MAINTAINER Marc Villacorta Morera <marc.villacorta@gmail.com>

#------------------------------------------------------------------------------
# Environment variables:
#------------------------------------------------------------------------------

ENV PORTUS_VERSION="master" \
    NOKOGIRI_USE_SYSTEM_LIBRARIES="1"

#------------------------------------------------------------------------------
# Install:
#------------------------------------------------------------------------------

RUN apk --no-cache add --update -t deps git gcc make musl-dev libxml2-dev \
    libxslt-dev mariadb-dev openssl-dev libffi-dev curl-dev \
    && apk --no-cache add bash ruby-bundler ruby-dev nodejs tzdata libxslt \
    mariadb-libs mariadb-client openssl ruby-io-console ruby-bigdecimal \
    mariadb-client-libs libcurl \
    && echo 'gem: --verbose --no-document' > /etc/gemrc; cd /tmp \
    && git clone https://github.com/SUSE/Portus.git . \
    && git checkout ${PORTUS_VERSION}; mkdir /portus \
    && git archive ${PORTUS_VERSION} | tar -xC /portus \
    && git rev-parse --short HEAD > /portus/VERSION; cd /portus \
    && sed -i 's/mysql2 (0.3.18)/mysql2 (0.4.4)/' Gemfile.lock \
    && gem update --system \
    && bundle install --retry=3 --no-cache --clean && gem cleanup \
    && apk del --purge deps; bash -c "rm -rf /{tmp,root}/{*,.??*}" \
    && rm -rf /usr/lib/ruby/gems/*/cache/* /var/cache/apk/*

#------------------------------------------------------------------------------
# Populate root file system:
#------------------------------------------------------------------------------

ADD rootfs /

#------------------------------------------------------------------------------
# Expose ports and entrypoint:
#------------------------------------------------------------------------------

WORKDIR /portus
EXPOSE 80 443
ENTRYPOINT ["/init"]
