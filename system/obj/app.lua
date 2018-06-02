--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
		http://creativecommons.org/licenses/by-sa/4.0/
	Descripcion:
		Objeto SDK para el desarrollo de aplicaciones.
	]]
local app_tmp = {} -- Objeto aplicacion 1shell

app_tmp.attributes = { -- Atributos para la aplicacion en el shell
	id = nil, -- ID de la aplicacion
	title = "ONESHELL APP",	-- Titulo de la aplicacion (en ventana)
	multiOpen = true,	-- Si se permite abrir multiples veces esta app
	--customBackground = true, --Si la aplicacion utilizara un fondo personalizado
	--back = nil, -- la img del fondo personalizado
	backColor = nil,
	tico = nil, -- Icono de aplicacion-- Estos se cargaran de manera automatica si es que existen como icon.png y iconAcces.png en la ruta del app, (raiz)
	path = nil, -- ruta
	}
	
-- Funciones Principales

-- Funcion "init" llamada al iniciar la app.
-- Nota: Se ejecuta una sola vez, al iniciar la app.
function app_tmp.init(path,input)
	--Argumentos:
	--path: ruta para cargar los sources del app, 
	--input: argumento variable; para ser llamado con la funcion abrir con (ruta archivo a abrir) por ejemplo.
end

-- Funcion "run" llamada durante cada ciclo del app abierta. (funcion principal)
-- Nota: Aqui no se requiere el uso de buttons.read() o screen.flip() o amg.update XD
function app_tmp.run(x,y)
	--Argumentos:
	--x,y coordenadas por asi decirlo 0 en la zona imprimible de la app
	--Nota#1: Se reciben las coordenadas donde dibujar o imprimir desde los puntos x = 0, y = 0, de la ventana (zona usable).
end

-- Funcion "term" llamada al cerrar la aplicacion.
-- Nota: Esta se ejecuta una sola vez, al cerra la app.
function app_tmp.term()
	--Argumentos:
	--Ninguno.
	--Nota Normalmente aqui se liberan los datos de la aplicacion.
end

--function app_tmp.free()
	-- Funcion llamada al liberar todo rastro de la aplicacion
	-- Es utilizada por ejemplo si tenemos mas de una app abierta, con el mismo id y no podemos liberar al cerrar 
	-- Pendiente revisar
	-- Creo lo puedo hacer esto revisando los id´s abiertos desde el app manager
--end

return app_tmp