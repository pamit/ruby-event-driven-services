FROM ruby:3.3.5

WORKDIR /app

RUN apt-get update -qq && apt-get install -y --no-install-recommends build-essential

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

ENV RACK_ENV=development

EXPOSE 4567

CMD ["bundle", "exec", "puma", "-C", "puma.rb"]
