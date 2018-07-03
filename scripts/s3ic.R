setwd("C:/Users/mathieu.rajerison/Desktop/11_DREAL_HdF_Detecte les friches/S3IC/")

library(tidyverse)
library(stringr)
library(stringdist)

# READING
f.s3ic = read.csv("S3IC_HdF.csv", sep=";", encoding="UTF-8")
f.sirene = read.csv("../SIRENE/geo-sirene_60.csv/geo-sirene_60.csv")

summary(f.s3ic)

# FILTRE
f.s3ic.friche = f.s3ic[f.s3ic$Etat.d.activité=="En cessation d'activité" & 
                         f.s3ic$Département=="60", ]

# REFORMATAGE
## S3IC
f.s3ic.friche$Nom.établissement = f.s3ic.friche$Nom.établissement %>% 
                                  iconv(from="UTF-8", to='ASCII//TRANSLIT') %>%
                                  str_to_upper()

## SIRENE
f.sirene$NOMEN_LONG = f.sirene$NOMEN_LONG %>%
                      iconv(from="UTF-8", to='ASCII//TRANSLIT') %>%
                      str_to_upper()
  

# f.s3ic$Commune
# f.s3ic$Département
# 
# f.sirene$LIBCOM
# f.sirene$NOMEN_LONG
# f.sirene$NOM

# TESTS
f.sirene[grep("COMMUNE", f.sirene$NOMEN_LONG), ]
f.sirene$NOMEN_LONG[grep("quartz", str_to_lower(f.sirene$NOMEN_LONG))]

# MATCHING
n = nrow(f.s3ic.friche)
start = 1
n = 97
out = vector(mode="list")
for (i in 1:n) {
  
  cat("-----\n")
  print(i)
  origine_libelle = f.s3ic.friche$Nom.établissement[i]
  origine_commune = str_to_upper(f.s3ic.friche$Commune[i])
  
  # print(">> ORIGINE")
  # print(origine_commune)
  # print(origine_libelle)
  
  # SEL. SUR BASE DE COMMUNE
  f.sirene.sel = f.sirene[f.sirene$LIBCOM == origine_commune, ]
  
  # INIT
  commune = NA
  libelle = NA
  x = NA
  y = NA
  methode = "pas trouvé"
  stringDistance = NA
  
  # SEL. sur LE NOM
  if (nrow(f.sirene.sel) > 0 & !is.na(origine_libelle)) {
    
    print("commune trouvée ainsi que libellé")
    libelles = f.sirene.sel$NOMEN_LONG
    gs = grep(origine_libelle, libelles, fixed=TRUE) # LIBELLES CONTENANTS
    # print(gs)
    if (length(gs) > 0) {
      
      print("compris dedans")
      
      libelles.sel = libelles[gs]
      if (length(libelles.sel) > 0 & !is.na(libelles.sel)) {
        
        res = detectBestString(origine_libelle, libelles.sel)
        # INDICE
        w = which(f.sirene.sel$NOMEN_LONG == res$libelle)
        # INFOS
        methode = "compris dedans"
      }
      
    } else {
      
      print("levenstein")
      res = detectBestString(origine_libelle, libelles)
      # INDICE
      w = res$w
      # INFOS
      methode = "levenstein"
    }
    
    # INFOS
    commune = origine_commune
    libelle = res$libelle
    x = f.sirene.sel$longitude[w]
    y = f.sirene.sel$latitude[w]
    stringDistance = res$d
  }
  
  out[[i]] = data.frame(commune, libelle, x, y, methode, stringDistance)
  cat("\n")
}

# FUSION
res = do.call(rbind, out)
f.s3ic.friche_sirene = cbind(f.s3ic.friche, res)
View(f.s3ic.friche_sirene[, c("Nom.établissement","libelle")])

# EXPORT
save(out, file="../_script_R/rda/s3ic/out.rda") 
save(res, file="../_script_R/rda/s3ic/res.rda")
save(f.s3ic.friche_sirene, file="../_script_R/rda/s3ic/f.s3ic.friche_sirene.rda")
write.csv(f.s3ic.friche_sirene, "../_script_R/csv/s3ic/f.s3ic.friche_sirene.csv", row.names=FALSE)

# ORPHELINS
w = which(is.na(f.s3ic.friches_sirene$libelle))

# EXPLORATIONS
f.sirene[grep("AUBINE", f.sirene$NOMEN_LONG), c("NOMEN_LONG", "LIBCOM")]
f.s3ic.friche[70, ]
length(which(!is.na(f.s3ic.friche$libelle))) # 10
length(which(!is.na(f.s3ic.friche$x))) # 10

# PAS RECONNUS
f.s3ic.friche$Nom.établissement[which(is.na(f.s3ic.friche$libelle))]
f.s3ic.friche[f.s3ic.friche$Nom.établissement=="AUBINE ONYX" & is.na(f.s3ic.friche$libelle), ]
f.sirene[grep("AUBINE", f.sirene$NOMEN_LONG), c("NOMEN_LONG", "LIBCOM")]

# df = data.frame(nom_s3ic = str, id = 1:nrow(f.sirene.sel), d, nom_sirene = f.sirene.sel$NOMEN_LONG)
# df = df[order(df$d, df$id), ]
# df$nom_sirene
# which(df$nom_sirene=="AUBINE*THIERRY MAURICE MARCEL/")