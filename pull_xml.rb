#!/usr/bin/env ruby

require 'csv'

require 'open-uri'

users = CSV.open("final.csv")

users.each do |user|

  user_id = user[0]
  count = user[1]
  if (count.to_i==0)
    next
  end
  xml_url = user[2]
  print "#{user_id} - #{count}\n"

  base_sleep = 0
  sleep_increment = 3
  retries = 4
  sleep_time = base_sleep
  tries = 0

  begin
    File.open("xml/#{user_id}.xml", "wb") do |saved_file|
      open(xml_url, "rb") do |read_file|
        saved_file.write(read_file.read)
      end
    end
  rescue
    sleep_time += sleep_increment
    print "#{user_id} - sleep #{sleep_time} ... \n"
    sleep sleep_time
    tries += 1
    if (tries > retries)
      next
    else
      retry
    end
  end

end
