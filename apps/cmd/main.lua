--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Modulo:	App
	Descripcion: Simbolo del Sistema "command prompt" (Terminal de Commandos).
]]

app = sdk.newApp("Command Prompt",color.new(0,0,0))
function app.init(path,input)
	app.buff = CONSOLE.new()
	app.buff:print("Team ONElua - OneShell [Version "..__SHELL_VERSION.."] [SDK "..__SDK_VERSION.."]\n")
	app.buff:print("2015 - Licensed by Creative Commons Attribution-ShareAlike 4.0\n")
	app.buff:print(__SHELL_NICK.."> ")
	app.textfield = sdk.newTextField()
	app.textfield:setw(sdk.w)
	app.textfield:xy(sdk.x,sdk.y+sdk.h-app.textfield.h)
	app.textfield:iosk("Command","")
	app.textfield:event(app.event_field)
end
function app.run(x,y)
	app.buff:draw()
	--if buttons.cross and sdk.underAppCursor() then	end
	app.textfield:draw()
end
function app.term()
	
end
function app.event_field(c) -- Evento cuando sea positivo la entrada de texto sobre el textfield.
	app.buff:print(c.."\n"..app.dispacht(c).."\n")
	app.buff:print(__SHELL_NICK.."> ")
	app.textfield:txt("")
end
-- ## Comandos ##
app.commands = {} -- Contenedor
function app.commands.recovery()
	screen.clip()
	dofile("system/core/recovery.lua")
	screen.clip(5,21,470,220) -- Limitamos a dibujar en el area de ventana
	return "Ok.."
end
function app.commands.r() -- temporal para test fast
	screen.clip()
	dofile("system/core/recovery.lua")
	screen.clip(5,21,470,220) -- Limitamos a dibujar en el area de ventana
	return "Ok.."
end
function app.commands.mkdir(path)
	files.mkdir(path)
	return "Ok.."
end
function app.commands.copy(src,dst)
	if src and dst then
		local res = files.copy(src,dst)
		if res == 1 then
			return "Ok.."
		end
	end
	return "Error.."
end
function app.commands.move(src,dst)
	if src and dst then
		local res = files.move(src,dst)
		if res == 1 then
			return "Ok.."
		end
	end
	return "Error.."
end
function app.commands.cwd()
	return files.cdir()
end
function app.commands.dir(path)
	local now = files.cdir()
	if path then
		files.cdir(path)
	end
	return "Ok.. cwd - old: "..now.." now: "..files.cdir()
end
function app.commands.ip()
	return wlan.getip() or "Unknown IP"
end
function app.commands.exit()
	kernel.exit()
	return "Exit to XMB..."
end
function app.commands.shutdown()
	kernel.off()
	return "Shutdown Console..."
end
function app.commands.suspend()
	kernel.suspend()
	return "Suspend Console..."
end
function app.commands.help()
	return "## List Of Available Command´s ##\nrecovery - enter to recovery mode\ncwd - get dir work\dir - get dir work\nip - get Adress wlan\nexit - goto xmb\nshutdown - shutdown console\nsuspend - suspend console\n## ##"
end
function app.dispacht(c)
	local tmp = string.explode(c," ")
	if #tmp > 0 then
		if app.commands[tmp[1]] then
			return app.commands[tmp[1]](tmp[2],tmp[3])
		end
	else
		if app.commands[c] then
			return app.commands[c]()
		end
	end
	return "Unknown Command"
end

CONSOLE = {}	-- Tabla de consola

function CONSOLE.new()
	local obj = {
		txt_color = color.new(255,255,255),
		data = {""},
		h = sdk.y,
		y = sdk.y,
		t = timer.new()
	}
	
	obj.t:start()
	function obj:print(text) 
		if text == nil then text = "" end
		local tmp = string.explode(text,"\n")
		if #tmp > 0 then
			obj.data[#obj.data] = obj.data[#obj.data]..tmp[1]
		else
			obj.data[#obj.data] = obj.data[#obj.data]..tmp
		end
		if #tmp>1 then
			for i=2,#tmp do
				obj.h = obj.h + 10
				table.insert(obj.data,tmp[i])
			end
		end
		
		if obj.h > sdk.h+22 then
			obj.y = obj.y - 10
		end
	end
	
	function obj.draw()
		if #obj.data == 0 then return end
		
		local y = obj.y
		local i = 1
		while i <= #obj.data do
			local sy = y + ((i - 1) * 10),obj.data[i]
			if sy < -10 then return end
			
			screen.print(sdk.x,y + ((i - 1) * 10),obj.data[i],0.5,obj.txt_color,0x0)
			i+=1
		end
		if obj.t:time() < 500 then
		draw.line(sdk.x+screen.textwidth(obj.data[i-1] or "",0.5),
					y+3 + ((i - 1-1) * 10),
					sdk.x+screen.textwidth(obj.data[i-1] or "",0.5),
					y + ((i - 1-1) * 10)+13,color.white)
		end
		if obj.t:time() >1000 then
			obj.t:reset() 
			obj.t:start()
		end
	end
	
	return obj
end