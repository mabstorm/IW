#!/usr/bin/ruby


ARGV.each do |arg|

  next if !arg.slice("stripped.txt").nil?

  fp = File.open(arg,'r')

  newfile = "#{arg}-stripped.txt"
  next if File.exist? newfile
  
  
  fpo = File.open("#{arg}-stripped.txt",'w+')

  while (line = fp.gets)
    val = line.match(/^#/).nil?
   if !val
     next
   else
     fpo.puts line
   end
  end
fp.close
fpo.close
end



