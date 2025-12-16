# ZK HUD V3 - Ultra Customizable HUD with Drag & Drop

HUD FiveM ultra customisable avec système de drag & drop, formes innovantes pour les statuts et 3 styles de compteur de vitesse.

## Fonctionnalités

### Éléments du HUD

**Informations Joueur** (haut droite par défaut)
- ID du joueur
- Job et Grade
- Argent liquide (Cash)
- Argent en banque (Bank)

**Indicateurs de Statut** (bas gauche par défaut)
- Santé (forme hexagone)
- Armure (forme diamant)
- Faim (forme pentagone)
- Soif (forme octogone)

**Compteur de Vitesse** (bas droite par défaut)
- Style Minimal : Affichage simple et épuré
- Style Moderne : Design futuriste avec barres animées
- Style Classique : Jauge circulaire avec aiguille
- Affiche la vitesse (km/h), l'essence et la santé du véhicule

### Système d'édition

Commande `/edithud` pour ouvrir le menu d'édition :
- **Drag & Drop** : Déplacer chaque élément librement
- **Grille d'alignement** : Pour un positionnement précis
- **Toggle éléments** : Activer/désactiver chaque élément individuellement
- **Choix de couleurs** : Personnaliser les couleurs principales
- **Style de compteur** : Choisir entre 3 styles différents
- **Sauvegarde automatique** : Configuration sauvegardée en base de données

## Prérequis

- ESX Framework
- ox_lib
- ox_inventory (pour la faim/soif)
- oxmysql

## Installation

1. **Télécharger et extraire** le script dans votre dossier `resources`

2. **Importer la base de données**
   ```bash
   Exécuter le fichier zk_hud_v3.sql dans votre base de données
   ```

3. **Configuration**
   - Modifier `config.lua` selon vos besoins
   - Positions par défaut
   - Couleurs par défaut
   - Commande d'édition

4. **Démarrer la ressource**
   ```lua
   ensure zk_hud
   ```

## Configuration

### Config.lua

```lua
-- Commande pour ouvrir le menu d'édition
Config.EditCommand = 'edithud'

-- Positions par défaut (en pourcentage)
Config.DefaultPositions = {
    playerInfo = { x = 85.0, y = 2.0, visible = true },
    statusIndicators = { x = 18.0, y = 82.0, visible = true },
    speedometer = { x = 85.0, y = 85.0, visible = true }
}

-- Couleurs par défaut
Config.DefaultColors = {
    primary = '#00d4ff',
    secondary = '#ff006e',
    success = '#00ff88',
    warning = '#ffaa00',
    danger = '#ff0055',
    info = '#0099ff'
}

-- Style par défaut du compteur
Config.DefaultSpeedometerStyle = 'moderne'
```

## Utilisation

### Pour les joueurs

1. **Rejoindre le serveur** : Le HUD s'affiche automatiquement après le spawn
2. **Éditer le HUD** : Utiliser la commande `/edithud`
3. **Déplacer les éléments** : Cliquer et maintenir pour drag & drop
4. **Personnaliser** : Changer les couleurs, activer/désactiver des éléments
5. **Sauvegarder** : Cliquer sur "Sauvegarder" pour enregistrer la configuration

### Pour les administrateurs

**Commande admin** : `/resethud [playerId]`
- Réinitialise la configuration HUD d'un joueur

## Fonctionnalités techniques

### Design moderne sans blur
- Pas de `backdrop-filter` pour éviter l'effet noir sur FiveM
- Utilisation de `rgba()` pour la transparence
- Optimisé pour les performances

### Gestion des erreurs NUI
- Try/catch sur toutes les fonctions critiques
- Logs d'erreurs détaillés
- Callbacks sécurisés

### Sauvegarde en base de données
- Configuration unique par joueur (identifier)
- Positions en pourcentage (responsive)
- Format JSON pour flexibilité
- Timestamps de création/modification

### Formes innovantes
- Hexagone pour la santé
- Diamant pour l'armure
- Pentagone pour la faim
- Octogone pour la soif
- Remplissage animé par clip-path

## Structure des fichiers

```
zk_hud/
├── fxmanifest.lua
├── config.lua
├── client/
│   └── main.lua
├── server/
│   └── main.lua
├── html/
│   ├── index.html
│   ├── style.css
│   └── script.js
├── zk_hud_v3.sql
└── README.md
```

## Support

Pour toute question ou problème, contactez l'auteur.

## Licence

Tous droits réservés - ZaK © 2025

## Crédits

- **Auteur** : ZaK
- **Version** : 3.0.0
- **Framework** : ESX
- **UI** : Font Awesome 6.5.1

---

**Note** : Ce script nécessite ox_lib et ox_inventory pour fonctionner correctement.
