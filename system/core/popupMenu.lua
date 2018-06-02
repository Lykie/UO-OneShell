--[[
	Modulo PopMenu
	Creado por: zerozelta (zerozelta@hotmail.com)
	Modificado, adaptado y mejorado a 1shell por: davisdev (david.nunezaguilera.131@gmail.com)

	Descripcion:
	Documentacion para el menu POPUP.
	--	Contenido de cada entrada :
	{ 
		STRING texto,
		FUNCTION / STRING action,
		BOOLEAN state,
		BOOLEAN overClose
	}
	texto, descripcion de la funcion.
	action, codigo a ejecutar function or chunk.
	state, habilita la ejecucion.
	overClose, ejecutar de las siguientes maneras (true: Acion al cerrar, false: Accion inmediata)
	--
]]--

POPUP = {}
POPUP.x = 0
POPUP.y = 0
POPUP.w = 150 
POPUP.h = 0
POPUP.trans = 0
POPUP.key = 10

POPUP.fontColor = color.new(20,20,20)
POPUP.fontColorFocus = color.new(240,240,240)
POPUP.elements = {}

POPUP.activado = false
POPUP.desactivar = false
POPUP.chunkToClose = nil
POPUP.argsToClose = nil
POPUP.tmpef1 = false

function POPUP.draw()
if POPUP.activado == false then return end

if POPUP.desactivar == false then
	POPUP.trans = POPUP.trans + 10
	cursor.lock(POPUP.key)
else
	POPUP.trans = POPUP.trans - 20
	cursor.unlock()
end

if POPUP.trans < 0 then POPUP.trans = 0 elseif POPUP.trans > 255 then POPUP.trans = 255 end

if POPUP.trans == 0 and POPUP.desactivar == true then
	if POPUP.tmpef1 == false then
		POPUP.tmpef1 = true
	else
		POPUP.desactivate();
		return 
	end
end

local nume = #POPUP.elements

if nume == 0 then return end

if POPUP.w + POPUP.x > 480 then
	POPUP.x = POPUP.x - ((POPUP.w + POPUP.x) - 480) - 6
end

if POPUP.y + (18 * (nume) + (nume * 2)) > 272 then
	POPUP.y = POPUP.y - (POPUP.y + (18 * (nume) + (nume * 2)) - 272) - 6
end

draw.fillrect(POPUP.x,POPUP.y,POPUP.w + 2,POPUP.h + 2,color.new(225,225,225,POPUP.trans))
draw.rect(POPUP.x,POPUP.y,POPUP.w + 2,POPUP.h + 2,color.new(50,50,50,POPUP.trans))

if POPUP.h < 18 * (nume) + (nume * 2) then
	POPUP.h = POPUP.h + 5
	return 
end
local ix,iy = -1,-1
local fx,fy = 0,0
for i = 1,nume do
	cx = POPUP.x + 2
	cy = POPUP.y + 2 + (18 * (i - 1) + ((i - 1) * 2))
	if ix == -1 and iy == -1 then ix,iy = cx,cy end
	--if buttons.cross and cursor.isOver(cx,cy,POPUP.w - 4,18,POPUP.key) then POPUP.elements[i].accion() end
	if POPUP.elements[i].state == true and cursor.isOver(cx,cy,POPUP.w - 4,18,POPUP.key) then
		
		--if POPUP.desactivar == false then cursor.overOn("link",POPUP.key) end
		
		
		--draw.fillrect(cx,cy + 18,POPUP.w - 2,1,color.new(255,255,255,POPUP.trans))
		draw.fillrect(cx,cy,POPUP.w - 2, 18, color.new(110,110,110,POPUP.trans))
		
		if POPUP.trans == 255 then
			screen.print(cx + 3,cy + 3,POPUP.elements[i].txt,0.5,POPUP.fontColorFocus,0x0)
		end
		--draw.fillrect(cx,cy,POPUP.w - 2,18,color.new(255,255,255,POPUP.trans-155))
		if buttons.cross then
			if POPUP.elements[i].overClose ~= nil and POPUP.elements[i].overClose == true then
				POPUP.chunkToClose = POPUP.elements[i].action
				POPUP.argsToClose = POPUP.elements[i].args
				POPUP.desactivar = true
			else
				--assert(loadstring(POPUP.elements[i].action))();
				if POPUP.elements[i].args ~= nil then
					POPUP.elements[i].action(POPUP.elements[i].args)
				else
					POPUP.elements[i].action()
				end
				POPUP.desactivar = true
			end
		end
		--cursor.set("select")
	else
		--cursor.set("normal")
		if POPUP.trans == 255 then
			screen.print(cx + 3,cy + 3,POPUP.elements[i].txt,0.5,POPUP.fontColor,0x0)
		end
	end
	
	if POPUP.elements[i].state == false then 
		draw.fillrect(cx,cy,POPUP.w - 2,18,color.new(170,170,170,POPUP.trans-155))	
	end
end
fx,fy = POPUP.w - 4,cy - iy + 18
if cursor.isOver(ix,iy,fx,fy,POPUP.key) then 
	cursor.set("select")
else
	cursor.set("normal")
end
if buttons.triangle or buttons.circle or buttons.r or buttons.l or buttons.home then
	POPUP.desactivar = true
	buttons.read()
end

if cursor.isOver(POPUP.x,POPUP.y,POPUP.w,POPUP.h,POPUP.key) == false then
	if buttons.cross then
		POPUP.desactivar = true
		buttons.read()
	end
end

end

function POPUP.activate(x,y,w)
	POPUP.trans = 0
	POPUP.h = 0
	
	if x == nil then
		POPUP.x = cursor.x
	else
		POPUP.x = x
	end
	
	if y == nil then
		POPUP.y = cursor.y
	else
		POPUP.y = y
	end
	
	if w == nil then
		POPUP.w = POPUP.getWidth()
	else
		POPUP.w = math.max(POPUP.getWidth(),w) 
	end
	
	POPUP.activado = true
	POPUP.desactivar = false
	cursor.lock(POPUP.key)	   		-- Bloquea los controles para los demas componentes
	--cursor.set("select")
end

function POPUP.desactivate()
	cursor.set("normal")
	POPUP.trans = 0
	POPUP.activado = false
	POPUP.desactivar = false
	POPUP.tmpef1 = false

	if POPUP.chunkToClose ~= nil then
		--assert(loadstring(POPUP.chunkToClose))();
		if POPUP.argsToClose ~= nil then
			--[[local arg1,arg2
			if type(POPUP.argsToClose) == "table" then
				arg1--,arg2 = POPUP.argsToClose[1],POPUP.argsToClose[2]
			else
				arg1 = POPUP.argsToClose
			end
			POPUP.chunkToClose(arg1,arg2)]]
			POPUP.chunkToClose(POPUP.argsToClose)
		else
			POPUP.chunkToClose()
		end
		POPUP.chunkToClose = nil
		POPUP.argsToClose = nil
	end

	POPUP.w = 10
	POPUP.elements = nil
	POPUP.elements = {}
end

function POPUP.getWidth()
	local w = 10
	
	for i = 1,#POPUP.elements do
		w = math.max(w,screen.textwidth(POPUP.elements[i].txt,0.5))
	end
	
	w = math.min(350,w)
	
	return w + 10
end

function POPUP.setElements(elements)
	POPUP.elements = nil
	POPUP.elements = elements
end
function POPUP.state()
	--[[if POPUP.activado == true then
		return false
	else
		return true
	end]]
	return POPUP.activado
end