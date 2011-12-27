#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require './WNJpn.rb'

dbfile = "../wnjpn.db"
wnj = WNJpn.new(dbfile)

file_first = ARGV[0]
file_last = ARGV[1]

file_dir = "../posfiles/"
file_type = ".txt"

output_filename = "../results"

synsetid = 5
wordid_id = 0
word_id = 2
max_results = 50
per_file_limit = 10000

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

#puts test_synsetids.first

file_output = File.open("#{output_filename}.txt",'w+')
lines_checked = 0
num_results = 0
num_results_this_fpo = 0
num_out_files = 1

(file_first..file_last).each do |i|
  $stderr.print "\rFile #: #{i} / #{file_last} Results : #{num_results}"
  filename = "#{file_dir}#{i}#{file_type}"
  fp = File.open(filename)
  lines = fp.readlines
  lines.each do |line|
    next if line=="nil\n"
    divided = line.split("-divider-")
    next if divided[1].nil?
    lines_checked+=1
    sentence = divided[0]
    test_synsetids.each_pair do |id,syn_ar|
      count = 0
      syn_ar.each do |word, wordid|
        count+=1 if !line.match(word).nil?
      end
      next if count <= 1
      file_output.puts line
      num_results+=1
      num_results_this_fpo+=1
      if num_results_this_fpo > per_file_limit
        file_output.close
        file_output = File.open("#{output_filename}#{num_out_files}.txt","w+")
        num_out_files+=1
        num_results_this_fpo = 0
      end
    end
  end
end
puts "number of checked: #{lines_checked}"
puts "number of results: #{num_results}"
