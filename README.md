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
- les fichiers fonciers MAJIC (Mise A Jour de l'Information Cadastrale)

Seules les bases BASOL et BASIAS sont disponibles en téléchargement libre sur Internet. La base SIIIC est une base confidentielle entretenue par les DREALs.

## Objectif fixé
L'équipe s'est fixée de fournir in fine une carte des friches, non pas sur toute la région, mais sur un département, l'Oise, comme preuve de concept, ceci afin, aussi, de raccourcir les temps de traitement et d'intégration de données.

Cette carte est disponible dans le dossier `scripts/rendu_html`
<iframe src="scripts/rendu_html/rendu.html" width=100% height=600></iframe>

https://github.com/CEREMA/dtermed.detection-friches/blob/master/scripts/rendu_html/rendu.html

<a href="#"><img src="home.png" alt="Carte" /></a>


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


