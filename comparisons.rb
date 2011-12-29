#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require './get_adj_groups.rb'
require 'pp'

@counts = Hash.new
@num_found = 0

def inc_count(item)
  @counts[item] = 0 if @counts[item].nil?
  @counts[item]+=1
  @num_found+=1
end

def prpa(files)

pattern_file = './jpn_structures.txt'
patterns = File.open(pattern_file,'r').readlines

adjs_groups = get_groups_simple
#adjs = adjs.first[1]

adjs_groups.each {|synsetid, adjs| adjs.each {|adj| adj.strip!}}


#test_sentence = "壮絶.*大胆不敵といえるほど"
#test_sentence = "壮絶大胆不敵ともいえる"
num_sentences = 0
files.each do |arg|
  sentences = File.open(arg,'r').readlines
  sentences.each do |line|
    line = line.split('-divider-') #currently ignoring POS tags...
    next if line[1].nil?
    sentence = line[0].gsub(" ", "")
    num_sentences+=1
    $stderr.print "\r#{num_sentences} / #{sentences.length} : found: #{@num_found}" if num_sentences % 200 == 0
    adjs_groups.each do |synsetid, adjs|
    #adjs = adjs_groups["01385255-a"] # `big`
    adjs.each_index do |i|
      adj_a = adjs[i]
      next if sentence.match(adj_a).nil?
      adjs.each_index do |j|
        adj_b = adjs[j]
        next if adj_a==adj_b
        next if sentence.match(adj_b).nil? 
        patterns.each do |pattern|
          fst_pattern = pattern.sub("{A}",adj_a).sub("{B}", adj_b).strip
          inc_count(fst_pattern) if !sentence.match(fst_pattern).nil?
        end
      end
    end
    end
  end
end
puts ''
pp @counts
puts @num_found
end

if __FILE__ == 0
  prpa(ARGV)
end

