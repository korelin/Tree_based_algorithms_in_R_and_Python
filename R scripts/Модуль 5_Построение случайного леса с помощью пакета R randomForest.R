# ������ 5. ���������� ���������� ���� � ������� ������ R randomForest

# ������ 5.1. ���������� �������� �������� �������������

## 5.1.1. ���������� ������

# ��������� ������
data <- read.csv2("C:/Trees/Response.csv")

# ��������� ����������� ��������������
data[, -c(12:13)] <- lapply(data[, -c(12:13)], factor)
set.seed(42)
random_number <- runif(nrow(data), 0, 1)
development <- data[random_number > 0.3, ]
holdout <- data[random_number <= 0.3, ]

## 5.1.2. ���������� ������ � ��������� OOB ������ ��������

# ��������� ����� randomForest
library(randomForest)

# ������ ��������� �������� ���������� ���������
# ����� ��� ����������������� �����������
set.seed(152)

# ������ ��������� ��� �������� �������������
model <- randomForest(response ~ ., development, importance = TRUE)

# ������� ���������� � �������� ������
print(model)

# ������� ������ �� ������ OOB 
# ����� ��� ������� ���
table(development$response, predict(model))

# ������ ������ ����������� ������ ������������� �� ������ OOB
# �� ���������� ��������
plot(model)

# ����������� ����������� �������� mtry
set.seed(152)
tuneRF(development[, 1:13], development[, 14], 
       ntreeTry = 500, trace = FALSE)


## 5.1.3. ��������� ���������� � �������� ���������� ����

# ������� ���������� � ��������� 15 �����
# ������ �1 ���������� ����, �� ���������
# ����� ���������� ����������� � �����
# ����������������� �������
info_tree1 <- getTree(model, k = 1, labelVar = FALSE)
tail(info_tree1, 15)

# ������� ���������� � ��������� 15 �����
# ������ �1 ���������� ����, ���������
# ����� ���������� ����������� � �����
# ����������������� �������
info_tree1 <- getTree(model, k = 1, labelVar = TRUE)
tail(info_tree1, 15)

## 5.1.4. �������� �����������

# ������� �������� �����������
importance(model)

# ������� ������ �������� �����������
varImpPlot(model)

# ��������� ������� ������������� ���������� 
# � �������� ����������� ���������
freq <- varUsed(model, by.tree = FALSE, count = TRUE)
# ��������� �������� �����������
names <- colnames(development[,-14])
# ������������ �������� �����������
# c ���������
names(freq) <- names
# ������� ���������� �������������
freq


## 5.1.5. ������� ������� �����������

# ������ ������ ������� ����������� ��� ���������� age,
# ������������ ����� � ����� 1 (����� ���� ������)
# �������� �� ��� ������� - �������� ����� ���������� 
# ���� �������, �������� ��������� �� ������������ ����� 
# ��������� ����������, � ����������� ������ ���������� 
# �������, �������� ��������� �� ������ �����
partialPlot(model, development, age, 1)

# ������ ������ ������� ����������� ��� ���������� cus_leng,
# ������������ ����� � ����� 1 (����� ���� ������)
partialPlot(model, development, cus_leng, 1)

# ������ ������ ������� ����������� ��� ���������� atm_user,
# ������������ ����� � ����� 1 (����� ���� ������)
partialPlot(model, development, atm_user, 1)

# ������ ������ ������� ����������� ��� ���������� atm_user,
# ������������ ����� � ����� 0 (����� ��� �������)
partialPlot(model, development, atm_user, 0)

## 5.1.6. ���������� ������������ �������

# ��������� ����������� ������� ��� ��������� �������
# ������� �������
prob_dev <- predict(model, development, type = "prob")
# ��������� ����������� ������� ��� ��������� �������
# �� ������ OOB
prob_dev_oob <- predict(model, type = "prob")

# ������� ����������� ��� ��������� 5 ����������
# ��������� �������, ����������� �� �������� ������
tail(prob_dev, 5)

# ������� ����������� ��� ��������� 5 ����������
# ��������� �������, ����������� �� ������ OOB
tail(prob_dev_oob, 5)

## 5.1.7. ������ ���������������� ����������� ������ � ������� ROC-������

# ��������� ����� pROC ��� ���������� ROC-������
library(pROC)
# ������ ROC-������ ��� ��������� ������� (�� ������ 
# ������������, ����������� ������� ��������)
roc_dev <- plot(roc(development$response, prob_dev[, 2], ci = TRUE), 
                percent = TRUE, print.auc = TRUE, col = "#1c61b6")
# ��������� ����������� ������� ��� ����������� �������
prob_hold <- predict(model, holdout, type = "prob")
# ��������� ROC-������ ��� ����������� �������
roc_hold <- plot(roc(holdout$response, prob_hold[, 2], ci = TRUE), 
                 percent = TRUE, print.auc = TRUE, col = "#008600", 
                 print.auc.y = 0.4, add = TRUE)
# ������� ������� � ROC-������
legend("bottomright", legend = c("��������� ������� (������� �����)", 
                                 "����������� �������"), 
       col = c("#1c61b6", "#008600"), lwd = 2)


# ������ ROC-������ ��� ��������� ������� (�� ������ 
# ������������, ����������� �� ������� OOB)
roc_dev <- plot(roc(development$response, prob_dev_oob[, 2], ci = TRUE), 
                percent = TRUE, print.auc = TRUE, col = "#1c61b6")
# ��������� ROC-������ ��� ����������� �������
roc_hold <- plot(roc(holdout$response, prob_hold[, 2], ci = TRUE), 
                 percent = TRUE, print.auc = TRUE, col = "#008600", 
                 print.auc.y = 0.4, add = TRUE)
# c������ ������� � ROC-������
legend("bottomright", legend = c("��������� ������� (����� OOB)", 
                                 "����������� �������"), 
       col = c("#1c61b6", "#008600"), lwd = 2)

# ��������� ����� rpart
library(rpart)
# ��������� ������ CART
set.seed(42)
model_cart <-rpart(response ~ ., development)
# ���������� �����������, ����������������� ������� CART
# ��� ����������� �������, � ������ prob_hold_cart 
prob_hold_cart <- predict(model_cart, holdout, type = "prob")
# ������������� ��� ROC-������
rf <- plot(roc(holdout$response, prob_hold[, 2], ci = TRUE), 
           percent = TRUE, print.auc = TRUE, col = "#1c61b6")
cart <- plot(roc(holdout$response, prob_hold_cart[, 2], ci = TRUE), 
             percent = TRUE, print.auc = TRUE, col = "#008600", 
             print.auc.y = 0.4, add = TRUE)
# ������� ������� � ROC-������
legend("bottomright", legend = c("��������� ���", "������ CRT"), 
       col = c("#1c61b6", "#008600"), lwd = 2)


## 5.1.8. ��������� ����������������� ������� ��������� ����������

# ������ ��������� �������� ����������
# ��������� �����
set.seed(152)

# ��������� ������ ��������� ���������� 
# ��� ��������� ������� ������� ��������
resp_dev <- predict(model, development, type = "response")

# ������� ������ ��������� ����������
# ��� ��������� 5 ���������� ��������� 
# �������, ����������� �� �������� ������
tail(resp_dev, 5)

# ������� ������� ������ ��� ��������� �������
# �� ������ �������, ����������� ������� �������
table(development$response, resp_dev)

# ������ ��������� �������� ����������
# ��������� �����
set.seed(152)
# ��������� ������ ��������� ���������� 
# ��� ����������� �������
resp_hold <- predict(model, holdout, type = "response")
# ������� ������� ������ ��� ����������� �������
table(holdout$response, resp_hold)


## 5.1.9. ������ ������ ���������

plot(margin(model))

# ������ 5.2. ���������� �������� �������� ���������

## 5.2.1. ���������� ������

# ��������� ������
data <- read.csv2("C:/Trees/Creddebt.csv")

# ��������� ����������� ��������������
data$ed <- ordered(data$ed, levels = c("�������� �������", 
                                       "�������", 
                                       "������� �����������",   
                                       "������������� ������", 
                                       "������, ������ �������"))
set.seed(100)
ind <- sample(2, nrow(data), replace = TRUE, prob = c(0.7, 0.3))
development <- data[ind == 1, ]
holdout <- data[ind == 2, ]

## 5.2.2. ���������� ������ � ��������� OOB ������ ��������

# ������ ��������� �������� ���������� ���������
# ����� ��� ����������������� �����������
set.seed(152)

# ������ ��������� ��� �������� ���������
model<-randomForest(creddebt ~ ., development, importance = TRUE)

# ������� ���������� � �������� ������
print(model)

# ������ ������ ����������� ������������������ ������ �� ������ OOB
# �� ���������� �������� � ��������
plot(model)


## 5.2.3. �������� �����������

# ������� �������� �����������
importance(model)

# ������� ������ �������� �����������
varImpPlot(model)

## 5.2.4 ������� ������� �����������

# ������ ������ ������� ����������� ��� ���������� income
partialPlot(model, development, income)

# ������ ������ ������� ����������� ��� ���������� debtinc
partialPlot(model, development, debtinc)

## 5.2.5. ������ � ���������� � ���������� �������������������� ������

# ������������ �������� ��������� ���������� 
# ��� ��������� ������� ������� ��������
predvalue_dev <- predict(model, development)

# ������� �������� ��������� ����������
# ��� ��������� 5 ���������� ��������� 
# �������, ����������� �� �������� ������
tail(predvalue_dev, 5)

# ��������� ������������������ ������ ��� ��������� ������� �� �������� ������, 
# ��� ����� ����� ��������� ��������� ����� ������������ � ������������������ 
# ���������� ��������� ���������� ����� �� ���������� ����������, ��� ����
# ������ ����������������� �������� � ��������� ���������� �������
# ��������, ����������� ��������� �� ���� ��������-�������� 
MSE_dev <- sum((development$creddebt - predvalue_dev)^2) / nrow(development)

# ��������� ����� ��������� ���������� ����������� ��������
# ��������� ���������� � ��������� ������� �� �� �������� ��������
TSS <- sum((development$creddebt - (mean(development$creddebt)))^2)
# ��������� ����� ��������� ���������� ����������� �������� 
# ��������� ���������� � ��������� ������� �� �����������������, 
# ��� ���� ������ ����������������� �������� � ��������� ���������� 
# ������� ��������, ����������� ��������� �� ���� ��������-�������� 
RSS <- sum((development$creddebt - predvalue_dev)^2)
# ��������� R-������� ��� ��������� ������� �� �������� ������
R2_dev <- (1 - (RSS / TSS)) * 100

# �������� ����������
output <- c("MSE" = MSE_dev, "R2" = R2_dev)
output

# ������������ �������� ��������� ���������� 
# ��� ��������� ������� �� ������ OOB
oob_predvalue_dev <- predict(model)

# ��������� ������������������ ������ ��� ��������� ������� �� �������� ������, 
# ��� ����� ����� ��������� ��������� ����� ������������ � ������������������ 
# ���������� ��������� ���������� ����� �� ���������� ����������, ��� ����
# ������ ����������������� �������� � ��������� ���������� �������
# ��������, ����������� ��������� �� OOB �������� 
oob_MSE_dev <- sum((development$creddebt - oob_predvalue_dev)^2) / nrow(development)

# ��������� ����� ��������� ���������� ����������� ��������
# ��������� ���������� � ��������� ������� �� �� �������� ��������
TSS <- sum((development$creddebt - (mean(development$creddebt)))^2)
# ��������� ����� ��������� ���������� ����������� �������� 
# ��������� ���������� � ��������� ������� �� �����������������, 
# ��� ���� ������ ����������������� �������� � ��������� ���������� 
# ������� ��������, ����������� ��������� �� OOB �������� 
RSS <- sum((development$creddebt-oob_predvalue_dev)^2)
# ��������� R-������� ��� ��������� ������� �� ������ OOB
oob_R2_dev <- (1 - (RSS / TSS)) * 100

# �������� ����������
output <- c("oob MSE" = oob_MSE_dev, "oob R2" = oob_R2_dev)
output

# ������������ �������� ��������� ���������� 
# ��� ����������� �������
predvalue_hold <- predict(model, holdout)

# ������� �������� ��������� ����������
# ��� ��������� 5 ���������� ����������� 
# �������
tail(predvalue_hold, 5)

# ��������� ������������������ ������ ��� ����������� ������� 
MSE_hold <- sum((holdout$creddebt - predvalue_hold)^2) / nrow(holdout)
# ��������� ����� ��������� ���������� ����������� ��������
# ��������� ���������� � ����������� ������� �� �� �������� ��������
TSS <- sum((holdout$creddebt - (mean(holdout$creddebt)))^2)
# ��������� ����� ��������� ���������� ����������� �������� 
# ��������� ���������� � ����������� ������� �� �����������������
RSS <- sum((holdout$creddebt - predvalue_hold)^2)
# ��������� R-������� ��� ����������� �������
R2_hold <- (1 - (RSS / TSS)) * 100
# �������� ����������
output <- c("MSE" = MSE_hold, "R2" = R2_hold)
output

## 5.2.6. ��������� �������� ���������

# ����������� ����������� �������� mtry
set.seed(152)
tuneRF(development[, 1:6], development[, 7], ntreeTry = 500, trace = FALSE)

# ������ ������ c ����� ��������� mtry
set.seed(152)
model2<-randomForest(creddebt ~ ., development, mtry = 6)

print(model2)

# ������������ �������� ��������� ���������� 
# ��� ����������� �������
predval_hold <- predict(model2, holdout)
# ��������� ������������������ ������ ��� ����������� ������� 
MSE_hold <- sum((holdout$creddebt - predval_hold)^2) / nrow(holdout)
# ��������� ����� ��������� ���������� ����������� ��������
# ��������� ���������� � ����������� ������� �� �� �������� ��������
TSS <- sum((holdout$creddebt - (mean(holdout$creddebt)))^2)
# ��������� ����� ��������� ���������� ����������� �������� 
# ��������� ���������� � ����������� ������� �� �����������������
RSS <- sum((holdout$creddebt-predval_hold)^2)
# ��������� R-������� ��� ����������� �������
R2_hold <- (1 - (RSS / TSS)) * 100
# �������� ����������
output <- c("MSE" = MSE_hold, "R2" = R2_hold)
output

## 5.2.7. ��������� ����� ������������ ������ � �������� ������

# ������� ����������
Xtrain <-development[, 1:6]
ytrain <-development[, 7]
Xtest <-holdout[, 1:6]
ytest <-holdout[, 7]

# ������ ������, ������ �� �������
# ����� ����������� ����������
set.seed(152)
model2 <- randomForest(Xtrain, ytrain, Xtest, ytest, mtry = 6)

# ������� ���������� � �������� ������
print(model2)

# ������ 5.3. ����� ����������� ���������� ���������� ���� � ������� ������ caret

## 5.3.1. ����� ����������� ����������, ������������� � ������ caret

## 5.3.2. ��������� ������� �����������

## 5.3.3. ����� ����������� ���������� ��� ������ �������������

# ������������� developer-������ ������ caret
# devtools::install_github("topepo/caret/pkg/caret")

# ��������� ������
data <- read.csv2("C:/Trees/Response.csv")

# ��������� ����������� ��������������
data[, -c(12:13)] <- lapply(data[, -c(12:13)], factor)

# ��������� ��������� ��������� �� ���������
# � ����������� �������
set.seed(42)
random_number <- runif(nrow(data), 0, 1)
training <- data[random_number > 0.3, ]
test <- data[random_number <= 0.3, ]

# ��������� ����� caret
library(caret)

# �� �������� ��������� ����� randomForest,
# ���� �� ����� �� ��� ��������
# library(randomForest)

# ���������������� ����������
library(parallel)

# install.packages("doParallel")
library(doParallel)

# ����� ������������ 3 ���� ����������
cluster <- makeCluster(3)
registerDoParallel(cluster)

# ������ ����� ������� �����������: ��������� 5-������� 
# ������������ �������� � ������� ����������
# �� �������� �����
control <- trainControl(method = "cv", number = 5, 
                        search = "grid", allowParallel = TRUE)

# ������ ����� ���������� ��� ����������� ������
tunegrid <- expand.grid(mtry = c(1:7))

# ������ ������ ���������� ���� � �������� 
# ����������� � �.�. ������������ 
set.seed(152)
rf_gridsearch <- train(response ~ ., data = training, method = "rf", 
                       ntree = 600, tuneGrid = tunegrid, 
                       trControl = control)

# ������� ���������� ����������� ������ 
print(rf_gridsearch)

# ������������� ���������� ����������� ������ 
plot(rf_gridsearch)

# ��������� �������� ��� �������� �������
predval <- predict(rf_gridsearch, test)
# ������� ������� ������
table(test$response, predval)

# ����������� ���������� ����� ���������
# ��������� ����������
training$response <- factor(training$response, levels = c(0, 1),
                            labels = c("NoResponse", "Response"), 
                            exclude = NULL)
test$response <- factor(test$response, levels = c(0, 1),
                        labels = c("NoResponse","Response"), 
                        exclude = NULL)

# ������ ����������� ����� ������� ��� �����������
control <- trainControl(method = "cv", number = 5, search = "grid",
                        allowParallel = TRUE,
                        classProbs = TRUE, 
                        summaryFunction = twoClassSummary)

# ������ ������ ���������� ���� � �������� 
# ����������� � �.�. AUC
set.seed(152)
rf_gridsearch2 <- train(response ~ ., data = training, method = "rf", 
                        metric = "ROC", ntree = 600,
                        tuneGrid = tunegrid, trControl = control)

# ������� ���������� ����������� ������ 
print(rf_gridsearch2)

# ������������� ���������� ����������� ������ 
plot(rf_gridsearch2)

# ��������� AUC ����������� ������
# �� �������� �������
prob <- predict(rf_gridsearch2, test, type = "prob")
roc(test$response, prob[, 2], ci = TRUE)

# ������ ROC-������ ����������� ������
# �� �������� �������
plot(roc(test$response, prob[, 2], ci = TRUE))

# ��������� ������� ������������ ����������
stopCluster(cluster)
# ��������� ����� R � ������� �����
registerDoSEQ()


# ����� ����������� ���������� ����������� 
# ������ ��� ���������� ���� 
customRF <- list(type = "Classification", library = "randomForest", loop = NULL)
customRF$parameters <- data.frame(parameter = c("mtry", "nodesize"), 
                                  class = rep("numeric", 2), label = c("mtry", "nodesize"))
customRF$grid <- function(x, y, len = NULL, search = "grid") {}
customRF$fit <- function(x, y, wts, param, lev, last, weights, classProbs, ...) {
  randomForest(x, y, mtry = param$mtry, nodesize = param$nodesize, ...)
}
customRF$predict <- function(modelFit, newdata, preProc = NULL, submodels = NULL)
  predict(modelFit, newdata)
customRF$prob <- function(modelFit, newdata, preProc = NULL, submodels = NULL)
  predict(modelFit, newdata, type = "prob")
customRF$sort <- function(x) x[order(x[, 1]),]
customRF$levels <- function(x) x$classes

control <- trainControl(method = "cv", number = 5, search = "grid",
                        classProbs = TRUE, summaryFunction = twoClassSummary)
tunegrid <- expand.grid(mtry = c(3:7), nodesize = c(40, 50, 60))
set.seed(152)
custom <- train(response ~ ., ntree = 600, data = training, 
                method = customRF, metric = "ROC",            
                tuneGrid = tunegrid, trControl = control)

# ������� ���������� ����������� ������
print(custom)

# ������������� ���������� ����������� ������ 
plot(custom)

# ��������� AUC ����������� ������
# �� �������� �������
score <- predict(custom, test, type = "prob")
roc(test$response, score[, 2], ci = TRUE)

# 5.3.4. ����� ����������� ���������� ��� ������ ���������

# ��������� ������
data <- read.csv2("C:/Trees/Creddebt.csv")

# ��������� ����������� ��������������
data$ed <- ordered(data$ed, levels = c("�������� �������", 
                                       "�������", 
                                       "������� �����������",   
                                       "������������� ������", 
                                       "������, ������ �������"))

# ��������� ��������� ��������� �� ���������
# � ����������� �������
set.seed(100)
ind <- sample(2, nrow(data), replace = TRUE, prob = c(0.7, 0.3))
tr <- data[ind == 1, ]
tst <- data[ind == 2, ]

# ����� ����������� ���������� ����������� 
# ������ ��� ���������� ���� 
customRF2 <- list(type = "Regression", library = "randomForest", loop = NULL)
customRF2$parameters <- data.frame(parameter = c("mtry", "nodesize"), 
                                   class = rep("numeric", 2), label = c("mtry", "nodesize"))
customRF2$grid <- function(x, y, len = NULL, search = "grid") {}
customRF2$fit <- function(x, y, wts, param, lev, last, weights, classProbs, ...) {
  randomForest(x, y, mtry = param$mtry, nodesize = param$nodesize, ...)
}
customRF2$predict <- function(modelFit, newdata, preProc = NULL, submodels = NULL)
  predict(modelFit, newdata)
customRF2$prob <- function(modelFit, newdata, preProc = NULL, submodels = NULL)
  predict(modelFit, newdata, type = "prob")
customRF2$sort <- function(x) x[order(x[,1]),]
customRF2$levels <- function(x) x$classes

control <- trainControl(method = "cv", number = 5, search = "grid", allowParallel = TRUE)
tunegrid <- expand.grid(mtry = c(1:6), nodesize = c(1, 2, 3, 4))
set.seed(152)
custom2 <- train(creddebt ~ ., ntree = 600, data = tr, 
                 method = customRF2, tuneGrid = tunegrid, 
                 trControl = control)

# ������� ���������� ����������� ������ 
print(custom2)

# ������������� ���������� ����������� ������ 
plot(custom2)

# ������������ �������� ��������� ���������� 
# ��� �������� ������� � �������
# ����������� ������
predictions <- predict(custom2, tst)
# ��������� ������ �� ������������������ ������ ��� �������� ������� 
RMSE <- sqrt(sum((tst$creddebt-predictions)^2) / nrow(tst))
# ��������� ����� ��������� ���������� ����������� ��������
# ��������� ���������� � �������� ������� �� �� �������� ��������
TSS <- sum((tst$creddebt - (mean(tst$creddebt)))^2)
# ��������� ����� ��������� ���������� ����������� �������� 
# ��������� ���������� � �������� ������� �� �����������������
RSS <- sum((tst$creddebt - predictions)^2)
# ��������� R-������� ��� �������� �������
R2 <- (1 - (RSS / TSS)) * 100
# ��������� ������� ���������� ������ ��� �������� ������� 
MAE <- sum(abs(tst$creddebt - predictions)) / nrow(tst)
# �������� ����������
output <- c("RMSE" = RMSE, "R2" = R2, "MAE" = MAE)
output


# ������ 5.4. ��������� ������������������� ���������� ���� � ������� ������ randomForestExplainer

# ������������� ����� randomForestExplainer
# devtools::install_github("MI2DataLab/randomForestExplainer")

# ��������� ����� randomForestExplainer
library(randomForestExplainer)

# ��������� ������
data <- read.csv2("C:/Trees/Response.csv")

# ��������� ����������� ��������������
data[, -c(12:13)] <- lapply(data[, -c(12:13)], factor)
set.seed(42)
random_number <- runif(nrow(data), 0, 1)
development <- data[random_number > 0.3, ]
holdout <- data[random_number <= 0.3, ]

# ������ ��������� �������� ����������
# ��������� �����
set.seed(152)
# ������ ��������� ��� �������� �������������
forest<-randomForest(response ~ ., development, localImp = TRUE)

## 5.4.1. ������ �������� ���������� � ����� ������ ����������� ������� �������������

# �� �������� ���� ������ ���������� ���� �������
# min_depth_distribution, ����� �������� ����������
# � ��������� ����������� ������� ��� ������� 
# ���������� �� ������� ������
min_depth_frame <- min_depth_distribution(forest)
# ������� ���������� � �������� ����������� �������
# ��� ���� ����������� �� ������� ������
subset(min_depth_frame, min_depth_frame$tree == 1)

# ������� ������ ������������� ����������� �������
plot_min_depth_distribution(min_depth_frame)

# ������� ������ ������������� ����������� �������,
# ������������� 5 �������� ������� ������������
plot_min_depth_distribution(min_depth_frame, 
                            mean_sample = "relevant_trees", 
                            k = 5)

## 5.4.2. �������������� ������� ��������

# �������� �������������� ������� ��������
importance_frame <- measure_importance(forest)
importance_frame

## 5.4.3. ����������� ������� ��� ������ �������� �����������

# �������� ����������� ������ ���
# ������ �������� �����������
plot_multi_way_importance(importance_frame)

# ������ ������� ����������� �����������
# ������ ��� ������ �������� �����������
plot_multi_way_importance(importance_frame, 
                          x_measure = "accuracy_decrease",
                          y_measure = "gini_decrease",
                          size_measure = "times_a_root", 
                          no_of_labels = 5)

## 5.4.4. ������ ������� ��� ������ ���������� ����� ��������� ��������

# ������ ������ ������� ��� ������ ���������� 
# ����� ��������� ��������
plot_importance_ggpairs(importance_frame)

# ������ ������ ������� ��� ������ ���������� 
# ����� ��������� �������� � ����������� 
# ����������� LOESS
plot_importance_rankings(importance_frame)

## 5.4.5. ������� �������������� ����� �����������

# ��������� ����� 5 ��������
# ������ �����������
vars <- important_variables(importance_frame, 
                            k = 5, 
                            measures = c("mean_min_depth",
                                         "no_of_trees"))

# ������ ������� ��������������
interactions_frame <- min_depth_interactions(forest, vars)

# ������� ������ 6 ����� �������
head(interactions_frame[order(interactions_frame$occurrences, decreasing = TRUE), ])

# ������������� ���������� ������
plot_min_depth_interactions(interactions_frame)

## 5.4.6. ��������� ������ �� ������������ ���������� ����
## 5.4.7. �������� ����� ���������

# ��������� ������
boston_data <- read.csv2("C:/Trees/boston.csv")
boston_data$CHAS <- as.logical(boston_data$CHAS)

# ������ ��������� �������� ���������� ���������
# ����� ��� ����������������� �����������
set.seed(152)

# ������ ��������� ��� �������� ���������
rf <-randomForest(MV ~., boston_data, localImp = TRUE)

# �������� ���������� ��������� ���
# �������������� ����������� RM � LSTAT
plot_predict_interaction(rf, boston_data, "RM", "LSTAT") 

# ������ 5.5. ��������� ������������������ ���������� ���� � ������ ������� 
# ���� ������� ���� � ������� ������ lime

# ������� ��������� ����� ���������, ��������� 
# ����� ����� � �������� ����� ���������
boston_train <- boston_data[-(501:504), 1:13]
boston_lab <- boston_data[[14]][-(501:504)]
boston_test <- boston_data[501:504, 1:13]

# ������������� � ���������
# ����� lime
# install.packages("lime")
library(lime)

# ������ ��������� �������� ���������� ���������
# ����� ��� ����������������� �����������
set.seed(152)

# ������ ��������� ��� �������� ���������
regr_model <- train(boston_train, boston_lab, method = "rf")

# ������� ������ ������ explainer
regr_explainer <- lime(boston_train, regr_model)

# �������� ���������� ��������� ���
# ��������� ����� ����������, 
# �� ������������� ��������
regr_explanation <- explain(boston_test, 
                            regr_explainer, 
                            n_features = 6,
                            n_permutations = 1000)
regr_explanation

# ������������� ���������� ���������
plot_features(regr_explanation)

# ��������� ������ ��� ������ �������������
default_data <- read.csv2("C:/Trees/Bankloan.csv")

# ������� ��������� ����� ���������, ��������� 
# ����� ����� � �������� ����� ���������
default_train <- default_data[-(606:609), 1:7]
default_lab <- default_data[[8]][-(606:609)]
default_test <- default_data[606:609, 1:7]

# ������ ��������� �������� ���������� ���������
# ����� ��� ����������������� �����������
set.seed(152)

# ������ ��������� ��� �������� �������������
cl_model <- train(default_train, default_lab, method = "rf")

# ������� ������ ������ explainer
cl_explainer <- lime(default_train, cl_model)

# �������� ���������� ��������� ���
# ��������� ����� ����������, 
# �� ������������� ��������
cl_explanation <- explain(default_test, 
                          cl_explainer, labels = "Yes",
                          n_features = 6,
                          n_permutations = 1000)
cl_explanation

# ������������� ���������� ���������
plot_features(cl_explanation)


cl_explainer

