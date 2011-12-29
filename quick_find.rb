#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'pp'

@counts = Hash.new

def inc_counts(item)
  @counts[item] = 0 if @counts[item].nil?
  @counts[item]+=1
end


word_a = "大きい"
word_b = "巨大"
pattern_a = "#{word_a}[^、]*#{word_b}"
pattern_b = "#{word_b}[^、]*#{word_a}"
filenm = 0
ttlfl = ARGV.length
ARGV.each do |arg|
  filenm+=1
  lines = File.open(arg, 'r').readlines
  linenum = 0
  totallines = lines.length
  lines.each do |line|
    linenum+=1
    $stderr.print "\r#{linenum} / #{totallines} : #{filenm} / #{ttlfl}" if linenum % 500 == 0
    line = line.split('-divider-')
    next if line[1].nil?
    sentence = line[0].strip
    next if (sentence.match(word_a).nil? || sentence.match(word_b).nil?)
    m = sentence.match(pattern_a)
    inc_counts(m[0]) if !m.nil?
    m2 = sentence.match(pattern_b)
    inc_counts(m2[0]) if !m2.nil?
  end
end

pp @counts

