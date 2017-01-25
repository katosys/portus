#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------

FROM alpine:3.5
MAINTAINER Marc Villacorta Morera <marc.villacorta@gmail.com>

#------------------------------------------------------------------------------
# Environment variables:
#------------------------------------------------------------------------------

ENV PORTUS_VERSION="2.2.0rc2" \
    NOKOGIRI_USE_SYSTEM_LIBRARIES="1"

#------------------------------------------------------------------------------
# Install:
#------------------------------------------------------------------------------

RUN apk --no-cache add -U -t dev git gcc make musl-dev libxml2-dev \
    libxslt-dev mariadb-dev libressl-dev libffi-dev curl-dev \
    && apk --no-cache add -U bash ruby-bundler ruby-dev nodejs tzdata \
    libxslt mariadb-libs mariadb-client libressl ruby-io-console \
    ruby-bigdecimal mariadb-client-libs libcurl \
    && echo 'gem: --verbose --no-document' > /etc/gemrc; cd /tmp \
    && git clone https://github.com/SUSE/Portus.git . \
    && git checkout ${PORTUS_VERSION} -b build; mkdir /portus \
    && git archive ${PORTUS_VERSION} | tar -xC /portus \
    && git rev-parse --short HEAD > /portus/VERSION; cd /portus \
    && sed -i 's/mysql2 (0.3.18)/mysql2 (0.4.4)/' Gemfile.lock \
    && gem update --no-document --quiet --system \
    && bundle install --retry=3 --no-cache --clean && gem cleanup \
    && apk del --purge dev; bash -c "rm -rf /{tmp,root}/{*,.??*}" \
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
