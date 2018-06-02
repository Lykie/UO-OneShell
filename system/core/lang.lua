--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Modulo:	Languaje Manager
	Descripcion: Gestor del Lenguajes
]]

lang = {} -- Modulo
--lang.parse = {"ENGLISH" = 1, "SPANISH" = 2, "JAPANESE" = 3, "GERMAN" = 4, "FRENCH" = 4 ,"ITALIAN" = 5 ,"DUTCH" = 6, "PORTUGUESE" = 7, "RUSSIAN" = 8, "KOREAN" = 9, "CHINESE TRADITIONAL" = 10, "CHINESE SIMPLIFIED" = 11}

function lang.register(argv)
	lang.data = argv
end
function lang.load()
	local not_err , msg = pcall(dofile,"langs/".. __SHELL_LANG ..".ini") -- proteccion de ejecucion.
	if not not_err then
		--os.message(msg)
		local not_err , msg = pcall(dofile,"langs/english.ini")
	end
end

function lang.save()
	if lang.data then
		ini.save("oneshell.ini",lang.data)
	end
end

function lang.get(sect,key,defval)
	if lang.data then
		if lang.data[sect] then
			if lang.data[sect][key] then
				return lang.data[sect][key]
			end
		end
	end
	return defval
end

function lang.set(sect,key,val)
	if not lang.data then lang.data = {} end
	if not lang.data[sect] then lang.data[sect] = {} end
	lang.data[sect][key] = val
	lang.save() -- revisar si es conveniente
end
--os.message("cargamos el modulo cfg")
lang.load()