--label.call("Beta tester","This version may still contain some bug´s. "..os.language(),__LABEL_QUESTION)
-- Disable LockScreen
--[[__SHELL_LOCK_SCR = false
local tf = sdk.newTextField()
tf:setw(120)
tf:seth(15)
tf:xy(240-60,136+65)
local y_lock_scr = 0
local up_lock_scr = false]]
function nucleus_main()
	amg.init() -- quiero que el shell soporte 3D :D
	while true do -- Bucle principal
		amg.begin() --dibuja 3d si lo hay
		amg.mode2d(1)-- Apartir de aqui todo es 2D a menos que se indique lo contrario
		-- ## Funciones de Controles ##
		buttons.read() -- Leemos pulsaciones
		-- si se mueven los controles basicos entonces pues se movio algo xD
		if buttons.up or buttons.down or buttons.left or buttons.right or buttons.cross or buttons.circle or buttons.triangle or cursor.activity() then tiempo:reset() tiempo:start() power.tick() end
		cursor.controls() -- Comprobamos Movimientos del cursor
		-- Disable LockScreen
		--[[if __SHELL_LOCK_SCR then
			desk.drawback()
			draw.fillrect(5,5,470,262,color.shadow)
			screen.print(10,10,"LockScreen ! :(")
			desk.power:blit(443,5)
		if cursor.isOver(443,5,32,32) then
			draw.fillrect(443,5,32,32,desk.brillo)
			draw.rect(443,5,32,32,color.new(255,255,255))
			if buttons.cross then
				power.menu()
			end
		end
		if up_lock_scr then
		y_lock_scr += 0.1
		else
		y_lock_scr -= 0.1
		end
		if y_lock_scr > 10 and up_lock_scr then
			--y_lock_scr = 0
			up_lock_scr = false
		elseif y_lock_scr < -10 and not up_lock_scr then
			--y_lock_scr = 0
		up_lock_scr = true
		end
			menu_start.avatar:blit(240-50,136-50-y_lock_scr)
			tf:draw()
			
			if tf:txt() == __SHELL_PASS then
				__SHELL_LOCK_SCR = false
			end
		else
		end
		]]
		desk.run() -- Ejecuta el desk (Barra, Menu, Pestañas, gadgets, apps)
		POPUP.draw() -- Funciones del menu POPUP
		cursor.draw() -- Funciones del Cursor
		--screen.print(50,2,"fps:"..screen.fps(),0.6,color.white,color.black) -- Debug
		if buttons.note then takeshot("OneShell") end -- Si presionan la tecla note, toma una captura! :D
		--[[if tiempo:time() > 180000 then
			kernel.suspend()
			tiempo:reset() tiempo:start()
			--os.message("suspend")
		end]]
		amg.mode2d(0) -- Finalizamos el modo 2D
		if tiempo:time() > 60000 then -- un minuto segun.
			screen.saver()
		end
		--[[if tiempo:time() > 120000 and not __SHELL_LOCK_SCR then
			__SHELL_LOCK_SCR = true
			--tiempo:reset() tiempo:start()
		end]]
		amg.update() -- Actualizamos el buffer 3D
		screen.flip()-- Mostramos el Buff Total.
		ram_mgr.run() -- Ejecutamos el manager de ram...
	end
end
