Config = {}
Locales = {}

-- Langue par défaut (fr, en, es, de, it, pt, nl, pl)
Config.Locale = 'fr'

-- Framework (esx, qb, custom)
Config.Framework = 'esx'

-- Inventaire (esx_inventoryhud, qb-inventory, ox_inventory, custom)
Config.Inventory = 'ox_inventory'

-- Commande pour ouvrir l'éditeur HUD
Config.EditCommand = 'edithud'

-- Afficher le HUD au spawn
Config.ShowOnSpawn = true

-- Délai avant affichage du HUD (ms)
Config.SpawnDelay = 2000

-- Mise à jour des données (ms)
Config.UpdateInterval = 500

-- Mise à jour du compteur véhicule (ms)
Config.VehicleUpdateInterval = 100

-- Positions par défaut (en %)
Config.DefaultPositions = {
    -- Informations joueur (haut droite)
    playerInfo = {
        top = 2,
        right = 2,
        enabled = true
    },

    -- Statuts (bas gauche, droite de la map)
    statuses = {
        bottom = 2,
        left = 22,
        enabled = true
    },

    -- Compteur de vitesse (bas droite)
    speedometer = {
        bottom = 2,
        right = 2,
        enabled = true
    }
}

-- Couleurs par défaut
Config.DefaultColors = {
    primary = '#3b82f6',      -- Bleu moderne
    secondary = '#8b5cf6',    -- Violet
    success = '#10b981',      -- Vert
    warning = '#f59e0b',      -- Orange
    danger = '#ef4444',       -- Rouge
    health = '#ef4444',       -- Santé
    armor = '#3b82f6',        -- Armure
    hunger = '#f59e0b',       -- Faim
    thirst = '#06b6d4',       -- Soif
    fuel = '#f59e0b',         -- Essence
    vehicle = '#10b981',      -- Santé véhicule
    cash = '#10b981',         -- Argent liquide
    bank = '#3b82f6'          -- Banque
}

-- Style de compteur par défaut (minimal, modern, classic)
Config.DefaultSpeedometerStyle = 'modern'

-- Unité de vitesse (kmh, mph)
Config.SpeedUnit = 'kmh'

-- Éléments visibles par défaut
Config.DefaultVisibility = {
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

-- Grille d'édition
Config.GridSize = 10 -- px

-- ESX Settings
Config.ESX = {
    Resource = 'es_extended',
    SharedObject = 'esx:getSharedObject'
}

-- QB-Core Settings
Config.QB = {
    Resource = 'qb-core',
    SharedObject = 'QBCore:GetObject'
}

-- Custom Framework Callbacks (si Config.Framework = 'custom')
Config.Custom = {
    -- Fonction pour récupérer les données du joueur
    GetPlayerData = function()
        -- Exemple de structure à retourner :
        return {
            id = GetPlayerServerId(PlayerId()),
            job = 'unemployed',
            grade = 'Freelance',
            cash = 0,
            bank = 0
        }
    end,

    -- Fonction pour récupérer les besoins (faim/soif)
    GetNeeds = function()
        -- Exemple de structure à retourner :
        return {
            hunger = 100,
            thirst = 100
        }
    end
}

-- Notifications (utilisé pour les messages d'erreur/succès)
Config.Notification = function(message, type)
    if Config.Framework == 'esx' then
        ESX.ShowNotification(message)
    elseif Config.Framework == 'qb' then
        QBCore.Functions.Notify(message, type)
    else
        -- Custom notification
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, true)
    end
end

-- Debug mode
Config.Debug = false

-- Fonction de debug
Config.DebugPrint = function(...)
    if Config.Debug then
        print('^3[ZK HUD V2]^7', ...)
    end
end
