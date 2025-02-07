library(lme4)
library(lmerTest)


#df <- read.csv("./cross-talker-ASR/O_Jan31/df_CNN_k=best_mean_tau=1.csv")


df <- read.csv("./cross-talker-ASR/O_Jan31/df_transformer_mean_k_tau=1.csv")


# 
df <- df[df$Condition2 != "Talker-specific",]
#df_no_talker_specific


calculate_zvalue <- function(k, data) {
  data$similarity <- exp(- data$distance **k)
  model <- glmer(
    formula = cbind(numCorrect, numIncorrect) ~ 1 + similarity + (1 | SentenceID/Keyword) + (1 | TestTalkerID),
    data = data,
    family = binomial(link = "logit")
  )
  summary_model <- summary(model)
  z_value <- summary_model$coefficients["similarity", "z value"]
  return(z_value)
}


if ("similarity" %in% colnames(df)) {
  df <- subset(df, select = -similarity)
}
objective_function <- function(k) {
  -calculate_zvalue(k, df)
}

result <- optim(par = 1, fn = objective_function, method = "BFGS")
best_k <- result$par
cat("Optimal k (based on z-value):", best_k, "\n")
df$similarity <- exp(-df$distance **best_k)
#head(df$similarity)



m.sim <- glmer(
  formula = cbind(numCorrect, numIncorrect)  ~ 1 + similarity + (1 | SentenceID / Keyword) + (1| TestTalkerID),
  data = df,#df,
  family = binomial(link = "logit")
)
summary(m.sim)


# Model with condition
m.sim_cond <- glmer(
  formula = cbind(numCorrect, numIncorrect) ~ 1 + similarity + Condition2 + (1 | SentenceID / Keyword)+ (1| TestTalkerID),
  data = df,#df,
  family = binomial(link = "logit")
)
summary(m.sim_cond)

anova(m.sim, m.sim_cond)



# Model with condition and interaction


m.sim_int <- glmer(
  formula = cbind(numCorrect, numIncorrect) ~ 1 + similarity * Condition2 + (1 | SentenceID / Keyword)+ (1| TestTalkerID),
  data = df,#df,
  family = binomial(link = "logit")
)
summary(m.sim_int)
anova(m.sim, m.sim_cond, m.sim_int, test = "Chisq")



m.cond <- glmer(
  formula = cbind(numCorrect, numIncorrect) ~ 1 + Condition2 + (1 | SentenceID / Keyword)+ (1| TestTalkerID),
  data = df,#df,
  family = binomial(link = "logit")
)
summary(m.cond)


predictions <- predict(
  m.sim_cond, newdata = df, se.fit = TRUE, type = "link"
)

predicted_probs <- plogis(predictions$fit)
predicted_ci_lower <- plogis(predictions$fit - 1.96 * predictions$se.fit)
predicted_ci_upper <- plogis(predictions$fit + 1.96 * predictions$se.fit)

df$Predicted_Prob <- predicted_probs
df$predicted_ci_lower <- predicted_ci_lower
df$predicted_ci_upper <- predicted_ci_upper

write.csv(df, "../data/predicted_study2_TS_max_tau=1_k=.csv", row.names = FALSE)

