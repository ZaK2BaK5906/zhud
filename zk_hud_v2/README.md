# ZK HUD V2 - Ultra Customizable HUD

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)
![License](https://img.shields.io/badge/license-Custom-red.svg)

HUD FiveM ultra customisable avec support multi-framework (ESX, QB-Core, Custom) et système de drag & drop complet.

## 🌟 Fonctionnalités

### 🎨 Interface Moderne
- **Design moderne** sans backdrop-filter pour de meilleures performances
- **Icônes circulaires remplissables** pour les statuts (Santé, Armure, Faim, Soif)
- **3 styles de compteur** : Minimal, Moderne, Classique
- **Animations fluides** et transitions CSS optimisées

### 🌍 Multilingue
Support de **8 langues** :
- 🇫🇷 Français (par défaut)
- 🇬🇧 English
- 🇪🇸 Español
- 🇩🇪 Deutsch
- 🇮🇹 Italiano
- 🇵🇹 Português
- 🇳🇱 Nederlands
- 🇵🇱 Polski

### 🎮 Multi-Framework
- ✅ **ESX Legacy**
- ✅ **QB-Core**
- ✅ **Custom** (framework personnalisé)

### 🎯 Inventaires Supportés
- `esx_inventoryhud`
- `qb-inventory`
- `ox_inventory`
- `custom`

### ⚙️ Personnalisation Complète
- **Drag & Drop** : Déplacez chaque élément du HUD
- **Couleurs personnalisables** : 8 couleurs différentes
- **Toggle éléments** : Activez/Désactivez n'importe quel élément
- **3 styles de compteur** : Changez le style en temps réel
- **Sauvegarde BDD** : Positions et paramètres sauvegardés par joueur

## 📋 Prérequis

- **oxmysql** : [GitHub](https://github.com/overextended/oxmysql)
- **ox_lib** : [GitHub](https://github.com/overextended/ox_lib)
- Un framework compatible (ESX, QB-Core, ou Custom)

## 📦 Installation

### 1. Téléchargement
```bash
cd resources
git clone https://github.com/votre-repo/zk_hud_v2.git
```

### 2. Base de données
Exécutez le fichier SQL dans votre base de données :
```sql
source zk_hud_v2/sql/install.sql
```

### 3. Configuration
Éditez `config.lua` selon vos besoins :
```lua
Config.Locale = 'fr' -- Langue
Config.Framework = 'esx' -- esx, qb, custom
Config.Inventory = 'ox_inventory' -- Système d'inventaire
Config.EditCommand = 'edithud' -- Commande pour ouvrir l'éditeur
```

### 4. server.cfg
Ajoutez dans votre `server.cfg` :
```cfg
ensure oxmysql
ensure ox_lib
ensure zk_hud_v2
```

## 🎮 Utilisation

### Commandes
- `/edithud` - Ouvrir l'éditeur HUD (configurable dans config.lua)

### Éditeur HUD
L'éditeur vous permet de :
1. **Déplacer les éléments** avec drag & drop
2. **Changer le style du compteur** (Minimal, Moderne, Classique)
3. **Activer/Désactiver** chaque élément
4. **Personnaliser les couleurs** de chaque élément
5. **Sauvegarder** vos paramètres en BDD
6. **Réinitialiser** aux paramètres par défaut

### Éléments du HUD

#### Informations Joueur (Haut Droite)
- ID du joueur
- Métier
- Grade
- Argent liquide (Cash)
- Argent en banque (Bank)

#### Statuts (Bas Gauche)
- 💗 Santé (Health)
- 🛡️ Armure (Armor)
- 🍔 Faim (Hunger)
- 💧 Soif (Thirst)

#### Compteur de Vitesse (Bas Droite)
- 🚗 Vitesse (km/h ou mph)
- ⛽ Essence
- 🔧 Santé du véhicule

## 🔧 Configuration Avancée

### Framework Custom
Si vous utilisez un framework custom, configurez les callbacks dans `config.lua` :

```lua
Config.Custom = {
    GetPlayerData = function()
        return {
            id = GetPlayerServerId(PlayerId()),
            job = 'unemployed',
            grade = 'Freelance',
            cash = 0,
            bank = 0
        }
    end,

    GetNeeds = function()
        return {
            hunger = 100,
            thirst = 100
        }
    end
}
```

### Positions par Défaut
Modifiez les positions par défaut dans `config.lua` :
```lua
Config.DefaultPositions = {
    playerInfo = {
        top = 2,
        right = 2,
        enabled = true
    },
    statuses = {
        bottom = 2,
        left = 22,
        enabled = true
    },
    speedometer = {
        bottom = 2,
        right = 2,
        enabled = true
    }
}
```

### Couleurs par Défaut
Personnalisez les couleurs par défaut dans `config.lua` :
```lua
Config.DefaultColors = {
    health = '#ef4444',    -- Rouge
    armor = '#3b82f6',     -- Bleu
    hunger = '#f59e0b',    -- Orange
    thirst = '#06b6d4',    -- Cyan
    fuel = '#f59e0b',      -- Orange
    vehicle = '#10b981',   -- Vert
    cash = '#10b981',      -- Vert
    bank = '#3b82f6'       -- Bleu
}
```

## 🎨 Styles de Compteur

### Minimal
- Design épuré et minimaliste
- Affichage numérique simple
- Barres de progression horizontales

### Moderne (Par défaut)
- Arc de progression animé
- Design futuriste
- Barres de progression avec pourcentages

### Classique
- Jauge circulaire complète
- Style retro/vintage
- Affichage centré

## 🐛 Debug

Activez le mode debug dans `config.lua` :
```lua
Config.Debug = true
```

Commande debug en jeu :
```
/zkhud_debug
```

## 📊 Base de Données

### Structure de la table
```sql
zk_hud_v2
├── identifier (VARCHAR)
├── positions (LONGTEXT)
├── colors (LONGTEXT)
├── visibility (LONGTEXT)
├── speedometer_style (VARCHAR)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)
```

Les données sont stockées en JSON pour chaque joueur.

## 🔥 Compatibilité Essence

Le script détecte automatiquement votre système d'essence :
- ✅ LegacyFuel
- ✅ ox_fuel
- ✅ cdn-fuel
- ✅ Système natif GTA

## ⚡ Performance

- **0.00ms** au repos (HUD masqué)
- **0.01-0.02ms** avec HUD affiché
- **0.00ms** en mode édition (pas de calculs inutiles)
- Optimisé pour de longues sessions

## 🆘 Support

Pour toute question ou problème :
1. Vérifiez que tous les prérequis sont installés
2. Vérifiez la console F8 pour les erreurs
3. Activez le mode debug
4. Contactez le support

## 📝 Changelog

### Version 2.0.0
- 🎉 Sortie initiale
- ✅ Support multi-framework (ESX, QB, Custom)
- ✅ 8 langues supportées
- ✅ Drag & drop complet
- ✅ 3 styles de compteur
- ✅ Sauvegarde BDD
- ✅ Design moderne sans backdrop-filter

## 👨‍💻 Auteur

**ZaK** - Développeur FiveM

## 📜 Licence

Ce script est protégé par une licence custom. Tous droits réservés.
❌ Revente interdite
❌ Redistribution interdite
✅ Modifications personnelles autorisées pour usage privé

---

**Made with ❤️ for the FiveM community**
