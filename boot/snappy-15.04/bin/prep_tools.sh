#!/bin/bash

docker build --tag=rpi-dev-sandbox - <<_END_
FROM armv7/armhf-ubuntu
MAINTAINER Jon Frisby

RUN export TERM=readline && \
  apt-get -y update && \
  apt-get -y install curl wget git golang ruby && \
  gem update --system --no-ri --no-rdoc && \
  gem install bundler --no-ri --no-rdoc && \
  gem --version && \
  ruby --version && \
  git --version && \
  go version

CMD ["/bin/bash"]
_END_
