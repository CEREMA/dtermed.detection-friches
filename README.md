# dtermed.detection.friches
La DTerMed du CEREMA a participé aux défis du Challenge [RST-Analytics-2018](https://www.cerema.fr/fr/actualites/cerema-sera-au-challenge-rst-analytics-19-20-juin-solutions)

L'équipe était composée de Silvio Rousic et Mathieu Rajerison du service GTIE.

Cette équipe a essayé de répondre au défi de la détection des friches urbaines.

![alt tag](https://user-images.githubusercontent.com/19548578/42260183-bacea1da-7f63-11e8-85fa-4bf5dccbbc3b.png)


## Bases utilisées
Pour cela, la DREAL Hauts-de-France a fourni 4 bases de données :

- la base [BASOL](https://basol.developpement-durable.gouv.fr/recherche.php) des sites pollués
- la base [BASIAS](http://www.georisques.gouv.fr/dossiers/inventaire-historique-des-sites-industriels-et-activites-de-service-basias#/) des sites industriels et activités de service
- une extraction de la base SIIIC sur les Installations Classées pour la Protection de l'Environnement
- les fichiers fonciers MAJIC (Mise A Jour de l'Information Cadastrale) sur le département de l'Oise

Seules les bases BASOL et BASIAS sont disponibles en téléchargement libre sur Internet. La base SIIIC est une base confidentielle entretenue par les DREALs.

## Objectif fixé
Afin d'optimiser les temps de traitement et d'intégration de données pour le délai imparti par l'exercice (mode hackathon sur 2 jours), l'équipe s'est fixée de produire comme preuve de concept (POC) une carte des friches centrée sur le territoire commun aux différentes sources d'entrée, soit sur le département de l'Oise.

Cette carte est disponible dans le dossier `scripts/rendu_html`
<iframe src="scripts/rendu_html/rendu.html" width=100% height=600></iframe>

## Description des bases et méthodes utilisées
La base [BASIAS](http://www.georisques.gouv.fr/dossiers/inventaire-historique-des-sites-industriels-et-activites-de-service-basias#/) comportait toutes les informations nécessaires, à savoir :

- le nom de l'établissement
- sa localisation
- son état d'activité

### BASOL et webscraping
Par contre, BASOL ne comportait pas l'état d'activité. Ce dernier a été récupéré depuis le site internet [BASOL](https://basol.developpement-durable.gouv.fr/recherche.php) par une technique de [webscraping](https://fr.wikipedia.org/wiki/Web_scraping).

### SIIIC et appariement par ressemblance entre chaîne de caractères (distance de levenstein)
SIIIC, elle, ne comportait pas les coordonnées géographiques. Une tentative de récupération de ces informations a été réalisée en tentant d'apparier les noms d'établissement de SIIIC avec ceux de la [base SIRENE géocodée par Christian Quest](http://data.cquest.org/geo_sirene/).

La technique d'appariement se base sur l'identicité des noms, l'inclusion possible, ou le niveau de ressemblance donné par la [distance de levenstein](https://fr.wikipedia.org/wiki/Distance_de_Levenshtein).

## Aperçu de la carte
![alt tag](https://user-images.githubusercontent.com/19548578/42266747-93c0627c-7f77-11e8-8617-a997d41be79a.png)
La technique de webscraping a également été utilisée pour afficher dans des infobulles le descriptif des sites récupéré sur internet.  

## Précautions concernant la carte
La localisation des sites SIIIC n'est pas toujours correcte puisque basée sur cette méthode d'appariement automatique.

La qualité de la carte dépend avant tout de l'actualité, ainsi que la qualité des données renseignées dans les bases de référence BASOL, BASIAS, BASOL.

La carte ne concerne que les friches industrielles, non les friches urbaines au sens large.

## Outils utilisés

### R
- Le paquet [rvest](https://cran.r-project.org/web/packages/rvest/index.html) a été utilisé pour scraper le site internet de BASOL.
- Le paquet [stringdist](https://cran.r-project.org/web/packages/stringdist/index.html) a été utilisé pour tenter d'apparier les noms d'établissements entre SIIIC et SIRENE.
- R Markdown et le paquet [leaflet](https://rstudio.github.io/leaflet/) ont servi à générer la carte interactive des friches de l'Oise.

### PostgreSQL
PostgreSQL a été utilisé afin de procéder à différentes extractions et requêtes sur les fichiers fonciers.

### QGIS
[QGIS](https://fr.wikipedia.org/wiki/QGIS) a permis de réaliser différents contrôles visuels avant la production de la carte interactive.

## Détail des fonctions

Les fonctions créées lors du défi sont dans le fichier ```functions.R``` du dossier ```lib```
 
### detectBestString

La fonction ```detectBestString``` est une fonction d'appariement basée sur la distance de levenstein qui prend en entrée la chaîne de caractères à apparier et une liste des chaînes de caractère cibles candidates.

Elle est basée sur la fonction ```stringdist``` du package du même nom.

Elle retourne un data.frame qui comprend trois colonnes :
1. la chaîne de caractère cible pour laquelle la distance de levenstein est la plus faible
2. la distance de levenstein (colonne d)
3. l'indice de la chaîne de caractère cible sélectionnée dans la liste des chaînes de caractères candidates

Par exemple :

	detectBestString("AUBINE ONYX", sirene$NOMEN_LONG)
	> libelle d  w
	1  AUBINE 5 10

### fricheOrNotFriche

La fonction ```fricheOrNotFriche``` permet de savoir, par un scraping du site BASOL, si un site est actuellement en friche ou pas.

	fricheOrNotFriche("02.0028")
	> FALSE

### getDescriptionSite

La fonction ```getDescriptionSite``` permet de récupérer la description détaillée du site telle qu'elle est sur le site BASOL. Sur la carte produite, cette description apparaît en popup.

	getDescriptionSite("60.0033")
	> <span class="marine">Le site de Liancourt a accueilli une usine fabriquant du gaz à partir de la distillation de la houille. Actuellement, il est utilisé pour les besoins d'EDF/GDF.</span>	
	

### formaterCodeBasol

La fonction ```formaterCodeBasol``` permet de formater convenablement les codes BASOL car ces derniers peuvent être considérés comme des numériques à l'ouverture. Ainsi, 02.0500 peut être considéré comme 2.005 à la lecture du fichier, ce qui nécessite de le reformater.

	formaterCodeBasol(2.05)
	> "02.0500"