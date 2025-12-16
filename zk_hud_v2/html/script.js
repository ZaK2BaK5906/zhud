// Gestion globale des erreurs NUI
window.addEventListener('error', (event) => {
    fetch(`https://${GetParentResourceName()}/nuiError`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            error: event.message,
            stack: event.error?.stack
        })
    }).catch(() => {});
});

window.addEventListener('unhandledrejection', (event) => {
    fetch(`https://${GetParentResourceName()}/nuiError`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            error: event.reason?.message || 'Unhandled promise rejection',
            stack: event.reason?.stack
        })
    }).catch(() => {});
});

// Utilitaire pour obtenir le nom de la ressource
function GetParentResourceName() {
    return window.location.hostname === '' ? 'zk_hud_v2' : window.location.hostname;
}

// État global
const HUDState = {
    settings: {
        positions: {},
        colors: {},
        visibility: {},
        speedometer_style: 'modern'
    },
    locale: 'fr',
    isEditMode: false,
    dragging: {
        element: null,
        offsetX: 0,
        offsetY: 0
    }
};

// Traductions
let translations = {};

// Initialisation
document.addEventListener('DOMContentLoaded', () => {
    initializeElements();
    setupEventListeners();
});

// Initialiser les éléments
function initializeElements() {
    // Rien à faire pour l'instant
}

// Configuration des écouteurs d'événements
function setupEventListeners() {
    // Éditeur - Boutons de style
    document.querySelectorAll('.style-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const style = btn.dataset.style;
            changeSpeedometerStyle(style);

            // Mise à jour UI
            document.querySelectorAll('.style-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
        });
    });

    // Éditeur - Toggles
    document.querySelectorAll('.toggle-item input[type="checkbox"]').forEach(checkbox => {
        checkbox.addEventListener('change', (e) => {
            const element = e.target.dataset.toggle;
            toggleElement(element, e.target.checked);
        });
    });

    // Éditeur - Couleurs
    document.querySelectorAll('.color-item input[type="color"]').forEach(input => {
        input.addEventListener('change', (e) => {
            const colorType = e.target.dataset.color;
            changeColor(colorType, e.target.value);
        });
    });

    // Boutons éditeur
    document.getElementById('close-editor')?.addEventListener('click', closeEditor);
    document.getElementById('save-settings')?.addEventListener('click', saveSettings);
    document.getElementById('reset-settings')?.addEventListener('click', resetSettings);

    // Drag & Drop
    setupDragAndDrop();
}

// Configuration du drag & drop
function setupDragAndDrop() {
    const draggables = document.querySelectorAll('.draggable');

    draggables.forEach(element => {
        element.addEventListener('mousedown', startDrag);
    });

    document.addEventListener('mousemove', drag);
    document.addEventListener('mouseup', stopDrag);
}

function startDrag(e) {
    if (!HUDState.isEditMode) return;

    const element = e.currentTarget;
    const rect = element.getBoundingClientRect();

    HUDState.dragging.element = element;
    HUDState.dragging.offsetX = e.clientX - rect.left;
    HUDState.dragging.offsetY = e.clientY - rect.top;

    element.classList.add('dragging');
    e.preventDefault();
}

function drag(e) {
    if (!HUDState.dragging.element || !HUDState.isEditMode) return;

    const element = HUDState.dragging.element;
    const elementName = element.dataset.element;

    // Calculer la nouvelle position en %
    const left = ((e.clientX - HUDState.dragging.offsetX) / window.innerWidth) * 100;
    const top = ((e.clientY - HUDState.dragging.offsetY) / window.innerHeight) * 100;

    // Limiter aux bords de l'écran
    const clampedLeft = Math.max(0, Math.min(90, left));
    const clampedTop = Math.max(0, Math.min(90, top));

    // Appliquer la position
    element.style.left = clampedLeft + '%';
    element.style.top = clampedTop + '%';
    element.style.right = 'auto';
    element.style.bottom = 'auto';

    e.preventDefault();
}

function stopDrag(e) {
    if (!HUDState.dragging.element) return;

    const element = HUDState.dragging.element;
    const elementName = element.dataset.element;

    // Calculer la position finale en %
    const rect = element.getBoundingClientRect();
    const left = (rect.left / window.innerWidth) * 100;
    const top = (rect.top / window.innerHeight) * 100;
    const right = ((window.innerWidth - rect.right) / window.innerWidth) * 100;
    const bottom = ((window.innerHeight - rect.bottom) / window.innerHeight) * 100;

    // Déterminer quelle position utiliser (côté le plus proche)
    const useLeft = left < right;
    const useTop = top < bottom;

    // Sauvegarder la position
    HUDState.settings.positions[elementName] = {
        ...(useTop ? { top: top } : { bottom: bottom }),
        ...(useLeft ? { left: left } : { right: right })
    };

    element.classList.remove('dragging');
    HUDState.dragging.element = null;

    e.preventDefault();
}

// Changer le style du compteur
function changeSpeedometerStyle(style) {
    HUDState.settings.speedometer_style = style;

    document.querySelectorAll('.speedometer-style').forEach(s => {
        s.classList.remove('active');
    });

    document.querySelector(`.speedometer-style[data-style="${style}"]`)?.classList.add('active');
}

// Toggle un élément
function toggleElement(element, visible) {
    HUDState.settings.visibility[element] = visible;

    // Appliquer la visibilité
    const elements = document.querySelectorAll(`[data-visible="${element}"]`);
    elements.forEach(el => {
        if (visible) {
            el.style.display = '';
        } else {
            el.style.display = 'none';
        }
    });
}

// Changer une couleur
function changeColor(colorType, color) {
    HUDState.settings.colors[colorType] = color;

    // Appliquer la couleur
    const root = document.documentElement;
    root.style.setProperty(`--${colorType}-color`, color);
}

// Écouteur de messages NUI
window.addEventListener('message', (event) => {
    const data = event.data;

    try {
        switch(data.action) {
            case 'initHUD':
                initHUD(data.settings, data.locale);
                break;
            case 'showHUD':
                showHUD();
                break;
            case 'hideHUD':
                hideHUD();
                break;
            case 'updatePlayerInfo':
                updatePlayerInfo(data.data);
                break;
            case 'updateStatuses':
                updateStatuses(data.data);
                break;
            case 'updateSpeedometer':
                updateSpeedometer(data.data);
                break;
            case 'openEditor':
                openEditor();
                break;
            case 'closeEditor':
                closeEditor();
                break;
            case 'loadSettings':
                loadSettings(data.settings);
                break;
        }
    } catch (error) {
        console.error('Error handling NUI message:', error);
        fetch(`https://${GetParentResourceName()}/nuiError`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                error: error.message,
                stack: error.stack
            })
        }).catch(() => {});
    }
});

// Initialiser le HUD
function initHUD(settings, locale) {
    HUDState.settings = settings;
    HUDState.locale = locale;

    // Appliquer les positions
    applyPositions(settings.positions);

    // Appliquer les couleurs
    Object.entries(settings.colors).forEach(([key, value]) => {
        changeColor(key, value);
        const input = document.querySelector(`input[data-color="${key}"]`);
        if (input) input.value = value;
    });

    // Appliquer la visibilité
    Object.entries(settings.visibility).forEach(([key, value]) => {
        toggleElement(key, value);
        const checkbox = document.querySelector(`input[data-toggle="${key}"]`);
        if (checkbox) checkbox.checked = value;
    });

    // Appliquer le style de compteur
    changeSpeedometerStyle(settings.speedometer_style);
    const styleBtn = document.querySelector(`.style-btn[data-style="${settings.speedometer_style}"]`);
    if (styleBtn) {
        document.querySelectorAll('.style-btn').forEach(b => b.classList.remove('active'));
        styleBtn.classList.add('active');
    }
}

// Afficher le HUD
function showHUD() {
    const container = document.getElementById('hud-container');
    if (container) container.classList.remove('hidden');
}

// Masquer le HUD
function hideHUD() {
    const container = document.getElementById('hud-container');
    if (container) container.classList.add('hidden');
}

// Mettre à jour les informations du joueur
function updatePlayerInfo(data) {
    if (!data) return;

    const idEl = document.getElementById('player-id');
    const jobEl = document.getElementById('player-job');
    const gradeEl = document.getElementById('player-grade');
    const cashEl = document.getElementById('player-cash');
    const bankEl = document.getElementById('player-bank');

    if (idEl) idEl.textContent = data.id || '0';
    if (jobEl) jobEl.textContent = data.job || 'Unemployed';
    if (gradeEl) gradeEl.textContent = data.grade || 'None';
    if (cashEl) cashEl.textContent = formatMoney(data.cash || 0);
    if (bankEl) bankEl.textContent = formatMoney(data.bank || 0);
}

// Mettre à jour les statuts
function updateStatuses(data) {
    if (!data) return;

    updateCircularProgress('health', data.health);
    updateCircularProgress('armor', data.armor);
    updateCircularProgress('hunger', data.hunger);
    updateCircularProgress('thirst', data.thirst);
}

// Mettre à jour une barre circulaire
function updateCircularProgress(type, value) {
    const circle = document.getElementById(`${type}-circle`);
    const valueEl = document.getElementById(`${type}-value`);

    if (circle) {
        const circumference = 283;
        const offset = circumference - (value / 100) * circumference;
        circle.style.strokeDashoffset = offset;
    }

    if (valueEl) {
        valueEl.textContent = Math.round(value);
    }
}

// Mettre à jour le compteur de vitesse
function updateSpeedometer(data) {
    if (!data) return;

    const speedometer = document.getElementById('speedometer');

    if (data.inVehicle) {
        speedometer?.classList.remove('hidden');

        const style = HUDState.settings.speedometer_style;

        // Mettre à jour la vitesse
        const speedEl = document.getElementById(`speed-${style}`);
        if (speedEl) speedEl.textContent = Math.round(data.speed);

        // Mettre à jour l'essence
        const fuelEl = document.getElementById(`fuel-${style}`);
        if (fuelEl) fuelEl.style.width = data.fuel + '%';

        const fuelValueEl = document.getElementById(`fuel-${style}-value`);
        if (fuelValueEl) fuelValueEl.textContent = data.fuel + '%';

        // Mettre à jour la santé du véhicule
        const vehicleEl = document.getElementById(`vehicle-${style}`);
        if (vehicleEl) vehicleEl.style.width = data.vehicle + '%';

        const vehicleValueEl = document.getElementById(`vehicle-${style}-value`);
        if (vehicleValueEl) vehicleValueEl.textContent = data.vehicle + '%';

        // Pour le style moderne (arc)
        if (style === 'modern') {
            const arc = document.getElementById('speed-arc-modern');
            if (arc) {
                const maxSpeed = 250;
                const percentage = Math.min(data.speed / maxSpeed, 1);
                const arcLength = 251.2;
                const offset = arcLength - (percentage * arcLength);
                arc.style.strokeDashoffset = offset;
            }
        }

        // Pour le style classique (gauge)
        if (style === 'classic') {
            const gauge = document.getElementById('speed-gauge-classic');
            if (gauge) {
                const maxSpeed = 250;
                const percentage = Math.min(data.speed / maxSpeed, 1);
                const circumference = 565.48;
                const offset = circumference - (percentage * circumference);
                gauge.style.strokeDashoffset = offset;
            }

            const fuelClassic = document.getElementById('fuel-classic');
            if (fuelClassic) fuelClassic.textContent = data.fuel + '%';

            const vehicleClassic = document.getElementById('vehicle-classic');
            if (vehicleClassic) vehicleClassic.textContent = data.vehicle + '%';
        }
    } else {
        speedometer?.classList.add('hidden');
    }
}

// Ouvrir l'éditeur
function openEditor() {
    HUDState.isEditMode = true;

    const editor = document.getElementById('hud-editor');
    const grid = document.getElementById('edit-grid');

    if (editor) editor.classList.remove('hidden');
    if (grid) grid.classList.remove('hidden');
}

// Fermer l'éditeur
function closeEditor() {
    HUDState.isEditMode = false;

    const editor = document.getElementById('hud-editor');
    const grid = document.getElementById('edit-grid');

    if (editor) editor.classList.add('hidden');
    if (grid) grid.classList.add('hidden');

    fetch(`https://${GetParentResourceName()}/closeEditor`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).catch(() => {});
}

// Sauvegarder les paramètres
function saveSettings() {
    fetch(`https://${GetParentResourceName()}/saveSettings`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            settings: HUDState.settings
        })
    }).catch((error) => {
        console.error('Error saving settings:', error);
    });
}

// Réinitialiser les paramètres
function resetSettings() {
    fetch(`https://${GetParentResourceName()}/resetSettings`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).catch((error) => {
        console.error('Error resetting settings:', error);
    });
}

// Charger les paramètres
function loadSettings(settings) {
    initHUD(settings, HUDState.locale);
}

// Appliquer les positions
function applyPositions(positions) {
    Object.entries(positions).forEach(([elementName, pos]) => {
        const element = document.querySelector(`[data-element="${elementName}"]`);
        if (!element) return;

        // Réinitialiser toutes les positions
        element.style.top = '';
        element.style.bottom = '';
        element.style.left = '';
        element.style.right = '';

        // Appliquer les nouvelles positions
        if (pos.top !== undefined) element.style.top = pos.top + '%';
        if (pos.bottom !== undefined) element.style.bottom = pos.bottom + '%';
        if (pos.left !== undefined) element.style.left = pos.left + '%';
        if (pos.right !== undefined) element.style.right = pos.right + '%';
    });
}

// Formater l'argent
function formatMoney(amount) {
    return '$' + amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

// Échappement pour fermer l'éditeur
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && HUDState.isEditMode) {
        closeEditor();
    }
});

// Debug
console.log('ZK HUD V2 - NUI Loaded');
