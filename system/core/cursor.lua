--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Modulo:	Cursor Manager
	Descripcion: Gestor del Cursor "Mouse"
]]

cursor = {
	img = kernel.loadimage("system/theme/cursor.png",30,30),
	ani_frame = kernel.loadimage("system/theme/cursor_anims.png",20,20),
	x = 480/2, -- Punto X
	y = 272/2, -- Punto Y
	a = 255, -- Alfa Blit
	despX = 0, -- Motion X
	despY = 0, -- Motion Y
	state = true, -- State Enable/Disable (Draw)
	holding = false, -- Hold Disable/Enable (Motion)
	moved = false, -- Hay Movimiento (true/false)
	type = 0, -- Modo actual del cursor
	anim = false,
	ani_pos = 0,
	modes = {normal = 0, select = 1, text = 2, option = 3}, -- Posibles modos del cursor
	lockkey = 0, -- Key of lock over state
	deadZone = 40, -- Zona que no sera tomada en cuenta del analogo
	sens = 5, -- Sensibilidad del analogo
	acelerator = 0, -- Acelerador .4 cada ciclo que siga en movimiento o 0
	-- Funciones para restrict y limit
	isLimit = false,
	Xlimit = 0,
	Ylimit = 0,
	Wlimit = 480,
	Hlimit = 272,
}
function cursor.enable(mode) -- Enable/Disable el cursor.
	cursor.state = mode
	cursor.hold(not mode)
end
function cursor.hold(mode) -- Disable/Enable movimiento del cursor.
	if mode != nil then
		cursor.holding = mode
	end
	return cursor.holding
end
function cursor.lock(key) -- Set Lock Key for Over State :P
	cursor.lockkey = key
end
function cursor.unlock() -- Set Unlock Key for Over State xD :P
	cursor.lockkey = 0 -- default
end
function cursor.set(t) -- Setea el modo o tipo del cursor.
	cursor.type = cursor.modes[t]
end
function cursor.xy(x,y) -- Retorna la ubicacion del cursor.
	if x and y then
		cursor.x,cursor.y = x,y
		return nil
	end
	return cursor.x,cursor.y
end
function cursor.motion() -- Retorna el desplazamiento del cursor.
	return cursor.despX,cursor.despY
end
function cursor.activity() -- Retorna si hay actividad (Movimiento) del cursor.
	return cursor.moved
end
function cursor.limit(x,y,w,h) -- Establece o Reestablece el limite del cursor.
	if x and y and w and w then
		cursor.isLimit = true
		cursor.Xlimit = x
		cursor.Ylimit = y
		cursor.Wlimit = x+w
		cursor.Hlimit = y+h
	else
		cursor.isLimit = false
		cursor.Xlimit = 0
		cursor.Ylimit = 0
		cursor.Wlimit = 480
		cursor.Hlimit = 272
	end
end
function cursor.restrict() -- retorna si hay o no restriccion de movimiento
	return cursor.isLimit
end
function cursor.animation(mode) -- retorna si hay o no restriccion de movimiento
	cursor.anim = mode
end
cursor.previusMillis = 0
function cursor.draw()
	if cursor.a > 0 then
		cursor.img:blitsprite(cursor.x,cursor.y,cursor.type,cursor.a)
		if cursor.anim then
			screen.bilinear(1)
			cursor.ani_frame:blitsprite(cursor.x+10,cursor.y,cursor.ani_pos,cursor.a)
			screen.bilinear(0)
			if millis()-cursor.previusMillis >= 25 then
				cursor.ani_pos += 1
				cursor.previusMillis = millis()
			end
			if cursor.ani_pos > 20 then	cursor.ani_pos = 0
			end
		end
	end
	if cursor.state then -- Esta Habilitado el cursor
		if cursor.labmsgopen == false and cursor.labtrans > 0 then cursor.labtrans = cursor.labtrans - 11 end
		cursor.labmsgopen = false
		if cursor.labtrans > 0 then -- revisar bien las areas.
			draw.gradrect(cursor.xscroll-3,cursor.y,50+3,15,color.new(255,255,255,cursor.labtrans),color.new(180,180,180,cursor.labtrans),0)
			draw.rect(cursor.xscroll-3,cursor.y,50+3,15,color.new(128,128,128,cursor.labtrans))
			cursor.labxscr = screen.print(cursor.labxscr,cursor.y,cursor.labtxt,0.6,color.new(128,128,128,cursor.labtrans),0x0,__SLEFT,45)
		end
		if cursor.a < 255 then
			cursor.a += 6
		end
	else
		if cursor.a > 0 then
			cursor.a -= 6
		end
	end
end
cursor.labtxt = ""
cursor.labtrans = 0
cursor.labxscr = 0
cursor.labmsgopen = false
cursor.labstep = 55
function cursor.label(txt)
	cursor.labmsgopen = true
	cursor.xscroll = math.floor(cursor.labxscr)
	--Pendiente Revisar lo de la mantencion del scroll
	--Pista: +(cursor.labxscr-cursor.xscroll)
	if cursor.x < 70 and cursor.xscroll-15 ~= cursor.x then
		cursor.labxscr = cursor.x+15
	elseif cursor.x > 70 and cursor.xscroll+55 ~= cursor.x then
		cursor.labxscr = cursor.x-55
	end
	--if cursor.xscroll + cursor.labstep ~= cursor.x then
		--cursor.labxscr = cursor.x - cursor.labstep
	--end
	cursor.labtrans = cursor.labtrans + 11
	if cursor.labtrans > 255 then cursor.labtrans=255 end
	cursor.labtxt = txt
end

function cursor.controls()
	cursor.moved = false -- set over that cycle
	if not cursor.holding then -- esta activado el cursor?
		local lastX = cursor.x
		local lastY = cursor.y
		if cfg.get("cursor","analog") then-- Esta activado el analogo?
			local isAnalogMove = false
			if math.abs(buttons.analogy) > cursor.deadZone then 
				cursor.y += math.floor((buttons.analogy / 100) * cursor.acelerator)
				isAnalogMove = true
			end
			if math.abs(buttons.analogx) > cursor.deadZone then 
				cursor.x += math.floor((buttons.analogx / 100) * cursor.acelerator)
				isAnalogMove = true
			end
			if isAnalogMove == true then
				cursor.acelerator += 0.40
				if cursor.acelerator > cursor.sens then
					cursor.acelerator = cursor.sens
				end
			else
				cursor.acelerator = 0
			end
		end
	
		local velocity = cfg.get("cursor","velocity")
		
		if buttons.held.up then cursor.y -= velocity
		end
		if buttons.held.down then cursor.y += velocity
		end
		if buttons.held.left then cursor.x -= velocity
		end
		if buttons.held.right then cursor.x += velocity
		end
		
		if cfg.get("sio","mouse_ps2") and not __SHELL_IS_VITA then -- Habilitado el Uso de mouse como cursor y no es VITA.
			check_Mouse()
		end
		
		--Ajuste de limites.
		if cursor.y < cursor.Ylimit then cursor.y = cursor.Ylimit 
		elseif cursor.y > cursor.Hlimit then cursor.y = cursor.Hlimit
		end
		if cursor.x < cursor.Xlimit then cursor.x = cursor.Xlimit 
		elseif cursor.x > cursor.Wlimit then cursor.x = cursor.Wlimit
		end
		
		-- Desplazamiento en este ciclo..
		cursor.despX = cursor.x - lastX
		cursor.despY = cursor.y - lastY
		
		if cursor.despX != 0 or cursor.despY != 0 then -- Hubo movimiento :P
			cursor.moved = true
		end
	end
end

local fist_press_bl = false
local fist_press_br = false
local fist_press_bc = false
function check_Mouse()
	sio.write(52) -- Get Data Device
	if sio.available() > 0 then -- Stuff recv over port!
		local ch = sio.read()
		if ch == 64 then -- Oww Yeah its the device!
			ch = sio.read()
			
			if ch == -1 then return end
			local dxtemp = (ch - 128)
			ch = sio.read()
			if ch == -1 then return end
			local dytemp = (ch - 128) * -1
			
			cursor.x += dxtemp
			cursor.y += dytemp
			if dxtemp != 0 then
				cursor.despX = dxtemp
			end
			if dytemp != 0 then
				cursor.despY = dytemp
			end
			
			ch = sio.read()
			if ch == -1 then return end
			local dztemp = (ch - 128) * -1
			
			if dztemp > 0 then
				buttons.l = true
				buttons.held.l = true
			elseif dztemp < 0 then
				buttons.r = true
				buttons.held.r = true
			end
			
			ch = sio.read()
			if ch == -1 then return end
			if ch == 1 then
				buttons.held.cross = true
			end
			if ch == 1 and fist_press_bl == false then
				 fist_press_bl = true
				 buttons.cross = true
			elseif ch == 0 and fist_press_bl == true then
				fist_press_bl = false
				buttons.released.cross = true   
				--bl = unpress
			end
			ch = sio.read()
			if ch == -1 then return end
			if ch == 1 then
				buttons.held.triangle = true
			end
			if ch == 1 and fist_press_br == false then
				 fist_press_br = true
				 buttons.triangle = true
			elseif ch == 0 and fist_press_br == true then
				fist_press_br = false
				buttons.released.triangle = true   
				--bl = unpress
			end
			ch = sio.read()
			if ch == -1 then return end
			if ch == 1 then
				buttons.held.home = true
			end
			if ch == 1 and fist_press_bc == false then
				 fist_press_bc = true
				 buttons.home = true
			elseif ch == 0 and fist_press_bc == true then
				fist_press_bc = false
				buttons.released.home = true   
				--bl = unpress
			end
			
			--[[if ch == 1 then
				bc = press
			else
				bc = unpress
			end]]
			
		end
	end
end

function cursor.isOver(x,y,w,h,unlockkey) -- return true si el cursor esta sobre el objeto
	if cursor.lockkey ~= 0 and unlockkey ~= true then
		if cursor.lockkey ~= unlockkey or unlockkey == nil then
			return false
		end
	end
	if cursor.x < x then return false end
	if cursor.x > x + w then return false end
	if cursor.y < y then return false end
	if cursor.y > y + h then return false end
	return true
end