--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
		http://creativecommons.org/licenses/by-sa/4.0/
	Funcion:
	Modulo Encargado de el manejo de los gadgets. :D
	Pendiente:
	Acomodar bien las funciones, añadir el skecth sdk y optimizar nombre de variables. :D
	]]

gadget_mgr = {-- Modulo Manager de Gadgets
	data = {}, -- ## Almacen Real de Gadgets {code, y sus atributos}
	manager = {}, -- ## Registrador de Gadgets Abiertas y index
	open = 0, -- ## Numero de Gadgets Abiertos, Evita el uso de un calcula max table cada ciclo :D 
	focus = 0 -- ## Posicion actual de Index ##
	} 
	
max_open_gadget = 3 -- limite de Gadgets a abrir 3
root_to_gadgets = "gadgets/" -- Obligatorio, lo cambiare luego a ms0 por ello

function gadget_mgr.load(path,id) -- carga el codigo y lo inserta al shell
	local root = path.."main.lua" -- ruta comun al main de una gadget
	if not files.exists(root) then box.new("Gadget does not exist","Main.lua not found."); return end -- comprobamos exista antes que nada
	local numofgadgets = gadget_mgr.open -- numero de gadget abiertas o cargadas
	if numofgadgets >= max_open_gadget then box.new("Error","Maximum number of Gadgets reached."); return end
	local idindex = numofgadgets + 1 -- por ejemplo si estamos en el 0
	local indextoset = "id0"..idindex -- ok pues si llegamos aqui se cargara en este index
	local codedata = files.read(root,"rb") -- cargaremos todo el programa en texto temporal
	codedata = string.gsub(codedata, "gadget", 'gadget_mgr.data.'..indextoset) -- aqui hacemos el trabajo sucio :D
	--files.write("debug_gadget_"..indextoset..".txt",codedata,"wb")
	-- ## Explicacion de lo anterior ##
	-- Bien creo se merece una explicacion mi metodo chusco xD
	-- Lo que hicimos fue cambiar toda ruta de apunte hacia el id a el puntero en el reposito real gadget_mgr.data
	-- esto es posible solo si queremos que la gadget_mgr sea multiabierta y separada, ademas me ayuda a mantener bien controlada la ram. :D
	--local tmpcode = assert(loadstring(codedata))()--(); -- ahora el code y todo lo de mas de la gadget_mgr queda registrado en el index correcto
	local not_err , msg = pcall(kernel.run,codedata,id) -- proteccion de ejecucion.
	if not not_err then
		box.new(id,msg)
		return
	end
	-- Bien ahora ya esta el code bien en el contenedor del shell, ahora, debemos completar campos y registrarlo
	if not gadget_mgr.data[indextoset] then box.new("Something went wrong","Registration error") return end -- quiere decir algun error al ejecutar el chunk
	
	gadget_mgr.data[indextoset].path = path -- ruta por si se requiere
	gadget_mgr.manager[#gadget_mgr.manager+1] = {id = id, index = indextoset} -- con eso se registro :D
	
	gadget_mgr.focus = indextoset
	gadget_mgr.open = gadget_mgr.open + 1
	--box.new("apps",tostring(gadget_mgr.open))
	return true
end

function gadget_mgr.create(id_name) -- regista la gadget esto en si la llama a load
	if id_name == nil then return	end -- Mejor Prevenir que se llame de alguna manera erronea
	local path = root_to_gadgets..id_name.."/" -- ruta a el cwd del app
	local response = gadget_mgr.load(path,id_name) -- llamamos a registrar el app
	if not response then return end -- se aborta, sin mensaje, pues ya debio haber salido xD
	-- Arranca la Gadget eh manda la ruta para recursos con cosas que requiera una unica llamada :)
	local not_err , msg = pcall(gadget_mgr.data[gadget_mgr.focus].init,path) -- proteccion de ejecucion.
	if not not_err then -- hay un error
		box.new("Error in the gadget"..gadget_mgr.focus, msg)
		return
	end
end

function gadget_mgr.loadall()
	local listaofgadgets = ini.load("gadget.ini")--files.listdirs(root_to_gadgets)
	local leng = #listaofgadgets
	if leng > 3 then leng = 3 end
	for i=1,leng do
		local name_id = listaofgadgets[i].id
		gadget_mgr.create(name_id)
		--println(name_id.. " | FOCUS: "..gadget_mgr.focus)
	end
end
function gadget_mgr.run()
	local x,y,t,i = 410,5,255,1
	while i <= gadget_mgr.open do --for i=1,gadget_mgr.open do
		local not_err, alert = pcall(gadget_mgr.data[gadget_mgr.manager[i].index].run,x,y)
		if not not_err then
		box.new("Gadget error",alert)
		end
		--if buttons.square and cursor.isOver(x,y,70,70,2) then gadget_mgr.data[gadget_mgr.manager[i].index] = nil table.remove(gadget_mgr.manager,i); gadget_mgr.open = gadget_mgr.open - 1 end
		y,i = y+80,i+1
		--draw.line(x,y-5,x+60,y-5,color.gray)
	end
end
