#!/usr/bin/ruby

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
  fp = File.open(arg,'r')
  dirnum = arg[7...8]
  filenum = arg[33...35]
  sentences = fp.readlines
  sentences.each do |line|
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
    (0..sentence.length).each do |window_size|
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
end

puts "\n\n\n++++++++++++PRES++++++++++++++++"
puts "\n\n\n"
pres = all_patterns.sort_by {|k,v| v[0]}.reverse


pres.each do |ar|
  puts "#{ar[0]}\t#{ar[1][0]}"
end

puts "\n\n\n++++++++++++MIDS++++++++++++++++"
puts "\n\n\n"
mids = all_patterns.sort_by {|k,v| v[1]}.reverse
mids.each do |ar|
  puts "#{ar[0]}\t#{ar[1][1]}"
end

puts "\n\n\n++++++++++++POSTS++++++++++++++++"

puts "\n\n\n"
posts = all_patterns.sort_by {|k,v| v[2]}.reverse
posts.each do |ar|
  puts "#{ar[0]}\t#{ar[1][2]}"
end




end


# main
if __FILE__ == $0
  make_patterns
end

