app = sdk.newApp("Command Prompt",color.new(0,0,0))
function app.init(path,input)
	app.buff = CONSOLE.new()
	app.buff:print("OneShell "..__SHELL_VERSION.." ("..__SDK_VERSION..")\n")
	app.buff:print(__SHELL_NICK.."> ")
	app.textfield = sdk.newTextField()
	app.textfield:setw(sdk.w)
	app.textfield:xy(sdk.x,sdk.y+sdk.h-app.textfield.h)
	app.textfield:iosk("Command","")
	app.textfield:event(app.event_field)
end
function app.run(x,y)
	app.buff:draw()
	app.textfield:draw()
end
function app.term()
	
end
function app.event_field(c)
	app.buff:print(c.."\n"..app.dispacht(c).."\n")
	app.buff:print(__SHELL_NICK.."> ")
	app.textfield:txt("")
end
-- ## Commands ##
app.commands = {}
function app.commands.recovery()
	screen.clip()
	dofile("system/core/recovery.lua")
	screen.clip(5,21,470,220)
	return
end
function app.commands.cwd()
	return files.cdir()
end
function app.commands.ip()
	return wlan.getip() or "Wi-Fi is Disabled"
end
function app.commands.exit()
	kernel.exit()
	return "Returning to XMB..."
end
function app.commands.shutdown()
	kernel.off()
	return "Shutting down..."
end
function app.commands.suspend()
	kernel.suspend()
	return "Entering Sleep Mode..."
end
function app.commands.help()
	return "CMD built-in commands are:\ncwd - Show current directory\nexit - Return to XMB\nip - Show IP Address\nrecovery - Enter the Recovery Menu\nshutdown - Shutdown Console\nsuspend - Suspend Console"
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

CONSOLE = {}

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
