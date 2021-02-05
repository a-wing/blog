#!/usr/bin/ruby

# Fork From: https://github.com/Huxpro/huxpro.github.io/blob/master/Rakefile

SOURCE = "."
CONFIG = {
  'posts' => File.join(SOURCE, "_posts"),
  'post_ext' => "md",
}

# Usage: ./new.rb 'A Title'
puts "Begin a new post in #{CONFIG['posts']}"
abort("new: '#{CONFIG['posts']}' directory not found.") unless FileTest.directory?(CONFIG['posts'])
title = ARGV[0] || "new_post"
slug = title.downcase.strip.gsub(' ', '_').gsub(/[^\w_]/, '')
begin
  date = (ENV['date'] ? Time.parse(ENV['date']) : Time.now).strftime('%Y-%m-%d')
rescue Exception => e
  puts "Error - date format must be YYYY-MM-DD, please check you typed it correctly!"
  exit -1
end
filename = File.join(CONFIG['posts'], "#{date}-#{slug}.#{CONFIG['post_ext']}")
if File.exist?(filename)
  abort("#{filename} already exists.")
end

puts "Creating new post: #{filename}"
open(filename, 'w') do |post|
  post.puts "---"
  post.puts "layout: post"
  post.puts "title: \"#{title.gsub(/-/,' ')}\""
  post.puts "author: \"Metal A-wing\""
  post.puts "date: #{Time.now}"
  post.puts "categories: other"
  post.puts "---"
end

