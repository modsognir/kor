#!/usr/bin/ruby
require 'rubygems'
require 'thor'

#system "git pull origin master"

system "touch ~/.kor"

Dir.glob("*.thor").each do |e|
  system "thor install #{e}"
end