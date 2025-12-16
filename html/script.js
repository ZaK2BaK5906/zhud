// Configuration globale
let hudConfig = {
    positions: {},
    colors: {},
    speedometerStyle: 'moderne',
    enabledElements: {}
};

let isEditMode = false;
let draggedElement = null;
let dragOffset = { x: 0, y: 0 };

// Éléments DOM
const hudContainer = document.getElementById('hud-container');
const editMenu = document.getElementById('edit-menu');
const editGrid = document.getElementById('edit-grid');

// Éléments draggables
const playerInfo = document.getElementById('player-info');
const statusIndicators = document.getElementById('status-indicators');
const speedometer = document.getElementById('speedometer');

// ========== GESTION DES MESSAGES NUI ==========
window.addEventListener('message', (event) => {
    const data = event.data;

    try {
        switch (data.action) {
            case 'toggleHud':
                toggleHud(data.show);
                break;
            case 'updateHud':
                updateHud(data.playerInfo, data.status, data.vehicle);
                break;
            case 'toggleEditMode':
                toggleEditMode(data.enabled);
                break;
            case 'updateConfig':
                applyConfig(data.config);
                break;
            default:
                console.warn('[ZK HUD] Action inconnue:', data.action);
        }
    } catch (error) {
        console.error('[ZK HUD] Erreur lors du traitement du message:', error);
    }
});

// ========== AFFICHAGE DU HUD ==========
function toggleHud(show) {
    if (show) {
        hudContainer.style.display = 'block';
    } else {
        hudContainer.style.display = 'none';
    }
}

// ========== MISE À JOUR DU HUD ==========
function updateHud(playerInfo, status, vehicle) {
    try {
        // Mise à jour des informations du joueur
        if (playerInfo) {
            document.getElementById('player-id').textContent = playerInfo.id || '000';
            document.getElementById('player-job').textContent = playerInfo.job || 'Chômeur';
            document.getElementById('player-grade').textContent = playerInfo.grade || 'N/A';
            document.getElementById('player-cash').textContent = formatMoney(playerInfo.cash || 0);
            document.getElementById('player-bank').textContent = formatMoney(playerInfo.bank || 0);
        }

        // Mise à jour des statuts
        if (status) {
            updateStatus('health', status.health);
            updateStatus('armor', status.armor);
            updateStatus('hunger', status.hunger);
            updateStatus('thirst', status.thirst);
        }

        // Mise à jour du compteur de vitesse
        if (vehicle) {
            if (vehicle.inVehicle && hudConfig.enabledElements.speedometer) {
                speedometer.style.display = 'block';
                updateSpeedometer(vehicle.speed, vehicle.fuel, vehicle.engine);
            } else {
                speedometer.style.display = 'none';
            }
        }
    } catch (error) {
        console.error('[ZK HUD] Erreur lors de la mise à jour du HUD:', error);
    }
}

// ========== MISE À JOUR DES STATUTS ==========
function updateStatus(type, value) {
    try {
        // Limiter la valeur entre 0 et 100
        value = Math.max(0, Math.min(100, value));

        // Mettre à jour la valeur affichée
        const valueElement = document.getElementById(`${type}-value`);
        if (valueElement) {
            valueElement.textContent = Math.floor(value);
        }

        // Mettre à jour le remplissage visuel
        const fillElement = document.getElementById(`${type}-fill`);
        if (fillElement) {
            const percentage = value / 100;

            // Appliquer le clip-path en fonction de la forme
            const statusItem = fillElement.closest('.status-item');
            if (statusItem.classList.contains('hexagon')) {
                fillElement.style.clipPath = `polygon(30% ${100 - percentage * 100}%, 70% ${100 - percentage * 100}%, 100% ${50 + (50 - percentage * 50)}%, 70% 100%, 30% 100%, 0% ${50 + (50 - percentage * 50)}%)`;
            } else if (statusItem.classList.contains('diamond')) {
                fillElement.style.clipPath = `polygon(50% ${100 - percentage * 100}%, 100% 50%, 50% 100%, 0% 50%)`;
            } else if (statusItem.classList.contains('pentagon')) {
                fillElement.style.clipPath = `polygon(50% ${100 - percentage * 100}%, 100% 38%, 82% 100%, 18% 100%, 0% 38%)`;
            } else if (statusItem.classList.contains('octagon')) {
                fillElement.style.clipPath = `polygon(30% ${100 - percentage * 100}%, 70% ${100 - percentage * 100}%, 100% ${30 + (70 - percentage * 70)}%, 100% 70%, 70% 100%, 30% 100%, 0% 70%, 0% ${30 + (70 - percentage * 70)}%)`;
            }

            // Changer la couleur en fonction de la valeur
            if (value < 25) {
                fillElement.style.opacity = '0.6';
            } else {
                fillElement.style.opacity = '1';
            }
        }
    } catch (error) {
        console.error(`[ZK HUD] Erreur lors de la mise à jour du statut ${type}:`, error);
    }
}

// ========== MISE À JOUR DU COMPTEUR ==========
function updateSpeedometer(speed, fuel, engine) {
    try {
        const style = hudConfig.speedometerStyle;

        if (style === 'minimal') {
            document.getElementById('speed-minimal').textContent = speed;
            document.getElementById('fuel-minimal').textContent = `${fuel}%`;
            document.getElementById('engine-minimal').textContent = `${engine}%`;
        } else if (style === 'moderne') {
            document.getElementById('speed-moderne').textContent = speed;
            document.getElementById('fuel-moderne').textContent = `${fuel}%`;
            document.getElementById('engine-moderne').textContent = `${engine}%`;

            // Mettre à jour les barres
            document.getElementById('fuel-bar-moderne').style.width = `${fuel}%`;
            document.getElementById('engine-bar-moderne').style.width = `${engine}%`;
        } else if (style === 'classique') {
            document.getElementById('speed-classique').textContent = speed;
            document.getElementById('fuel-classique').textContent = `${fuel}%`;
            document.getElementById('engine-classique').textContent = `${engine}%`;

            // Mettre à jour la jauge (0-220 km/h)
            const maxSpeed = 220;
            const percentage = Math.min(speed / maxSpeed, 1);
            const dashOffset = 251 - (251 * percentage);
            document.getElementById('speed-gauge-path').style.strokeDashoffset = dashOffset;

            // Mettre à jour l'aiguille (rotation de -90 à 90 degrés)
            const rotation = -90 + (180 * percentage);
            document.getElementById('gauge-needle').style.transform = `rotate(${rotation}deg)`;
        }
    } catch (error) {
        console.error('[ZK HUD] Erreur lors de la mise à jour du compteur:', error);
    }
}

// ========== FORMATAGE DE L'ARGENT ==========
function formatMoney(amount) {
    return new Intl.NumberFormat('fr-FR', {
        style: 'currency',
        currency: 'EUR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    }).format(amount);
}

// ========== MODE ÉDITION ==========
function toggleEditMode(enabled) {
    isEditMode = enabled;

    if (enabled) {
        editMenu.style.display = 'block';
        hudContainer.classList.add('edit-mode');

        // Afficher tous les éléments en mode édition
        playerInfo.classList.remove('hidden');
        statusIndicators.classList.remove('hidden');
        speedometer.style.display = 'block';

        // Initialiser les toggles
        updateEditToggles();

        // Initialiser les couleurs
        updateColorPickers();

        // Initialiser le style du compteur
        updateStyleButtons();
    } else {
        editMenu.style.display = 'none';
        hudContainer.classList.remove('edit-mode');

        // Réappliquer la visibilité des éléments
        applyElementVisibility();
    }
}

// ========== APPLICATION DE LA CONFIGURATION ==========
function applyConfig(config) {
    try {
        hudConfig = config;

        // Appliquer les positions
        if (config.positions) {
            if (config.positions.playerInfo) {
                playerInfo.style.left = `${config.positions.playerInfo.x}%`;
                playerInfo.style.top = `${config.positions.playerInfo.y}%`;
            }
            if (config.positions.statusIndicators) {
                statusIndicators.style.left = `${config.positions.statusIndicators.x}%`;
                statusIndicators.style.top = `${config.positions.statusIndicators.y}%`;
            }
            if (config.positions.speedometer) {
                speedometer.style.left = `${config.positions.speedometer.x}%`;
                speedometer.style.top = `${config.positions.speedometer.y}%`;
            }
        }

        // Appliquer les couleurs
        if (config.colors) {
            Object.keys(config.colors).forEach(key => {
                document.documentElement.style.setProperty(`--color-${key}`, config.colors[key]);
            });
        }

        // Appliquer le style du compteur
        if (config.speedometerStyle) {
            updateSpeedometerStyle(config.speedometerStyle);
        }

        // Appliquer la visibilité des éléments
        applyElementVisibility();

        console.log('[ZK HUD] Configuration appliquée avec succès');
    } catch (error) {
        console.error('[ZK HUD] Erreur lors de l\'application de la configuration:', error);
    }
}

// ========== VISIBILITÉ DES ÉLÉMENTS ==========
function applyElementVisibility() {
    try {
        // Éléments d'info joueur
        ['id', 'job', 'grade', 'cash', 'bank'].forEach(element => {
            const elem = playerInfo.querySelector(`[data-element="${element}"]`);
            if (elem) {
                if (hudConfig.enabledElements[element]) {
                    elem.classList.remove('hidden');
                } else {
                    elem.classList.add('hidden');
                }
            }
        });

        // Indicateurs de statut
        ['health', 'armor', 'hunger', 'thirst'].forEach(element => {
            const elem = statusIndicators.querySelector(`[data-element="${element}"]`);
            if (elem) {
                if (hudConfig.enabledElements[element]) {
                    elem.classList.remove('hidden');
                } else {
                    elem.classList.add('hidden');
                }
            }
        });

        // Compteur (géré dans updateHud)
    } catch (error) {
        console.error('[ZK HUD] Erreur lors de l\'application de la visibilité:', error);
    }
}

// ========== MISE À JOUR DES TOGGLES ==========
function updateEditToggles() {
    Object.keys(hudConfig.enabledElements).forEach(element => {
        const toggle = document.getElementById(`toggle-${element}`);
        if (toggle) {
            toggle.checked = hudConfig.enabledElements[element];
        }
    });
}

// ========== MISE À JOUR DES COLOR PICKERS ==========
function updateColorPickers() {
    Object.keys(hudConfig.colors).forEach(color => {
        const picker = document.getElementById(`color-${color}`);
        if (picker) {
            picker.value = hudConfig.colors[color];
        }
    });
}

// ========== MISE À JOUR DES BOUTONS DE STYLE ==========
function updateStyleButtons() {
    document.querySelectorAll('.style-btn').forEach(btn => {
        if (btn.dataset.style === hudConfig.speedometerStyle) {
            btn.classList.add('active');
        } else {
            btn.classList.remove('active');
        }
    });
}

// ========== MISE À JOUR DU STYLE DU COMPTEUR ==========
function updateSpeedometerStyle(style) {
    document.querySelectorAll('.speedometer-style').forEach(elem => {
        elem.classList.remove('active');
    });

    const styleElement = speedometer.querySelector(`.speedometer-style.${style}`);
    if (styleElement) {
        styleElement.classList.add('active');
    }
}

// ========== DRAG & DROP ==========
function initDragAndDrop() {
    const draggables = [playerInfo, statusIndicators, speedometer];

    draggables.forEach(element => {
        element.addEventListener('mousedown', startDrag);
    });

    document.addEventListener('mousemove', drag);
    document.addEventListener('mouseup', endDrag);
}

function startDrag(e) {
    if (!isEditMode) return;

    draggedElement = e.currentTarget;
    draggedElement.classList.add('dragging');

    const rect = draggedElement.getBoundingClientRect();
    dragOffset.x = e.clientX - rect.left;
    dragOffset.y = e.clientY - rect.top;

    e.preventDefault();
}

function drag(e) {
    if (!draggedElement || !isEditMode) return;

    const x = e.clientX - dragOffset.x;
    const y = e.clientY - dragOffset.y;

    // Convertir en pourcentage
    const percentX = (x / window.innerWidth) * 100;
    const percentY = (y / window.innerHeight) * 100;

    // Limiter aux bords de l'écran
    const clampedX = Math.max(0, Math.min(95, percentX));
    const clampedY = Math.max(0, Math.min(95, percentY));

    draggedElement.style.left = `${clampedX}%`;
    draggedElement.style.top = `${clampedY}%`;

    e.preventDefault();
}

function endDrag(e) {
    if (!draggedElement || !isEditMode) return;

    draggedElement.classList.remove('dragging');

    // Sauvegarder la position
    const left = parseFloat(draggedElement.style.left);
    const top = parseFloat(draggedElement.style.top);

    if (draggedElement === playerInfo) {
        hudConfig.positions.playerInfo.x = left;
        hudConfig.positions.playerInfo.y = top;
    } else if (draggedElement === statusIndicators) {
        hudConfig.positions.statusIndicators.x = left;
        hudConfig.positions.statusIndicators.y = top;
    } else if (draggedElement === speedometer) {
        hudConfig.positions.speedometer.x = left;
        hudConfig.positions.speedometer.y = top;
    }

    draggedElement = null;
}

// ========== GESTION DES ÉVÉNEMENTS DU MENU ==========
function initMenuEvents() {
    // Fermer le menu
    document.getElementById('close-edit').addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/closeEditMode`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        }).catch(err => console.error('[ZK HUD] Erreur callback closeEditMode:', err));
    });

    // Toggles des éléments
    document.querySelectorAll('.toggle-item input[type="checkbox"]').forEach(toggle => {
        toggle.addEventListener('change', (e) => {
            const element = e.target.dataset.element;
            hudConfig.enabledElements[element] = e.target.checked;
            applyElementVisibility();
        });
    });

    // Sélecteur de style
    document.querySelectorAll('.style-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const style = e.target.dataset.style;
            hudConfig.speedometerStyle = style;

            document.querySelectorAll('.style-btn').forEach(b => b.classList.remove('active'));
            e.target.classList.add('active');

            updateSpeedometerStyle(style);
        });
    });

    // Color pickers
    document.querySelectorAll('[data-color]').forEach(picker => {
        picker.addEventListener('input', (e) => {
            const color = e.target.dataset.color;
            const value = e.target.value;

            hudConfig.colors[color] = value;
            document.documentElement.style.setProperty(`--color-${color}`, value);
        });
    });

    // Sauvegarder
    document.getElementById('save-config').addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/saveConfig`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ config: hudConfig })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                console.log('[ZK HUD] Configuration sauvegardée');
            } else {
                console.error('[ZK HUD] Erreur lors de la sauvegarde:', data.message);
            }
        })
        .catch(err => console.error('[ZK HUD] Erreur callback saveConfig:', err));
    });

    // Réinitialiser
    document.getElementById('reset-config').addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/resetConfig`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        }).catch(err => console.error('[ZK HUD] Erreur callback resetConfig:', err));
    });
}

// ========== FONCTION UTILITAIRE POUR OBTENIR LE NOM DE LA RESSOURCE ==========
function GetParentResourceName() {
    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    return urlParams.get('resource') || 'zk_hud';
}

// ========== INITIALISATION ==========
document.addEventListener('DOMContentLoaded', () => {
    console.log('[ZK HUD] Interface initialisée');
    initDragAndDrop();
    initMenuEvents();
});

// ========== GESTION DES ERREURS GLOBALES ==========
window.addEventListener('error', (event) => {
    console.error('[ZK HUD] Erreur non gérée:', event.error);
});

window.addEventListener('unhandledrejection', (event) => {
    console.error('[ZK HUD] Promise rejetée non gérée:', event.reason);
});
