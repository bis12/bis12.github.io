FROM debian:9.0
MAINTAINER Brian Stack <im.bstack@gmail.com>

RUN apt-get update
RUN apt-get install -y certbot
RUN apt-get install -y python-pip python-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev zlib1g-dev dialog

RUN pip install certbot-s3front

ENV site /site

RUN mkdir $site
WORKDIR $site
ADD script.sh $site
