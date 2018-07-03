library(rvest)
library(tidyverse)

setwd("C:/Users/mathieu.rajerison/Desktop/11_DREAL_HdF_Detecte les friches/BASOL/")

source("../_script_R/lib/fonctions.R")

# READING
f.basol = read.csv("BASOL_HdF.csv",sep=";", encoding="UTF-8")

# FILTRE
dep = "60"
f.basol.extrait = f.basol[f.basol$Dépt.==dep, ]

# EXPLORATION
summary(f.basol.extrait)
names(f.basol.extrait)
summary(f.basol.extrait$Numéro.BASOL.complet)

# CHANGEMENT DE TYPE
f.basol.extrait$Numéro.BASOL.complet = as.character(f.basol.extrait$Numéro.BASOL.complet)

# REFORMATAGE
f.basol.extrait$Numéro.BASOL.complet = sapply(f.basol.extrait$Numéro.BASOL.complet, formaterCodeBasol)

# REQUETAGE INFO SITE
out = vector(mode="list")
for (i in 1:length(f.basol.extrait$Numéro.BASOL.complet)) {
  numero_site = f.basol.extrait$Numéro.BASOL.complet[i]
  print(i)
  print(numero_site)
  out[[i]] = getInfoSite(numero_site)
}
res = do.call(rbind, out)
names(res) = c("evenement", "date_prescription", "etat_site", "date_realisation")

# EXPLORATION
unique(res$etat_site)

# REQUETAGE FRICHE OU PAS
n = length(f.basol.extrait$Numéro.BASOL.complet)
out = vector(mode="list")
while(length(out) < n) {
  for (i in 20:n) {
  # for (i in 75:101) {
    if (i > length(out)) {
      numero_site = f.basol.extrait$Numéro.BASOL.complet[i]
      print(i)
      print(numero_site)
      out[[i]] = fricheOrNotFriche(numero_site)
    }
  }
}
save(out, file="../_script_R/rda/out_basol.rda")
res = unlist(out)
save(res, file="../_script_R/rda/res_basol.rda")

f.basol.extrait$estFriche = res
save(f.basol.extrait, file="../_script_R/rda/f.basol.extrait.rda")

# EXPORT CSV
write.csv(f.basol.extrait, "../_script_R/csv/basol_dep60.csv", row.names=F)

# SAPPLY
# f.basol.extrait = sapply(f.basol.extrait$Numéro.BASOL.complet, fricheOrNotFriche)





sapply("02.005", fricheOrNotFriche)

#-------------------------------------------------------------
titres = html_nodes(html, 'div#titre.blanc')
w = which(html_text(titres) == "Situation technique du site")
# html_nodes(html, xpath='//div#titre.blanc[text() = "Situation technique du site"]')

html = htmlParse("http://www.le-footballeur.com/clubs_football-liste-departement.php", asText=FALSE)

html = htmlParse("https://basol.developpement-durable.gouv.fr/fiche.php?page=1&index_sp=02.0006", asText=FALSE)