FROM certbot/certbot
MAINTAINER Brian Stack <im.bstack@gmail.com>

RUN pip install certbot-s3front

ENV site /site

RUN mkdir $site
WORKDIR $site
ADD script.sh $site
