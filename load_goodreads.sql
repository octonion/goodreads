begin;

drop table if exists goodreads.rss;

create table goodreads.rss (
       user_id		   integer,
       count		   integer,
       rss_url		   text,
       primary key (user_id)
);

copy goodreads.rss from '/tmp/rss_go.csv' with delimiter as ',' csv header quote as '"';

drop table if exists goodreads.quotes;

create table goodreads.quotes (
       rss_url		   text,
       quote_url	   text,
       primary key (rss_url,quote_url)
);

copy goodreads.quotes from '/tmp/quotes.csv' with delimiter as ',' csv header quote as '"';

drop table if exists goodreads.quote_books;

create table goodreads.quote_books (
       quote_url	   text,
       author_url	   text,
       work_url		   text,
       primary key (quote_url)
);

copy goodreads.quote_books from '/tmp/quote_books.csv' with delimiter as ',' csv header quote as '"';

commit;
