--[[ 
	OBJECT LIB 1.1 @zerozelta
	Pequeña pero util lbreria para uso de "objetos" en luaDEV 
	
	Lua player (y en este caso lua Dev) no es un lenguaje de programacion orientada a objetos, pero con algo
	de imaginacion se puede utilizar un sistema para "simular" en lo mas posible el uso de objetos en este
	lenguaje.
	
	ObjectLib  proporciona un sistema de programacion mas "orientado a objetos" d lo que LUA ofrece, podras usar objetos
	instancias y herencias de datos para crear componentes, objetos y demas recursos con el mas alto nivel de detalle
--]]

OBJECT = {} 		-- Iniciando tabla OBJECT
OBJECT.DATA = {}	-- Data de objetos { id , chunk }

function OBJECT.loadResource(id,path) -- Carga el objeto (.luaObject | .lua) en la memoria RAM con el id pasado como argumento

	if path == nil or files.exists(path) == false then return 0 end	-- La documentacion del objeto no existe
	if id == nil or id == "" then return 1 end						-- ID para el objeto es erroneo
	if OBJECT.idIsExist(id) == true then return 2 end 				-- El id de este objeto ya existe
	
	local ext = files.ext(path)
	
	if ext ~= "lua" and ext ~= "luaObject" then return 3 end		-- Extencion del archivo incorrecta
	
	local documento = io.open(path)
	
	if documento == nil then return 4 end							-- No se pudo acceder al documento
	
	local codigo = documento:read("*a")		-- Leemos el documento
	documento:close()
	
	local chunk = nil
	
	local data = {
		id = id,
		path = path
	}
	
	data.chunk = loadstring(codigo)		-- Pasamos el texto a chunk y lo guardamos en la tabla 
	
	OBJECT.DATA[id] = data				-- insertamos la tabla local en la data global
		
	return true
end

function OBJECT.load(id,path)
	OBJECT.loadResource(id,path)
end

function OBJECT.get(id,args)			-- Retorna una instancia del objeto que coincida con el id pasado como argumento
	local data = OBJECT.getData(id)
	
	if data == nil then return end
	
	if data.chunk == nil then
		--error("Error en el codigo del objeto: "..id.." (Use OBJECT.debugResource([path]) para identificar el error)",0)
		OBJECT.debugResource(data.path)
		return 
	end
	
	local instance = data.chunk()
	
	if instance == nil then
		error("Object "..id.." does not return value at the end of the script.")
		return
	end
	
	if instance ~= nil and instance.constructor ~= nil then 
		instance.constructor(args)		-- Inicializamos el constructor del objeto con los argumentos pasados
	end
	
	return instance					-- Devolvemos la instancia del objeto
end

function OBJECT.getInstance(id,args)
	OBJECT.get(id,args)
end

function OBJECT.free(id)			-- Libera de la memoria ram el objeto con el id pasado (esta funcion elimina el objeto, pero no las instancias del mismo)
	for i = 1,#OBJECT.DATA do
		if OBJECT.DATA[i].id == id then
			OBJECT.DATA[i].id = {}
			OBJECT.DATA[i] = {}
			table.remove(OBJECT.DATA,i)
			OBJECT.free(id)
			break
		end
	end
	
	collectgarbage()
end

function OBJECT.getData(id)
	if id == nil then return end	
	
	if OBJECT.idIsExist(id) == true then
		return OBJECT.DATA[id]
	end
end

function OBJECT.idIsExist(id)
	if id == nil then return end	
	
	if OBJECT.DATA[id] ~= nil then 
		return true 
	else
		return false
	end
end

function OBJECT.debugResource(path)
	if files.exists(path) == false then return 0 end
	dofile(path)
	return true
end

function OBJECT.debugInstance(id)
	data = OBJECT.getData(id)
	data.chunk()
end
