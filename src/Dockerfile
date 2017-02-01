FROM ruby:2.3

ADD api /usr/src/api
WORKDIR /usr/src/api

RUN cd /usr/src/api/ \
    && bundle

EXPOSE 3000
CMD ["sh", "start.sh"]