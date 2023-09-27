##--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--++
#  Partisan Response
#  Xperceive
#  Last Edited: 1.09.14 
#  Doug Ahler and Gaurav Sood
##--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--++

# Set Working dir.
	setwd(basedir)

# Sourcing Common Functions
	source("func/func.R")

# Load data
	pr			<- read.csv("xperceive/PartisanResponse/data/partisanresponse.csv")
	names(pr)	<- tolower(names(pr))

# PID
	#"pid"            "pid_text"       "pid_d"          "pid_r"          "pid_i"
	
	aggpid	<-	paste0(pr$pid, pr$pid_d, pr$pid_r, pr$pid_i)
	pr$pid7	<-	NA
	pr$pid7 <-	ifelse(aggpid=='11NANA', 1, pr$pid7)
	pr$pid7 <-	ifelse(aggpid=='12NANA', 2, pr$pid7)
	pr$pid7 <-	ifelse(aggpid=='3NANA3' | aggpid=='4NANA3', 3, pr$pid7)
	pr$pid7 <-	ifelse(aggpid=='3NANA2' | aggpid=='4NANA2', 4, pr$pid7)
	pr$pid7 <-	ifelse(aggpid=='3NANA1' | aggpid=='4NANA1', 5, pr$pid7)
	pr$pid7 <-	ifelse(aggpid=='2NA2NA', 6, pr$pid7)
	pr$pid7 <-	ifelse(aggpid=='2NA1NA', 7, pr$pid7)
	
	pr$pid3 <-  car::recode(pr$pid7, "c(1,2,3)='Democrat';4='Independent';c(5,6,7)='Republican'")
	
# Attention Check
	pr$attentive <-	!is.na(pr$attn_check_3) & !is.na(pr$attn_check_5)
	
# Political Knowledge
	# no qs 3 and 4
	pr$know1r	<- pr$know1 ==3 
	pr$know2r	<- pr$know2 ==1
	pr$know5r	<- pr$know5 ==4
	pr$know6r	<- pr$know6 ==4
	pr$know7r	<- pr$know7 ==2
	
	pr$know		<- with(pr, rowMeans(cbind(know1r, know2r, know5r, know6r, know7r)))
	
# Treatment
	# All Conds.
	# dc, dt, rc, rt
		pr$treat 	<- NA
		pr$treat	<- ifelse(!is.na(pr$dc), 'D Change', pr$treat)
		pr$treat	<- ifelse(!is.na(pr$dt), 'D No Change', pr$treat)
		pr$treat	<- ifelse(!is.na(pr$rc), 'R Change', pr$treat)
		pr$treat	<- ifelse(!is.na(pr$rt), 'R No Change', pr$treat)
		pr$treat	<- ifelse(is.na(pr$treat), 'Control', pr$treat)
	
	# Trifecta
		pr$treat3	<- "Control"
		pr$treat3[(pr$treat=='R Change' | pr$treat=='R No Change')] <- "Bad Elite R"
		pr$treat3[(pr$treat=='D Change' | pr$treat=='D No Change')] <- "Bad Elite D"
	
	# R Change/No Change 1
		pr$ronly	<- pr$treat
		pr$ronly[pr$treat %in% c('D No Change', 'D Change', 'Control')] <- NA
		
	# D Change/No Change 
		pr$donly	<- pr$treat
		pr$donly[pr$treat %in% c('R No Change', 'R Change', 'Control')] <- NA

# DVs
	pr$therm_dem <- zero1(ifelse(is.na(pr$ft_1), pr$q53_1, pr$ft_1))
	pr$therm_rep <- zero1(ifelse(is.na(pr$ft_2), pr$q53_2, pr$ft_2))
	
	pr$rdtherm		<- pr$therm_rep - pr$therm_dem
	
	# Traits
		#Ignorant				
		#Sincere				
		#Open to reason				
		#Smug				
		#Selfish				
		#Patriotic				
		#Compassionate			
		#Hypocritical

		pr$dem_traits_1r <- ifelse(is.na(pr$dem_traits_1), pr$dem_traits_1.1, pr$dem_traits_1)
		pr$dem_traits_2r <- ifelse(is.na(pr$dem_traits_2), pr$dem_traits_2.1, pr$dem_traits_2)
		pr$dem_traits_3r <- ifelse(is.na(pr$dem_traits_3), pr$dem_traits_3.1, pr$dem_traits_3)
		pr$dem_traits_4r <- ifelse(is.na(pr$dem_traits_4), pr$dem_traits_4.1, pr$dem_traits_4)
		pr$dem_traits_5r <- ifelse(is.na(pr$dem_traits_5), pr$dem_traits_5.1, pr$dem_traits_5)
		pr$dem_traits_6r <- ifelse(is.na(pr$dem_traits_6), pr$dem_traits_6.1, pr$dem_traits_6)
		pr$dem_traits_7r <- ifelse(is.na(pr$dem_traits_7), pr$dem_traits_7.1, pr$dem_traits_7)
		pr$dem_traits_8r <- ifelse(is.na(pr$dem_traits_8), pr$dem_traits_8.1, pr$dem_traits_8)
		
		pr$rep_traits_1r <- ifelse(is.na(pr$rep_traits_1), pr$rep_traits_1.1, pr$rep_traits_1)
		pr$rep_traits_2r <- ifelse(is.na(pr$rep_traits_2), pr$rep_traits_2.1, pr$rep_traits_2)
		pr$rep_traits_3r <- ifelse(is.na(pr$rep_traits_3), pr$rep_traits_3.1, pr$rep_traits_3)
		pr$rep_traits_4r <- ifelse(is.na(pr$rep_traits_4), pr$rep_traits_4.1, pr$rep_traits_4)
		pr$rep_traits_5r <- ifelse(is.na(pr$rep_traits_5), pr$rep_traits_5.1, pr$rep_traits_5)
		pr$rep_traits_6r <- ifelse(is.na(pr$rep_traits_6), pr$rep_traits_6.1, pr$rep_traits_6)
		pr$rep_traits_7r <- ifelse(is.na(pr$rep_traits_7), pr$rep_traits_7.1, pr$rep_traits_7)
		pr$rep_traits_8r <- ifelse(is.na(pr$rep_traits_8), pr$rep_traits_8.1, pr$rep_traits_8)
	
		# Scale: Good to bad
		oppscale <- "5=1;4=2;3=3;2=4;1=5"
		# cor(cbind(pr$dem_traits_1, pr$dem_traits_8, pr$dem_traits_2, pr$dem_traits_3, pr$dem_traits_4, pr$dem_traits_5, pr$dem_traits_6, pr$dem_traits_7), use="na.or.complete")
		# cor(cbind(pr$rep_traits_1r, pr$rep_traits_2r, pr$rep_traits_3r, pr$rep_traits_4r, pr$rep_traits_5r, pr$rep_traits_6r, pr$rep_traits_7r, pr$rep_traits_8r), use="na.or.complete")		
		# cor(cbind(pr$dem_traits_1r, pr$dem_traits_2r, pr$dem_traits_3r, pr$dem_traits_4r, pr$dem_traits_5r, pr$dem_traits_6r, pr$dem_traits_7r, pr$dem_traits_8r), use="na.or.complete")
		
		pr$dem_traits_2r <- car::recode(pr$dem_traits_2r, oppscale)
		pr$dem_traits_3r <- car::recode(pr$dem_traits_3r, oppscale)
		pr$dem_traits_6r <- car::recode(pr$dem_traits_6r, oppscale)
		pr$dem_traits_7r <- car::recode(pr$dem_traits_7r, oppscale)
		
		pr$rep_traits_2r <- car::recode(pr$rep_traits_2r, oppscale)
		pr$rep_traits_3r <- car::recode(pr$rep_traits_3r, oppscale)
		pr$rep_traits_6r <- car::recode(pr$rep_traits_6r, oppscale)
		pr$rep_traits_7r <- car::recode(pr$rep_traits_7r, oppscale)
		
		pr$reptrt 		<- rowMeans(zero1(cbind(pr$rep_traits_1r, pr$rep_traits_2r, pr$rep_traits_3r, pr$rep_traits_4r, pr$rep_traits_5r, pr$rep_traits_6r, pr$rep_traits_7r, pr$rep_traits_8r)), na.rm=T)
		pr$demtrt 		<- rowMeans(zero1(cbind(pr$dem_traits_1r, pr$dem_traits_8r, pr$dem_traits_2r, pr$dem_traits_3r, pr$dem_traits_4r, pr$dem_traits_5r, pr$dem_traits_6r, pr$dem_traits_7r)), na.rm=T)
		
		pr$rdtrt		<- pr$reptr - pr$demtr
	
		pr$inouttrt								<- ifelse(pr$pid3=='Democrat', -pr$rdtrt, pr$rdtrt)
		pr$inouttrt[pr$pid3=='Independent']		<- NA
		
		# Traits that I don't think apply for us: smug, selfish, compassionate
		pr$reptrt2 		<- rowMeans(zero1(cbind(pr$rep_traits_1r, pr$rep_traits_2r, pr$rep_traits_3r, pr$rep_traits_6r, pr$rep_traits_8r)), na.rm=T)
		pr$demtrt2		<- rowMeans(zero1(cbind(pr$dem_traits_1r, pr$dem_traits_3r, pr$dem_traits_3r, pr$dem_traits_6r, pr$dem_traits_8r)), na.rm=T)
		
		pr$rdtrt2		<- pr$reptrt2 - pr$demtrt2
		
	# Save data
		write.csv(pr, file="xperceive/PartisanResponse/data/pr.recode.csv")
	
		
		