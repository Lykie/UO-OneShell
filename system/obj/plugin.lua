--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
		http://creativecommons.org/licenses/by-sa/4.0/
	Descripcion:
		Objeto SDK para el desarrollo de aplicaciones de segundo plano (plugin´s).
	]]

local obj = {}

--obj.name = "plugin"

function obj.init()
	-- Funcion llamada al cargar el plugin
end

function obj.run(f)
	-- Funcion llamada al correr el plugin
end

function obj.term()
	-- Funcion llamada al cerrar el plugin
end

return obj