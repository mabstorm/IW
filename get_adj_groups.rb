#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require './WNJpn.rb'

output_file = "./adjgroups"

def print_adjs_groups
  
  fp = File.open(output_file,'w+')
  synsetid = 5
  wordid_id = 0
  word_id = 2
  max_results = 50

  adjs = wnj.get_adj_sets
  counts=Hash.new(0)
  adjs.each {|adj| counts[adj[synsetid]]+=1}

  results = counts.sort_by{|k,v| -v}

  num_results = 0

  test_synsetids = Hash.new

  results.each do |synset, num|
    num_results+=1
    break if num_results > max_results
    #puts "#{synset}=#{num}"
    test_synsetids[synset] = Array.new
  end

  adjs.each do |adj|
    synset = adj[synsetid]
    next if test_synsetids[synset].nil?
    word = adj[word_id]
    wordid = adj[wordid_id]
    test_synsetids[synset].push([word,wordid])
  end

  test_synsetids.each_pair do |synset, wordar|
    fp.print '#{synset}\t'
    wordar.each_index do |i|
      fp.print '#{wordar[i][0]}--#{wordar[i][1]}\t'
    end
  end
end

def read_adjs_groups
  fp = File.open(output_file, 'r')
  data = fp.readlines
  test_synsetids = Hash.new
  data.each do |line|
    line = line.split('\t')
    synset = line[0]
    test_synsetids[synset] = Array.new
    (1..length(line)).each do |i|
      wordpair = line[i].split('--')
      test_synsetids[synset].push(wordpair)
    end
  end
  return test_synsetids
end

def read_adjs_groups_simple
  fp = File.open(output_file, 'r')
  data = fp.readlines
  test_synsetids = Hash.new
  data.each do |line|
    line = line.split('\t')
    synset = line[0]
    test_synsetids[synset] = Array.new
    (1..length(line)).each do |i|
      wordpair = line[i].split('--')
      test_synsetids[synset].push(wordpair[0])
    end
  end
  return test_synsetids
end


def get_groups
  print_adjs_groups if !File.exist? output_file
  read_adjs_groups
end

def get_groups_simple
  print_adjs_groups if !File.exist? output_file
  read_adjs_groups_simple
end
