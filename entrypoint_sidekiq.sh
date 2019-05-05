#!/bin/bash
bundle install && bundle exec sidekiq -q mailers -q reanalyses -q scrapers -L log/sidekiq.log
