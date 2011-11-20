#!/usr/bin/ruby

require 'MeCab'
sentence = "太郎はこの本を二郎を見た女性に渡した。"

c = MeCab::Tagger.new()

ARGV.each do |arg|
  fp = File.open(arg,'r')
  data = fp.readlines
  data.each do |sentence|
    puts sentence
    puts c.parse(sentence)

    n = c.parseToNode(sentence)

    while n do
      #print n.surface, "\t", n.feature, "\t", n.cost, "\n"
      print n.surface, "\t", n.feature.split(",").first
      n = n.next
    end
    puts ''
    break
  end
end

