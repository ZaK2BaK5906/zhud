local ESX = nil

-- Initialisation ESX
CreateThread(function()
    while ESX == nil do
        ESX = exports['es_extended']:getSharedObject()
        Wait(100)
    end

    if Config.Debug then
        print('[ZK HUD] Server initialized')
    end
end)

-- Callback pour charger la configuration du joueur
ESX.RegisterServerCallback('zk_hud:loadConfig', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        if Config.Debug then
            print('[ZK HUD] Player not found:', source)
        end
        cb(nil)
        return
    end

    local identifier = xPlayer.identifier

    MySQL.query('SELECT * FROM zk_hud_v3 WHERE identifier = ?', {identifier}, function(result)
        if result and #result > 0 then
            local data = result[1]

            -- Décoder le JSON
            local config = {
                positions = json.decode(data.positions or '{}'),
                colors = json.decode(data.colors or '{}'),
                speedometerStyle = data.speedometer_style or Config.DefaultSpeedometerStyle,
                enabledElements = json.decode(data.enabled_elements or '{}')
            }

            -- Vérifier si les données sont valides, sinon utiliser les valeurs par défaut
            if not config.positions or not next(config.positions) then
                config.positions = Config.DefaultPositions
            end

            if not config.colors or not next(config.colors) then
                config.colors = Config.DefaultColors
            end

            if not config.enabledElements or not next(config.enabledElements) then
                config.enabledElements = Config.EnableElements
            end

            if Config.Debug then
                print('[ZK HUD] Config loaded for:', xPlayer.getName())
            end

            cb(config)
        else
            -- Aucune configuration trouvée, utiliser les valeurs par défaut
            if Config.Debug then
                print('[ZK HUD] No config found for:', xPlayer.getName(), '- Using defaults')
            end

            cb({
                positions = Config.DefaultPositions,
                colors = Config.DefaultColors,
                speedometerStyle = Config.DefaultSpeedometerStyle,
                enabledElements = Config.EnableElements
            })
        end
    end)
end)

-- Callback pour sauvegarder la configuration du joueur
ESX.RegisterServerCallback('zk_hud:saveConfig', function(source, cb, config)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        if Config.Debug then
            print('[ZK HUD] Player not found:', source)
        end
        cb(false)
        return
    end

    if not config then
        if Config.Debug then
            print('[ZK HUD] Invalid config data')
        end
        cb(false)
        return
    end

    local identifier = xPlayer.identifier

    -- Encoder en JSON
    local positions = json.encode(config.positions or Config.DefaultPositions)
    local colors = json.encode(config.colors or Config.DefaultColors)
    local speedometerStyle = config.speedometerStyle or Config.DefaultSpeedometerStyle
    local enabledElements = json.encode(config.enabledElements or Config.EnableElements)

    -- Vérifier si le joueur a déjà une configuration
    MySQL.query('SELECT id FROM zk_hud_v3 WHERE identifier = ?', {identifier}, function(result)
        if result and #result > 0 then
            -- Mettre à jour la configuration existante
            MySQL.update('UPDATE zk_hud_v3 SET positions = ?, colors = ?, speedometer_style = ?, enabled_elements = ?, updated_at = NOW() WHERE identifier = ?', {
                positions,
                colors,
                speedometerStyle,
                enabledElements,
                identifier
            }, function(affectedRows)
                if Config.Debug then
                    print('[ZK HUD] Config updated for:', xPlayer.getName())
                end
                cb(true)
            end)
        else
            -- Créer une nouvelle configuration
            MySQL.insert('INSERT INTO zk_hud_v3 (identifier, positions, colors, speedometer_style, enabled_elements, created_at, updated_at) VALUES (?, ?, ?, ?, ?, NOW(), NOW())', {
                identifier,
                positions,
                colors,
                speedometerStyle,
                enabledElements
            }, function(insertId)
                if Config.Debug then
                    print('[ZK HUD] Config created for:', xPlayer.getName())
                end
                cb(true)
            end)
        end
    end)
end)

-- Commande admin pour réinitialiser la configuration d'un joueur
ESX.RegisterCommand('resethud', 'admin', function(xPlayer, args, showError)
    local targetId = args.playerId
    local xTarget = ESX.GetPlayerFromId(targetId)

    if not xTarget then
        xPlayer.showNotification('Joueur non trouvé', 'error')
        return
    end

    MySQL.query('DELETE FROM zk_hud_v3 WHERE identifier = ?', {xTarget.identifier}, function(affectedRows)
        if affectedRows > 0 then
            xPlayer.showNotification('Configuration du HUD réinitialisée pour ' .. xTarget.getName(), 'success')

            -- Notifier le joueur cible
            TriggerClientEvent('ox_lib:notify', targetId, {
                title = 'ZK HUD',
                description = 'Votre configuration HUD a été réinitialisée par un administrateur',
                type = 'info'
            })
        else
            xPlayer.showNotification('Aucune configuration trouvée pour ce joueur', 'error')
        end
    end)
end, true, {help = 'Réinitialiser la configuration HUD d\'un joueur', validate = true, arguments = {
    {name = 'playerId', help = 'ID du joueur', type = 'number'}
}})

-- Export pour obtenir la configuration d'un joueur (utilisable par d'autres ressources)
exports('getPlayerHudConfig', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return nil
    end

    local identifier = xPlayer.identifier
    local config = nil

    MySQL.query('SELECT * FROM zk_hud_v3 WHERE identifier = ?', {identifier}, function(result)
        if result and #result > 0 then
            local data = result[1]
            config = {
                positions = json.decode(data.positions or '{}'),
                colors = json.decode(data.colors or '{}'),
                speedometerStyle = data.speedometer_style or Config.DefaultSpeedometerStyle,
                enabledElements = json.decode(data.enabled_elements or '{}')
            }
        end
    end)

    return config
end)
