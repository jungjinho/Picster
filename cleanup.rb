#!/usr/bin/env ruby
# Clean up all the test folders made by picster.rb

require 'fileutils'

Dir.glob("Year *").each do |folder|
  puts "Deleting #{folder}"
  FileUtils.rm_r(folder)
end
