FROM ruby:2.6.3

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos PM"

ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8

RUN apt-get update \
    && apt-get install -y \
        nodejs \
        python-pygments \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/

RUN gem install \
    github-pages \
    jekyll \
    jekyll-feed \
    jekyll-redirect-from \
    jekyll-seo-tag \
    kramdown \
    rdiscount \
    rouge

COPY compile.sh /

CMD ["/compile.sh"]
