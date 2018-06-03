--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Modulo:	Acccess Manager
	Descripcion: Gestor de Accesos Desk
	Añadido soporte para swap btt accept y swap menu
]]

access_mgr = { -- Modulo Manager de accesos de escritorio.
	data = {}, -- Almacen de accesos.
	icon = {}, -- Almacen de iconos...
	text = {}, -- Almacen de textos... (titulos ajustados) :P
	exists = {}, -- Almacen de exists...
	position = {}, -- Almacen de textos...
	len = 0, -- numero de accesos
	focus = 0, -- Acceso sobre el cual estamos (seleccionado)
} 

access_mgr.default = {
	access = kernel.loadimage("system/theme/def_aico.png"), -- Acceso Icon Default.
	not_exist = kernel.loadimage("system/theme/def_aico_noexist.png"), -- Acceso Icon No found.
	icon0unk = kernel.loadimage("system/theme/icon0unk.png"),
	folder = kernel.loadimage("system/theme/folder.png"),
	link = kernel.loadimage("system/theme/shortcut.png"),
	}
access_mgr.default.icon0unk:resize(60,35)
-- ## Constantes ##
__DESKACCESSAPP = 1 -- Accesso a un app nativo del shell.
__DESKACCESSFILE = 2 -- Accesso a un archivo, abrir con navegador.
__DESKACCESSFOLDER = 3 -- Accesso a una carpeta, abrir con navegador.
__DESKACCESSGAME = 4 -- Accesso a un juego (iso,cso,pbp), ejecutar.

function access_mgr.load()-- Carga desde la base de datos los accesos.
	access_mgr.data = ini.load("access.ini")
end
function access_mgr.save()-- Guarda a la base de datos los accesos.
	ini.save("access.ini",access_mgr.data)-- Solucion temporal a los userdata
end

function access_mgr.add(name,id_o_path) -- Añade un acceso al desk (data es una tabla con los campos de un acceso).
	local ext = string.sub(id_o_path,-4,-1):lower() -- Extension(si es que la tiene)
	local icon = nil -- puntero del icon del nuevo access
	local exists = true -- puntero del exists del nuevo access
	local tmp = { -- Nuevo Obj Access 
		title = name,
		--x=0,
		--y=0,
		}
	-- Comprobamos Exista un App Con el id pasado como 2do arg
	if files.exists(root_to_apps..id_o_path.."/") then -- Es una App del shell "__DESKACCESSAPP"
		local path = root_to_apps..id_o_path.."/icon.png" -- ruta al icono del app
		if files.exists(path) then -- Si existe un icono entonces lo carga.
			icon = image.load(path)
		else -- De lo contrario carga un icono default
			icon = access_mgr.default.access
		end
		tmp.type = __DESKACCESSAPP
		tmp.id = id_o_path
	elseif ext == ".pbp" or ext == ".iso" or ext == ".cso" then -- Es un App externa (PBP | ISO | CSO) "__DESKACCESSGAME"
		if files.exists(id_o_path) then -- Existe el archivo Game externo
			icon = game.geticon0(id_o_path) --Cargamos el icon0 del mismo... --access_mgr.data[i].icon:save("icon0.png")
			if icon then
				icon:resize(60,35)
			else
				icon = access_mgr.default.icon0unk
			end
		else -- Si no existe pues ponemos un icono default no existe.
			icon = access_mgr.default.not_exist
			exists = false
		end
		tmp.type = __DESKACCESSGAME
		tmp.path = id_o_path
	else
		if files.exists(id_o_path) then -- Comprobamos exista y vemos que es...
			local fp = io.open(id_o_path,"rb")
			if fp then -- archivo
				fp:close()
				tmp.type = __DESKACCESSFILE
				icon = sdk.mime.icon[string.sub(id_o_path,-3,-1):lower()] or sdk.mime.icon.unknown
			else -- carpeta
				tmp.type = __DESKACCESSFOLDER
				icon = access_mgr.default.folder
			end
		else -- No existe es un unknown.
			icon = access_mgr.default.not_exist
			exists = false
			tmp.type = __DESKACCESSFOLDER
		end
		tmp.path = id_o_path
	-- Es un Archivo, Intentar ejecutar segun su tipo o abrir en explorer "__DESKACCESSFILE"
	-- Es una Carpeta intentar abrir en explorer "__DESKACCESSFOLDER"
	end
	icon:center() -- Centramos los iconos.
	table.insert(access_mgr.data, tmp) -- mandamos el obj access a el buffer data
	table.insert(access_mgr.exists, tmp) -- mandamos el exists access a el buffer exists
	table.insert(access_mgr.icon, icon) -- mandamos el icon access a el buffer icon
	table.insert(access_mgr.text, access_mgr.wordwrap(name,76,0.6)) -- mandamos el titulo ajustado a el buffer text
	
	-- Ajustamos XY Punteros
	local i,len = 1,#access_mgr.data
	local x,y,pos,s = 5,5,0,7 -- set
	local w,h = 80,54 -- espacio de seleccion.
	while i < len do
		i,pos,y = i + 1, pos + 1, y + h + s
		if pos > 3 then
			pos = 0
			y = 5
			x = x + w + s
		end
	end
	--tmp.x = x
	--tmp.y = y
	table.insert(access_mgr.position, {x = x, y = y}) -- mandamos el icon access a el buffer position
	access_mgr.len += 1
end

function access_mgr.init()-- Carga los accesos.
	--access_mgr.load()
	local buff = ini.load("access.ini")
	--access_mgr.len = #access_mgr.buffer
	for i=1, #buff do -- Barrido de Matrix
		access_mgr.add(buff[i].title, buff[i].id or buff[i].path)
	end -- Finaliza el barrido.
end


	--[[local iniciallen = #desk.access
	local iconoaccess
	if id_filer.list[i].ext and id_filer.list[i].ext == "pbp" then
		iconoaccess = game.geticon0(id_filer.list[i].path)
		local scalar = 40*iconoaccess:geth() / iconoaccess:getw()
		--iconoaccess:rotate(45)
		--iconoaccess:center()
		iconoaccess:resize(40,scalar) --30
	else
		if not id_filer.list[i].size then
			iconoaccess = id_filer.icons["folder"]
		elseif id_filer.list[i].ext and id_filer.icons[id_filer.list[i].ext] then
			iconoaccess = id_filer.icons[id_filer.list[i].ext]
		else
			iconoaccess = id_filer.icons["unknown"]
		end
	end
	local dataaccess = {icon = iconoaccess,title = id_filer.list[i].name,type = __DESKACCESSGAME,id = "",path = id_filer.list[i].path}
	table.insert(desk.access,dataaccess)
	if iniciallen < #desk.access then os.message("Se registro") else os.message("no se registro") end
	access_mgr.len = access_mgr.len + 1 -- añadimos 1 a el numero de accesos]]

function access_mgr.create(name,id_o_path)
	access_mgr.add(name,id_o_path)
	access_mgr.save()
end

function access_mgr.rename(index) -- Renombra un acceso del desk.
	local txt = iosk.init("New Name",access_mgr.data[index].title)
	if txt then
		access_mgr.data[index].title = txt
		access_mgr.text[index] = access_mgr.wordwrap(txt,76,0.6)
		access_mgr.save()
	end
end

function access_mgr.remove(index)-- Remueve un acceso del desk.
	table.remove(access_mgr.data, index) -- removemos el obj access a el buffer data
	table.remove(access_mgr.exists, index) -- removemos el exists access a el buffer exists
	table.remove(access_mgr.icon, index) -- removemos el icon access a el buffer icon
	table.remove(access_mgr.text, index) -- removemos el titulo ajustado a el buffer text
	table.remove(access_mgr.position, index) -- removemos el xy ajustado a el buffer position
	collectgarbage("collect") -- limpiamos la ram para asegurarnos de la maxima limpieza.
	access_mgr.len -= 1 -- restamos 1 a el numero de accesos
	access_mgr.save()
	access_mgr.focus = 0
end

function access_mgr.run(index) -- Trata de ejecutar un acceso segun su tipo.
	if access_mgr.data[index].type == __DESKACCESSAPP then -- Es un app Oficial 1shell
		access_mgr.focus = 0
		app_mgr.create(access_mgr.data[index].id) -- Creamos la app segun su id, y creamos la ventana nueva.
	elseif access_mgr.data[index].type == __DESKACCESSGAME then -- Es un App externa (PBP | ISO | CSO)
		if files.exists(access_mgr.data[index].path) then -- Existe?
			if box.new(lang.get("access_mgr","run_ext_app_t","Desea ejecutar una aplicación externa?"),lang.get("access_mgr","run_ext_app_d","Se cerraran todas las aplicaciónes y saldra del shell.")) then -- La ejecutamos?
				
				--game.launch(
				sdk.runGame(access_mgr.data[index].path)
			end
		else -- No la encontramos damos alerta
			box.new(lang.get("access_mgr","not_found_t","El archivo no existe!"),lang.get("access_mgr","not_found_d","Se intento ejecutar, pero no se encontro el archivo en la ruta indicada."))
		end
	elseif access_mgr.data[index].type == __DESKACCESSFILE then -- Es un Archivo, Intentar ejecutar segun su tipo o abrir en explorer
		local ext = string.sub(access_mgr.data[index].path,-4,-1):lower()
		if ext and ext == ".bmp" or ext == ".jpg" or ext == ".png" or ext == ".gif" then
			app_mgr.create("gallery",access_mgr.data[index].path)
		elseif ext and ext == ".pmf" then
			pmf.run(access_mgr.data[index].path)
		elseif ext and ext == ".zip" or ext == ".rar" then
			app_mgr.create("winrar",access_mgr.data[index].path)
		else
			app_mgr.create("filer",access_mgr.data[index].path)
		end
	elseif access_mgr.data[index].type == __DESKACCESSFOLDER then -- Es una Carpeta intentar abrir en explorer
		app_mgr.create("filer",access_mgr.data[index].path)
	end
	access_mgr.focus = 0
end

function access_mgr.options(index) -- Opciones del Menu Pop Sobre un acceso.
	local opciones = {
		{txt = lang.get("access_pop","execute","Ejecutar"), action = access_mgr.run, args = index, state = true, overClose = true},
		{txt = lang.get("access_pop","location","Abrir Ubicacion"), action = app_mgr.create, args = {"filer",access_mgr.data[index].path}, state = true, overClose = true},
		{txt = lang.get("access_pop","rename","Renombrar Acceso"), action = access_mgr.rename, args = index, state = true, overClose = true},
		{txt = lang.get("access_pop","remove","Eliminar Acceso"), action = access_mgr.remove, args = index, state = true, overClose = true},
		{txt = lang.get("access_pop","move","Mover Acceso"), action = nil, args = nil, state = false, overClose = true},
		}
	if access_mgr.data[index].type == __DESKACCESSAPP then	opciones[2].state = false end
	POPUP.setElements(opciones)
	POPUP.activate()
end


desk.xscrollaccess = 0

function access_mgr.ajustXY(tmp)
	local ajust_X,ajust_Y = 0,0
	local i,len = 1,30
	local x,y,pos,s = 5,5,0,7 -- set
	local w,h = 80,54 -- espacio de seleccion.
	local fx,fy = false,false
	while i < len do
		ajust_X = x
		ajust_Y = y
		--if tmp.x > x and tmp.y > y then
			--tmp.x = ajust_X
			--tmp.y = ajust_Y
			--return
		--end
		i,pos,y = i + 1, pos + 1, y + h + s
		if pos > 3 then
			pos = 0
			y = 5
			x = x + w + s
		end
		if tmp.x < x and tmp.x > ajust_X and not fx then
			tmp.x = x
			--tmp.y = y--5+(math.ceil(i/4)-1)*(h+s)
			--return
			fx = true
		end
		if not(tmp.x < x) and not(tmp.x > ajust_X) and not fx then
			tmp.x = ajust_X
			--tmp.y = y--5+(math.ceil(i/4)-1)*(h+s)
			--return
			fx = true
		end
		if tmp.y < y and tmp.y > ajust_Y and not fy then
			tmp.y = y
			--tmp.y = y--5+(math.ceil(i/4)-1)*(h+s)
			--return
			fy = true
		end
		if not(tmp.y < y) and not(tmp.y > ajust_Y) and not fy then
			tmp.y = ajust_Y
			--tmp.y = y--5+(math.ceil(i/4)-1)*(h+s)
			--return
			fy = true
		end
	end
end
function access_mgr.draw()
	local i,len = 1,access_mgr.len
	local x,y,pos,s = 5,5,0,7 -- set
	local w,h = 80,54 -- espacio de seleccion.
	--screen.print(10,10,access_mgr.focus)
	local oneover = 0 -- sobre ninguno por default
	while i <= len do -- busqueda de que estemos sobre un acceso y cual?
		x,y = access_mgr.position[i].x,access_mgr.position[i].y
		if access_mgr.focus == i then draw.fillrect(x, y, w, h, color.shine); draw.rect(x, y, w, h, color.white) end
		local overOn = cursor.isOver(x, y, w, h)
		if overOn then -- si estamos sobre uno, Draw contorno
			draw.fillrect(x, y, w, h, color.shine); draw.rect(x, y, w, h, color.white)
			oneover = i -- ok hubo al menos una coincidencia la parseamos a oneover
			if access_mgr.data[i].type == __DESKACCESSAPP then
				cursor.label(lang.get("access_mgr","execute","Ejecutar")..': "'..access_mgr.data[i].title ..'"')
			else -- Es Un juego o file..
				if access_mgr.exists[i] then -- Existe..
					cursor.label('Ruta: "'.. access_mgr.data[i].path ..'"')
				else -- No encontrado..
					cursor.label(lang.get("access_mgr","root_not_found",'Destino no encontrado.'))
				end
			end
		end
		if access_mgr.icon[i] then
			access_mgr.icon[i]:blit(x+(w/2),y+((h-10)/2))
		end
		if access_mgr.data[i].type != __DESKACCESSAPP then
			access_mgr.default.link:resize(10,10)
			access_mgr.default.link:blit(x+(w/2)-30,y+((h-10)/2)+8)
			--access_mgr.default.link:blit(x+(w/2)-(access_mgr.icon[i]:getw()/2),y+((h-10)/2))--+(access_mgr.icon[i]:geth()/2))
		end
		--[[if overOn then -- efecto scroll sobre el seleccionado
			if math.floor(desk.xscrollaccess) ~= x+(w/2) then
				desk.xscrollaccess = x+(w/2)
			end
			desk.xscrollaccess = screen.print(desk.xscrollaccess,y+h-15,access_mgr.data[i].title,0.6,color.white,color.black,__SSEESAW,40)
		else]]
			--screen.clip(x+5,y+h-15,w-10,h)
		--if oneover != 0 and access_mgr.focus != 0 then
			--screen.print(x+(w/2),y+h-15,access_mgr.data[i].name,0.6,color.white,color.black,__ACENTER)
		--else
			screen.print(x+(w/2),y+h-15,access_mgr.text[i],0.6,color.white,color.black,__ACENTER)
		--end
			--screen.clip()
		--end

		i,pos,y = i + 1, pos + 1, y + h + s
		if pos > 3 then
			pos = 0
			y = 5
			x = x + w + s
		end
	end
	
	if buttons.held.accept and access_mgr.focus != 0 then
		local mx,my = cursor.motion()
		access_mgr.position[access_mgr.focus].x += mx
		access_mgr.position[access_mgr.focus].y += my
		--oneover = 0
	end
	
	--[[if buttons.released.cross and access_mgr.focus != 0 then
		access_mgr.ajustXY(access_mgr.data[access_mgr.focus])
	end]]
	if buttons.accept and oneover != 0 and access_mgr.focus == oneover  then -- sobre alguno, y que no sea cero xD
		access_mgr.run(access_mgr.focus)
		access_mgr.focus = 0
		oneover = 0
	end
	if buttons.accept and POPUP.activado == false and access_mgr.focus ~= oneover then -- sobre ninguno
		access_mgr.focus = oneover
	end
	if buttons.menu and  oneover ~= 0 then -- Menu de opciones
		--opt_show = true
		access_mgr.focus = oneover
		access_mgr.options(access_mgr.focus) 
	end 
	--return (oneover == 0 and opt_show == false)
end

	--[[					
			
			--screen.clip(ejex,ejey+40,45,40)
			desk.xscrollaccess = screen.print(desk.xscrollaccess,ejey+(pos*55)+35,access_mgr.data[i].title,0.5,color.white,color.black,__SLEFT,35)
		else
			screen.clip(ejex,ejey+(pos*55)+35,45,40)
			screen.print(ejex+25,ejey+(pos*55)+35,access_mgr.data[i].title,0.5,color.white,color.black,__ACENTER)
			screen.clip()

end]]
function access_mgr.wordwrap(txt,space,size)
	if not size then size = 0.6 end
	local width = screen.textwidth(txt,size)
	if width > space then -- El tamaño es mayor a el espacio1
		local ch_end = #txt -- Cargamos el largo a ch_end
		while width > space-6 do -- Mientras el width sea mayor al space - el ancho del ".."
			width = screen.textwidth(string.sub(txt,1,ch_end),0.6)
			ch_end -= 1 -- vamos quitando un char en cada prueba
		end
		return string.sub(txt,1,ch_end).."..." -- regresamos el texto con espacio ajustado
	end
	return txt -- regresamos el texto igual pues al parecer no hubo cambios.
end
