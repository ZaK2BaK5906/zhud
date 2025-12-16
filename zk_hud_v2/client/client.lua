local ESX = nil
local QBCore = nil
local PlayerData = {}
local isHudVisible = false
local isEditMode = false
local isPlayerLoaded = false

-- Fonction de traduction
function _U(str, ...)
    if Locales[Config.Locale] and Locales[Config.Locale][str] then
        return string.format(Locales[Config.Locale][str], ...)
    else
        return 'Translation [' .. Config.Locale .. '][' .. str .. '] not found'
    end
end

-- Fonction de notification (surcharge de Config.Notification)
local function ShowNotification(message, type)
    if Config.Framework == 'esx' and ESX then
        ESX.ShowNotification(message)
    elseif Config.Framework == 'qb' and QBCore then
        QBCore.Functions.Notify(message, type or 'primary')
    else
        -- Notification native GTA
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, true)
    end
end

-- Surcharger Config.Notification avec la vraie fonction
Config.Notification = ShowNotification

-- Initialisation du framework
CreateThread(function()
    if Config.Framework == 'esx' then
        ESX = exports[Config.ESX.Resource]:getSharedObject()

        while not ESX.IsPlayerLoaded() do
            Wait(100)
        end

        PlayerData = ESX.GetPlayerData()
        isPlayerLoaded = true

        RegisterNetEvent('esx:playerLoaded', function(xPlayer)
            PlayerData = xPlayer
            isPlayerLoaded = true
            Wait(Config.SpawnDelay)
            InitializeHUD()
        end)

        RegisterNetEvent('esx:onPlayerLogout', function()
            isPlayerLoaded = false
            SendNUIMessage({action = 'hideHUD'})
        end)

        RegisterNetEvent('esx:setJob', function(job)
            PlayerData.job = job
        end)

    elseif Config.Framework == 'qb' then
        QBCore = exports[Config.QB.Resource]:GetCoreObject()

        RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
            PlayerData = QBCore.Functions.GetPlayerData()
            isPlayerLoaded = true
            Wait(Config.SpawnDelay)
            InitializeHUD()
        end)

        RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
            isPlayerLoaded = false
            SendNUIMessage({action = 'hideHUD'})
        end)

        RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
            PlayerData = data
        end)

    elseif Config.Framework == 'custom' then
        Wait(Config.SpawnDelay)
        isPlayerLoaded = true
        InitializeHUD()
    end
end)

-- Initialiser le HUD
function InitializeHUD()
    CreateThread(function()
        Config.DebugPrint('Initializing HUD')

        -- Charger les paramètres depuis la BDD
        local settings = lib.callback.await('zk_hud:server:loadSettings', false)

        if settings then
            Config.DebugPrint('Settings loaded from database')
            SendNUIMessage({
                action = 'initHUD',
                settings = settings,
                locale = Config.Locale
            })
        else
            Config.DebugPrint('Using default settings')
            SendNUIMessage({
                action = 'initHUD',
                settings = {
                    positions = Config.DefaultPositions,
                    colors = Config.DefaultColors,
                    visibility = Config.DefaultVisibility,
                    speedometer_style = Config.DefaultSpeedometerStyle
                },
                locale = Config.Locale
            })
        end

        if Config.ShowOnSpawn then
            Wait(100)
            isHudVisible = true
            SendNUIMessage({action = 'showHUD'})
            StartHUDUpdates()
        end
    end)
end

-- Mise à jour des données du joueur
function UpdatePlayerData()
    if not isPlayerLoaded or not isHudVisible then return end

    CreateThread(function()
        local data = lib.callback.await('zk_hud:server:getPlayerData', false)
        if data then
            SendNUIMessage({
                action = 'updatePlayerInfo',
                data = data
            })
        end
    end)
end

-- Mise à jour des statuts (santé, armure, faim, soif)
function UpdateStatuses()
    if not isPlayerLoaded or not isHudVisible then return end

    local ped = PlayerPedId()
    local health = math.floor((GetEntityHealth(ped) - 100) / (GetEntityMaxHealth(ped) - 100) * 100)
    local armor = GetPedArmour(ped)

    -- Récupérer la faim et la soif selon le framework/système
    local hunger = 100
    local thirst = 100

    if Config.Framework == 'esx' then
        TriggerEvent('esx_status:getStatus', 'hunger', function(status)
            if status then hunger = math.floor(status.getPercent()) end
        end)
        TriggerEvent('esx_status:getStatus', 'thirst', function(status)
            if status then thirst = math.floor(status.getPercent()) end
        end)
    elseif Config.Framework == 'qb' then
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData and PlayerData.metadata then
            hunger = math.floor(PlayerData.metadata['hunger'] or 100)
            thirst = math.floor(PlayerData.metadata['thirst'] or 100)
        end
    elseif Config.Framework == 'custom' and Config.Custom.GetNeeds then
        local needs = Config.Custom.GetNeeds()
        if needs then
            hunger = needs.hunger or 100
            thirst = needs.thirst or 100
        end
    end

    SendNUIMessage({
        action = 'updateStatuses',
        data = {
            health = math.max(0, math.min(100, health)),
            armor = math.max(0, math.min(100, armor)),
            hunger = math.max(0, math.min(100, hunger)),
            thirst = math.max(0, math.min(100, thirst))
        }
    })
end

-- Mise à jour du compteur de vitesse
function UpdateSpeedometer()
    if not isPlayerLoaded or not isHudVisible then return end

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
        local speed = GetEntitySpeed(vehicle)
        local speedKmh = math.floor(speed * 3.6)
        local speedMph = math.floor(speed * 2.236936)

        local fuel = 100
        -- Support pour différents systèmes d'essence
        if GetResourceState('LegacyFuel') == 'started' then
            fuel = exports['LegacyFuel']:GetFuel(vehicle)
        elseif GetResourceState('ox_fuel') == 'started' then
            fuel = GetVehicleFuelLevel(vehicle)
        elseif GetResourceState('cdn-fuel') == 'started' then
            fuel = exports['cdn-fuel']:GetFuel(vehicle)
        else
            fuel = GetVehicleFuelLevel(vehicle)
        end

        local vehicleHealth = math.floor((GetVehicleEngineHealth(vehicle) / 10))

        SendNUIMessage({
            action = 'updateSpeedometer',
            data = {
                speed = Config.SpeedUnit == 'kmh' and speedKmh or speedMph,
                fuel = math.floor(fuel),
                vehicle = math.max(0, math.min(100, vehicleHealth)),
                inVehicle = true
            }
        })
    else
        SendNUIMessage({
            action = 'updateSpeedometer',
            data = {
                inVehicle = false
            }
        })
    end
end

-- Démarrer les mises à jour
function StartHUDUpdates()
    CreateThread(function()
        while isHudVisible do
            UpdatePlayerData()
            UpdateStatuses()
            Wait(Config.UpdateInterval)
        end
    end)

    CreateThread(function()
        while isHudVisible do
            UpdateSpeedometer()
            Wait(Config.VehicleUpdateInterval)
        end
    end)
end

-- Commande d'édition
RegisterCommand(Config.EditCommand, function()
    if not isPlayerLoaded then return end

    isEditMode = not isEditMode

    if isEditMode then
        Config.Notification(_U('hud_editor_opened'), 'info')
        SendNUIMessage({action = 'openEditor'})
        SetNuiFocus(true, true)
    else
        Config.Notification(_U('hud_editor_closed'), 'info')
        SendNUIMessage({action = 'closeEditor'})
        SetNuiFocus(false, false)
    end
end)

-- Callbacks NUI
RegisterNUICallback('closeEditor', function(data, cb)
    isEditMode = false
    SetNuiFocus(false, false)
    Config.Notification(_U('hud_editor_closed'), 'info')
    cb('ok')
end)

RegisterNUICallback('saveSettings', function(data, cb)
    if not data or not data.settings then
        Config.DebugPrint('Invalid settings data from NUI')
        cb('error')
        return
    end

    Config.DebugPrint('Saving settings to database')
    TriggerServerEvent('zk_hud:server:saveSettings', data.settings)
    cb('ok')
end)

RegisterNUICallback('resetSettings', function(data, cb)
    Config.DebugPrint('Resetting to default settings')
    SendNUIMessage({
        action = 'loadSettings',
        settings = {
            positions = Config.DefaultPositions,
            colors = Config.DefaultColors,
            visibility = Config.DefaultVisibility,
            speedometer_style = Config.DefaultSpeedometerStyle
        }
    })
    Config.Notification(_U('settings_reset'), 'info')
    cb('ok')
end)

RegisterNUICallback('nuiError', function(data, cb)
    print('^1[ZK HUD V2] NUI Error: ' .. (data.error or 'Unknown error') .. '^7')
    if data.stack then
        print('^1Stack trace: ' .. data.stack .. '^7')
    end
    cb('ok')
end)

-- Events pour les notifications
RegisterNetEvent('zk_hud:client:saveSuccess', function()
    Config.Notification(_U('settings_saved'), 'success')
end)

RegisterNetEvent('zk_hud:client:saveError', function()
    Config.Notification(_U('error_save'), 'error')
end)

-- Masquer le HUD par défaut de GTA
CreateThread(function()
    while true do
        -- Masquer le HUD radar (minimap reste visible)
        DisplayRadar(true)

        -- Masquer les composants du HUD par défaut
        for i = 1, 22 do
            if i ~= 14 and i ~= 19 then -- Garder la map et le reticule
                HideHudComponentThisFrame(i)
            end
        end

        Wait(0)
    end
end)

-- Debug
if Config.Debug then
    RegisterCommand('zkhud_debug', function()
        print('^3[ZK HUD V2] Debug Info:^7')
        print('  Player Loaded: ' .. tostring(isPlayerLoaded))
        print('  HUD Visible: ' .. tostring(isHudVisible))
        print('  Edit Mode: ' .. tostring(isEditMode))
        print('  Framework: ' .. Config.Framework)
    end)
end
