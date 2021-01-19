#!/bin/sh

git pull
gem build nomadic.gemspec
sudo bundle install
sudo gem install nomadic-*.gem
