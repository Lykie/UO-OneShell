--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Modulo:	Config Manager
	Descripcion: Gestor del Configuraciones
]]

cfg = {} -- Modulo

function cfg.load()
	cfg.data = ini.load("config/settings.ini")
end

function cfg.save()
	if cfg.data then
		ini.save("config/settings.ini",cfg.data)
	end
end

function cfg.get(sect,key,defval)
	if cfg.data then
		if cfg.data[sect] then
			if cfg.data[sect][key] ~= nil then
				return cfg.data[sect][key]
			end
		end
	end
	return defval
end

function cfg.set(sect,key,val)
	if not cfg.data then cfg.data = {} end
	if not cfg.data[sect] then cfg.data[sect] = {} end
	cfg.data[sect][key] = val
	cfg.save() -- revisar si es conveniente
end
--os.message("Load module cfg")
cfg.load()
