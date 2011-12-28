#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require './get_adj_groups.rb'
require 'pp'


pattern_file = './jpn_structures'
patterns = File.open(pattern_file,'r').readlines

adjs = get_groups_simple

puts adjs.first
return ''

counts = Hash.new

ARGV.each do |arg|
  sentences = File.open(arg,'r').readlines
  sentences.each do |sentence|
    adjs.each do |adj_a|
      adjs.each do |adj_b|
        next if adj_a==adj_b
        next if (sentence.match(adj_a).nil? || sentence.match(adj_b).nil?) 
        patterns.each do |pattern|
          fst_pattern = pattern.sub("{A}",adj_a).sub("{B}", adj_b)
          sec_pattern = pattern.sub("{A}",adj_b).sub("{B}", adj_a)
          counts[fst_pattern]+=1 if sentence.match(fst_pattern)
          counts[sec_pattern]+=1 if sentence.match(sec_pattern)
        end
      end
    end
  end
end



