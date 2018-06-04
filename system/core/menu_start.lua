--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Modulo:	Menu Start "Menu Inicio"
	Descripcion: Gestor de Aplicaciones y funciones del sistema.. al menos mostrarlas...
	Añadido soporte para swap btt accept y swap menu
	Añadido soporte de lenguaje en todos los strings
]]

menu_start = { -- modulo "Menu Inicio"
	data = {},
	leng = 0,
	apps = {},
	default = {
		access = kernel.loadimage("system/images/menu/default40.png"), -- Acceso Icon Default.
		not_exist = kernel.loadimage("system/images/menu/notfound.png"), -- Acceso Icon No found.
		icon0unk = kernel.loadimage("system/images/menu/icon0unk.png"),
	},
}
function menu_start.add(name,id_o_path) -- Añade un acceso al desk (data es una tabla con los campos de un acceso).
	local ext = string.sub(id_o_path,-4,-1):lower()
	--os.message(ext)
	local tmp = {title = name,exists = true} -- contenedor temporal para luego añadir
	-- Comprobamos Exista un App Con el id pasado como 2do arg
	if files.exists(root_to_apps..id_o_path.."/") then -- Es una App del shell "__DESKACCESSAPP"
		local path = root_to_apps..id_o_path.."/icon.png" -- ruta al icono del app
		if files.exists(path) then -- Si existe un icono entonces lo carga.
			tmp.icon = image.load(path)
		else -- De lo contrario carga un icono default
			tmp.icon = menu_start.default.access
		end
		tmp.type = __DESKACCESSAPP
		tmp.id = id_o_path
		
		tmp.icon:center() -- Centramos los iconos.
		table.insert(menu_start.apps,tmp)
	end
end
menu_start.data = ini.load("config/apps.ini")
menu_start.leng = #menu_start.data
for i=1,menu_start.leng do
	menu_start.add(menu_start.data[i].title,menu_start.data[i].id or menu_start.data[i].path)
end
menu_start.leng = #menu_start.apps
if menu_start.leng > 16 then
	menu_start.leng = 16
end
--function menu_start.load()end
function menu_start.save()
end
menu_start.focus = 0
function menu_start.draw_apps()
	local i,len = 1,menu_start.leng
	local x,y,pos,s = 5,5,0,7 -- set
	local w,h = 80,54 -- espacio de seleccion.
	--screen.print(10,10,menu_start.focus)
	local oneover = 0 -- sobre ninguno por default
	while i <= len do -- busqueda de que estemos sobre un acceso y cual?
		if menu_start.focus == i then draw.fillrect(x, y, w, h, color.shine); draw.rect(x, y, w, h, color.white) end
		local overOn = cursor.isOver(x, y, w, h)
		if overOn then -- si estamos sobre uno, Draw contorno
			draw.fillrect(x, y, w, h, color.shine); draw.rect(x, y, w, h, color.white)
			oneover = i -- ok hubo al menos una coincidencia la parseamos a oneover
			--if menu_start.apps[i].type == __DESKACCESSAPP then
				cursor.label("Execute"..': "'.. menu_start.apps[i].title ..'"')
			--end
		end
		if menu_start.apps[i].icon then
			menu_start.apps[i].icon:blit(x+(w/2),y+((h-10)/2))
		end
		
		--[[if overOn then -- efecto scroll sobre el seleccionado
			if math.floor(desk.xscrollaccess) ~= x+(w/2) then
				desk.xscrollaccess = x+(w/2)
			end
			desk.xscrollaccess = screen.print(desk.xscrollaccess,y+h-15,menu_start.apps[i].title,0.6,color.white,color.black,__SSEESAW,40)
		else]]
			--screen.clip(x+5,y+h-15,w-10,h)
			screen.print(x+(w/2),y+h-15,menu_start.apps[i].title,0.6,color.white,color.black,__ACENTER)
			--screen.clip()
		--end

		i,pos,y = i + 1, pos + 1, y + h + s
		if pos > 3 then
			pos = 0
			y = 5
			x = x + w + s
		end
	end
	local opt_show = false
	if buttons.menu and  oneover ~= 0 then -- Menu de opciones
		opt_show = true
		menu_start.focus = oneover
		local opciones = {
			{txt = "Execute", action = app_mgr.create, args = menu_start.data[menu_start.focus].id, state = true, overClose = true},
			--{txt = "Abrir Ubicacion", action = app_mgr.create, args = {"id_filer",access_mgr.data[index].path}, state = true, overClose = true},
			--{txt = "Renombrar Acceso", action = access_mgr.rename, args = index, state = true, overClose = true},
			--{txt = "Eliminar Acceso", action = access_mgr.remove, args = index, state = true, overClose = true},
			{txt = "Create Shortcut", action = function (argc)  access_mgr.create(menu_start.data[menu_start.focus].title,menu_start.data[menu_start.focus].id) end, args = menu_start.data[menu_start.focus], state = true, overClose = true},
		}
		POPUP.setElements(opciones)
		POPUP.activate()
	end 

	if buttons.accept and POPUP.activado == false and menu_start.focus ~= oneover then -- sobre ninguno
		menu_start.focus = oneover
	elseif buttons.accept and oneover ~= 0 and menu_start.focus == oneover  then -- sobre alguno, y que no sea cero xD
		app_mgr.create(menu_start.data[menu_start.focus].id) -- Creamos la app segun su id, y creamos la ventana nueva.
		menu_start.focus = 0
	end
end
menu_start.avatar = kernel.loadimage("system/images/menu/avatar.png")
function menu_start.run()
	draw.fillrect(5,5,470,238,desk.barcolor)
	--8,8,
	screen.print(470,230,"Start Menu",0.7,color.white,color.black,__ARIGHT)
	desk.power:blit(443,5)
	if cursor.isOver(370,37,100,100) then
		cursor.set("option")
	--draw.fillrect(443,5,32,32,desk.brillo)
		--draw.rect(443,5,32,32,color.new(255,255,255))
		if buttons.accept then
			local opciones = {
				{txt = "Change Username", action = function() local txt = iosk.init("New Username","");	if txt then __SHELL_NICK = txt; cfg.set("os","nick",__SHELL_NICK) end end, args = nil, state = true, overClose = true},
				{txt = "Change Avatar", action = nil, args = nil, state = false, overClose = true},
			}
			POPUP.setElements(opciones)
			POPUP.activate()
		end
	else
		cursor.set("normal")
	end
	menu_start.draw_apps()
	menu_start.avatar:blit(370,37)
	if cursor.isOver(443,5,32,32) then
		if buttons.accept then
			power.menu()
		end
	end
	screen.print(370+50,137,__SHELL_NICK,0.7,color.white,color.black,512)
	if __SHELL_DEBUG then
		screen.print(370+50,150,__SHELL_PASS,0.7,color.white,0x0,512)
		screen.print(370+50,160,__SHELL_SWAP_ACCEPT,0.7,color.white,0x0,512)
		screen.print(370+50,170,__SHELL_BIOS,0.7,color.white,0x0,512)
		local bios_fw = "VHBL"
		if __SHELL_IS_VITA then
		
		else
			if __SHELL_CFW_ME then
				bios_fw = "CFW L/ME"
			else
				bios_fw = "CFW PRO"
			end
		end
		screen.print(370+50,180,bios_fw,0.7,color.white,0x0,512)
		screen.print(370+50,190,__SHELL_INIT_BIOS,0.7,color.white,0x0,512)
	end
	--err()--draw.rect(370,10,100,100,color.gray)
end

--desk.backimg:blit(465-112,10)
	--desk.user.ico:resize(40,40)
	--desk.user.ico:center()
	--if cursor.isOver(desk.user.xs,5,desk.user.ws+10+32,32) then
	--draw.fillrect(desk.user.xs,5,desk.user.ws+10+32,32,color.shine)
	--draw.rect(desk.user.xs,5,desk.user.ws+10+32,32,color.new(255,255,255))
	--end
	--desk.user.ico:blit(406+15,5+15)
	--screen.print(401,13,desk.user.name,0.7,color.white,0x0,__ARIGHT)
	--menu_start.avatar:blit(395,5)
	
