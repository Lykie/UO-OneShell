--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
		http://creativecommons.org/licenses/by-sa/4.0/
	Version: 
		0.6.0 BETA
	Descripcion:
		Modulo de Gestor de Escritorio, todo lo relacionado con la manipulacion.
	Pendiente:
	Acomodar bien las funciones, 
	Realizado: 	añadir el sdk de los accesos directos y su manipulacion ademas de optimizar nombre de variables :D
				Añadido soporte para swap btt accept y swap menu
	]]
	
desk = {} -- modulo desk o escritorio.
desk.apps = {} -- registro de apps abiertas segun el desk.
desk.open = 0
desk.state = 1 -- estado del desk.
desk.imenu = kernel.loadimage("system/theme/desk/menu.png") -- boton de inicio o menu.
desk.power = kernel.loadimage("system/theme/desk/power.png") -- boton de inicio o menu.

desk.unrar = kernel.loadimage("system/theme/desk/unpack.png")


--desk.ac = kernel.loadimage("system/theme/desk/adapter.png")



--desk.ftp = kernel.loadimage("system/theme/desk/ftp.png")
--desk.ftp:resize(18,18)

__DEFBACKPATH = "system/theme/back_00.png"
local rootto = __DEFBACKPATH
	if files.exists(cfg.get("theme","backpath")) then
		rootto = cfg.get("theme","backpath")
	end
desk.background = kernel.loadimage(rootto) -- realmente quiero que siga buscando un fondo.
-- ## Colores ##
desk.brillo = color.shine
desk.barcolor = color.new(44,86,129,100)--color.new(53,68,84,100)--color.shadow--
desk.linecolor = color.gray
-- ## Constantes ##
__DESKOVERAPP = 3 -- Estamos viendo un app
__DESKOVERMENU = 2 -- Estamos viendo el menu
__DESKOVERNOTHING = 1 -- Estamos viendo el escritorio

__DESKACCESSAPP = 1 -- Accesso a un app nativo del shell.
__DESKACCESSFILE = 2 -- Accesso a un archivo, abrir con navegador.
__DESKACCESSFOLDER = 3 -- Accesso a una carpeta, abrir con navegador.
__DESKACCESSGAME = 4 -- Accesso a un juego (iso,cso,pbp), ejecutar.


function desk.registerapp(index,icoimg,name) -- registra un app en el escritorio
	local sh = icoimg:getrealh()
	local sw = icoimg:getrealw()
	local deskbicon = image.copy(icoimg)
	deskbicon:resize(20,(sh*20)/sw)
	deskbicon:center()
	
	desk.open = desk.open + 1
	desk.apps[#desk.apps+1] = {index = index,bico = deskbicon,label = name}
	desk.state = __DESKOVERAPP -- set que estamos en una app ahora.
	return #desk.apps
end
--desk.backimg = image.load("back.png")
--desk.user = {name = os.nick(),ico = image.load("user.png"),ws = screen.textwidth(os.nick()),xs = 396 - screen.textwidth(os.nick())}
-- Code implementado improvisadamente para la seleccion multiple, almenos solo mostrar como seria xD
desk.drawsel = false
desk.xsel=0
desk.ysel=0
desk.wsel=0
desk.hsel=0
-- end code
function desk.run() -- funcion de acceso a el desk.
	desk.drawback()
	desk.drawbottombar()-- Cambiada la posicion del la barra (revisar antes estaba despues de los if)
	driver.run_low()
	if desk.state == __DESKOVERMENU then -- Estamos sobre el menu start
		menu_start.run() -- Dibuja el menu inicio
	else -- nada o app
		if desk.state == __DESKOVERNOTHING then -- estamos sobre el desk
			gadget_mgr.run() -- Dibujamos los gadget´s
			if __SHELL_DEBUG then
				desk.debug()
			end
			-- Code implementado improvisadamente para la seleccion multiple, almenos solo mostrar como seria xD
			if buttons.held.accept and desk.drawsel then
				local tx,ty = cursor.motion()
				desk.wsel += tx
				desk.hsel += ty
				draw.fillrect(desk.xsel,desk.ysel,desk.wsel,desk.hsel,color.shine)
				draw.rect(desk.xsel,desk.ysel,desk.wsel,desk.hsel,color.white)
			end
			-- end code
			access_mgr.draw()
			desk.menu()
			-- Code implementado improvisadamente para la seleccion multiple, almenos solo mostrar como seria xD
			if buttons.accept and cursor.isOver(0,0,480,247) and access_mgr.focus == 0 and not desk.drawsel then -- Dibujamos los access
				desk.drawsel = true
				desk.xsel,desk.ysel = cursor.xy()
				desk.wsel,desk.hsel = 0,0
			end
			if buttons.released.accept and desk.drawsel then
				desk.drawsel = false
			end
			-- end code
		elseif desk.state == __DESKOVERAPP then
			app_mgr.run_app() -- ejecuta y dibuja la app, de haber.
		end
	end
	driver.run_high()
	label.run()
end
--if not desk.background then	desk.background = image.load("system/theme/back.png") end
desk.tmpalfa = 0
desk.tmpback = nil
function desk.drawback()
	if desk.background then
		--if desk.state == __DESKOVERAPP then
		--desk.background:blit(0,247,0,247,480,25)
		--else
		desk.background:blit(0,0)
		--end
		--MyWave:blit(4,255)
	end
	if desk.tmpback then
		desk.tmpback:blit(0,0,desk.tmpalfa)
		if desk.tmpalfa < 255 then
			desk.tmpalfa += 11
		else
			desk.tmpalfa = 0
			desk.background = nil
			collectgarbage() -- limpiamos la ram para asegurarnos de la maxima limpieza.
			desk.background = desk.tmpback
			desk.tmpback = nil
			collectgarbage() -- limpiamos la ram para asegurarnos de la maxima limpieza.
		end
	end
end
desk.randombacks = {"system/theme/back_00.png","system/theme/back_01.png","system/theme/back_02.png","system/theme/back_03.png","system/theme/back_04.png","system/theme/back_05.png"}
function desk.setback(root)
	math.randomseed(os.clock())
	desk.tmpback = image.load(desk.randombacks[math.random(1,#desk.randombacks)])
end
--wlan.getfile("http://devonelua.x10.mx/oneinstaller/apps/dgp.zip","ms0:/descarga1luasecondplane.zip",1)

function desk.drawbottombar()
	
	draw.fillrect(0,247,480,25,desk.barcolor) -- Dibuja la barra inferior
	draw.line(0,247,480,247,desk.linecolor) -- Dibuja la linea superior de la barra
	if buttons.home then 
			if desk.state ~= __DESKOVERMENU then
				desk.laststate = desk.state
				desk.state = __DESKOVERMENU
			else
				desk.state = desk.laststate
			end
		end
	-- Dibuja el Icon Menu or menu inicio
	if cursor.isOver(0,247,35,25) then
		draw.fillrect(0,247,35,25,desk.brillo)
		cursor.label(lang.get("menu_start","title","Menu Inicio"))
		if buttons.menu then 
			power.menu()
		end
		if buttons.accept then
			if desk.state ~= __DESKOVERMENU then
				desk.laststate = desk.state
				desk.state = __DESKOVERMENU
			else
				desk.state = desk.laststate
			end
		end
	end
	desk.imenu:blit(5,249)
	--if cursor.isOver(0,247,35,25) then
	desk.imenu:blitadd(5,249,50)
	--end
	draw.line(35,247,35,272,desk.linecolor)
	
	local ejex = 5
	if desk.open > 0 then
		local i=1
		while i<=desk.open do
			--if not desk.apps[i] then i = i + 1 end
			if cursor.isOver(ejex+(i*35),249,25,25) then
				draw.fillrect(ejex+(i*35)-5,247,35,25,desk.brillo)
				if buttons.accept then 
					
					if app_mgr.focus == desk.apps[i].index then
						if desk.state == __DESKOVERNOTHING then
							desk.state = __DESKOVERAPP
						elseif desk.state == __DESKOVERAPP then
							desk.state = __DESKOVERNOTHING
						end
					else
						if desk.state == __DESKOVERNOTHING then
							desk.state = __DESKOVERAPP
						end
					end
					
					app_mgr.focus = desk.apps[i].index 
				end
				if buttons.menu then
					local opciones = {
						{txt = "Close", action = function (index) app_mgr.free(desk.apps[index].index) end, args = i, state = true, overClose = false},
						{txt = "Minimize", action = function () desk.state = __DESKOVERNOTHING end, args = i, state = true, overClose = false},
						}
					if desk.state == __DESKOVERNOTHING or app_mgr.focus != desk.apps[i].index then
						opciones[2].txt = "Maximize"
						opciones[2].action = function (index) app_mgr.focus = desk.apps[index].index; desk.state = __DESKOVERAPP end
					end
					POPUP.setElements(opciones)
					POPUP.activate()
				end
				cursor.label(desk.apps[i].label)
			end
			if desk.apps[i].index == app_mgr.focus then
				draw.fillrect(ejex+(i*35)-5,247,35,25,desk.brillo)
			end
			--desk.apps[i].bico:resize(20,20)
			--desk.apps[i].bico:center()
			desk.apps[i].bico:blit(ejex+(i*35)+12,259)
			--draw.line(ejex+(i*35)+15,247,ejex+(i*35)+15,272,color.red)
			--screen.print(ejex+(i*35)+15,259,desk.apps[i].index,0.7,color.white,color.black,512)
			draw.line(ejex+(i*35)-5+35,247,ejex+(i*35)-5+35,247+25,color.gray)
			i = i + 1
		end
	end
	

	
	--desk.unrar:resize(21,23)
	--desk.unrar:blit(265,248)


	if cursor.isOver(398,247,72,25) then
		cursor.label(os.date('%a, %d %b %R'))
	end
	draw.line(398,247,398,272,desk.linecolor)
	screen.print(434,247,os.date("%I:%M %p"),0.5,color.white,0x0,__ACENTER)--os.getdate():sub(18)
	screen.print(434,257,os.date("%d/%m/%y"),0.5,color.white,0x0,__ACENTER)--os.getdate():sub(4,14)
	draw.line(470,247,470,272,desk.linecolor)
	if cursor.isOver(470,247,10,25) then
		draw.fillrect(470,247,10,25,desk.brillo)
		if buttons.accept then
			if desk.state == __DESKOVERNOTHING and app_mgr.open ~= 0 then
				desk.state = __DESKOVERAPP
			elseif desk.state == __DESKOVERAPP and app_mgr.open ~= 0 then
				desk.state = __DESKOVERNOTHING 
			elseif desk.state == __DESKOVERMENU then
				desk.state = __DESKOVERNOTHING 
			end
		end
	end

end
function desk.drawupperbar()
	draw.fillrect(0,0,480,20,desk.barcolor)
	draw.line(0,20,480,20,desk.linecolor)
end

function desk.menu()
	if cursor.isOver(0,0,480,247) and POPUP.state() == false and buttons.menu then -- Dibujamos los access
		access_mgr.focus = 0
		POPUP.setElements({
		{txt = lang.get("desk_pop","change_wallpaper","Cambiar Fondo"), action = desk.setback, args = nil, state = true, overClose = false},
		{txt = lang.get("desk_pop","change_theme","Personalizar"), action = function () window.theme += 1; if window.theme > 4 then window.theme = 0 end end, args = nil, state = true, overClose = false},
		})
		POPUP.activate()
	end
end

function power.menu()
	local opciones = {
		{txt = "Suspend", action = kernel.suspend, args = nil, state = true, overClose = true},
		{txt = "Restart", action = kernel.restart, args = nil, state = true, overClose = true},
		{txt = "Shutdown", action = kernel.off, args = nil, state = true, overClose = true},
		{txt = "Return to XMB", action = kernel.exit, args = nil, state = true, overClose = true},
	}
	-- Mini Parche para la funcion de lock screen
	if not __SHELL_LOCK_SCR then
		table.insert(opciones,1,{txt = "Lock", action = function () __SHELL_LOCK_SCR = true end, args = nil, state = true, overClose = true})	
	end
	POPUP.setElements(opciones)
	POPUP.activate()
end



function desk.debug()
--if not __SHELL_DEBUG then return false end
local debugtext = "fps:"..screen.fps().." | "..math.round(os.clock()*1000).."\n"--.." | skip:"..screen.skipfps().."\n"
--debugtext = debugtext.."Ram Used:"..math.floor(gadget_mgr.data["id02"].porcent).."%\n"
debugtext = debugtext.."Cursor:\n"
debugtext = debugtext.."X:"..cursor.x.."\n"
debugtext = debugtext.."Y:"..cursor.y.."\n"
debugtext = debugtext.."DX:"..cursor.despX.."\n"
debugtext = debugtext.."DY:"..cursor.despY.."\n"
debugtext = debugtext.."SX:"..desk.xsel.."\n"
debugtext = debugtext.."SY:"..desk.ysel.."\n"
debugtext = debugtext.."SW:"..desk.wsel.."\n"
debugtext = debugtext.."SH:"..desk.hsel.."\n"
debugtext = debugtext.."Ventanas:".."\n"
debugtext = debugtext.."Actual:"..app_mgr.focus.."\n"
debugtext = debugtext.."Abiertas:"..app_mgr.open.."\n"
screen.print(400,100,debugtext,0.6,color.white,0x0,__ARIGHT)
--[[if app_mgr.open > 0 then
	ah = 120
	local i = 1
	while i <= app_mgr.open do 
		if app_mgr.manager[i]["id"] then
			screen.print(5,ah,"id: "..app_mgr.manager[i]["id"].." | index: "..app_mgr.manager[i]["index"])
		end
		ah = ah + 15
		i = i +1
	end
end]]

end
