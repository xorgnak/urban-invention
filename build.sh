#!/bin/sh

gem build nomadic.gemspec
sudo gem install bundle
bundle install
sudo gem install nomadic-*.gem
