#!/usr/bin/env ruby
# == Synopsis 
#   This command is used to take a collection of jpeg files and resort 
#   them and rename them so that they reside in folders containing the 
#   date which they were taken, as well as making sure that the files 
#   are in sequential order.
#
# == Examples
#   picster Pics\[6.28.2010\]/
#
# == Usage 
#   picster [options] picture_folder
#
#   For help use: renamer -h
#
# == Options
#   -h, --help          Displays help message
#   -v, --version       Display the version, then exit
#   -V, --verbose       Verbose output
#
# == Author
#   Paul Chung
#
# == Copyright
#   Copyright (c) 2010 Paul Chung. Licensed under the MIT License:
#   http://www.opensource.org/licenses/mit-license.php

require 'optparse'
require 'exifr'
require 'fileutils'

# Months
$MONTH_LIST = {1 => "January", 2 => "February", 3 => "March", 4 => "April", 5 => "May", 6 => "June", 7 => "July", 8 => "August", 9 => "September", 10 => "October", 11 => "November", 12 => "December"}

# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
options = {}
 
optparse = OptionParser.new do|opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner = "Usage: renamer.rb [options] pic_folder"

  # Define the options, and what they do
  options[:verbose] = false
  opts.on( '-V', '--verbose', 'Output more information' ) do
    options[:verbose] = true
  end

  # Display the version
  options[:version] = false
  opts.on( '-v', '--version', 'picster v0.01' ) do
    puts opts
    exit
  end
  #options[:logfile] = nil
  #opts.on( '-l', '--logfile FILE', 'Write log to FILE' ) do|file|
  #  options[:logfile] = file
  #end

  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. 
optparse.parse!

# If any options were chosen that don't cause the program to exit,
# then have them turned on here
puts "Verbose" if options[:verbose]
#puts "Logging to file #{options[:logfile]}" if options[:logfile]

# Going through the command line arguments
ARGV.each do |folder|
  # Making sure that if there are special characters in the folder name,
  # that they are properly escaped so that the path can be accessed
  f = Regexp.escape( folder )
  
  # Where we store the dates
  images = {}

  # Filtering out just the JPEG files
  Dir.glob(f + "*.[jJ][pP][gG]").each do |pic|
    
    # Getting the date meta data from the jpeg file
    d = EXIFR::JPEG.new(pic).date_time
   
    # This will correspond to the name of the folder that holds all pics 
    # taken on that day
    date = "#{d.year}_#{d.month}_#{d.day}"
    time = "#{d.hour}_#{d.min}_#{d.sec}"

    if not images.has_key?(date)
      # That date has not yet been added to images
      images[date + "#" + time] = []
    end
   
    # Extract path and file name of the images
    location = pic.split("\/")
    # That date has already been added to images
    images[date + "#" + time] = [location.first, location.last]
  end

  # Sorting the images chronologically
  images = images.sort
  
  # Now do the file system manipulation stuff
  # I KNOW THAT THIS ISN'T THE MOST EFFICIENT WAY OF DOING THIS...
  # BUT IT'S v0.01, SO CUT ME SOME SLACK!
  
    
  # First iterate through each item in images and get just the date
  images.each do |key, value|
    date_taken = key.split("#").first

    # Not very pretty but...
    date_tmp = date_taken.split("_")
    y = date_tmp[0]
    m = date_tmp[1]
    # day = date_tmp[2]

    year_taken = "Year #{y}"
    month_taken = "#{m} #{$MONTH_LIST[m.to_i]} #{y}"

    # Making the Year folder
    if not File.exists?(year_taken)
      Dir.mkdir(year_taken)
    end

    # Making the Month sub-folder
    if not File.exists?(year_taken + "\/" + month_taken)
      Dir.mkdir(year_taken + "\/" + month_taken)
    end

    time_taken = key.split("#").last
    original_folder = value.first
    original_name = value.last
    new_name = date_taken + "_" + time_taken + "\.JPG"

    # Verbose
    if options[:verbose]
      puts "#{date_taken} | #{time_taken} | #{original_name} | #{Dir.pwd}"
    end
    
    # The target and source directory
    target = Dir.pwd + "\/" + year_taken + "\/" + month_taken + "\/" + date_taken + "\/"
    source = original_folder + "\/"

    # Check whether directory with the same name as 'date_taken' exists
    if not File.directory?(target)
      # Directory doesn't exist, therefore create it
      Dir.mkdir(target)
    end

    # Add the jpeg to the directory corresponding to the date in which
    # that jpeg was taken
    if not File.exists?(target + original_name)
      FileUtils.cp(source + original_name, target + new_name)
    end

  end

end
