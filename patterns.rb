#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*- 

require 'pp'
require 'yaml'



def make_patterns

all_patterns = Hash.new
pre = 0
mid = 1
post = 2

if ARGV.empty?
  to_run = "./tsubame00.kototoi.org/doc0000000000-pos.txt"
else
  to_run = ARGV
end


to_run.each do |arg|
  puts arg
  fp = File.open(arg,'r')
  dirnum = arg[7...8]
  filenum = arg[33...35]
  data = fp.readlines
  data.each do |line|
    temp = line.split("-divider-")
    sentence = temp[0]
    pos_linked = temp[1]
    next if pos_linked.nil?
    words = sentence.split
    found_adjs = Array.new
    num_adjs = 0
    pos = pos_linked.split
    pos.each_index do |i|
      if pos[i]=="形容詞" || pos[i]=="連体詞"
        found_adjs[num_adjs] = i
        num_adjs+=1
      end
    end
    (0..10).each do |window_size|
      words.each_index do |i|
        num_above = found_adjs.select {|v| v>(i+window_size)}.length
        num_below = found_adjs.select {|v| v<i}.length
        this_word = words[i..i+window_size].join(" ") if i+window_size < words.length
        this_pos = pos[i..i+window_size].join(" ") if i+window_size < words.length
        key = "#{this_word}--#{this_pos}"
        if num_above > 1
          all_patterns[key] = [0,0,0] if all_patterns[key].nil?
          all_patterns[key][post]+=1
        end
        if num_below > 1
          all_patterns[key] = [0,0,0] if all_patterns[key].nil?
          all_patterns[key][pre]+=1
        end
        if num_above > 0 && num_below > 0
          all_patterns[key] = [0,0,0] if all_patterns[key].nil?
          all_patterns[key][mid]+=1
        end
      end
    end
  end
  fp.close
  fp = File.open("../patterns/#{arg}.patterns","w+")

  # pre patterns

  pres = all_patterns.sort_by {|k,v| v[pre]}.reverse
 
  pres.each do |ar|
    fp.puts "#{ar[0]}\t0\t#{ar[1][pre]}"
  end

  # mid patterns

  mids = all_patterns.sort_by {|k,v| v[mid]}.reverse
  mids.each do |ar|
    fp.puts "#{ar[0]}\t1\t#{ar[1][mid]}"
  end

  # post patterns

  posts = all_patterns.sort_by {|k,v| v[post]}.reverse
  posts.each do |ar|
    fp.puts "#{ar[0]}\t2\t#{ar[1][post]}"
  end
  fp.close

end




end


# main
if __FILE__ == $0
  make_patterns
end

