#!/bin/sh

gem build nomadic.gemspec
bundle install
sudo gem install nomadic-*.gem
