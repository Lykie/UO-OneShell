driver = {}
function driver.run_low()
	if __FILES_THREAD_STATE != 0 and __NET_THREAD_STATE != 0 then
	draw.line(240,247,240,272,desk.linecolor)
	elseif __FILES_THREAD_STATE != 0 or __NET_THREAD_STATE != 0 then
	draw.line(265,247,265,272,desk.linecolor)
	elseif 	__FILES_THREAD_STATE == 0 and __NET_THREAD_STATE == 0 then
	draw.line(285,247,285,272,desk.linecolor)
	end
	driver.usb_ftp.run()
	driver.music.run()
	driver.batt.run()
	driver.wifi.run()
	driver.volume.run()
end

function driver.run_high()
	driver.vol_bright.run()
end

driver.volume = {
	icon = kernel.loadimage("system/images/desktop/audio.png",18,18)
}
function driver.volume.run()
	if hw.getmute() == 1 then
		driver.volume.icon:blitsprite(369,250,0)
	else
		local level = hw.volume()
		local frame = 0
		if level > 0 and level <= 10 then
			frame = 1
		elseif level >= 10 and level <= 20 then
			frame = 2
		elseif level >= 20 and level <= 30 then
			frame = 3
		end
		driver.volume.icon:blitsprite(369,250,frame)
	end

	if cursor.isOver(369,250,18,18) then
		cursor.label("Volume: ".. (hw.volume()*100/30) .."%")
		if buttons.menu then
			local opciones = {
				{txt = "Volume 0%", action = hw.volume, args = 0, state = true, overClose = true},
				{txt = "Volume 24%", action = hw.volume, args = 7, state = true, overClose = true},
				{txt = "Volume 50%", action = hw.volume, args = 15, state = true, overClose = true},
				{txt = "Volume 77%", action = hw.volume, args = 23, state = true, overClose = true},
				{txt = "Volume 100%", action = hw.volume, args = 30, state = true, overClose = true},
			}
			POPUP.setElements(opciones)
			POPUP.activate()
		end
	end
end
driver.wifi = {
	icon = kernel.loadimage("system/images/desktop/wifi.png",22,22),
	label = false
}
function driver.wifi.run()
	if wlan.isconnected() then
		if not driver.wifi.label then
			if __SHELL_IS_VITA and not __SHELL_CFW_TNV then
				label.call("Network","Connecting to access point...",__LABEL_INFO)
			else
				label.call("Network","Connected to access point "..wlan.over()..".",__LABEL_INFO)
			end
			driver.wifi.label = true
		end
		local frame = wlan.strength()
		driver.wifi.icon:blitsprite(347,248,math.ceil(frame/25))
	else
		if driver.wifi.label then
			driver.wifi.label = false
		end
		driver.wifi.icon:blitsprite(347,248,0)
	end

	if cursor.isOver(347,248,22,22) then
		if buttons.menu then
			local opciones = {}
			
			if ((__SHELL_CFW_TNV  and __SHELL_IS_VITA) or not __SHELL_IS_VITA) then
				table.insert(opciones,{txt = "Enable WiFi", action = function(a) wlan.autoconnect(a[1],a[2]) end, args = {1,30}, state = true, overClose = true})
				if wlan.autostatus() then
					opciones[1].txt = "Disable WiFi"
					opciones[1].args = {0,30}
					wlan.disconnect()
				end
			else
				table.insert(opciones,{txt = "Connected to WiFi", action = wlan.connect, args = nil, state = true, overClose = true})
				if wlan.isconnected() then
					opciones[1].txt = "Disconnected from WiFi"
					opciones[1].action = wlan.disconnect
				end
			end
			POPUP.setElements(opciones)
			POPUP.activate()
		end
		if ((__SHELL_CFW_TNV  and __SHELL_IS_VITA) or not __SHELL_IS_VITA) then
			if wlan.isconnected() then
				cursor.label("Access Point: "..wlan.over().." ".. wlan.strength() .."%")
			elseif wlan.autostatus() then
				cursor.label("Searching...")
			else
				cursor.label("No Signal")
			end
		else
			if wlan.isconnected() then
				cursor.label("Signal Strength: "..wlan.strength() .."%")
			else
				cursor.label("No Signal")
			end
		end
	end
end
driver.batt = {
	icon = kernel.loadimage("system/images/desktop/battery.png"),
	is_charging = false,
	is_low = false,
	audio_alert = nil
}
function driver.batt.run()
	driver.batt.icon:blit(334,252)
	local txt = "Battery: "
	local porcentbatt = 0
	local fullbatt = 0
	if batt.exists() then
		porcentbatt = batt.lifepercent()
		fullbatt = porcentbatt / 10
		txt = txt..porcentbatt.."%"
	else
		txt = txt.."Removed"
	end
	if not levelofbatt then levelofbatt = 0 end
	if levelofbatt < fullbatt-0.1 then
		levelofbatt = levelofbatt + 0.1
	elseif levelofbatt > fullbatt then
		levelofbatt = levelofbatt - 0.1
	end
	draw.fillrect(337,266-levelofbatt,4,levelofbatt,color.white)
	if cursor.isOver(334,252,10,16) then
		cursor.label(txt)
	end
	if batt.low() and not driver.batt.is_low then
		driver.batt.is_low = true
		label.call("Power Manager","Your battery is running low.",__LABEL_ALERT)
		driver.batt.audio_alert = sound.load("system/sound/batt_more_low.wav")
		driver.batt.audio_alert:play()
	elseif not batt.low() and driver.batt.is_low then
		driver.batt.is_low = false
	end
	if batt.charging() and not driver.batt.is_charging then
		label.call("Power Manager","Your battery is charging.")
		driver.batt.is_charging = true
	elseif not batt.charging() and driver.batt.is_charging then
		driver.batt.is_charging = false
	end
end
-- Music Player Management
driver.music = {
	icon = kernel.loadimage("system/images/desktop/music.png"),
	state = false,
	sound = nil,
	over = 0,
}
if not files.exists("ms0:/MUSIC/") then
	files.mkdir("ms0:/MUSIC/")
end
driver.music.list = files.list("ms0:/MUSIC/")
driver.music.count = #driver.music.list
function driver.music.run()
	driver.music.icon:blit(311,251)
	if cursor.isOver(311,251,18,14) then
		if driver.music.over > 0 then
			cursor.label(driver.music.list[driver.music.over].name)
		else
			cursor.label("Music")
		end
		if buttons.menu then
			local opciones = {
				{txt = "Play", action = function () driver.music.state = true end, args = nil, state = true, overClose = true},
				{txt = "Stop", action = function () end, args = nil, state = true, overClose = true},
				{txt = "Next", action = function () driver.music.sound = nil end, args = nil, state = true, overClose = true},
				{txt = "Prev", action = function () end, args = nil, state = true, overClose = true},
			}
			POPUP.setElements(opciones)
			POPUP.activate()
		end
	end
	if driver.music.count > 0 and driver.music.state then
		if driver.music.sound then
			if driver.music.sound:endstream() then
				driver.music.over += 1
				if driver.music.over > driver.music.count then
					driver.music.over = driver.music.count
				end
				driver.music.sound = sound.load(driver.music.list[driver.music.over].path)
				if driver.music.sound then driver.music.sound:play(1) end
			end
		else
			driver.music.over += 1
			if driver.music.over > driver.music.count then
				driver.music.over = driver.music.count
			else
				driver.music.sound = sound.load(driver.music.list[driver.music.over].path)
				if driver.music.sound then driver.music.sound:play(1) end
			end
		end
	end
end
-- USB & FTP Management
driver.usb_ftp = {
	icon = kernel.loadimage("system/images/desktop/usb.png"),
	isOnFTP = false,
}
function driver.usb_ftp.run()
	if ftp.state() and not driver.usb_ftp.isOnFTP and wlan.isconnected() then
		driver.usb_ftp.isOnFTP = true
		label.call("FTP Server","ftp://"..wlan.getip())
	elseif not ftp.state() and driver.usb_ftp.isOnFTP then
		driver.usb_ftp.isOnFTP = false
	end
	if usb.isactive() then
		if usb.isconnected() then
			draw.fillrect(290,254,14,8,color.new(0,156,255))
		else
			draw.fillrect(290,254,14,8,color.new(10,156,10))
		end
	else
		draw.fillrect(290,254,14,8,color.orange)
	end
	driver.usb_ftp.icon:blit(288,253)
	if cursor.isOver(288,253,18,14) then
		cursor.label("File Access")
		if buttons.menu then
			local opciones = {
				{txt = "Enable USB", action = usb.mstick, args = nil, state = true, overClose = true},
				{txt = "Enable FTP", action = ftp.init, args = nil, state = true, overClose = true},
			}
			if usb.isactive() then
				opciones[1].txt = "Disable USB"
				opciones[1].action = usb.stop
			end
			opciones[2].state = wlan.isconnected()
			if ftp.state() then
				opciones[2].txt = "Disable FTP"
				opciones[2].action = ftp.term
			end
			POPUP.setElements(opciones)
			POPUP.activate()
		end
	end
end
-- Volume and Brightness Management
driver.vol_bright = {
	ico_bright = kernel.loadimage("system/images/desktop/brightness.png"), 
	ico_vol = kernel.loadimage("system/images/desktop/volume.png"),
	alfa = 0,
	mode = 0,	
}
function driver.vol_bright.run()
	if buttons.held.screen or buttons.held.volup or buttons.held.voldown then
		driver.vol_bright.alfa = 255
		if buttons.held.screen then
			driver.vol_bright.mode = 2
		else
			driver.vol_bright.mode = 1
		end
	end
	if driver.vol_bright.alfa > 0 then
		draw.fillrect(190-25,10,150,50,color.shadow:a(driver.vol_bright.alfa-155))
		draw.rect(190-25,10,150,50,color.white:a(driver.vol_bright.alfa))
		if driver.vol_bright.mode == 1 then
			driver.vol_bright.ico_vol:blit(195-25,15,driver.vol_bright.alfa)
			screen.print(190-25+50+(95/2),15+5,math.ceil(hw.volume()*100/30) .."%",0.7,color.white:a(driver.vol_bright.alfa),0x0,512)
			draw.fillrect(190-25+50,30+10,math.ceil(hw.volume()*95/30),5,color.green:a(driver.vol_bright.alfa))
			draw.rect(190-25+50,30+10,95,5,color.gray:a(driver.vol_bright.alfa))
		else
			driver.vol_bright.ico_bright:blit(195-25,15,driver.vol_bright.alfa)
			screen.print(190-25+50+(95/2),15+5,screen.brightness() .."%",0.7,color.white:a(driver.vol_bright.alfa),0x0,512)
			draw.fillrect(190-25+50,30+10,math.ceil(((screen.brightness()-36)*95/32)),5,color.green:a(driver.vol_bright.alfa))
			draw.rect(190-25+50,30+10,95,5,color.gray:a(driver.vol_bright.alfa))
		end
		driver.vol_bright.alfa -= 3
	end
end
