--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Modulo:	Gadget
	Descripcion: Notas recordatorio
]]
gadget = {}

function gadget.init(path,input)
	gadget.img_background = image.load(path.."note.png")
	gadget.img_background:resize(64,72)
	gadget.txt = files.read(path.."note.ini")
	gadget.settxt()
end
function gadget.run(x,y)
	gadget.img_background:blit(x,y)
	screen.print(x+2,y+12,gadget.txt,0.5,color.gray)
	if cursor.isOver(x,y+12,64,60) then
	if buttons.cross then 
		gadget.txt = gadget.txt:gsub("\n","")
		local txt = iosk.init("Sticky Note",gadget.txt,100,nil)
		if txt then
			gadget.txt = txt
			files.write(gadget.path.."note.ini",txt)
		end
		gadget.settxt()
	end
		cursor.set("text")
	else
		cursor.set("normal")
	end

end

function gadget.settxt()
	gadget.txt = wordwrap(gadget.txt,0.4,60)
end