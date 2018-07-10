fricheOrNotFriche = function(numero_site) {
  url = paste0("https://basol.developpement-durable.gouv.fr/fiche.php?page=1&index_sp=", numero_site)
  
  html <- read_html(url)
  
  # sélection des noeuds
  checked = html_attr(html_nodes(html, xpath='//p[span[a[text()="friche"]]]/input')[[1]], "checked")
  
  if (is.na(checked)) {
    checked = FALSE
  } else if (checked == "checked") {
    checked = TRUE
  } 
  
  return(checked)
}

# code = "02.0030"
# fricheOrNotFriche("02.0028")

#------------------------------------------------------------------------------------------
getInfoSite = function(numero_site) {
  
  url = paste0("https://basol.developpement-durable.gouv.fr/fiche.php?page=1&index_sp=", numero_site)
  
  #Reading the HTML code from the website
  html <- read_html(url)
  
  # sélection des noeuds
  t = html_nodes(html, xpath='//div[strong[text()="Situation technique du site"]]/following-sibling::div[@id="contenu"]/table')
  
  # récupération du tableau
  df = html_table(t)[[1]]
  df = df[nrow(df), ]
  df$numero_site = numero_site
  
  return(df)
  
}

# numero_site = "59.0562"
# getInfoSite(numero_site)

#------------------------------------------------------------------------------------------
getDescriptionSite = function(numero_site) {
  
  url = paste0("https://basol.developpement-durable.gouv.fr/fiche.php?page=1&index_sp=", numero_site)
  
  #Reading the HTML code from the website
  html <- read_html(url)
  
  # sélection des noeuds
  n = html_nodes(html, xpath='//div[strong[contains(text(), "risation du site")]]//following-sibling::div[@id="contenu"]/p/strong[contains(text(), "Description du")]/following-sibling::span')
  
  if (html_text(n) == "") {
    t = "non trouvé"
  } else {
    t = as.character(n)
  }
  return(n)
  
}

# numero_site = "59.0562"
# getInfoSite(numero_site)

#------------------------------------------------------------------------------------------
formaterCodeBasol = function(code) {
  numero.s = code %>% as.character() %>% str_split("\\.")[[1]]
  numero = paste0(str_pad(numero.s[1], 2, "left", "0"), ".", str_pad(numero.s[2], 4, "right", "0"))
  return(numero)
}

# code ="02.005"
# formaterCodeBasol(code)

#------------------------------------------------------------------------------------------
detectBestString = function(str, libelles) {
  
  out = vector(mode="list")
  for (i in 1:length(libelles)) {
    
    libelle = libelles[i]
    
    # SPLIT
    if (str_detect(libelle, "\\*")) {
        v = str_split(libelle, "\\*")[[1]]
    } else {
      v = libelle
    }
    
    # DISTANCES
    s = sapply(v, function(x) stringdist(str, x, method="dl"))
    
    # MEILLEUR CANDIDAT DANS LA CHAINE (UTILE SI SPLIT)
    d = min(s)
    w = which.min(s)
    # print(d)
    out[[i]] = data.frame(libelle, d, w)
  }
  df = do.call(rbind, out)
  
  # MIN DISTANCE
  res = df[which.min(df$d), ]

  return(res)
}

# str = "AUBINE ONYX"
# libelles = f.sirene.sel$NOMEN_LONG
# detectBestString(str, libelles)
