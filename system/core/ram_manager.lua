--[[
	===========================================
		BASADO EN EL MANAGER RAM DE FISHELL
	===========================================
]]
ram_mgr = {} -- Modulo De control de ram
ram_mgr.timer = timer.new() -- creamos un timer del modulo ram
ram_mgr.timer:start() -- Iniciamos el timer del modulo ram

function ram_mgr.run()
	if ram_mgr.timer:time() > 5000 then -- 15 segundos en cada limpiado automatico
		collectgarbage() -- limpiado de ram...
		ram_mgr.timer:reset();ram_mgr.timer:start(); -- reiniciamos el contador
		--os.message("funciona")
	end
end