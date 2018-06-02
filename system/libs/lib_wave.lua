--[[
==	Libreria Wave (olas)
==	Descripcion:
==	Esta nos permite Crear y Manipular Objetos wave
==	Creada Por:
==	David Nuñez A. David.nunezaguilera.131@gmail.com
==	Version 1.0 -- 01/01/2015
==	Modificada Por:
==	Equipo OneShell para la utilizacion en el entorno.
==	Version 2.0 -- 18/02/2015
==	PD. Gdl descubri como usar objetos en modulos :D
]]
wave = {}
function wave.init(path)
	if not path then return end
	local obj = {y = 0,x = 0,img = image.load(path)}
	function obj:blit(vel,trans)
		if trans == nil then trans = 255 end
		if vel == nil then vel = 2 end	
		if obj.x < 0 then obj.x = obj.x + 480 end
		obj.x = obj.x + vel
		local x = obj.x
		local y = obj.y
		if x >= 480 then obj.x = 0 end
		obj.img:blit(x,y,trans)
		obj.img:blit(x - 480,y,trans)
	end
	return obj
end


