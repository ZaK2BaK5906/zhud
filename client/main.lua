local ESX = nil
local PlayerData = {}
local isHudVisible = false
local isEditMode = false
local playerLoaded = false

-- Variables pour les statuts
local currentStatus = {
    health = 100,
    armor = 0,
    hunger = 100,
    thirst = 100
}

-- Variables pour le véhicule
local currentVehicle = {
    speed = 0,
    fuel = 0,
    engine = 100,
    inVehicle = false
}

-- Configuration du HUD du joueur
local hudConfig = {
    positions = Config.DefaultPositions,
    colors = Config.DefaultColors,
    speedometerStyle = Config.DefaultSpeedometerStyle,
    enabledElements = Config.EnableElements
}

-- Initialisation ESX
CreateThread(function()
    while ESX == nil do
        ESX = exports['es_extended']:getSharedObject()
        Wait(100)
    end

    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end

    PlayerData = ESX.GetPlayerData()
    playerLoaded = true

    -- Charger la configuration du joueur depuis le serveur
    ESX.TriggerServerCallback('zk_hud:loadConfig', function(config)
        if config then
            hudConfig = config
        end

        -- Envoyer la config au NUI
        SendNUIMessage({
            action = 'updateConfig',
            config = hudConfig
        })

        -- Afficher le HUD
        Wait(1000) -- Attendre un peu après le spawn
        ShowHud(true)
    end)
end)

-- Mise à jour des données du joueur
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    playerLoaded = true
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
    for i=1, #PlayerData.accounts, 1 do
        if PlayerData.accounts[i].name == account.name then
            PlayerData.accounts[i] = account
            break
        end
    end
end)

-- Fonction pour afficher/masquer le HUD
function ShowHud(show)
    isHudVisible = show
    SendNUIMessage({
        action = 'toggleHud',
        show = show
    })
end

-- Fonction pour obtenir l'argent
function GetMoney()
    local cash = 0
    local bank = 0

    if PlayerData.accounts then
        for _, account in pairs(PlayerData.accounts) do
            if account.name == 'money' then
                cash = account.money
            elseif account.name == 'bank' then
                bank = account.money
            end
        end
    end

    return cash, bank
end

-- Thread principal de mise à jour
CreateThread(function()
    while true do
        Wait(Config.UpdateInterval)

        if playerLoaded and isHudVisible and not isEditMode then
            local ped = PlayerPedId()

            -- Mettre à jour la santé et l'armure
            currentStatus.health = GetEntityHealth(ped) - 100
            currentStatus.armor = GetPedArmour(ped)

            -- Obtenir faim et soif depuis ox_inventory
            local status = exports.ox_inventory:GetPlayerStatus()
            if status then
                currentStatus.hunger = math.floor((status.hunger or 0) / 10000)
                currentStatus.thirst = math.floor((status.thirst or 0) / 10000)
            end

            -- Informations du joueur
            local cash, bank = GetMoney()
            local playerInfo = {
                id = GetPlayerServerId(PlayerId()),
                job = PlayerData.job and PlayerData.job.label or 'Chômeur',
                grade = PlayerData.job and PlayerData.job.grade_label or 'N/A',
                cash = cash,
                bank = bank
            }

            -- Vérifier si dans un véhicule
            local vehicle = GetVehiclePedIsIn(ped, false)
            if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
                currentVehicle.inVehicle = true
                currentVehicle.speed = math.floor(GetEntitySpeed(vehicle) * 3.6) -- Convertir en km/h
                currentVehicle.fuel = math.floor(GetVehicleFuelLevel(vehicle))
                currentVehicle.engine = math.floor(GetVehicleEngineHealth(vehicle) / 10)
            else
                currentVehicle.inVehicle = false
            end

            -- Envoyer les données au NUI
            SendNUIMessage({
                action = 'updateHud',
                playerInfo = playerInfo,
                status = currentStatus,
                vehicle = currentVehicle
            })
        end
    end
end)

-- Commande pour ouvrir le mode édition
RegisterCommand(Config.EditCommand, function()
    if not playerLoaded then
        lib.notify({
            title = 'ZK HUD',
            description = 'Vous devez être connecté pour éditer le HUD',
            type = 'error'
        })
        return
    end

    isEditMode = not isEditMode

    SendNUIMessage({
        action = 'toggleEditMode',
        enabled = isEditMode
    })

    SetNuiFocus(isEditMode, isEditMode)

    lib.notify({
        title = 'ZK HUD',
        description = isEditMode and 'Mode édition activé' or 'Mode édition désactivé',
        type = 'info'
    })
end, false)

-- Callback NUI pour sauvegarder la configuration
RegisterNUICallback('saveConfig', function(data, cb)
    if not data or not data.config then
        cb({ success = false, message = 'Configuration invalide' })
        return
    end

    hudConfig = data.config

    -- Sauvegarder sur le serveur
    ESX.TriggerServerCallback('zk_hud:saveConfig', function(success)
        if success then
            lib.notify({
                title = 'ZK HUD',
                description = 'Configuration sauvegardée avec succès',
                type = 'success'
            })
            cb({ success = true })
        else
            lib.notify({
                title = 'ZK HUD',
                description = 'Erreur lors de la sauvegarde',
                type = 'error'
            })
            cb({ success = false, message = 'Erreur serveur' })
        end
    end, hudConfig)
end)

-- Callback NUI pour fermer le mode édition
RegisterNUICallback('closeEditMode', function(data, cb)
    isEditMode = false
    SetNuiFocus(false, false)
    cb({ success = true })
end)

-- Callback NUI pour réinitialiser la configuration
RegisterNUICallback('resetConfig', function(data, cb)
    hudConfig = {
        positions = Config.DefaultPositions,
        colors = Config.DefaultColors,
        speedometerStyle = Config.DefaultSpeedometerStyle,
        enabledElements = Config.EnableElements
    }

    SendNUIMessage({
        action = 'updateConfig',
        config = hudConfig
    })

    lib.notify({
        title = 'ZK HUD',
        description = 'Configuration réinitialisée',
        type = 'info'
    })

    cb({ success = true })
end)

-- Masquer le HUD lors du chargement
AddEventHandler('playerSpawned', function()
    ShowHud(false)
end)

-- Gestion de l'affichage du HUD pendant les écrans de chargement
CreateThread(function()
    while true do
        Wait(1000)

        if IsPlayerSwitchInProgress() or IsPauseMenuActive() then
            if isHudVisible then
                ShowHud(false)
            end
        else
            if playerLoaded and not isHudVisible and not isEditMode then
                ShowHud(true)
            end
        end
    end
end)

-- Debug
if Config.Debug then
    CreateThread(function()
        while true do
            Wait(5000)
            print('[ZK HUD] Status:', json.encode(currentStatus))
            print('[ZK HUD] Vehicle:', json.encode(currentVehicle))
        end
    end)
end
