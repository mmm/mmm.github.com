---
layout:post
title: $i
tags: ["howto"]
---


#!/usr/bin/env ruby
# 
# USAGE: Turn off wireless, run this, then turn it back on.
# ./random_mac.rb <nothing> # =>  random mac address
# ./random_mac.rb --reset # =>  original mac address

# Set this to your Original MAC Address
original_mac = ""

# Just a little warning
puts "Warning: You haven't set your original Mac Address in the script yet." if original_mac.empty?

# Generates a 2 digit code
def generate_pair
  a = rand(255).to_s(16)
  return (a.length < 2 ? generate_pair : a)
end

# Sets the mac address to the passed value
def set_mac_address( mac_addr )
  raise "MacAddressFormatError" if mac_addr.scan(/^(?:[\w\d]{2}\:){5}[\w\d]{2}$/).empty?
  puts "Old MAC address: #{`ifconfig en1 | grep ether`.match(/ether\s(.+)/)[1]}"
  `sudo ifconfig en1 ether #{mac_addr}`
  puts "New MAC address: #{`ifconfig en1 | grep ether`.match(/ether\s(.+)/)[1]}"
end



case ARGV.first
when "--reset"
  # Try to reset to old mac address
  if original_mac.empty?
    puts "ERROR - You need to set the old mac address in the script"
    exit(1)
  end
  puts "Resetting to old mac address"
  set_mac_address( original_mac )
  
when nil
  # Generate & set a random mac address
  random_mac = (0..5).map { |x| generate_pair }.join(":")
  set_mac_address( random_mac )
  
when "--help"
  # Show some help I guess
  puts [
    "USAGE: Turn off wireless, run this, then turn it back on.",
    "./random_mac.rb <nothing> # =>  random mac address",
    "./random_mac.rb --reset # =>  original mac address"
    ].join("\n")
  
else
  # Who knows?
  puts "Unknown Flag, try --help"
  exit(2)
end
