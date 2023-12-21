# Реализовать функцию, считающую значение статистики критерия Дарбина-Уотсона. 
# В качестве аргумента использовать вектор регрессионных остатков. 
# Проверить для трех моделей, рассмотренных на семинарах 

fun <- function(r){
  n <- length(r)
  dw <- (sum((r[2:n] - r[1:(n-1)])^2))/sum(r^2)
  
  dw
}

lab <- function(d){
  model <- lm(data=d)
  
  print(durbinWatsonTest(model))
  
  fun(residuals(model))
}

lab(cars)

lab(mtcars)

lab(iris)
