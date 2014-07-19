# Item response theory prototype
# Rasch model using lme4

sink("goodreads_rasch_lmer.txt")

library("lme4")
library("nortest")
library("RPostgreSQL")

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv,host="localhost",port="5432",dbname="books")

query <- dbSendQuery(con, "
select
distinct
q.rss_url as user,
qb2.quote_url as quote,
(case when q2.quote_url is not null then 1
      when q2.quote_url is null then 0
end) as quoted
from goodreads.quotes q
join goodreads.quote_books qb
  on (qb.quote_url)=(q.quote_url)
join goodreads.quote_books qb2
  on (qb2.work_url)=(qb.work_url)
left join goodreads.quotes q2
  on (q2.rss_url,q2.quote_url)=(q.rss_url,qb2.quote_url)
where
qb.work_url is not null
;")

results <- fetch(query,n=-1)

head(results)

dim(results)

attach(results)

user <- as.factor(user)
quote <- as.factor(quote)

quotes <- data.frame(user,quote)

model <- quoted ~ 1+(1|user)+(1|quote)
fit <- lmer(model, data=quotes, family=binomial(link="logit"), verbose=T)

f <- fixef(fit)
fn <- names(f)

r <- ranef(fit)
rn <- names(r) 

results <- list()

for (n in fn) {

  df <- f[[n]]

  factor <- n
  level <- n
  type <- "fixed"
  estimate <- df

  results <- c(results,list(data.frame(factor,type,level,estimate)))

 }

for (n in rn) {

  df <- r[[n]]

  factor <- rep(n,nrow(df))
  type <- rep("random",nrow(df))
  level <- row.names(df)
  estimate <- df[,1]

  results <- c(results,list(data.frame(factor,type,level,estimate)))

 }

combined <- as.data.frame(do.call("rbind",results))
m <- nrow(combined)

dbWriteTable(con,c("goodreads","_basic_factors"),combined,row.names=TRUE,append=TRUE)

quit("no")
