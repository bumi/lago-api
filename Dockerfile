FROM ruby:3.0.1-alpine

WORKDIR /app

COPY . /app
COPY ./Gemfile /app/Gemfile
COPY ./Gemfile.lock /app/Gemfile.lock
COPY ./start.sh /app/start.sh

RUN apk add --no-cache \
  git \
  bash \
  build-base \
  libxml2-dev \
  libxslt-dev \
  nodejs \
  python2 \
  tzdata \
  postgresql-dev

RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install

CMD ["./start.sh"]