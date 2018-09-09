FROM alpine:3.8

RUN apk --no-cache add ca-certificates libotr openssl glib ncurses

ENV HOME /home/user
RUN adduser -u 1001 -D user \
	&& mkdir -p $HOME/.irssi \
	&& chown -R user:user $HOME

ENV LANG C.UTF-8

ENV IRSSI_VERSION 1.1.1

RUN set -x \
	&& apk add --no-cache --virtual .irssi-builddeps \
		autoconf automake coreutils gcc glib-dev libc-dev libtool \
		make ncurses-dev openssl-dev perl-dev pkgconf tar git libotr-dev \
		xz gnupg \
	&& wget https://github.com/irssi/irssi/releases/download/${IRSSI_VERSION}/irssi-${IRSSI_VERSION}.tar.xz -O /tmp/irssi.tar.xz \
	&& wget "https://github.com/irssi/irssi/releases/download/${IRSSI_VERSION}/irssi-${IRSSI_VERSION}.tar.xz.asc" -O /tmp/irssi.tar.xz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 7EE65E3082A5FB06AC7C368D00CCB587DDBEF0E1 \
	&& gpg --batch --verify /tmp/irssi.tar.xz.asc /tmp/irssi.tar.xz \
	&& gpgconf --kill all \
	&& rm -rf "$GNUPGHOME" /tmp/irssi.tar.xz.asc \
	&& mkdir -p /usr/src/irssi \
	&& cd /usr/src \
	&& git clone https://github.com/cryptodotis/irssi-otr.git \
	&& tar -xf /tmp/irssi.tar.xz -C /usr/src/irssi --strip-components 1 \
	&& rm /tmp/irssi.tar.xz \
	&& cd irssi \
	&& ./configure --prefix=/usr --enable-true-color --with-bot --with-proxy --with-socks --with-perl \
	&& make \
	&& make install \
	&& cd ../irssi-otr \
	&& git checkout ea5b8e09506a1d6c7bb51651e19fa1165e373c61 \
	&& ./bootstrap \
	&& ./configure --prefix=/usr \
	&& make \
	&& make install \
	&& rm -rf /usr/src \
	&& RUNDEPS="$(scanelf --needed --nobanner --format '%n#p' --recursive /usr \
		| tr ',' '\n' \
		| sort -u \
		| awk 'system("[ -e /usr/lib/" $1 " ]") == 0 { next } { print "so:" $1 }')" \
	&& apk add --no-cache --virtual .irssi-rundeps $RUNDEPS \
	&& apk del --virtual .irssi-builddeps

WORKDIR $HOME

USER user
CMD ["irssi"]

