"
 Partisan Response
 Xperceive
 Last Edited: 3/23/16 
 Doug Ahler and Gaurav Sood
"

# Set Working dir.
setwd(basedir)

# Sourcing Common Functions
library(goji)
library(grid)
library(ggplot2)

# Load data
pr			<- read.csv("xperceive/PartisanScandal/tabs/partisanresponse_inout_traitdiffs.csv")
names(pr)	<- tolower(names(pr))

pr$strong <- as.factor(pr$strong)

ggplot(data = pr, aes(y = condition, x = mean_ti, xmin = x95l_ti, xmax = x95h_ti, colour = strong)) + 
geom_point() + 
geom_errorbarh(height = 0, size=.25) +
scale_colour_manual("", labels = c("Weak/leaning partisans", "Strong partisans"), values = c("#A84E1C", "#42C4C7")) +
scale_y_discrete(labels=c("Control", "In-Party Unchanged", "In-Party Responds", "Out-Party Unchanged", "Out-Party Responds")) + 
scale_x_continuous(breaks=seq(.5,1,.05), labels=nolead0s(seq(.5,1,.05))) + 
labs(x="Evaluative Polarization",y="") +
theme_minimal() +
theme(panel.grid.major.y = element_line(colour = "#e3e3e3", linetype = "dotted"),
	  panel.grid.minor.x = element_blank(),
	  panel.grid.major.x = element_line(colour = "#f1f1f1", linetype = "solid"),
	  panel.border       = element_blank(),
	  legend.position  = "bottom",
	  legend.key       = element_blank(),
	  legend.key.width = unit(1,"cm"),
 	  title        = element_text(size=8),
	  axis.title   = element_text(size=11),
	  axis.text    = element_text(size=11),
	  axis.ticks.y = element_blank(),
	  axis.ticks.x = element_line(colour = '#f1f1f1'),
	  strip.text.x =  element_text(size=9),
	  legend.text=element_text(size=11)) 

ggsave(file="xperceive/PartisanScandal/figs/gg_exp.pdf")

"
Dems. Only
"
		
pr <- read.csv("xperceive/PartisanScandal/tabs/partisanresponse_demsonly.csv")
names(pr)	<- tolower(names(pr))

pr$strong <- as.factor(pr$strong)
	
ggplot(data = pr, aes(y = cond, x = mean_ti, xmin = x95l_ti, xmax = x95h_ti, colour = strong)) + 
geom_point() + 
geom_errorbarh(height = 0, size=.25) +
scale_colour_manual("", values = c("#A84E1C", "#42C4C7")) +
scale_y_discrete(labels=c("Control", "No Response", "Response")) + 
scale_x_continuous(breaks=seq(0,1,.1), labels=nolead0s(seq(0,1,.1))) + 
labs(x="",y="") + 
theme_minimal() +
theme(panel.grid.major.y = element_line(colour = "#e3e3e3", linetype = "dotted"),
	  panel.grid.minor.x = element_blank(),
	  panel.grid.major.x = element_line(colour = "#f1f1f1", linetype = "solid"),
	  panel.border       = element_blank(),
	  legend.position  = "none",
	  legend.key       = element_blank(),
	  legend.key.width = unit(1,"cm"),
 	  title        = element_text(size=8),
	  axis.title   = element_text(size=8),
	  axis.text    = element_text(size=8),
	  axis.ticks.y = element_blank(),
	  axis.ticks.x = element_line(colour = '#f1f1f1'),
	  strip.text.x =  element_text(size=9),
	  legend.text=element_text(size=8)) 

ggsave(file="xperceive/PartisanScandal/figs/gg_dems_exp.pdf")
