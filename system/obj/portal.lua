-- SDK: objeto portal

local app = OBJECT.get("PORTAL")	-- Inicializamos tabla del portal

app.cfg = {
	fishbar = false,		-- Uso la FISHBAR
	fupbar = true,			-- Uso la FUPBAR
	shell_background = true,-- Dibuja el fondo configurado
	kernel = true,			-- Corre el kernel portable
	cursor = false			-- Uso del cursor
}

function app.run()
	-- Funcion que se llama al correr el portal (contenido del portal)
end

function app.free()
	-- Funcion que se llama al cerrar el portal (libera los datos inecesarios)
end
	
return app