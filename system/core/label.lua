--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Modulo:	Label Manager
	Descripcion: Gestor del Label´s "Mensajes al escritorio"
]]
__LABEL_INFO = 0
__LABEL_QUESTION = 1
__LABEL_ALERT = 2
label = {
	audio = sound.load("system/sound/msg.wav"),
	img = image.new(200,60,color.white),
	close = kernel.loadimage("system/images/label/close.png"),
	info = kernel.loadimage("system/images/label/label.png",40,40),
	time = timer.new(),
	alfa = 1,
	title = {},
	text = {},
	mode = {},
	lockkey = 0,
	}
function label.run()
	if label.alfa > 0 then
		draw.fillrect(275,185,200,60,color.white:a(label.alfa))
		label.close:blit(455,190,label.alfa)
		if cursor.isOver(275,185,200,60,label.lockkey) then
			label.checkLockCursor()
		else
			label.checkUnlockCursor()
		end
		if cursor.isOver(455,190,15,15,label.lockkey) then
			label.close:blitadd(455,190,60)
			if buttons.cross then
				label.next()
			end
		else
			label.close:blitsub(455,190,20)
		end
		label.info:blitsprite(285,195,label.mode[1] or 0,label.alfa)
		screen.print(405,190,label.title[1] or "",0.6,color.gray:a(label.alfa),0x0,512)
		screen.print(335,205,label.text[1] or "",0.6,color.gray:a(label.alfa),0x0)
	else
		label.checkUnlockCursor()
	end
	
	if label.time:time() > 10000 and label.alfa > 0 then
		label.alfa -= 1
	elseif label.alfa < 1 then
		label.next()
	end
end
function label.call(title,txt,mode)
	if not mode then mode = 0 end
	label.alfa = 255
	table.insert(label.title,title)
	table.insert(label.text,wordwrap(txt,140,0.6))
	table.insert(label.mode,mode)
	if #label.title < 2 then
		label.time:stop()
		label.time:reset()
		label.time:start()
	end
end
function label.next()
	label.alfa = 0
	table.remove(label.title, 1)
	table.remove(label.text, 1)
	table.remove(label.mode, 1)
	if #label.text > 0 and #label.title > 0 then
		label.alfa = 255
		label.time:stop()
		label.time:reset()
		label.time:start()
		label.audio:play()
	end
end
function label.checkLockCursor()
	if label.lockkey == 0 then
		cursor.lock(9)
		label.lockkey = 9
	end
end
function label.checkUnlockCursor()
	if label.lockkey == 9 then
		cursor.unlock()
		label.lockkey = 0
	end
end
