# Реализовать функцию, считающую p-value в случае проверки основной гипотезы в 
# критерии Уэлша о совпадении средних двух нормальных совокупностей, при условии, 
# что дисперсии различны.
# В качестве аргументов использовать только 2 вектора из нормальных совокупностей. 
# Составить 3 пары выборок разного объема и с разными дисперсиями из нормального 
# распределения с одинаковыми средними и проверить функцию для них. 
# Аналогично и для трех выборок с разными средними.

orig <- function(x, y){
  res<-t.test(x,y)
  res
}

fun <- function(x, y){
  nx <- length(x)
  mx <- mean(x)
  vx <- var(x) # Дисперсия
  ax <- vx/nx
  
  ny <- length(y)
  my <- mean(y)
  vy <- var(y) # Дисперсия
  ay <- vy/ny
  
  c <- sqrt(ax + ay)
  
  d <- c^4/(ax^2/(nx-1) + ay^2/(ny-1))
  
  print(d)
  
  t <- (mx - my)/c
  
  cdf <- pt(t, d) # ф-ия в-ти Стьюдента
  pval <- 2 * min(cdf, 1 - cdf)
  
  sprintf("t: %f, pval: %f", t, pval)
}


d1 <- rnorm(100, mean = 0, sd = 0.5)
d2 <- rnorm(300, mean = 0, sd = 0.2)
orig(d1, d2)
fun(d1, d2)
# pval > 0.05 -> H0

d1 <- rnorm(200, mean = 0, sd = 0.9)
d2 <- rnorm(220, mean = 0, sd = 0.1)
orig(d1, d2)
fun(d1, d2)

d1 <- rnorm(105, mean = 0, sd = 0.2)
d2 <- rnorm(310, mean = 0, sd = 1.6)
orig(d1, d2)
fun(d1, d2)
  


d1 <- rnorm(100, mean = 1, sd = 0.5)
d2 <- rnorm(300, mean = 0, sd = 0.2)
orig(d1, d2)
fun(d1, d2)

d1 <- rnorm(200, mean = 0, sd = 0.9)
d2 <- rnorm(220, mean = 1, sd = 0.1)
orig(d1, d2)
fun(d1, d2)

d1 <- rnorm(105, mean = 0.1, sd = 0.2)
d2 <- rnorm(310, mean = 0, sd = 1.6)
orig(d1, d2)
fun(d1, d2)
