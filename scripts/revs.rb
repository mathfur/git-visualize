#!/usr/bin/env ruby

start_revision = ARGV[0]
raise "1st argument `#{start_revision}` has to be revision" unless start_revision

puts "rev"
puts `git log --reverse --oneline --pretty=%H #{start_revision}`
