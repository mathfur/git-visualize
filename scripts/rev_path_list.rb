#!/usr/bin/env ruby

range = ARGV[0]
raise "1st argument `#{range}` has to be revision" unless range

puts "rev,path,size"
rev_lists = `git log --reverse --oneline --pretty=%H #{range}`
rev_lists.split.map(&:strip).each do |rev|
  puts `git ls-tree -r -l #{rev} | ruby -ane 'puts "#{rev},./\#{$F[4]}, \#{$F[3]}"'`
end
