# NoCloud Auto Installer

NoCloud-Auto-Installer est conçu pour installer automatiquement l'ensemble des
applications pour la solution NoCloud.

Deux types d'installations sont possibles :

* Full installation : permet d'installer la totalité des packages pour la
    Solution NoCloud.
    * Installe les paquets pour Apache2, Certbot, Php
    * Installe et configure MySql 
    * Installation automatisé de Nextcloud :
        * Création de la database Nextcloud.
        * Création de l'utilisateur Nextcloud.
        * Création de l'utilisateur Admin pour Nextcloud
        * Ajoute un fichier de préconfiguration pour l'accès à Nexcloud dans
            apache.
    * Installation automatisé de Dolibarr à partir du fichier d'installation de
        debian.
    * Installation automatisé de TetrasBack à partir du dépot TetrasBack de Tétras-Libre
* Installation sélective : permet d'installer l'outil voulu.

## Pré-requis

NoCloud-Auto-Installer a été testé sur Debian Jessie.
Pas de pré-requis nécessaires.

## Installation

### Full script

L'installation totale du système se fait en trois temps :

1. Configuration des variables d'environnement pour chaque logiciel à
   installer.<br/>
A chaque fichier SH correspond un fichier ENV qui contient l'ensemble des
variables que l'installeur peut personnaliser.<br/>
Pour chaque variable existantes il existe une valeur par défaut. Donc si un
oubli est fait la valeur par défaut est utilisée.
2. Exécution automatisé des outils via ``sh run.sh``
3. Actions Post installation.
    1. DNS + réseau
    2. Finalisation Dolibarr
    3. Ajout les certificats SSL
    4. Extractions MDP vers keepass

### Selective script

L'installation d'un script spécifique se fait aussi en trois étapes.

1. Configuration du ENV du script à faire tourner
2. Exécution de la commande avec le script voulu : 
    * Mysql : ``sh initInstall.sh && sh installMySQL.sh``
    * Nextcloud :
      ``sh initInstall.sh && sh installMySQL.sh && sh installNextcloud.sh``
    * Dolibarr : 
      ``sh initInstall.sh && sh installMySQL.sh && sh installDolibarr.sh``
    * TetrasBack : ``sh initInstall.sh && sh installTetrasBack.sh``
3. Faire la post installationd du script

### Actions post installation

#### MySql

* Vérifier le fichier /root/.my.cnf
* Le sauvegarder dans un lieu sûr. (Attention TetraBack à besoin de ce fichier
  pour fonctionner correctement)

#### Nextcloud

* Activer l'accès à Nextcloud sur via apache2

#### Dolibarr

* Ouvrir le navigateur pour aller sur Dolibarr et finaliser l'installation via
  l'interface web.

#### TetrasBack

* Installation a partir du dépot de Tétras-Libre

## Mises à jour

Le script `upgradeAll.sh`, met à jour tous les logiciels installés via cet
installer.

### Nextcloud

Le script `upgradeNextcloud.sh` met nextcloud à jour depuis la dernière version
stable depuis les dépots nextcloud.

### Tetras-back

Le script `upgradeTetras-back.sh` met Tetras-Back à jour en clonant la version
dans le gitlab tetras-libre.

### Dolibarr

Le script `upgradeDolibarr.sh` met Dolibarr à jour depuis la version deb
contenue dans ce dépot.

## Project

### TODO
+ [ ] Ajouter clé maintenance de tetrix
+ [x] Permettre root sans password
+ [ ] ufw permettre http https et ssh seulement.
+ [x] installation MySQL automatisée
	+ [x] Mot de passe root aléatoire ou prédéfinie
	+ [x] sauvegarde des informations de log dans /root/.my.cnf
+ [ ] installation de Nextcloud
	+ [x] Installation des fichiers de configuration pour apache2
	+ [ ] Activation nextcloud sur apache
	+ [x] Variables de spécialisation installation Nextcloud
+ [x] Installation Dolibarr
+ [x] Installation TetrasBack
