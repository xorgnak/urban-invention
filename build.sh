#!/bin/sh

git pull
gem build nomadic.gemspec
sudo gem install nomadic-*.gem
