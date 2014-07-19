#!/usr/bin/env ruby

require "csv"
require "rexml/document"

include REXML

quotes = CSV.open("quotes.csv","w")

$*.each do |file|
      
  file_name = File.basename(file)
  print "Parsing #{file_name} ...\n"

  if (File.size(file)<10)
    print "  #{file_name} is too short\n"
    next
  end
      
  xml_file = Document.new(File.open(file)).root

  user_url = nil

  xml_file.elements.each("//atom:link") do |user|
    user_url = user.attributes["href"]
  end

  xml_file.elements.each("//guid") do |quote_url|
    quotes << [user_url,quote_url.text]
  end

end
