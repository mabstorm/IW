#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'rubygems'
require 'sqlite3'

class WNJpn

  Word = Struct.new("Word",:wordid, :lang, :lemma, :pron, :pos)
  Sense = Struct.new("Sense",:synset, :wordid, :lang, :rank, :lexid, :freq, :src)
  Synset = Struct.new("Synset",:synset, :pos, :name, :src)
  SynLink = Struct.new("SynLink",:synset1, :synset2, :link, :src)

  def initialize(dbfile)
    @conn = SQLite3::Database.new(dbfile)
  end

  def get_adj_sets
    @conn.execute("SELECT word.*, sense.synset FROM word, sense WHERE word.lang='jpn' AND word.pos='a' AND word.wordid=sense.wordid AND word.wordid IN (SELECT wordid FROM sense WHERE lang='jpn' AND synset LIKE '%-a') ORDER BY sense.synset")
  end

  def get_words(lemma)
    @conn.execute("select * from word where lemma=?",lemma).map{|row|Word.new(*row)}
  end

  def get_word(wordid)
    Word.new(*@conn.get_first_row("select * from word where wordid=?",wordid))
  end

  def get_senses(word)
    @conn.execute("select * from sense where wordid=?",(word.wordid)).map{|row|Sense.new(*row)}
  end

  def get_sense(synset, lang="jpn")
    row = @conn.get_first_row("select * from sense where synset=? and lang=?",synset,lang)
    row ? Sense.new(*row) : nil
  end

  def get_synset(synset)
    row = @conn.get_first_row("select * from synset where synset=?",synset)
    row ? Synset.new(*row) : nil
  end

  def get_syn_links(sense, link)
    @conn.execute("select * from synlink where synset1=? and link=?",sense.synset,link).map{|row|SynLink.new(*row)}
  end

  def get_sys_links_recursive(senses, link, lang="jpn", depth=0)
    senses.each do |sense|
      syn_links = get_syn_links(sense, link)
      puts "#{'  ' * depth}#{get_word(sense.wordid).lemma} #{get_synset(sense.synset).name}" unless syn_links.empty?
      _senses = syn_links.map{|syn_link|get_sense(syn_link.synset2,lang)}.compact
      get_sys_links_recursive(_senses, link, lang, depth + 1)
    end
  end

  def main(word, link, lang='jpn')
    if words = get_words(word)
      sense = get_senses(words.first)
      get_sys_links_recursive(sense, link, lang)
    else
      STDERR.puts "(nothing found)"
    end
  end

  def self.print_usage
    puts <<-EOS
usage: wn.rb word link [lang]
    word      word to investigate

    link      syns - Synonyms
      hype - Hypernyms
      inst - Instances
      hypo - Hyponym
      hasi - Has Instances      mero - Meronyms
      mmem - Meronyms --- Member
      msub - Meronyms --- Substance
      mprt - Meronyms --- Part
      holo - Holonyms
      hmem - Holonyms --- Member      hsub - Holonyms --- Substance      hprt - Holonyms -- Part      attr - Attributes
      sim - Similar to      entag - Entails
      causg - Causes
      dmncg - Domain --- Category
      dmnug - Domain --- usage      dmnrg - Domain --- Region
      dmtcg - In Domain --- Category      dmtug - In Domain --- usage      dmtrg - In Domain --- Region      antsg - Antonyms

    lang (default: jpn)
      jpn - Japanese
      eng - English
    EOS
  end

  def close_db
    @conn.close
  end


end


if __FILE__ == $0
  if ARGV.length >= 2
    dbfile = "wnjpn-0.9.db"
    wnj = WNJpn.new(dbfile)
    wnj.main(*ARGV)
    wnj.close_db
  else
    WNJpn.print_usage
  end
end
