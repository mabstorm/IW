#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'pp'

@counts = Hash.new

def inc_counts(item)
  @counts[item] = 0 if @counts[item].nil?
  @counts+=1
end


word_a = "大きい"
word_b = "巨大"
pattern_a = "#{word_a}.*#{word_b}"
pattern_b = "#{word_b}.*#{word_a}"
ARGV.each do |arg|
  lines = File.open(arg, 'r').readlines
  lines.each do |line|
    line = line.split('-divider-')
    next if line[1].nil?
    sentence = line[0].strip
    next if (sentence.match(word_a).nil? || sentence.match(word_b).nil?)
    m = sentence.match(pattern_a)
    inc_counts(m) if !m.nil?
    m2 = sentence.match(pattern_b)
    inc_counts(m2) if !m2.nil?
  end
end

pp @counts

