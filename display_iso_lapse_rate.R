library(ggplot2)
library(RColorBrewer)

# Check your working directory
wd <- setwd("C:/Users/iotte/Documents/Desktop/training/")

## Read data
df <- read.csv2("elevation_d18_16_wd_outlier_corrected_reshape.csv", 
                header = T, sep = ";")

df.sub = subset(df, df$station != "Sav5" &
                  df$station != "Hom4" &
                  df$station != "Fpo0")


##### sort facets according to elevation (not alphabetic order!)
f <- c("rain", "tf", "fog")

df <- within(df, type <- factor(type, levels = f))
df.sub <- within(df.sub, type <- factor(type, levels = f))

shape = points(c(16,17,15,3,7,8,11,13))

### plotting elevation lapse rate d18_16
iso.elvtn.d1816 <- ggplot(df, aes(x = Elevation, y = d1816, colour = year, 
                                  group = year, size = .75)) + # shape = station
  geom_point() +
  stat_smooth(data = df.sub, method = lm, se = FALSE, size = .5) +
  facet_grid(. ~ type) +
  ylab( expression(delta^{18}*O ~ "\u2030")) +
  #ylab( expression(delta*D ~ "\u2030")) +
  xlab("Elevation (m a.s.l.)") +
  theme(
    axis.text.x = element_text(color = "black"),
    axis.text.y = element_text(color = "black"),
    strip.text = element_text(face = "bold", size = rel(1.1)),
    strip.background = element_rect(color = "black", fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    panel.border = element_rect(color = "black", fill = NA),
    legend.title = element_blank(),
    legend.text = element_blank(),
    legend.key = element_blank()) +#,
    #legend.text = element_text(size = rel(.6)))+#,
    #legend.key.size = unit(.65, "cm"),
    #legend.background = element_rect(color = "black", fill = "white")) +
  labs(fill = "") +
  #scale_shape_manual(values = c(16,17,15,3,7,8,11,13,6)) +
  scale_color_manual(values = c(brewer.pal(4, "Paired"), "black"))#,
  #                   labels = c("2012-2013 (dry)", 
  #                              "2012-2013 (wet)",
  #                              "2013-2014 (dry)",
  #                              "2013-2014 (wet)",
  #                              "2012-2014"))


# print "iso.mns.mnth.elvtn.18O"
png("out_sia/iso_elvtn_d1816_wd_outlier_corrected_reloaded.png", width = 38, height = 14, units = "cm", 
    res = 300, pointsize = 15)
print(iso.elvtn.d1816)
dev.off()














ann.uw.d1816 <- qplot(Elevation, all_d18_16_uw, data = df) +
  #stat_smooth(method = "lm", formula = y ~ x, se = FALSE, color = "black",
  #            fullrange = TRUE) +
  stat_smooth(method = "lm", formula = y ~ log(x), se = FALSE, color = "black",
              fullrange = TRUE) + 
  # fullrange: extrapolierte Regressionslinie pro facet_grid (aber nach gleicher formel)
  # facet_grid(. ~ type) +
  annotate("text", label = eqn, parse = TRUE, x = 2300, y = -1.5, hjust = -1.1, vjust = -.5)

coef.fog <- coef(lm(all_d18_16_uw ~ log(Elevation), data = df.fog))
summary(lm(all_d18_16_uw ~ log(Elevation), data = df.fog))

# add regression function and r?? to scatterplot
model <- lm(all_d18_16_uw ~ log(Elevation), df.fog)
eqn <- as.character(as.expression(
  #substitute(italic(y) == a + b * log(x) * "," ~~ italic(r)^2 ~ "=" ~ r2,
  substitute(italic(y) == b * log(x) + a *"," ~~ italic(r)^2 ~ "=" ~ r2,
             list(a = format(coef(model)[1], digits = 3),
                  b = format(coef(model)[2], digits = 3),
                  r2 = format(summary(model)$r.squared, digits = 2)
             ))))
parse(text = eqn)