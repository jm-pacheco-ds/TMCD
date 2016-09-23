# 20160923-exercises - mean and std for each within a dataframe

library("dplyr")
library("tidyr")

#Mean, and std  for each column in mtcars dataframe
mtcars %>% 
  summarise_each(funs(mean, sd))

mtcars %>% 
  summarise_all(funs(mean, sd))

#only for a set of cols
mtcars %>% 
  select(hp, drat, wt) %>% 
  summarise_all(sd)

#filter rows with cyl >= 5.5
mtcars %>% filter(cyl >= 5.5)
  
#filter rows with 5.5 >= cyl >= 7.5
mtcars %>% filter(cyl >= 5.5 & cyl <= 7.5)
mtcars %>% filter(cyl >= 5.5, cyl <= 7.5)

#Exercise: ¿Cómo obtenemos la media y la desviación típica para todos los trimestres en cada grupo?
suppressMessages(library(dplyr))
DF <- tbl_df(read.table(header = TRUE, text = "
   Group   Year   Qtr.1  Qtr.2  Qtr.3  Qtr.4
    g1      2006   15     16     19     17
    g1      2007   12     13     27     23
    g1      2008   22     22     24     20
    g1      2009   10     14     20     16
    g2      2006   12     13     25     18
    g2      2007   16     14     21     19
    g2      2008   13     11     29     15
    g2      2009   23     20     26     20
    g3      2006   11     12     22     16
    g3      2007   13     11     27     21
    g3      2008   17     12     23     19
    g3      2009   14     9      31     24
"))

#Example from the slides
DF %>%
  select(Group, Year, Qtr.1) %>%
  group_by(Group) %>%
  summarise(Mean_Qtr.1 = mean(Qtr.1, na.rm=TRUE))

#Solution
DF %>%
  group_by(Group) %>%
  summarise_at(vars(Qtr.1, Qtr.2, Qtr.3, Qtr.4), funs(mean,sd))





