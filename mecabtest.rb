#!/usr/bin/ruby

require 'MeCab'


class SenPos
  attr_accessor :sentence, :pos, :counts
  def initialize n
    @sentence = Array.new(size=n)
    @pos = Array.new(size=n)
    @counts = Hash.new(0)
  end
end



# main
if __FILE__ == $0

sentence = "太郎はこの本を二郎を見た女性に渡した。"

c = MeCab::Tagger.new()

tags = Hash.new # obtain all types of tags found

ARGV.each do |arg|
  fp = File.open(arg,'r')
  new_filename = "#{arg[0...35]}-pos.txt"
  next if File.exist? new_filename
  fpo = File.open(new_filename,'w+')
  data = fp.readlines
  final_ar = Array.new(size=data.length)
  final_i = 0

  data.each do |sentence|
    #puts sentence
    #puts c.parse(sentence)

    n = c.parseToNode(sentence)
    

    index = 0;
    sp = SenPos.new(n.length)
    while n do
      pos_tag = n.feature.match(/^[^,]*/)[0]
      if pos_tag=="BOS/EOS"
        n = n.next
        next
      end
      #print n.surface, "\t", n.feature, "\t", n.cost, "\n"
      sp.sentence[index] = n.surface
      sp.pos[index] = pos_tag
      sp.counts[pos_tag]+=1
      if tags[pos_tag].nil?
        tags[pos_tag] = pos_tag
      end
      n = n.next
      index+=1
    end
    #arprint sp.pos
    if sp.counts["形容詞"] + sp.counts["連体詞"] > 2
      #arprint sp.sentence
      final_ar[final_i] = "#{sp.sentence.join(" ")}-divider-#{sp.pos.join(" ")}"
      final_i+=1
    end
  end
  fpo.puts final_ar
end
  puts "---------------------\n------------------"
  puts tags.keys
end


