--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
		http://creativecommons.org/licenses/by-sa/4.0/
	Pendiente:
	Acomodar bien las funciones, añadir el skecth sdk y optimizar nombre de variables :D
	]]

app_mgr = {-- Modulo app manager
	defico = kernel.loadimage("system/theme/def_tico.png"), -- ## Default Mini Icon Windows App
	defbico = kernel.loadimage("system/theme/def_bico.png"),-- ## Default Mini Icon Desk App
	tmp = {}, -- ## Almacen temporal al crear aplicaciones (No se utilizo)
	data = {}, -- ## Almacen Real de aplicaciones {code, y sus atributos}
	manager = {}, -- ## Registrador de aplicaciones Abiertas y index
	id = {0,0,0,0,0},
	focus = 0, -- ## Aplicacion enfocada
	open = 0, -- ## Numero de Apps Abiertas, Evita el uso de un calcula max table cada ciclo :D 
	}

max_open_apps = 5 -- limite de aplicaciones a abrir 5
root_to_apps = "apps/" -- Obligatorio, lo cambiare luego a ms0 por ello

function app_mgr.load(path,id) -- carga el codigo y lo inserta al shell
	
	local root = path.."main.lua" -- ruta comun al main de una aplicacion
	if not files.exists(root) then box.new(lang.get("app_mgr","no_main_t","La app no esta completa"),lang.get("app_mgr","no_main_d","No se logro encontrar su main o codigo.")); return end -- comprobamos exista antes que nada
	local numofapps = app_mgr.open -- numero de apps abiertas o cargadas
	if numofapps >= max_open_apps then box.new(lang.get("app_mgr","app_max_t","Imposible iniciar aplicacion"),lang.get("app_mgr","app_max_d","Numero maximo de aplicaciones abiertas alcanzado.")); return end
	local idindex = app_mgr.getfreeindex()
	local indextoset = "id0"..idindex -- ok pues si llegamos aqui se cargara en este index
	---box.new("test",indextoset)
	local codedata = files.read(root,"rb") -- cargaremos todo el programa en texto temporal
	--codedata = string.gsub(codedata, id, 'app_mgr.data.'..indextoset) -- aqui hacemos el trabajo sucio :D
	codedata = string.gsub(codedata, "app", 'app_mgr.data.'..indextoset) -- aqui hacemos el trabajo sucio :D
	--files.write("debugapp.txt",codedata,"wb") -- debug :P XD
	-- ## Explicacion de lo anterior ##
	-- Bien creo se merece una explicacion mi metodo devdavis xDDDDD xD
	-- Lo que hicimos fue cambiar toda ruta de apunte hacia el id a el puntero en el reposito real app_mgr.data
	-- esto es posible solo si queremos que la app sea multiabierta y separada, ademas me ayuda a mantener bien controlada la ram. :D
	--local tmpcode = assert(loadstring(codedata))()--(); -- ahora el code y todo lo de mas de la app queda registrado en el index correcto
	local not_err , msg = pcall(kernel.run,codedata) -- proteccion de ejecucion.
	if not not_err then
		box.new("error over "..id, root .."\n".. msg)
		return
	end
	-- Bien ahora ya esta el code bien en el contenedor del shell, ahora, debemos completar campos y registrarlo.
	if not app_mgr.data[indextoset] then box.new(lang.get("app_mgr","app_chunk_t","La app no responde!"),lang.get("app_mgr","app_chunk_d","Verifique este completa la aplicación, no se envio estado al núcleo.")) return end -- quiere decir algun error al ejecutar el chunk
	
	-- Comenzamos registros de atributos :)
	app_mgr.data[indextoset].attributes.id = id -- id; realmente esto pendiente
	app_mgr.data[indextoset].attributes.index = idindex -- index del manager
	local tmpico = nil
	if files.exists(path.."icon.png") then
		tmpico = image.load(path.."icon.png") -- cargamos el personalizado
		local sh = tmpico:geth()
		local sw = tmpico:getw()
		tmpico:resize(16,(sh*16)/sw)
	else
		tmpico = app_mgr.defico -- cargamos el default
	end
	tmpico:center() -- Por cuestion grafica lo centramos sobre su punto medio
	app_mgr.data[indextoset].attributes.tico = tmpico -- icono de la barra superior.
	local indexdesk = desk.registerapp(idindex,tmpico,app_mgr.data[indextoset].attributes.title) -- Registramos la app en la barra de tareas.
	app_mgr.data[indextoset].attributes.path = path -- ruta por si se requiere
	
	app_mgr.id[idindex] = 1 -- colocamos el espacio en ocupado
	app_mgr.manager[idindex] = {id = id, index = indextoset, bar_index = indexdesk} -- con eso se registro :D
	app_mgr.focus = idindex -- numero en espacio--indextoset
	app_mgr.open = app_mgr.open + 1 -- sumamos 1 a los abiertos.
	return true
end
loaddesk = image.load("system/theme/wait.png")
loaddesk:center()
function app_mgr.create(identificador,args) -- regista la app esto en si la llama a load
	if identificador == nil then return	end -- Mejor Prevenir que se llame de alguna manera erronea
	local path = root_to_apps..identificador.."/" -- ruta a la app raiz
	local response = app_mgr.load(path,identificador)
	if not response then return end -- se aborta, sin mensaje, pues ya debio haber salido xD
	local oldbuff = screen.buffertoimage()
	local nowbuff = screen.toimage()
	for i=0,255,11 do
		nowbuff:blit(0,0)
		loaddesk:blit(240,136,i)
		screen.print(240,160,"Loading Application",0.7,color.white:a(i),color.black:a(i),512)
		screen.flip()
	end
	--oldbuff:blit(0,0)
	-- Arranca la app & manda la ruta para recursos con cosas que requiera una unica llamada :)
	local not_err , msg = pcall(app_mgr.data[app_mgr.manager[app_mgr.focus].index].init,path,args) -- proteccion de ejecucion.
	for i=255,0,-11 do
		nowbuff:blit(0,0)
		loaddesk:blit(240,136,i)
		screen.print(240,160,"Loading Application",0.7,color.white:a(i),color.black:a(i),512)
		screen.flip()
	end
	oldbuff:blit(0,0)
	if not not_err then -- error :(
		local args = string.explode(msg,":")
		box.new("Error Chunk App",{"ID: "..tostring(app_mgr.data[app_mgr.manager[app_mgr.focus].index].attributes.id),"Name: "..tostring(app_mgr.data[app_mgr.manager[app_mgr.focus].index].attributes.title),"Line: "..tostring(args[2]),"Warning: "..wordwrap(tostring(args[3]),250,0.6)})
		--box.new("Error Over App "..app_mgr.manager[app_mgr.focus].index, msg)
		app_mgr.free(app_mgr.focus)
		--msg = string.explode(msg,":")
		--box.new("Error en la app "..app_mgr.data[app_mgr.focus].id,{"File: "..app_mgr.data[app_mgr.focus].path.."main.lua","Line: "..msg[2],"Error: "..msg[3]})
		return
	end
end

function app_mgr.getfreeindex() -- busca un index vacio
	for i=1,max_open_apps do -- hace un recorrido de el index 1 a el maximo y nos dice cual esta libre :D
		if app_mgr.id[i] == 0 then
			return i
		end
	end
	return 0
end
function app_mgr.getsetindex() -- busca un index ocupado
	for i=1,max_open_apps do -- hace un recorrido de el index 1 a el maximo y nos dice cual esta libre :D
		if app_mgr.id[i] == 1 then
			return i
		end
	end
	return 0
end



function app_mgr.free(focus) -- Libera y cierra una aplicacion enfocada :D
	--Llamamos a la funcion de cierre.
	local err , msg = pcall(app_mgr.data[app_mgr.manager[focus].index].term) -- proteccion de ejecucion.
	if not err then
		box.new("Error Over App "..app_mgr.manager[focus].index, msg)
	end
	table.remove(desk.apps,app_mgr.manager[focus].bar_index)
	if focus < 5 then
		for i=focus,5 do
			if app_mgr.manager[i] then
				app_mgr.manager[i].bar_index = app_mgr.manager[i].bar_index - 1
			end
		end
	end
	desk.open = desk.open - 1
	app_mgr.data[app_mgr.manager[focus].index] = nil -- liberamos toda la aplicacion :)
	app_mgr.id[focus] = 0 -- colocamos el espacio en libre
	app_mgr.manager[focus] = nil -- libero ese index del manager
	if focus == app_mgr.focus then -- mandamos cerrar en el que estamos :(
		app_mgr.focus = app_mgr.getsetindex() -- Colocamos el index en algun usado o 0 :)
		if app_mgr.focus == 0 then
			desk.state = __DESKOVERNOTHING
		end
		--app_mgr.focus = 0
	end 
	app_mgr.open = app_mgr.open - 1 -- restamos 1 a los abiertos.
	collectgarbage("collect") -- Limpiamos basura de ram :D
end -- table.remove(desk.apps,i)



window = {-- Modulo Windows 
	--back = kernel.loadimage("system/theme/window/window.png"),
	close = kernel.loadimage("system/theme/window/Closed.png"),
	min = kernel.loadimage("system/theme/window/Minimized.png"),
	--btts = kernel.loadimage("system/theme/window/buttons.png"),
	mode = 1, -- 2 Suma / 1 Nada  / 0 Resta
	size = 0, -- 0 - 100 porcentaje
	act = false
	}

function app_mgr.run_app()-- Ejecuta la ventana abiera y Dibuja Todas las apps Cargadas

	if app_mgr.open < 1 or app_mgr.focus == 0 then return end -- no hay nada abierto
	app_mgr.draw(app_mgr.data[app_mgr.manager[app_mgr.focus].index].attributes,0,0,480,247) -- enviamos los atributos y con ellos las coordenadas.
	if app_mgr.open < 1 or app_mgr.focus == 0 then return end -- no hay nada abierto
	app_mgr.running(app_mgr.data[app_mgr.manager[app_mgr.focus].index],5,21)

end


function app_mgr.draw(pack,x,y,w,h,t)  --Dibuja las ventanas
	window.draw(pack.backColor)--window.back:blit(x,y) -- fondo
	pack.tico:blit(14,11) -- Tico (icono de barra)
	screen.print(240,3,pack.title,0.6,color.black,0x0,512) -- Titulo de ventana
	
	-- Botones de Ventana
	window.close:blit(454,2)
	if cursor.isOver(454,2,19,16) then
		if buttons.cross then app_mgr.free(app_mgr.focus) end
		window.close:blitadd(454,2,40)
	end
	window.min:blit(432,2)
	if cursor.isOver(432,2,21,16) then
		if buttons.cross then desk.state = __DESKOVERNOTHING end
		window.min:blitadd(432,2,40) -- Minimizar
	end
end

function app_mgr.running(pack,x,y) -- ejecuta el code de la app
	draw.rect(4,20,472,222,color.gray)
	screen.clip(5,21,470,220) -- Limitamos a dibujar en el area de ventana
	local not_err , msg = pcall(pack.run,x,y) -- proteccion de ejecucion.
	if not not_err then
		amg.mode2d(1)
		local args = string.explode(msg,":")
		box.new("Error Chunk App",{"ID: "..pack.attributes.id,"Name: "..pack.attributes.title,"Line: "..tostring(args[2]),"Warning: "..wordwrap(tostring(args[3]),250,0.6)})
		app_mgr.free(app_mgr.focus)
	end
	screen.clip() -- quitamos limitacion
end
window.theme = 0
--[[0: Azul
	1: Verde
	2: Gris
	]]
function window.draw(col)
	if window.theme == 0 then
		cl = color.new(132,168,209)--Estilo Azul
	elseif window.theme == 1 then
		cl = color.new(156,187,90)--Estilo verde
	elseif window.theme == 2 then
		cl = color.new(102,102,102)--Estilo Gris
	elseif window.theme == 3 then
		cl = color.new(245,107,189)--Estilo Violeta
		elseif window.theme == 4 then
		cl = color.new(211,180,140)--Estilo Cafe
	end
	draw.fillrect(0,0,480,21,cl)
	draw.fillrect(0,0,5,247,cl)
	draw.fillrect(475,0,5,247,cl)
	draw.fillrect(5,241,475,6,cl)
	draw.fillrect(5,21,470,220,col or color.white)
end

	















--[[ -- ## Super Mega Betas Inutilizadas ##
function window.overon()
	if buttons.held.cross then
		if app_mgr.open > 0 then
			if cursor.isOver(app_mgr.data[app_mgr.focus].x,app_mgr.data[app_mgr.focus].y,app_mgr.data[app_mgr.focus].w,22) then
				window.move()
			else
				local i = app_mgr.open
				while i >= 1 do 
					if cursor.isOver(app_mgr.data[i].x,app_mgr.data[i].y,app_mgr.data[i].w,app_mgr.data[i].h) and not cursor.isOver(app_mgr.data[app_mgr.focus].x,app_mgr.data[app_mgr.focus].y,app_mgr.data[app_mgr.focus].w,app_mgr.data[app_mgr.focus].h) then
						app_mgr.focus = i
					end
					i = i - 1
				end
			end
		end
	end
end

function window.move()
	app_mgr.data[app_mgr.focus].x += cursor.despX
	app_mgr.data[app_mgr.focus].y += cursor.despY
end

function app_mgr.errorlog(id,root,msg)
	msg = string.explode(msg,":")
	box.new("Error Al iniciar app "..tostring(id),{"File: "..tostring(root),"Line: "..tostring(msg[4]),"Error: "..tostring(msg[5])})
end]]