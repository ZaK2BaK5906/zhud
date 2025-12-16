local ESX = nil
local QBCore = nil

-- Initialisation du framework
CreateThread(function()
    if Config.Framework == 'esx' then
        ESX = exports[Config.ESX.Resource]:getSharedObject()
        Config.DebugPrint('ESX Framework loaded')
    elseif Config.Framework == 'qb' then
        QBCore = exports[Config.QB.Resource]:GetCoreObject()
        Config.DebugPrint('QBCore Framework loaded')
    elseif Config.Framework == 'custom' then
        Config.DebugPrint('Custom Framework mode enabled')
    else
        print('^1[ZK HUD V2] ERROR: Invalid framework specified in config.lua^7')
    end
end)

-- Fonction pour obtenir l'identifiant du joueur
local function GetIdentifier(source)
    local identifier = nil

    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            identifier = xPlayer.identifier
        end
    elseif Config.Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            identifier = Player.PlayerData.citizenid
        end
    elseif Config.Framework == 'custom' then
        -- Pour custom framework, utiliser license par défaut
        for _, id in ipairs(GetPlayerIdentifiers(source)) do
            if string.match(id, 'license:') then
                identifier = id
                break
            end
        end
    end

    return identifier
end

-- Charger les paramètres du joueur
lib.callback.register('zk_hud:server:loadSettings', function(source)
    local identifier = GetIdentifier(source)
    if not identifier then
        Config.DebugPrint('Failed to get identifier for player ' .. source)
        return nil
    end

    local result = MySQL.single.await('SELECT * FROM zk_hud_v2 WHERE identifier = ?', {identifier})

    if result then
        Config.DebugPrint('Settings loaded for ' .. identifier)
        return {
            positions = json.decode(result.positions),
            colors = json.decode(result.colors),
            visibility = json.decode(result.visibility),
            speedometer_style = result.speedometer_style
        }
    else
        Config.DebugPrint('No settings found for ' .. identifier .. ', using defaults')
        return nil
    end
end)

-- Sauvegarder les paramètres du joueur
RegisterNetEvent('zk_hud:server:saveSettings', function(settings)
    local source = source
    local identifier = GetIdentifier(source)

    if not identifier then
        Config.DebugPrint('Failed to get identifier for player ' .. source)
        TriggerClientEvent('zk_hud:client:saveError', source)
        return
    end

    if not settings or not settings.positions or not settings.colors or not settings.visibility or not settings.speedometer_style then
        Config.DebugPrint('Invalid settings data received from ' .. source)
        TriggerClientEvent('zk_hud:client:saveError', source)
        return
    end

    local positions = json.encode(settings.positions)
    local colors = json.encode(settings.colors)
    local visibility = json.encode(settings.visibility)
    local speedometer_style = settings.speedometer_style

    local result = MySQL.single.await('SELECT identifier FROM zk_hud_v2 WHERE identifier = ?', {identifier})

    if result then
        MySQL.update.await('UPDATE zk_hud_v2 SET positions = ?, colors = ?, visibility = ?, speedometer_style = ? WHERE identifier = ?', {
            positions,
            colors,
            visibility,
            speedometer_style,
            identifier
        })
        Config.DebugPrint('Settings updated for ' .. identifier)
    else
        MySQL.insert.await('INSERT INTO zk_hud_v2 (identifier, positions, colors, visibility, speedometer_style) VALUES (?, ?, ?, ?, ?)', {
            identifier,
            positions,
            colors,
            visibility,
            speedometer_style
        })
        Config.DebugPrint('Settings created for ' .. identifier)
    end

    TriggerClientEvent('zk_hud:client:saveSuccess', source)
end)

-- Obtenir les données du joueur
lib.callback.register('zk_hud:server:getPlayerData', function(source)
    local playerData = {
        id = source,
        job = 'Unemployed',
        grade = 'None',
        cash = 0,
        bank = 0
    }

    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            playerData.id = source
            playerData.job = xPlayer.job.label or 'Unemployed'
            playerData.grade = xPlayer.job.grade_label or 'None'
            playerData.cash = xPlayer.getMoney() or 0
            playerData.bank = xPlayer.getAccount('bank').money or 0
        end
    elseif Config.Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            playerData.id = source
            playerData.job = Player.PlayerData.job.label or 'Unemployed'
            playerData.grade = Player.PlayerData.job.grade.name or 'None'
            playerData.cash = Player.PlayerData.money.cash or 0
            playerData.bank = Player.PlayerData.money.bank or 0
        end
    elseif Config.Framework == 'custom' then
        -- Utiliser la fonction custom si définie
        if Config.Custom.GetPlayerData then
            local customData = Config.Custom.GetPlayerData()
            if customData then
                playerData = customData
            end
        end
    end

    Config.DebugPrint('Player data sent for ' .. source)
    return playerData
end)

-- Callback pour ox_lib (nécessaire pour lib.callback)
if GetResourceState('ox_lib') ~= 'started' then
    print('^1[ZK HUD V2] ERROR: ox_lib is required for this resource to work!^7')
    print('^3[ZK HUD V2] Please install ox_lib: https://github.com/overextended/ox_lib^7')
end

-- Version check
CreateThread(function()
    print('^2[ZK HUD V2] Successfully started!^7')
    print('^3[ZK HUD V2] Version 2.0.0^7')
    print('^3[ZK HUD V2] Framework: ' .. Config.Framework .. '^7')
    print('^3[ZK HUD V2] Made by ZaK^7')
end)
