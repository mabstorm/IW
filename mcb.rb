#!/usr/bin/ruby

require 'MeCab'

c = MeCab::Tagger.new()

ARGV.each do |arg|

  next if !arg.slice("stripped.txt").nil?

  fpo = File.open("#{arg}-stripped.txt",'w+')


