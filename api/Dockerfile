FROM ruby:3.2.2

ENV BUNDLE_PATH /bundle

RUN apt-get update -qq && apt-get install

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN gem install bundler -v $(grep -A1 "BUNDLED WITH" Gemfile.lock | tail -n 1 | tr -d ' ')
RUN bundle install

COPY . /app

EXPOSE 9292

CMD bundle exec rackup --host 0.0.0.0 --port 9292