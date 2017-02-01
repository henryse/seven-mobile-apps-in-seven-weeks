FROM ruby:2.3

ADD api /usr/src/api
WORKDIR /usr/src/api

RUN cd /usr/src/api/ \
    && bundle

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]