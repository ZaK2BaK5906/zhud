Config = {}

-- Commande pour ouvrir le menu d'édition du HUD
Config.EditCommand = 'edithud'

-- Framework (auto-detect ESX)
Config.Framework = 'ESX'

-- Positions par défaut (en pourcentage)
Config.DefaultPositions = {
    -- Informations joueur (haut droite par défaut)
    playerInfo = {
        x = 85.0, -- % de la largeur
        y = 2.0,  -- % de la hauteur
        visible = true
    },

    -- Indicateurs de statut (bas gauche, à droite de la minimap)
    statusIndicators = {
        x = 18.0,
        y = 82.0,
        visible = true
    },

    -- Compteur de vitesse (bas droite)
    speedometer = {
        x = 85.0,
        y = 85.0,
        visible = true
    }
}

-- Couleurs par défaut
Config.DefaultColors = {
    primary = '#00d4ff',     -- Cyan moderne
    secondary = '#ff006e',   -- Rose/magenta
    success = '#00ff88',     -- Vert
    warning = '#ffaa00',     -- Orange
    danger = '#ff0055',      -- Rouge
    info = '#0099ff',        -- Bleu
    text = '#ffffff',        -- Blanc
    background = '#1a1a1a'   -- Noir/gris foncé
}

-- Styles de compteur disponibles
Config.SpeedometerStyles = {
    'minimal',    -- Style minimaliste
    'moderne',    -- Style moderne avec barres
    'classique'   -- Style classique avec jauge
}

-- Style par défaut du compteur
Config.DefaultSpeedometerStyle = 'moderne'

-- Icônes pour les statuts (Font Awesome)
Config.StatusIcons = {
    health = 'fa-heart',
    armor = 'fa-shield-halved',
    hunger = 'fa-burger',
    thirst = 'fa-droplet'
}

-- Icônes pour les informations joueur
Config.PlayerInfoIcons = {
    id = 'fa-id-card',
    job = 'fa-briefcase',
    grade = 'fa-star',
    cash = 'fa-money-bill-wave',
    bank = 'fa-landmark'
}

-- Icônes pour le compteur
Config.VehicleIcons = {
    speed = 'fa-gauge-high',
    fuel = 'fa-gas-pump',
    engine = 'fa-wrench'
}

-- Activer/désactiver certains éléments
Config.EnableElements = {
    id = true,
    job = true,
    grade = true,
    cash = true,
    bank = true,
    health = true,
    armor = true,
    hunger = true,
    thirst = true,
    speedometer = true
}

-- Intervalle de mise à jour (ms)
Config.UpdateInterval = 500

-- Afficher le HUD uniquement en véhicule pour le compteur
Config.SpeedometerOnlyInVehicle = true

-- Debug mode
Config.Debug = false
