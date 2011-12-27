#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*- 

require 'pp'
require 'yaml'



def make_patterns(files)

all_patterns = Hash.new
pre = 0
mid = 1
post = 2
min_print = 10

if files.nil?
  puts "error"
else
  to_run = files
end


to_run.each do |arg|
  puts arg
  fp = File.open(arg,'r')
  dirnum = arg[7...8]
  filenum = arg[33...35]
  data = fp.readlines
  num_lines_to_process = data.length
  data.each_index do |li|
    line = data[li]
    $stderr.print "\rFile: #{arg} Line: #{li} / #{num_lines_to_process}"
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
        break if i+window_size >= words.length
        num_above = found_adjs.select {|v| v>(i+window_size)}.length
        num_below = found_adjs.select {|v| v<i}.length
        this_word = words[i..i+window_size].join(" ")
        this_pos = pos[i..i+window_size].join(" ")
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
  fp.puts "---pres---"
  pres = all_patterns.sort_by {|k,v| -v[pre]}
 
  pres.each do |ar|
    fp.puts "#{ar[0]}\tpre\t#{ar[1][pre]}" if ar[1][pre] > min_print
  end

  # mid patterns
  fp.puts "---mids---"
  mids = all_patterns.sort_by {|k,v| -v[mid]}
  mids.each do |ar|
    fp.puts "#{ar[0]}\tmid\t#{ar[1][mid]}" if ar[1][mid] > min_print
  end

  # post patterns
  fp.puts "---post---"
  posts = all_patterns.sort_by {|k,v| -v[post]}
  posts.each do |ar|
    fp.puts "#{ar[0]}\tpst\t#{ar[1][post]}" if ar[1][post] > min_print
  end
  fp.close

end




end


# main
if __FILE__ == $0
  make_patterns(ARGV)
end

