select level
from goodreads._basic_factors
where factor='quote'
order by estimate desc limit 20;
