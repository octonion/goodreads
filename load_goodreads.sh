#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'books';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="psql template1 -t -c \"create database books\" > /dev/null 2>&1"
   eval $cmd
fi

psql books -f create_schema_goodreads.sql

cp rss_go.csv /tmp/rss_go.csv
chmod 777 /tmp/rss_go.csv

cp quotes.csv /tmp/quotes.csv
chmod 777 /tmp/quotes.csv

cp quote_books.csv /tmp/quote_books.csv
chmod 777 /tmp/quote_books.csv

psql books -f load_goodreads.sql
rm /tmp/rss_go.csv
rm /tmp/quotes.csv
rm /tmp/quote_books.csv
