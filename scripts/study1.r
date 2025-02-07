library(lme4)
library(lmerTest)

df <- read.csv("./data/df_CNN_k=1_max.csv")


summary(df)


m.sim <- glmer(

  formula = cbind(numCorrect, numIncorrect)  ~ 1 + similarity + (1 | SentenceID / Keyword) + (1| TestTalkerID),
  data = df,#df,
  family = binomial(link = "logit")
)
summary(m.sim)


m.sim_cond <- glmer(
  formula = cbind(numCorrect, numIncorrect) ~ 1 + similarity + Condition2 + (1 | SentenceID / Keyword)+ (1| TestTalkerID),
  data = df,#df,
  family = binomial(link = "logit")
)
summary(m.sim_cond)

anova(m.sim, m.sim_cond)

predictions <- predict(
  m.sim_cond, newdata = df, se.fit = TRUE, type = "link"
)

predicted_probs <- plogis(predictions$fit)
predicted_ci_lower <- plogis(predictions$fit - 1.96 * predictions$se.fit)
predicted_ci_upper <- plogis(predictions$fit + 1.96 * predictions$se.fit)

df$Predicted_Prob <- predicted_probs
df$predicted_ci_lower <- predicted_ci_lower
df$predicted_ci_upper <- predicted_ci_upper

write.csv(df, "./cross-talker-ASR/O_Jan31/predicted_study1_TS_max1.csv", row.names = FALSE)








df <- read.csv("./cross-talker-ASR/O_Jan31/df_CNN_k=1_max.csv")
df_no_talker_specific <- df[df$Condition2 != "Talker-specific",]
summary((df_no_talker_specific))
colnames(df)

m.sim <- glmer(

  formula = cbind(numCorrect, numIncorrect)  ~ 1 + similarity + (1 | SentenceID / Keyword) + (1| TestTalkerID),
  data = df_no_talker_specific,#df,
  family = binomial(link = "logit")
)
summary(m.sim)


m.sim_cond <- glmer(
  formula = cbind(numCorrect, numIncorrect) ~ 1 + similarity + Condition2 + (1 | SentenceID / Keyword)+ (1| TestTalkerID),
  data = df_no_talker_specific,#df,
  family = binomial(link = "logit")
)
summary(m.sim_cond)

anova(m.sim, m.sim_cond)



m.sim_int <- glmer(
  formula = cbind(numCorrect, numIncorrect) ~ 1 + similarity * Condition2 + (1 | SentenceID / Keyword)+ (1| TestTalkerID),
  data = df_no_talker_specific,#df,
  family = binomial(link = "logit")
)
summary(m.sim_int)
anova(m.sim, m.sim_cond, m.sim_int, test = "Chisq")



m.cond <- glmer(
  formula = cbind(numCorrect, numIncorrect) ~ 1 + Condition2 + (1 | SentenceID / Keyword)+ (1| TestTalkerID),
  data = df_no_talker_specific,#df,
  family = binomial(link = "logit")
)
summary(m.cond)

