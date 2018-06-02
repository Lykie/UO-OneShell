--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Modulo:	Gadget
	Descripcion: Visor de ram
]]

gadget = {
	--totalramfree = os.totalram(),
	level = 0,
	crono = 0, -- Timer en conjunto con millis()
	}
function gadget.init(path)
	gadget.bg = image.load(path.."back.png")
	gadget.puntero = image.load(path.."puntero.png")
	gadget.tapa = image.load(path.."tapa.png")
end

function gadget.run(x,y)
	if millis()-gadget.crono >= 2000 then -- 2 segundo´s
		gadget.crono = millis()
		gadget.refresh() 
	end
	gadget.bg:blit(x,y)
	gadget.puntero:rotate(gadget.getAngle() + 5)
	gadget.puntero:center(16,0)
	gadget.puntero:blit(x + 32,y + 37)
	gadget.tapa:blit(x,y)
	screen.print(x + 21,y + 47,"RAM",0.47,color.black)
	if cursor.isOver(x,y,70,70) then cursor.label("RAM Usage: "..string.format("%.2f",gadget.porcent).."%") end
	
end

function gadget.getAngle() -- revisar puse lo de subir gradualmente
	if gadget.level < gadget.porcent-0.1 then
		gadget.level = gadget.level + 0.1
	elseif gadget.level > gadget.porcent then
		gadget.level = gadget.level - 0.1
	end
	tiempo_grados = math.floor(((360 - 100)/ 100) * gadget.level)
	return tiempo_grados
end

function gadget.refresh()
	gadget.porcent = 100 - ((os.ram() * 100 ) / __SHELL_MAX_RAM)--gadget.totalramfree)
end

gadget.refresh()