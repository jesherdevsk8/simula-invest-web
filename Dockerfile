FROM ruby:3.3.4-slim-bookworm AS base

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 4567

ENV RACK_ENV=production
ENV APP_ENV=production

CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0"]