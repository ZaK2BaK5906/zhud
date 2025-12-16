-- Création de la table pour stocker les configurations du HUD par joueur
CREATE TABLE IF NOT EXISTS `zk_hud_v3` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `positions` LONGTEXT NOT NULL,
    `colors` LONGTEXT NOT NULL,
    `speedometer_style` VARCHAR(20) NOT NULL DEFAULT 'moderne',
    `enabled_elements` LONGTEXT NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
