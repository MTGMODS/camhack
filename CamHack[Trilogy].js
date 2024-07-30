/// <reference path=".config/sa.d.ts" />
// CamHack by MTG MODS
// https://discord.gg/mtg-mods-samp-1097643847774908526
// https://www.blast.hk/threads/175690/

// GET KEYS ID: https://keycode-visualizer.netlify.app/
// Use the "," symbol to use multiple keys
var ACTIVATE = [18, 67];        // Alt + C
var DISABLE = [18, 86];         // Alt + V
var FORWARD = [87];             // W
var BACK = [83];                // S
var LEFT = [65];                // A
var RIGHT = [68];               // D
var UP = [16];                  // Left Shift
var DOWN = [17];                // Left Ctrl
var ANGLE_UP = [38];            // ?
var ANGLE_DOWN = [40];          // ?
var ANGLE_LEFT = [37];          // ?
var ANGLE_RIGHT = [39];         // ?
var SPEED_PLUS = [187];         // +
var SPEED_MINUS = [189];        // -

var p = new Player(0);

var camhack_active = false;
var camhack_speed  = 0.2;
var posX;
var posY;
var posZ;
var angZ;
var angY;
var radZ;
var radY;
var sinZ;
var cosZ;
var sinY;
var cosY;
var poiX;
var poiY;
var poiZ;
var curZ;
var curY;

function isHotkeyClicked(keysArray) {
    try {
        if (keysArray.length === 0) {
            log('Error: Keys array is empty');
            return false;
        }
        for (var i = 0; i < keysArray.length; i++) {
            if (!Pad.IsKeyPressed(keysArray[i])) {
                return false;
            }
        }
        return true;
    } catch (e) {
        log("Error checking hotkey: " + e);
        return false;
    }
}
function radians(degrees) {
    return degrees * (Math.PI / 180);
};
function camhack_on() {
    let {x, y, z} = p.getChar().getCoordinates();
    posX = x;
    posY = y;
    posZ = z;
    Camera.SetFixedPosition(posX, posY, posZ, 0.0, angY, angZ);
    angZ = p.getChar().getHeading();
    // angZ = angZ * -1.0;
    angY = 0.0;
    camhack_active = true;
};
function camhack_off() {
	camhack_active = false;
	// angZ = angZ * -1.0;
    Camera.RestoreJumpcut();
    Camera.SetBehindPlayer();	
};
function camhack_update() {
    radZ = radians(angZ);
    radY = radians(angY);
    sinZ = Math.sin(radZ);
    cosZ = Math.cos(radZ);
    sinY = Math.sin(radY);
    cosY = Math.cos(radY);
    sinZ = sinZ * cosY;
    cosZ = cosZ * cosY;
    sinY = sinY * 1.0;
    poiX = posX + sinZ;
    poiY = posY + cosZ;
    poiZ = posZ + sinY;
	Camera.PointAtPoint(poiX, poiY, poiZ, 2);
};
function camhack_forward() {
    radZ = radians(angZ);
    radY = radians(angY);
    sinZ = Math.sin(radZ);
    cosZ = Math.cos(radZ);
    sinY = Math.sin(radY);
    cosY = Math.cos(radY);
	sinZ = sinZ * cosY;
	cosZ = cosZ * cosY;
	sinZ = sinZ * camhack_speed;
	cosZ = cosZ * camhack_speed;
	sinY = sinY * camhack_speed;
	posX = posX + sinZ;
	posY = posY + cosZ;
	posZ = posZ + sinY;
	Camera.SetFixedPosition(posX, posY, posZ, 0.0, angY, angZ);
}
function camhack_left() {
	curZ = angZ - 90.0;
	radZ = radians(curZ);
	radY = radians(angY);
	sinZ = Math.sin(radZ);
	cosZ = Math.cos(radZ);
	sinZ = sinZ * camhack_speed;
	cosZ = cosZ * camhack_speed;
	posX = posX + sinZ;
	posY = posY + cosZ;
	Camera.SetFixedPosition(posX, posY, posZ, 0.0, angY, angZ);
}
function camhack_right() {
	curZ = angZ + 90.0;
	radZ = radians(curZ);
	radY = radians(angY);
	sinZ = Math.sin(radZ);
	cosZ = Math.cos(radZ);
	sinZ = sinZ * camhack_speed;
	cosZ = cosZ * camhack_speed;
	posX = posX + sinZ;
	posY = posY + cosZ;
	Camera.SetFixedPosition(posX, posY, posZ, 0.0, angY, angZ);
}
function camhack_back() {
	curZ = angZ + 180.0;
	curY = angY * -1.0;
    radZ = radians(curZ);
    radY = radians(curY);
    sinZ = Math.sin(radZ);
    cosZ = Math.cos(radZ);
    sinY = Math.sin(radY);
    cosY = Math.cos(radY);
	sinZ = sinZ * cosY;
	cosZ = cosZ * cosY;
	sinZ = sinZ * camhack_speed;
	cosZ = cosZ * camhack_speed;
	sinY = sinY * camhack_speed;
	posX = posX + sinZ;
	posY = posY + cosZ;
	posZ = posZ + sinY;
    Camera.SetFixedPosition(posX, posY, posZ, 0.0, angY, angZ);
}
function camhack_up() {
	posZ = posZ + camhack_speed;
    Camera.SetFixedPosition(posX, posY, posZ, 0.0, angY, angZ);
}
function camhack_down() {
	posZ = posZ - camhack_speed;
    Camera.SetFixedPosition(posX, posY, posZ, 0.0, angY, angZ);
}
function camhack_speed_plus() {
	camhack_speed = camhack_speed + 0.01;
};
function camhack_speed_minus() {
	camhack_speed = camhack_speed - 0.01;
	if (camhack_speed < 0.01) {
        camhack_speed = 0.01;
    };
};
function camhack_angle_left() {
    let angle = 1 + camhack_speed / 10;
    angZ = angZ - angle;
    if (angZ < 0) {
        angZ = 360 - angZ;
    };
    Camera.SetFixedPosition(posX, posY, posZ, 0.0, 0.0, angZ);
};
function camhack_angle_right() {
    let angle = 1 + camhack_speed / 10;
    angZ = angZ + angle;
    if (angZ < 0) {
        angZ = 360 - angZ;
    };
    Camera.SetFixedPosition(posX, posY, posZ, 0.0, 0.0, angZ);
};
function camhack_angle_up() {
    let angle = 1 + camhack_speed / 10;
    angY = angY + angle;
    if (angY > 90) {
        angY = 90;
    }
    Camera.SetFixedPosition(posX, posY, posZ, 0.0, angY, angZ);
};
function camhack_angle_down() {
    let angle = 1 + camhack_speed / 10;
    angY = angY - angle;
    if (angY < -90) {
        angY = -90;
    }
    Camera.SetFixedPosition(posX, posY, posZ, 0.0, angY, angZ);
};

while (true) {
    wait(0);
 
    if (isHotkeyClicked(ACTIVATE) && !camhack_active) {
        camhack_on();
    }

    if (camhack_active) {

        p.setControl(false);

        camhack_update();

        if (isHotkeyClicked(FORWARD)) {
            camhack_forward();
        };

        camhack_update();

        if (isHotkeyClicked(BACK)) {
            camhack_back();
        };

        camhack_update();

        if (isHotkeyClicked(LEFT)) {
            camhack_left();
        };

        camhack_update();

        if (isHotkeyClicked(RIGHT)) {
            camhack_right();
        };

        camhack_update();

        if (isHotkeyClicked(UP)) {
            camhack_up();
        };

        camhack_update();

        if (isHotkeyClicked(DOWN)) {
            camhack_down();
        };

        if (isHotkeyClicked(SPEED_PLUS))  {
            camhack_speed_plus();
        };

        camhack_update();

        if (isHotkeyClicked(SPEED_MINUS)) {
            camhack_speed_minus();
        };

        camhack_update();

        if (isHotkeyClicked(ANGLE_LEFT)) {
            camhack_angle_left();
        };

        camhack_update();

        if (isHotkeyClicked(ANGLE_RIGHT)) {
            camhack_angle_right();
        };

        camhack_update();

        if (isHotkeyClicked(ANGLE_UP)) {
            camhack_angle_up();
        };

        camhack_update();

        if (isHotkeyClicked(ANGLE_DOWN)) {
            camhack_angle_down();
        };

        camhack_update();

        if (isHotkeyClicked(DISABLE)) {
            camhack_off();
            p.setControl(true);
        };
        
    };

}