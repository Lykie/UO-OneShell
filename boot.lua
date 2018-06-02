--game.add("eboot.pbp","resource/icon_0.png",__ICON0)
--game.add("eboot.pbp","resource/pic_1.png",__PIC1)
kernel.loadscr.fadein()

println("Starting OneShell")
kernel.include("cfg_manager.lua",cfg)
kernel.include("lang.lua",lang)
println("Kernel")

if cfg.get("sio","auto_on") and not __SHELL_IS_VITA then
	println("SIO Driver")
	println("SIO Driver")
	println("SIO Driver")
	sio.init()
	sio.baud(19200)
--elseif __SHELL_IS_VITA == true then
	--cfg.set("sio","auto_on",false)
	--cfg.set("sio","mouse_ps2",false)
end

println("Cursor Driver")
kernel.include("cursor.lua")

println("PopMenu")
kernel.include("popupMenu.lua")

println("Labels")
kernel.include("label.lua")

println("App Manager")
kernel.include("app_manager.lua")

println("Ram Manager")
kernel.include("ram_manager.lua")

println("Gadget Manager")
kernel.include("gadget_manager.lua")

println("Start Menu")
kernel.include("menu_start.lua")

println("Drivers")
kernel.include("drivers.lua")

println("Desktop")
kernel.include("desk.lua")

println("Source Dev Kit (sdk)")
kernel.dofile("system/sdk/1shell.lua")

println("Access Manager")
kernel.include("access_manager.lua")

println("Access Desktop")
access_mgr.init() -- Cargamos los accesos.

--println("Source Dev Kit (sdk)")
--kernel.dofile("system/sdk/1shell.lua")

--println("Library http")
--kernel.lib("http.lua")

println("Library Utf8")
kernel.lib("utf8.lua")

println("Library iosk")
kernel.lib("iosk.lua")

--println("Library bmp")
--kernel.lib("bmplib.lua")

println("Library 3D")
kernel.lib("screen_saver.lua")

--[[println("Library wave")
kernel.lib("lib_wave.lua")
MyWave = wave.init("system/theme/wave.png")]]

println("Library Box")
box.init("system/theme/") -- inicia la libreria box mensajes! :D

println("Gadgets")
gadget_mgr.loadall()
sndin = kernel.loadsound("system/sound/in.wav")
sndin:play()

kernel.loadscr.fadeout()

tiempo = timer.new() -- variable de tiempo del shell (sleep, suspend, savescreen)
tiempo:start()