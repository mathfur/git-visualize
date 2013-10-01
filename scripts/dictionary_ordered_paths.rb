#!/usr/bin/env ruby

start_revision = ARGV[0]
raise "1st argument `#{start_revision}` has to be revision" unless start_revision

rev_lists = `git log --reverse --oneline --pretty=%H #{start_revision}`

puts rev_lists.split.map(&:strip).map{|rev| `git ls-tree -r -l #{rev} | ruby -ane 'puts "./\#{$F[4]}"'`.split.map(&:strip) }.uniq.sort
