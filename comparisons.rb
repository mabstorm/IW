#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require './get_adj_groups.rb'
require 'pp'

@counts = Hash.new

def inc_count(item)
  @counts[item] = 0 if @counts[item].nil?
  @counts[item]+=1
end

pattern_file = './jpn_structures.txt'
patterns = File.open(pattern_file,'r').readlines

adjs = get_groups_simple
adjs = adjs.first[1]
adj_a = adjs[0]
adj_b = adjs[1]

#test_sentence = "壮絶.*大胆不敵といえるほど"
#test_sentence = "壮絶大胆不敵ともいえる"


ARGV.each do |arg|
  sentences = File.open(arg,'r').readlines
  sentences.each do |line|
    line = line.split('-divided-') #currently ignoring POS tags...
    next if line[1].nil?
    sentence = line[1]
    adjs.each do |adj_a|
      adjs.each do |adj_b|
        next if adj_a==adj_b
        next if (sentence.match(adj_a).nil? || sentence.match(adj_b).nil?) 
        patterns.each do |pattern|
          fst_pattern = pattern.sub("{A}",adj_a).sub("{B}", adj_b).strip
          sec_pattern = pattern.sub("{A}",adj_b).sub("{B}", adj_a).strip
          inc_count(fst_pattern) if !sentence.match(fst_pattern).nil?
          inc_count(sec_pattern) if !sentence.match(sec_pattern).nil?
        end
      end
    end
  end
end

pp @counts


