#!/usr/bin/env ruby

start_revision = ARGV[0]
raise "1st argument `#{start_revision}` has to be revision" unless start_revision

puts "rev,path,size"
rev_lists = `git log --reverse --oneline --pretty=%H #{start_revision}`
rev_lists.split.map(&:strip).each do |rev|
  puts `git ls-tree -r -l #{rev} | ruby -ane 'puts "#{rev}, ./\#{$F[4]}, \#{$F[3]}"'`.split.map(&:strip)
end
