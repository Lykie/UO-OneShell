--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.

	Desarrollado por El Equipo OneShell:
		Gdljjrod & Davis_Nuñez & Mills.
	y probado por el tester:
		Pendiente.
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
		http://creativecommons.org/licenses/by-sa/4.0/
	Version Inicial creada el:
		0.0.1 ALFA XD
		Miercoles - 10/12/2014 - 10:00 am
	Version Actual: 
		1.1.0 Dev - 18/12/2015 - 03:55 pm
	Descripcion:
		Modulo de arranque, donde se inicializa el entorno.
	Pendiente:
	Mil y un detalles :D
	]]

power.event(0)
os.cpu(333) -- Set CPU as Max Value

-- ## Error Manager "Debugger" ## :D
dofile("debugger.lua")

-- ## Lib Kernel ##
dofile("system/libs/kernel.lua")
kernel.setinclude("system/core/") -- ruta a los modulos
kernel.setlibs("system/libs/") -- ruta a las librerias

-- Register Global Constants
__SHELL_VERSION = "Dev-0r3" -- Version del Shell
__SHELL_DEBUG = false -- Default debug is off.
__SHELL_NEW_DEVICE = false -- Its over new device?

__SHELL_MAX_RAM = os.totalram()
__SHELL_MAC = os.mac()
__SHELL_SYS = hw.nand()
__SHELL_LANG = os.language():lower()
__SHELL_NICK = os.nick()
__SHELL_PASS = os.password()
__SHELL_BOARD = hw.board()
__SHELL_INIT_BIOS = hw.ofwinitial() -- Original Bios || CFW
__SHELL_BIOS = os.cfw() -- Actual Bios || CFW
if __SHELL_BIOS == "VHBL" then __SHELL_CFW_VHBL = true -- Its VHBL?
else __SHELL_CFW_VHBL = false
end
if string.find(__SHELL_BIOS,"ME/LME",1,true) then __SHELL_CFW_ME = true -- Its ME/LME?
else __SHELL_CFW_ME = false
end
__SHELL_SOPORT_DAX = __SHELL_CFW_ME -- Suport DAX?
if string.find(__SHELL_BIOS,"PRO",1,true) then __SHELL_CFW_PRO = true -- Its PRO?
else __SHELL_CFW_PRO = false
end
if string.find(__SHELL_BIOS,"eCFW TN-V",1,true) then __SHELL_CFW_TNV = true -- Its TNV?
else __SHELL_CFW_TNV = false
end
__SHELL_OVER_MODEL = hw.getmodel() or "unknow" -- Now Model "1000", "2000", "3000", "Go", "Street", "Vita" o "UNK". 
if __SHELL_OVER_MODEL == "Vita" then __SHELL_IS_VITA = true -- Its Vita hw?
else __SHELL_IS_VITA = false
end
if __SHELL_OVER_MODEL == "Go" then __SHELL_IS_GO = true -- Its GO hw?
else __SHELL_IS_GO = false
end
__SHELL_IS_DEVROOT = string.lower(tostring(files.cdir():sub(1,5)))
if __SHELL_IS_DEVROOT == "umd0:" then -- Esto quiere decir que estamos en modo ISO
	if __SHELL_IS_GO and not files.exists("ms0:/") then -- Es una Go, y no hay ms0
		__SHELL_IS_DEVROOT = "ef0:/"
	else  -- No es una GO, o es una Go, ejecutando sobre la ms0
		__SHELL_IS_DEVROOT = "ms0:/"
	end
end
--os.message(__SHELL_LANG)
__SHELL_SWAP =  buttons.assign()
if __SHELL_SWAP == 0 then -- Acept = O - Cancel = X
	__SHELL_SWAP_ACCEPT = "circle"
	__SHELL_SWAP_CANCEL = "cross"
else -- Acept = X - Cancel = O
	__SHELL_SWAP_ACCEPT = "cross"
	__SHELL_SWAP_CANCEL = "circle"
end
__SHELL_SWAP_MENU = "triangle"

oficialbutonsread = buttons.read
function buttons.read()
	oficialbutonsread() -- call to oficial function
	--Add support three vars
	buttons.accept = buttons[__SHELL_SWAP_ACCEPT]
	buttons.held.accept = buttons.held[__SHELL_SWAP_ACCEPT]
	buttons.released.accept = buttons.released[__SHELL_SWAP_ACCEPT]

	buttons.cancel = buttons[__SHELL_SWAP_CANCEL]
	buttons.held.cancel = buttons.held[__SHELL_SWAP_CANCEL]
	buttons.released.cancel = buttons.released[__SHELL_SWAP_CANCEL]
	
	buttons.menu = buttons[__SHELL_SWAP_MENU]
	buttons.held.menu = buttons.held[__SHELL_SWAP_MENU]
	buttons.released.menu = buttons.released[__SHELL_SWAP_MENU]
end


--os.message(__SHELL_MAC)

function onPmfPlay(state) -- PMF Callback Player
    buttons.read()
    if buttons[__SHELL_SWAP_CANCEL] then pmf.stop() buttons.read() end
    if buttons[__SHELL_SWAP_ACCEPT] then
        if state then pmf.pause()
        else pmf.play()
        end
    end
end

function onPowerEvent(event)
	if event == __POWER_EVENT_SUSPEND then -- Suspend
		label.call("Into a Suspend","Device intro a sleep mode")
	elseif event == __POWER_EVENT_RESUME then -- Resume
		label.call("Return From Suspend","Device return of sleep mode, Resume Complete!")
	end
end

buttons.read() -- Leemos pulsaciones
if buttons.held.r then dofile("system/core/recovery.lua") end -- Goto Recovery menu.
if buttons.held.l then __SHELL_DEBUG = true end -- Enable Debug´s.

-- ## Code de inicio "BOOT" ##
println = kernel.loadscr.print
dofile("boot.lua")
if cfg.get("wlan","auto_on") and ((__SHELL_CFW_TNV  and __SHELL_IS_VITA) or not __SHELL_IS_VITA)  then -- En la psp o en vita con TNV, usamos el modo autoconnect
	wlan.autoconnect(1,10)
elseif cfg.get("wlan","auto_on") and __SHELL_IS_VITA then -- En la vita usamos la conexion manual (al menos de momento :P)
	wlan.connect()
end
-- Check if its a new device
if cfg.get("os","mac") == nil then
	__SHELL_NEW_DEVICE = true -- claro que es nuevo :P no tenia el config de esto
else
	__SHELL_NEW_DEVICE = cfg.get("os","mac") != __SHELL_MAC
end
if __SHELL_NEW_DEVICE then -- Si, es nuevo, actualizamos el config
	cfg.set("os","mac",__SHELL_MAC)
end
-- Get Nick "USERNAME"
if cfg.get("os","nick") != nil and not __SHELL_NEW_DEVICE then
	__SHELL_NICK = cfg.get("os","nick")
else
	cfg.set("os","nick",__SHELL_NICK)
end
-- Get Pass "PASSWORD"
if cfg.get("os","pass") != nil and not __SHELL_NEW_DEVICE then
	__SHELL_PASS = cfg.get("os","pass")
else
	cfg.set("os","pass",__SHELL_PASS)
end
if cfg.get("os","homepopup") then
	buttons.homepopup(0)
else
	--buttons.homepopup(1)
end

if cfg.get("controls","menu") == nil then
	cfg.set("controls","menu",__SHELL_SWAP_MENU)
else
	__SHELL_SWAP_MENU = cfg.get("controls","menu")
end
if cfg.get("lock","auto_on") == nil then
	cfg.set("lock","auto_on", false)
end
--os.message(hw.board  (  ) )--type(__SHELL_PASS) .. " | "..tostring(__SHELL_PASS))

--os.message(tostring(cfg.get("controls","menu")))
if __SHELL_NEW_DEVICE then -- Es nuevo, mostramos la bienvenida.
	label.call(lang.get("labels","hello","Hola").." "..__SHELL_NICK.."!",lang.get("labels","welcome","Hola"))
end
if __SHELL_DEBUG then -- Entramos en modo debug, mostramos el aviso.
	label.call(lang.get("labels","over_debug","Iniciado en modo debug."), lang.get("labels","info_debug","Este modo, permite ver informacion extra."))
end

--os.message(tostring(cfg.get("controls","menu")))
--os.message(tostring(cfg.get("lock","auto_on")))
dofile("nucleus.lua") -- Nucleo Principal :D

--nucleus_main() -- :P
local not_err , msg = pcall(nucleus_main) -- proteccion de ejecucion.
	if not not_err then
		onDebug(msg)
		--os.message(msg)
	end
