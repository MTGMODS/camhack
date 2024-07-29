script_name("CamHack V3")
script_description('CamHack for MonetLoader / MoonLoader')
script_author("MTG MODS")
script_version(3)

require('lib.moonloader')
require ('encoding').default = 'CP1251'
local u8 = require('encoding').UTF8
local ffi = require('ffi')

local camhack_active = false
local camhack_speed = 0.2

local posX
local posY
local posZ
local angZ
local angY
local radZ
local radY
local sinZ
local cosZ
local sinY
local cosY
local poiX
local poiY
local poiZ
local curZ
local curY

-------------------------------------------- JSON SETTINGS ---------------------------------------------

local settings = {}
local default_settings = {
	general = {
		enable = true,
		hud = true,
		chat_bubble = false,
		hide_nick = false,
		camhack_type = 1
	},
	binds = {
		activate = '[18, 67]',
		disable = '[18, 86]',
		foward = '[87]',
		back = '[83]',
		left = '[65]',
		right = '[68]',
		left_foward = '[81]',
		right_foward = '[69]',
		up = '[16]',
		down = '[17]',
		speed_plus = '[187]',
		speed_minus = '[189]',
		hud = '[121]'
	}
}

local configDirectory = getWorkingDirectory() .. "/config"
local path = configDirectory .. "/CamHack_Settings.json"

function load_settings()
    if not doesDirectoryExist(configDirectory) then
        createDirectory(configDirectory)
    end
    if not doesFileExist(path) then
        settings = default_settings
		print('[CamHack V3] Файл с настройками не найден, использую стандартные настройки!')
    else
        local file = io.open(path, 'r')
        if file then
            local contents = file:read('*a')
            file:close()
			if #contents == 0 then
				settings = default_settings
				print('[CamHack V3] Не удалось открыть файл с настройками, использую стандартные настройки!')
			else
				local result, loaded = pcall(decodeJson, contents)
				if result then
					settings = loaded
					for category, _ in pairs(default_settings) do
						if settings[category] == nil then
							settings[category] = {}
						end
						for key, value in pairs(default_settings[category]) do
							if settings[category][key] == nil then
								settings[category][key] = value
							end
						end
					end
					print('[CamHack V3] Настройки успешно загружены!')
				else
					print('[CamHack V3] Не удалось открыть файл с настройками, использую стандартные настройки!')
				end
			end
        else
            settings = default_settings
			print('[CamHack V3] Не удалось открыть файл с настройками, использую стандартные настройки!')
        end
    end
end
function save_settings()
    local file, errstr = io.open(path, 'w')
    if file then
        local result, encoded = pcall(encodeJson, settings)
        file:write(result and encoded or "")
        file:close()
        return result
    else
        print('[CamHack V3] Не удалось сохранить настройки скрипта, ошибка: ', errstr)
        return false
    end
end

load_settings()

------------------------------------------- MonetLoader --------------------------------------------------

function isMonetLoader() return MONET_VERSION ~= nil end

if isMonetLoader() then
	widgets = require('widgets')
	gta = ffi.load('GTASA') 
	ffi.cdef[[ void _Z12AND_OpenLinkPKc(const char* link); ]]
end

if not isMonetLoader() and MONET_DPI_SCALE == nil then MONET_DPI_SCALE = 1.0 end

if not isMonetLoader() then
	mem = require 'memory'
end

---------------------------------------------- Mimgui -----------------------------------------------------

local imgui = require('mimgui')
local fa = require('fAwesome6_solid')

local sizeX, sizeY = getScreenResolution()

local MainWindow = imgui.new.bool()
local camhack_type = imgui.new.int(settings.general.camhack_type or 1)

local CamHackWindow = imgui.new.bool()

------------------------------------------- Mimgui Hotkey  -----------------------------------------------------

if not isMonetLoader()  then
	
	hotkey = require('mimgui_hotkeys')
	hotkey.Text.NoKey = u8'< nill >'
    hotkey.Text.WaitForKey = u8'< wait >'

	ActivateCamHackHotKey = hotkey.RegisterHotKey('Activate CamHack', false, decodeJson(settings.binds.activate), function()
		-- if not camhack_active then camhack_on() end
	end)

	DisableCamHackHotKey = hotkey.RegisterHotKey('Disable CamHack', false, decodeJson(settings.binds.disable), function()
		-- if camhack_active then camhack_off() end
	end)

	CamHackFowardHotKey = hotkey.RegisterHotKey('CamHack Foward', false, decodeJson(settings.binds.foward), function()
		-- if camhack_active then camhack_foward() end
	end)

	CamHackBackHotKey = hotkey.RegisterHotKey('CamHack Back', false, decodeJson(settings.binds.back), function()
		-- if camhack_active then camhack_back() end
	end)

	CamHackLeftHotKey = hotkey.RegisterHotKey('CamHack Left', false, decodeJson(settings.binds.left), function()
		-- if camhack_active then camhack_left() end
	end)

	CamHackRightHotKey = hotkey.RegisterHotKey('CamHack Right', false, decodeJson(settings.binds.right), function()
		-- if camhack_active then camhack_right() end
	end)

	CamHackLeftFowardHotKey = hotkey.RegisterHotKey('CamHack Left Foward', false, decodeJson(settings.binds.left_foward), function()
		-- if camhack_active then camhack_left_foward() end
	end)

	CamHackRightFowardHotKey = hotkey.RegisterHotKey('CamHack Right Foward', false, decodeJson(settings.binds.right_foward), function()
		-- if camhack_active then camhack_right_foward() end
	end)

	CamHackUpHotKey = hotkey.RegisterHotKey('CamHack Up', false, decodeJson(settings.binds.up), function()
		-- if camhack_active then camhack_up() end
	end)

	CamHackDownHotKey = hotkey.RegisterHotKey('CamHack Down', false, decodeJson(settings.binds.down), function()
		-- if camhack_active then camhack_down() end
	end)

	CamHackSpeedPlusHotKey = hotkey.RegisterHotKey('CamHack Speed Plus', false, decodeJson(settings.binds.speed_plus), function()
		-- if camhack_active then camhack_speed_plus() end
	end)

	CamHackSpeedMinusHotKey = hotkey.RegisterHotKey('CamHack Speed Minus', false, decodeJson(settings.binds.speed_minus), function()
		-- if camhack_active then camhack_speed_minus() end
	end)

	CamHackHudHotKey = hotkey.RegisterHotKey('CamHack Hud', false, decodeJson(settings.binds.hud), function()
		if camhack_active and settings.general.camhack_type == 1 then
			settings.general.hud = not settings.general.hud
			save_settings()
		end
	end)

	function getNameKeysFrom(keys)
		local keys = decodeJson(keys)
		local keysStr = {}
		for _, keyId in ipairs(keys) do
			local keyName = require('vkeys').id_to_name(keyId) or ''
			table.insert(keysStr, keyName)
		end
		return tostring(table.concat(keysStr, ' + '))
	end

	function IsHotkeyClicked(keys_id)
		local keysArray = decodeJson(keys_id)
		if next(keysArray) == nil then
			return false
		end
		local allKeysPressed = true
		for _, element in ipairs(keysArray) do
			if not isKeyDown(element) then
				allKeysPressed = false
				break
			end
		end
		return allKeysPressed
	end

	addEventHandler('onWindowMessage', function(msg, key, lparam)
		if msg == 641 or msg == 642 or lparam == -1073741809 then  hotkey.ActiveKeys = {} end
		if msg == 0x0005 then hotkey.ActiveKeys = {} end
	end)

end

------------------------------------------- Check PC/Mobile --------------------------------------------------

function check()
	if ((isMonetLoader()) and (settings.general.camhack_type == 1 or camhack_type[0] == 1)) then
		sampAddChatMessage('{ff0000}[CamHack V3] {ffffff}Нельзя использовать Hotkeys на MonetLoader, изменяю на Joystick!',-1)
		settings.general.camhack_type = 2
		camhack_type[0] = 2
		save_settings()
		return false
	elseif ((not isMonetLoader()) and (settings.general.camhack_type == 2 or camhack_type[0] == 2 or settings.general.camhack_type == 3 or camhack_type[0] == 3)) then
		sampAddChatMessage('{ff0000}[CamHack V3] {ffffff}Нельзя использовать Joystick на MoonLoader, изменяю на Hotkey!',-1)
		settings.general.camhack_type = 1
		camhack_type[0] = 1
		save_settings()
		return false
	else
		return true
	end
end

------------------------------------------- Main -----------------------------------------------------

function main()

    if ((not isSampLoaded()) or (not isSampfuncsLoaded())) then return end;
    while (not isSampAvailable()) do wait(0) end; 

	sampAddChatMessage('{ff0000}[INFO] {ffffff}Скрипт "CamHack" загружен и готов к работе! Автор: MTG MODS | Версия: 3 | Используйте {00ccff}/cmh',-1);

	check();

	sampRegisterChatCommand("cmh", function()
		MainWindow[0] = not MainWindow[0];
	end);

	if (settings.general.camhack_type == 0) then
		sampRegisterChatCommand("cam", function()
			if (camhack_active) then
				camhack_off();
			elseif settings.general.enable then
				camhack_on();
				CamHackWindow[0] = true;
			end;
		end);
	end;

	while (true) do 
		wait(0);
		if (settings.general.enable) then
			if (camhack_active) then

				camhack_update();
	
				if (settings.general.hud) then
					camhack_enable_hud();
				else
					camhack_disable_hud();
				end;
	
				if ((isMonetLoader()) and (settings.general.camhack_type == 2)) then
					if (isWidgetPressed(WIDGET_ZOOM_IN)) then
						camhack_speed_plus();
					end;
					if (isWidgetPressed(WIDGET_ZOOM_OUT)) then
						camhack_speed_minus();
					end;
					if (isWidgetPressed(WIDGET_CRANE_UP)) then
						camhack_up();
					end;
					if (isWidgetPressed(WIDGET_CRANE_DOWN)) then
						camhack_down()
					end
					if (isWidgetPressed(WIDGET_RACE_LEFT)) then
						camhack_angle_left();
					end;
					if (isWidgetPressed(WIDGET_RACE_RIGHT)) then
						camhack_angle_right();
					end;
					local result, var_1, var_2 = isWidgetPressedEx(WIDGET_PED_MOVE, 0);
					if (result and var_1 ~= 0 and var_2 ~= 0) then
						handleJoystick(var_1, var_2);
					end
					if (isWidgetPressed(WIDGET_MISSION_CANCEL)) then
						camhack_off();
					end
				end
	
				if ((not isMonetLoader()) and (settings.general.camhack_type == 1)) then
					if camhack_active and not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
					
						offMouX, offMouY = getPcMouseMovement()
						angZ = (angZ + offMouX/4.0) % 360.0
						angY = math.min(89.0, math.max(-89.0, angY + offMouY/4.0))
		
						camhack_update()
		
						if IsHotkeyClicked(settings.binds.foward) then
							camhack_foward()
						end
		
						camhack_update()
			
						if IsHotkeyClicked(settings.binds.back) then
							camhack_back()
						end
		
						camhack_update()
			
						if IsHotkeyClicked(settings.binds.left) then
							camhack_left()
						end
		
						camhack_update()
			
						if IsHotkeyClicked(settings.binds.right)then
							camhack_right()
						end
		
						camhack_update()
			
						if IsHotkeyClicked(settings.binds.right_foward) then
							camhack_right_foward()
						end
	
						camhack_update()
	
						if IsHotkeyClicked(settings.binds.left_foward) then
							camhack_left_foward()
						end
	
						camhack_update();
	
						if (IsHotkeyClicked(settings.binds.up)) then
							camhack_up();
						end;
	
						camhack_update();
	
						if (IsHotkeyClicked(settings.binds.down)) then
							camhack_down();
						end;
	
						camhack_update();
	
						if (settings.general.hud) then
							camhack_enable_hud();
						else
							camhack_disable_hud();
						end;
	
						if (IsHotkeyClicked(settings.binds.speed_plus)) then
							camhack_speed_plus();
						end;
	
						if (IsHotkeyClicked(settings.binds.speed_minus)) then
							camhack_speed_minus();
						end;
	
						if (IsHotkeyClicked(settings.binds.disable)) then
							camhack_off();
						end;
					end;
				end;
			else
				if ((isMonetLoader()) and (settings.general.camhack_type == 2)) then
					if (isWidgetPressed(WIDGET_CAM_TOGGLE)) then
						camhack_on();
					end
				elseif ((not isMonetLoader()) and (settings.general.camhack_type == 1)) then
					if ((IsHotkeyClicked(settings.binds.activate)) and (not camhack_active)) then
						camhack_on();
					end
				end;
			end; 
		end;
	end;
end;

function camhack_on()
	posX, posY, posZ = getCharCoordinates(playerPed)
	setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
	angZ = getCharHeading(playerPed)
	angZ = angZ * -1.0
	angY = 0.0
	if settings.general.camhack_type == 0 then
		CamHackWindow[0] = true
	end
	if settings.general.camhack_type == 0 or settings.general.camhack_type == 1 then
		lockPlayerControl(true)
	end
	camhack_active = true
	if not isMonetLoader() and settings.general.hide_nick then
		hidenicks(1)
	end
end
function camhack_off()
	camhack_active = false
	angPlZ = angZ * -1.0
	restoreCameraJumpcut()
	setCameraBehindPlayer()
	if settings.general.camhack_type == 0 then
		CamHackWindow[0] = false
	end
	if settings.general.camhack_type == 0 or settings.general.camhack_type == 1 then
		lockPlayerControl(false)
	end
	camhack_enable_hud()
	if not isMonetLoader() and settings.general.hide_nick then
		hidenicks(0)
	end
end
function camhack_update()
	radZ, radY = math.rad(angZ), math.rad(angY)
	sinZ, cosZ = math.sin(radZ), math.cos(radZ)
	sinY, cosY = math.sin(radY), math.cos(radY)
	sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
	poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
	pointCameraAtPoint(poiX, poiY, poiZ, 2)
end
function camhack_foward()
	radZ = math.rad(angZ)
	radY = math.rad(angY)
	sinZ = math.sin(radZ)
	cosZ = math.cos(radZ)
	sinY = math.sin(radY)
	cosY = math.cos(radY)
	sinZ = sinZ * cosY
	cosZ = cosZ * cosY
	sinZ = sinZ * camhack_speed 
	cosZ = cosZ * camhack_speed 
	sinY = sinY * camhack_speed 
	posX = posX + sinZ
	posY = posY + cosZ
	posZ = posZ + sinY
	setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_back()
	curZ = angZ + 180.0
	curY = angY * -1.0
	radZ = math.rad(curZ)
	radY = math.rad(curY)
	sinZ = math.sin(radZ)
	cosZ = math.cos(radZ)
	sinY = math.sin(radY)
	cosY = math.cos(radY)
	sinZ = sinZ * cosY
	cosZ = cosZ * cosY
	sinZ = sinZ * camhack_speed
	cosZ = cosZ * camhack_speed
	sinY = sinY * camhack_speed
	posX = posX + sinZ
	posY = posY + cosZ
	posZ = posZ + sinY
	setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_left()
	curZ = angZ - 90.0
	radZ = math.rad(curZ)
	radY = math.rad(angY)
	sinZ = math.sin(radZ)
	cosZ = math.cos(radZ)
	sinZ = sinZ * camhack_speed
	cosZ = cosZ * camhack_speed
	posX = posX + sinZ
	posY = posY + cosZ
	setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_right()
	curZ = angZ + 90.0
	radZ = math.rad(curZ)
	radY = math.rad(angY)
	sinZ = math.sin(radZ)
	cosZ = math.cos(radZ)
	sinZ = sinZ * camhack_speed
	cosZ = cosZ * camhack_speed
	posX = posX + sinZ
	posY = posY + cosZ
	setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_up()
	posZ = posZ + camhack_speed
	setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_down()
	posZ = posZ - camhack_speed
	setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_left_foward()
    curZ = angZ - 45.0  
    radZ = math.rad(curZ)
    radY = math.rad(angY)
    sinZ = math.sin(radZ)
    cosZ = math.cos(radZ)
    sinY = math.sin(radY)
    cosY = math.cos(radY)
    sinZ = sinZ * camhack_speed
    cosZ = cosZ * camhack_speed
    sinY = sinY * camhack_speed
    posX = posX + sinZ
    posY = posY + cosZ
    posZ = posZ + sinY
    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_left_back()
    curZ = angZ - 135.0  
    radZ = math.rad(curZ)
    radY = math.rad(angY)
    sinZ = math.sin(radZ)
    cosZ = math.cos(radZ)
    sinY = math.sin(radY)
    cosY = math.cos(radY)
    sinZ = sinZ * camhack_speed
    cosZ = cosZ * camhack_speed
    sinY = sinY * camhack_speed
    posX = posX + sinZ
    posY = posY + cosZ
    posZ = posZ + sinY
    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_right_foward()
    curZ = angZ + 45.0  
    radZ = math.rad(curZ)
    radY = math.rad(angY)
    sinZ = math.sin(radZ)
    cosZ = math.cos(radZ)
    sinY = math.sin(radY)
    cosY = math.cos(radY)
    sinZ = sinZ * camhack_speed
    cosZ = cosZ * camhack_speed
    sinY = sinY * camhack_speed
    posX = posX + sinZ
    posY = posY + cosZ
    posZ = posZ + sinY
    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_right_back()
    curZ = angZ + 135.0  
    radZ = math.rad(curZ)
    radY = math.rad(angY)
    sinZ = math.sin(radZ)
    cosZ = math.cos(radZ)
    sinY = math.sin(radY)
    cosY = math.cos(radY)
    sinZ = sinZ * camhack_speed
    cosZ = cosZ * camhack_speed
    sinY = sinY * camhack_speed
    posX = posX + sinZ
    posY = posY + cosZ
    posZ = posZ + sinY
    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_left_up()
    curZ = angZ - 45.0  
    radZ = math.rad(curZ)
    radY = math.rad(angY)
    sinZ = math.sin(radZ)
    cosZ = math.cos(radZ)
    sinY = math.sin(radY)
    cosY = math.cos(radY)
    sinZ = sinZ * camhack_speed
    cosZ = cosZ * camhack_speed
    sinY = sinY * camhack_speed
    posX = posX + sinZ
    posY = posY + cosZ
    posZ = posZ + sinY
	posZ = posZ + camhack_speed
    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_left_down()
    curZ = angZ - 135.0  
    radZ = math.rad(curZ)
    radY = math.rad(angY)
    sinZ = math.sin(radZ)
    cosZ = math.cos(radZ)
    sinY = math.sin(radY)
    cosY = math.cos(radY)
    sinZ = sinZ * camhack_speed
    cosZ = cosZ * camhack_speed
    sinY = sinY * camhack_speed
    posX = posX + sinZ
    posY = posY + cosZ
    posZ = posZ + sinY
	posZ = posZ - camhack_speed
    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_right_up()
    curZ = angZ + 45.0  
    radZ = math.rad(curZ)
    radY = math.rad(angY)
    sinZ = math.sin(radZ)
    cosZ = math.cos(radZ)
    sinY = math.sin(radY)
    cosY = math.cos(radY)
    sinZ = sinZ * camhack_speed
    cosZ = cosZ * camhack_speed
    sinY = sinY * camhack_speed
    posX = posX + sinZ
    posY = posY +cosZ
    posZ = posZ + sinY
	posZ = posZ + camhack_speed
    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_right_down()
    curZ = angZ + 135.0  
    radZ = math.rad(curZ)
    radY = math.rad(angY)
    sinZ = math.sin(radZ)
    cosZ = math.cos(radZ)
    sinY = math.sin(radY)
    cosY = math.cos(radY)
    sinZ = sinZ * camhack_speed
    cosZ = cosZ * camhack_speed
    sinY = sinY * camhack_speed
    posX = posX + sinZ
    posY = posY + cosZ
    posZ = posZ + sinY
	posZ = posZ - camhack_speed
    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_speed_plus()
	camhack_speed = camhack_speed + 0.01
	printStringNow("[CamHack V3] Speed: ".. camhack_speed, 1000)
end
function camhack_speed_minus()
	camhack_speed = camhack_speed - 0.01
	if camhack_speed < 0.01 then
		camhack_speed = 0.01
	end
	printStringNow("[CamHack V3] Speed: " .. camhack_speed, 1000)
end
function camhack_enable_hud()
	displayRadar(true)
	displayHud(true)
end
function camhack_disable_hud()
	displayRadar(false)
	displayHud(false)
end
function camhack_angle_left() 
    local angle = 1 + camhack_speed / 10 
    angZ = (angZ - angle) % 360.0
    setFixedCameraPosition(posX, posY, posZ, 0.0, angY, angZ)
end
function camhack_angle_right()
    local angle = 1 + camhack_speed / 10
    angZ = (angZ + angle) % 360.0
    setFixedCameraPosition(posX, posY, posZ, 0.0, angY, angZ)
end
function handleJoystick(x, y)
    normalizedX = x / 127.0
    normalizedY = y / 127.0

    if normalizedX > 0.5 then
        if normalizedY > 0.5 then
            camhack_right_back()
        elseif normalizedY < -0.5 then
            camhack_right_foward()
            camhack_update()
        else
            camhack_right()
            camhack_update()
        end
    elseif normalizedX < -0.5 then
        if normalizedY > 0.5 then
            camhack_left_back()
        elseif normalizedY < -0.5 then
            camhack_left_foward()
            camhack_update()
        else
            camhack_left()
            camhack_update()
        end
    else
        if normalizedY > 0.5 then
			camhack_back()
			camhack_update() 
        elseif normalizedY < -0.5 then
            camhack_foward()
            camhack_update()
        end
    end
end
function openLink(link)
	if isMonetLoader() then
		gta._Z12AND_OpenLinkPKc(link)
	else
		os.execute("explorer " .. link)
	end
end
if not isMonetLoader() then
	function hidenicks(status) -- func hide nicks (FR)
		if pStSet and NTdist and NTwalls then
			if status == 1 then
				mem.setfloat(pStSet + 39, 0.00001)
				mem.setint8(pStSet + 47, 0)
				mem.setint8(pStSet + 56, 1)
			else
				local pStSet = sampGetServerSettingsPtr();
				mem.setfloat(pStSet + 39, NTdist)
				mem.setint8(pStSet + 47, NTwalls)
			end
		else
			sampAddChatMessage('{ff0000}[CamHack V3] {ffffff}Не удалось переключить видимость ников, скорее всего вы не заспавнились!',-1)
		end
	end
end

require "samp.events".onSendAimSync = function () if camhack_active then return false end end
require "samp.events".onPlayerChatBubble = function(player_id, color, distance, duration, message)
	if camhack_active and settings.general.chat_bubble then
	  	return {player_id, color, 9999, duration, message}
	end
end
require "samp.events".onSendSpawn = function()
	if not isMonetLoader() then
		pStSet = sampGetServerSettingsPtr()
		NTdist = mem.getfloat(pStSet + 39)
		NTwalls = mem.getint8(pStSet + 47)
		NTshow = mem.getint8(pStSet + 56)
	end
end

imgui.OnInitialize(function()
	imgui.GetIO().IniFilename = nil
	fa.Init(14 * MONET_DPI_SCALE)
	apply_dark_theme()
end)

local MainWindow = imgui.OnFrame(
    function() return MainWindow[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(300 * MONET_DPI_SCALE, 386	* MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.CAMERA.." CamHack V3 by MTG MODS##main_window", MainWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize )
		imgui.BeginChild('##1', imgui.ImVec2(289 * MONET_DPI_SCALE, 352 * MONET_DPI_SCALE), true)
		imgui.CenterText(fa.GEARS .. u8' Работоспособность:')
		imgui.SameLine()
		if settings.general.enable then
			if imgui.SmallButton(fa.TOGGLE_ON .. '##enable') then
				settings.general.enable = false
				camhack_off()
				CamHackWindow[0] = false
				save_settings()
			end
			if imgui.IsItemHovered() then
				imgui.SetTooltip(u8"Отключить CamHack")
			end
			imgui.CenterTextDisabled(u8'   (работает)')
		else
			if imgui.SmallButton(fa.TOGGLE_OFF .. '##enable') then
				settings.general.enable = true
				save_settings()
			end
			if imgui.IsItemHovered() then
				imgui.SetTooltip(u8"Включить CamHack")
			end
			imgui.CenterTextDisabled(u8'   (не работает)')
		end
		imgui.Separator()
		imgui.CenterText(fa.LIST_CHECK .. u8' Способ управления:')
		if imgui.RadioButtonIntPtr(u8" Mimgui Window [PC + MOBILE]", camhack_type, 0) then	
			camhack_type[0] = 0
			if check() then
				settings.general.camhack_type = camhack_type[0]
				save_settings()
				sampRegisterChatCommand("cam", function()
					if (camhack_active) then
						camhack_off();
					elseif settings.general.enable then
						camhack_on();
						CamHackWindow[0] = true;
					end;
				end);
				if (camhack_active) then
					camhack_off();
				end
			end
		end
		if imgui.RadioButtonIntPtr(u8" Hotkeys [PC]", camhack_type, 1) then	
			camhack_type[0] = 1
			if check() then
				settings.general.camhack_type = camhack_type[0]
				save_settings()
				if (camhack_active) then
					camhack_off();
					CamHackWindow[0] = false
				end
			end
		end
		if camhack_type[0] == 1 then
			imgui.SameLine()
			if imgui.Button(fa.KEYBOARD .. u8' Настройка клавиш') then	
				imgui.OpenPopup(fa.KEYBOARD .. u8' Настройка клавиш')
			end
		end
		if imgui.BeginPopupModal(fa.KEYBOARD .. u8' Настройка клавиш', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  ) then
			imgui.SetWindowSizeVec2(imgui.ImVec2(600 * MONET_DPI_SCALE, 300 * MONET_DPI_SCALE))
			imgui.Text(u8'Активация:')
			imgui.SameLine()
			if ActivateCamHackHotKey:ShowHotKey() then
				settings.binds.activate = encodeJson(ActivateCamHackHotKey:GetHotKey())
				save_settings()
			end
			imgui.SameLine()
			imgui.CenterText(u8'Деактивация:')
			imgui.SameLine()
			if DisableCamHackHotKey:ShowHotKey() then
				settings.binds.disable = encodeJson(DisableCamHackHotKey:GetHotKey())
				save_settings()
			end
			imgui.Separator()
			imgui.Text(u8'Вперёд:')
			imgui.SameLine()
			if CamHackFowardHotKey:ShowHotKey() then
				settings.binds.foward = encodeJson(CamHackFowardHotKey:GetHotKey())
				save_settings()
			end
			imgui.SameLine()
			imgui.CenterText(u8'Назад:')
			imgui.SameLine()
			if CamHackBackHotKey:ShowHotKey() then
				settings.binds.back = encodeJson(CamHackBackHotKey:GetHotKey())
				save_settings()
			end
			imgui.Separator()
			imgui.Text(u8'Налево:')
			imgui.SameLine()
			if CamHackLeftHotKey:ShowHotKey() then
				settings.binds.left = encodeJson(CamHackLeftHotKey:GetHotKey())
				save_settings()
			end
			imgui.SameLine()
			imgui.CenterText(u8'Направо:')
			imgui.SameLine()
			if CamHackRightHotKey:ShowHotKey() then
				settings.binds.right = encodeJson(CamHackRightHotKey:GetHotKey())
				save_settings()
			end
			imgui.Separator()
			imgui.Text(u8'Налево и вперёд:')
			imgui.SameLine()
			if CamHackLeftFowardHotKey:ShowHotKey() then
				settings.binds.left_foward = encodeJson(CamHackLeftFowardHotKey:GetHotKey())
				save_settings()
			end
			imgui.SameLine()
			imgui.CenterText(u8'Направо и вперёд:')
			imgui.SameLine()
			if CamHackRightFowardHotKey:ShowHotKey() then
				settings.binds.right_foward = encodeJson(CamHackRightFowardHotKey:GetHotKey())
				save_settings()
			end
			imgui.Separator()
			imgui.Text(u8'Вверх:')
			imgui.SameLine()
			if CamHackUpHotKey:ShowHotKey() then
				settings.binds.up = encodeJson(CamHackUpHotKey:GetHotKey())
				save_settings()
			end
			imgui.SameLine()
			imgui.CenterText(u8'Вниз:')
			imgui.SameLine()
			if CamHackDownHotKey:ShowHotKey() then
				settings.binds.down = encodeJson(CamHackDownHotKey:GetHotKey())
				save_settings()
			end
			imgui.Separator()
			imgui.Text(u8'Увеличить скросоть:')
			imgui.SameLine()
			if CamHackSpeedPlusHotKey:ShowHotKey() then
				settings.binds.speed_plus = encodeJson(CamHackSpeedPlusHotKey:GetHotKey())
				save_settings()
			end
			imgui.SameLine()
			imgui.CenterText(u8'Уменьшить скорость:')
			imgui.SameLine()
			if CamHackSpeedMinusHotKey:ShowHotKey() then
				settings.binds.speed_minus = encodeJson(CamHackSpeedMinusHotKey:GetHotKey())
				save_settings()
			end
			imgui.Separator()
			imgui.Text(u8'Переключить видимость худа (вкл/выкл):')
			imgui.SameLine()
			if CamHackHudHotKey:ShowHotKey() then
				settings.binds.hud = encodeJson(CamHackHudHotKey:GetHotKey())
				save_settings()
			end
			imgui.Separator()
			if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
				imgui.CloseCurrentPopup()
			end
			imgui.End()
		end
		if imgui.RadioButtonIntPtr(u8" Joystick + Widgets [MOBILE]", camhack_type, 2) then	
			camhack_type[0] = 2
			if check() then
				settings.general.camhack_type = camhack_type[0]
				save_settings()
				sampUnregisterChatCommand('cam')
				if (camhack_active) then
					camhack_off();
					CamHackWindow[0] = false
				end
			end
		end
		-- if imgui.RadioButtonIntPtr(u8" Joystick [Advanced] (есть баг)", camhack_type, 3) then	
		-- 	camhack_type[0] = 3
		-- 	if check() then
		-- 		settings.general.camhack_type = camhack_type[0]
		-- 		save_settings()
		-- 	end
		-- end
		imgui.Separator()
		imgui.CenterText(fa.CIRCLE_INFO .. u8' Инструкция по использованию:')
		if imgui.Button(fa.FILE_LINES .. u8' Посмотреть',  imgui.ImVec2(imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
			imgui.OpenPopup(fa.CIRCLE_INFO .. u8' Инструкция по использованию')
		end
		if imgui.BeginPopupModal(fa.CIRCLE_INFO .. u8' Инструкция по использованию', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize  ) then
			if settings.general.camhack_type == 0 then
				imgui.Text(u8'Активировать/деактивировать CamHack: /cam')
				imgui.Text(u8'Управление: кнопки в Mimgui меню управления')
			elseif settings.general.camhack_type == 1 then
				imgui.Text(u8'Активировать CamHack: ' .. getNameKeysFrom(settings.binds.activate))
				imgui.Text(u8'Деактивировать CamHack: ' .. getNameKeysFrom(settings.binds.disable))
				imgui.Text(u8'Вперёд: ' .. getNameKeysFrom(settings.binds.foward))
				imgui.Text(u8'Назад: ' .. getNameKeysFrom(settings.binds.back))
				imgui.Text(u8'Налево: ' .. getNameKeysFrom(settings.binds.left))
				imgui.Text(u8'Направо: ' .. getNameKeysFrom(settings.binds.right))
				imgui.Text(u8'Налево и вперёд: ' .. getNameKeysFrom(settings.binds.left_foward))
				imgui.Text(u8'Направо и вперёд: ' .. getNameKeysFrom(settings.binds.right_foward))
				imgui.Text(u8'Вверх: ' .. getNameKeysFrom(settings.binds.up))
				imgui.Text(u8'Вниз: ' .. getNameKeysFrom(settings.binds.down))
				imgui.Text(u8'Повысить скорость: ' .. getNameKeysFrom(settings.binds.speed_plus))
				imgui.Text(u8'Понизить скорость: ' .. getNameKeysFrom(settings.binds.speed_minus))
				imgui.Text(u8'Переключить видимость худа: ' .. getNameKeysFrom(settings.binds.hud))
				imgui.Text(u8'')
				imgui.Text(u8'P.S. Эти клавиши можно изменить на другие!')
				imgui.Text(u8'Нажмите "Закрыть" и потом ""Настройка клавиш"')
			elseif settings.general.camhack_type == 2 or settings.general.camhack_type == 3 then
				imgui.Text(u8'Активировать CamHack: виджет камеры (справа)')
				imgui.Text(u8'Управление вперёд/назад/влево/вправо: джойстик')
				imgui.Text(u8'Поднять/опустить камеру: (виджеты стрелочки)')
				imgui.Text(u8'Развернуть камеру: виджеты стрелочки (по бокам)')
				imgui.Text(u8'Изменить скорость: виджеты + и -')
				imgui.Text(u8'Деактивировать CamHack: виджет Х (слева)')
				imgui.Text(u8'')
				imgui.Text(u8'P.S. Можно изменить местоположение виджетов!')
				imgui.Text(u8'Настройки игры - Управление - тип Vehicle')
			end
			if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
				imgui.CloseCurrentPopup()
			end
			imgui.End()
		end
		imgui.Separator()
		imgui.CenterText(fa.EYE .. u8' Дополнительные функции:')
		if imgui.Button(fa.SLIDERS .. u8' Настроить',  imgui.ImVec2(imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
			imgui.OpenPopup(fa.EYE .. u8' Дополнительные функции')
		end
		if imgui.BeginPopupModal(fa.EYE .. u8' Дополнительные функции', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
			if not isMonetLoader() then
				imgui.CenterText(fa.ID_CARD ..  u8' Отображение ников в режиме камеры:')
				imgui.SameLine()
				if not settings.general.hide_nick then
					if imgui.SmallButton(fa.TOGGLE_ON .. '##nick') then
						settings.general.hide_nick = true
						save_settings()
					end
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8"Отключить отображение ников")
					end
					imgui.CenterTextDisabled(u8'(видны только те ники, на которые вы навелись)')
				else
					if imgui.SmallButton(fa.TOGGLE_OFF .. '##nick') then
						settings.general.hide_nick = false
						save_settings()
						hidenicks(0)
					end
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8"Включить отображение ников")
					end
					imgui.CenterTextDisabled(u8'(будут видны только те ники, на которые вы наведетесь)')
				end
				imgui.Separator()
			end
			imgui.CenterText(fa.MESSAGE ..  u8' Отображение текста над головой в режиме камеры:')
			imgui.SameLine()
			if settings.general.chat_bubble then
				if imgui.SmallButton(fa.TOGGLE_ON .. '##buble') then
					settings.general.chat_bubble = false
					save_settings()
				end
				if imgui.IsItemHovered() then
					imgui.SetTooltip(u8"Отключить отображение текста над головой")
				end
				imgui.CenterTextDisabled(u8'(видны действия игроков на которых вы навелись)')
			else
				if imgui.SmallButton(fa.TOGGLE_OFF .. '##buble') then
					settings.general.chat_bubble = true
					save_settings()
				end
				if imgui.IsItemHovered() then
					imgui.SetTooltip(u8"Включить отображение текста над головой")
				end
				imgui.CenterTextDisabled(u8'(будут видны действия игроков на которых вы навелись)')
			end
			imgui.Separator()
			imgui.CenterText(fa.TRIANGLE_EXCLAMATION ..  u8' ВНИМАНИЕ ' .. fa.TRIANGLE_EXCLAMATION)
			imgui.CenterText(u8'Данные функции являються разрешеными, но:')
			imgui.CenterText(u8'Злоупотребление ради получения преимущества грозит баном!')
			imgui.CenterText(u8'Перед включением обязательно изучите правила сервера!')
			imgui.Separator()
			if imgui.Button(fa.CIRCLE_XMARK .. u8' Закрыть', imgui.ImVec2(400 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
				imgui.CloseCurrentPopup()
			end
			imgui.End()
		end
		imgui.Separator()
		imgui.CenterText(fa.HEADSET .. u8' Связь с MTG MODS и поддержка:')
		if imgui.Button(fa.GLOBE .. u8' Discord',  imgui.ImVec2(imgui.GetMiddleButtonX(2), 25 * MONET_DPI_SCALE)) then
			openLink('https://discord.com/invite/qBPEYjfNhv')
		end
		imgui.SameLine()

		if imgui.Button(fa.GLOBE .. u8' Telegram', imgui.ImVec2(imgui.GetMiddleButtonX(2), 25 * MONET_DPI_SCALE)) then
			openLink('https://t.me/mtgmods')
		end
		imgui.Separator()
		if imgui.Button(fa.GLOBE .. u8' Тема скрипта на BlastHack', imgui.ImVec2(imgui.GetMiddleButtonX(1), 25 * MONET_DPI_SCALE)) then
			openLink('https://www.blast.hk/threads/175690')
		end
		imgui.EndChild()
		imgui.End()
    end
)

local CamHackWindow = imgui.OnFrame(
    function() return CamHackWindow[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 5, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		--imgui.SetNextWindowSize(imgui.ImVec2(480 * MONET_DPI_SCALE, 130	* MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.CAMERA.." CamHack V3 by MTG MODS##camhack", CamHack, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		if imgui.BeginChild('##1', imgui.ImVec2(150 * MONET_DPI_SCALE, 120 * MONET_DPI_SCALE), true) then
			imgui.CenterText('Main Camera')
			imgui.Separator()
			if imgui.Button('##1',imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_left_foward()
			end
			if imgui.IsItemActive() then
				camhack_left_foward()
			end
			imgui.SameLine()
			if imgui.Button(fa.CIRCLE_UP,imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_foward()
			end
			if imgui.IsItemActive() then
				camhack_foward()
			end
			imgui.SameLine()
			if imgui.Button('##2',imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_right_foward()
			end
			if imgui.IsItemActive() then
				camhack_right_foward()
			end
			if imgui.Button(fa.CIRCLE_LEFT,imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_left()
			end
			if imgui.IsItemActive() then
				camhack_left()
			end
			imgui.SameLine()
			if imgui.Button(fa.UP_DOWN_LEFT_RIGHT,imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_on()
			end
			imgui.SameLine()
			if imgui.Button(fa.CIRCLE_RIGHT,imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_right()
			end
			if imgui.IsItemActive() then
				camhack_right()
			end
			if imgui.Button('##4',imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_left_back()
			end
			if imgui.IsItemActive() then
				camhack_left_back()
			end
			imgui.SameLine()
			if imgui.Button(fa.CIRCLE_DOWN,imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_back()
			end
			if imgui.IsItemActive() then
				camhack_back()
			end
			imgui.SameLine()
			if imgui.Button('##5',imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_right_back()
			end
			if imgui.IsItemActive() then
				camhack_right_back()
			end
			imgui.EndChild()
		end
		imgui.SameLine()
		if imgui.BeginChild('##2', imgui.ImVec2(150 * MONET_DPI_SCALE, 120 * MONET_DPI_SCALE), true) then
			imgui.CenterText('Height & Angle')
			imgui.Separator()
			if imgui.Button('##11',imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_angle_left()
				camhack_up()
			end
			if imgui.IsItemActive() then
				camhack_angle_left()
				camhack_up()
			end
			imgui.SameLine()
			if imgui.Button(fa.CIRCLE_UP .. '##22',imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_up()
			end
			if imgui.IsItemActive() then
				camhack_up()
			end
			imgui.SameLine()
			if imgui.Button('##22',imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_angle_right()
				camhack_up()
			end
			if imgui.IsItemActive() then
				camhack_angle_right()
				camhack_up()
			end
			if imgui.Button(fa.CIRCLE_LEFT .. '##22',imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_angle_left()
			end
			if imgui.IsItemActive() then
				camhack_angle_left()
			end
			imgui.SameLine()
			if imgui.Button('##33',imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				
			end
			imgui.SameLine()
			if imgui.Button(fa.CIRCLE_RIGHT .. '##22',imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_angle_right()
			end
			if imgui.IsItemActive() then
				camhack_angle_right()
			end
			if imgui.Button('##44',imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_angle_left()
				camhack_down()	
			end
			if imgui.IsItemActive() then
				camhack_angle_left()
				camhack_down()	
			end
			imgui.SameLine()
			if imgui.Button(fa.CIRCLE_DOWN .. '##22',imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_down()
			end
			if imgui.IsItemActive() then
				camhack_down()
			end
			imgui.SameLine()
			if imgui.Button('##55',imgui.ImVec2(imgui.GetMiddleButtonX(3), 0)) then	
				camhack_angle_right()
				camhack_down()	
			end
			if imgui.IsItemActive() then
				camhack_angle_right()
				camhack_down()	
			end
			imgui.EndChild()
		end
		imgui.SameLine()
		if imgui.BeginChild('##3', imgui.ImVec2(55 * MONET_DPI_SCALE, 120 * MONET_DPI_SCALE), true) then
			imgui.CenterText('Speed')
			imgui.Separator()
			if imgui.Button(fa.CIRCLE_PLUS, imgui.ImVec2(imgui.GetMiddleButtonX(1), 0)) then	
				camhack_speed_plus()
			end
			if imgui.IsItemActive() then
				camhack_speed_plus()
			end
			if imgui.Button('##77', imgui.ImVec2(imgui.GetMiddleButtonX(1), 0)) then	
				
			end
			if imgui.Button(fa.CIRCLE_MINUS, imgui.ImVec2(imgui.GetMiddleButtonX(1), 0)) then	
				camhack_speed_minus()
			end
			if imgui.IsItemActive() then
				camhack_speed_minus()
			end
			imgui.EndChild()
		end
		imgui.SameLine()
		if imgui.BeginChild('##4', imgui.ImVec2(55 * MONET_DPI_SCALE, 120 * MONET_DPI_SCALE), true) then
			imgui.CenterText('Other')
			imgui.Separator()
			if imgui.Button(fa.LAYER_GROUP, imgui.ImVec2(imgui.GetMiddleButtonX(1), 0)) then	
				settings.general.hud = not settings.general.hud
				save_settings()
			end
			if imgui.Button('##88', imgui.ImVec2(imgui.GetMiddleButtonX(1), 0)) then	
				
			end
			if imgui.Button(fa.POWER_OFF,imgui.ImVec2(imgui.GetMiddleButtonX(1), 0)) then	
				camhack_off()
				CamHackWindow[0] = false
			end
			imgui.EndChild()
		end
		imgui.End()
    end
)

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end
function imgui.CenterTextDisabled(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.TextDisabled(text)
end
function imgui.CenterColumnText(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end
function imgui.CenterColumnTextDisabled(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.TextDisabled(text)
end
function imgui.CenterColumnSmallButton(text)
	if text:find('(.+)##(.+)') then
		local text1, text2 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
    if imgui.SmallButton(text) then
		return true
	else
		return false
	end
end
function imgui.GetMiddleButtonX(count)
    local width = imgui.GetWindowContentRegionWidth() -- ширины контекста окно
    local space = imgui.GetStyle().ItemSpacing.x
    return count == 1 and width or width/count - ((space * (count-1)) / count) -- вернется средние ширины по количеству
end
function apply_dark_theme()
	imgui.SwitchContext()
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2 * MONET_DPI_SCALE, 2 * MONET_DPI_SCALE)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().GrabMinSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().WindowBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().ChildBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().PopupBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().FrameBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().TabBorderSize = 1 * MONET_DPI_SCALE
	imgui.GetStyle().WindowRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ChildRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().FrameRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().PopupRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ScrollbarRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().GrabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().TabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.12, 0.12, 0.12, 0.95)
end

function onScriptTerminate(script, quit) 
	if script == thisScript() and not quit then
		if camhack_active then camhack_off() end
		if camhack_active and not isMonetLoader() then hidenicks(0) end
	end
end
