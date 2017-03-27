FROM ruby:2.3.1
MAINTAINER Brian Stack <im.bstack@gmail.com>

ENV site /site

RUN mkdir $site
WORKDIR $site
ADD Gemfile $site
ADD Gemfile.lock $site

RUN bundle install
RUN apt-get update
RUN apt-get install -y awscli
