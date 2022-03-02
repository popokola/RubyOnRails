### Set Rails app

# Documentation:
https://docs.docker.com/samples/rails/

# Before starting, install Docker compose
https://docs.docker.com/compose/install/

# Create a folder with the application name
Student_blog

#############################################
# There are 5 files to add before running docker-compose run !!!
# Dockerfile, docker-compose.yml, Gemfile, Gemfile.lock, entrypoint.sh

#############################################
# Dockerfile
FROM ruby:3.0.0

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client npm
RUN npm i -g yarn && yarn

RUN mkdir /Student_blog
WORKDIR /Student_blog
COPY Gemfile /Student_blog/Gemfile
COPY Gemfile.lock /Student_blog/Gemfile.lock
RUN bundle install
COPY . /Student_blog

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
#############################################

#############################################
# docker-compose.yml
version: "3.4"
services:
  db:
    image: postgres
    volumes:
      - ./tmp/db:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: password
  web:
    build: .
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"
    volumes:
      - .:/Student_blog
    ports:
      - "3000:3000"
    depends_on:
      - db
#############################################

#############################################
# Create a Gemfile
source 'https://rubygems.org'

gem 'rails', '~> 6.1.3', '>= 6.1.3.1'
#############################################

#############################################
# Create a empty Gemfile.lock
#############################################

#############################################
# Next, provide an entrypoint script to fix a Rails-specific issue that prevents the server from restarting when a 
# certain server.pid file pre-exists. This script will be executed every time the container gets started. entrypoint.sh 
# consists of:

# Create entrypoint.sh

#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /Student_blog/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
#############################################


#############################################
# run new app
docker-compose run --no-deps web rails new . --force --database=postgresql


#LINUX !!!
# If you are running Docker on Linux, the files rails new created are owned by root. 
#This happens because the container runs as the root user. If this is the case, change the ownership of the new files.
sudo chown -R $USER:$USER .


# Now that you’ve got a new Gemfile, you need to build the image again
# docker build
docker-compose build


# Dans le fichier Student_blog/config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  # ajouter ces 3 lignes
  ####################
  host: db
  username: postgres
  password: password
  ####################
  pool: 5

development:
  <<: *default
  database: new_app_development


test:
  <<: *default
  database: new_app_test


# boot app (it launchs the Rails server)
docker-compose up

# in another window terminal, create database with the following command:
docker-compose run web rake db:create

# Visit the following url
http://localhost:3000

# webpacker install (normally it should be installed in the docker-compose run)
docker-compose run web rails webpacker:install

# Now you should have a working app !!!
#############################################

#############################################
# others commands

# stop app
docker-compose down

# rebuild and restart app
docker-compose up --build.
#############################################















