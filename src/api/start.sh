#!/usr/bin/env bash

bin/rake db:migrate RAILS_ENV=development
rails server -b 0.0.0.0