#!/usr/bin/env ruby

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

author_xpath = "/html/body/div[1]/div[2]/div[1]/div[2]/div[3]/div[1]/div[1]/div[1]/a"
book_xpath = "/html/body/div[1]/div[2]/div[1]/div[2]/div[3]/div[1]/div[1]/div[1]/i/a"

base_url = "https://www.goodreads.com"
quote_books = CSV.open("quote_books.csv","w")

quote_file = CSV.open("quotes.csv","r")

quotes = []
quote_file.each do |quote|
  quotes << quote[1]
end

quotes = quotes.sort.uniq

qs = quotes.size

quotes.each_with_index do |quote_url,i|

  print "#{i}/#{qs}\n"

  begin
    page = agent.get(quote_url)
  rescue
    print "Banned!\n"
    exit
  end

  author_url = nil
  page.parser.xpath(author_xpath).each do |a|
    author_url = base_url+a.attribute("href").text
  end

  book_url = nil
  page.parser.xpath(book_xpath).each do |a|
    book_url = base_url+a.attribute("href").text
  end

  quote_books << [quote_url,author_url,book_url]

end
