-----------------------------------------------------------
------------- ## iThunder OS Keyboard Module ## -----------
-------------- @@ Creative Commons License @@ -------------
------------------ Modified by David Nunez ----------------
-----------------------------------------------------------

--[[
	Este modulo fue basado en el codigo de iThunder OS SDL y fue 
	modificado para ser utilizado como libreria, aprobado por su autor,
	pues este codigo fue obtenido de su autoridad en twitter.
]]--

iosk = {}--load = false
iosk.img = {}

iosk.text = {}
iosk.tipText = ""
iosk.type = 0
iosk.maxChars = 50
iosk.tfstate = 0
iosk.tftimer = timer.new()

iosk.charTable = {}
iosk.charTable[1] = {
	{ "q","Q" },
	{ "w" , "W" },
	{ "e","é","è","ê","ë","E","É","Ê" },
	{ "r","R" },
	{ "t","T" },
	{"y","Y"},
	{"u","U","ú","ù","û","ü","Ú","Û","Ü"},
	{"i","I","í","ì","î","ï","Í","Î","Ï"},
	{"o","O","ó","ò","ô","ö","Ó","Ô","Ö"},
	{"p","P"},
	{"a","A","á","à","â","ä","Á","Â","Ä"},
	{"s","S"},
	{"d","D"},
	{"f","F"},
	{"g","G"},
	{"h","H"},
	{"j","J"},
	{"k","K"},
	{"l","L"},
	{"z","Z"},
	{"x","X"},
	{"c","C"},
	{"v","V"},
	{"b","B"},
	{"n","N","ñ","Ñ"},
	{"m","M"}
}

iosk.charTable[2] = {
	{"1"},
	{"2"},
	{"3"},
	{"4"},
	{"5"},
	{"6"},
	{"7"},
	{"8"},
	{"9"},
	{"0" ,"="},
	{"!"},
	{"¿","?"},
	{'"',"'"},
	{"@","%"},
	{"#","&","%"},
	{"$"},
	{"+","-","/","="},
	{"(",")"},
	{"[","]"},
	{"{","}"},
	{"<",">"},
	{"*","/"},
	{"ç","Ç"},
	{",",";"},
	{".",":"},
	{"-","_"}
}

function iosk.loadImage(name)
	local path = "system/images/iosk/"
	return image.load(path..name)
end

function iosk.loadResources()
	--if iosk.load == true then return end
	iosk.img.little_selector = iosk.loadImage("little_selector.png")
	iosk.img.medium_selector = iosk.loadImage("medium_selector.png")
	iosk.img.leftArrow = iosk.loadImage("left_arrow.png")
	iosk.img.rightArrow = iosk.loadImage("right_arrow.png")
	iosk.img.letter_selector = iosk.loadImage("letter_selector.png")
	iosk.img.header = iosk.loadImage("headerSmallText.png")
	iosk.img.space_selector = iosk.loadImage("space_selector.png")
	iosk.img.keyboard_normal = iosk.loadImage("keyboard_normal.png")
	iosk.img.keyboard_special = iosk.loadImage("keyboard_special.png")
	--iosk.load = true
end

function iosk.free()
	iosk.img.header = nil
	iosk.img.space_selector = nil
	iosk.img.keyboard_normal = nil
	iosk.img.keyboard_special = nil
	collectgarbage("collect") -- limpiamos la ram para asegurarnos de la maxima limpieza.
end

function iosk.init(tip_text,text,max_char,type)
	local screenshot = screen.buffertoimage()
	tiempo:stop()
	buttons.read()
	--CURSOR.unlock()	-- Desbloquea los controles
 	
	iosk.y = 250
	iosk.hy = -132 
	iosk.alfa = 0
	
	iosk.isRun = true
	iosk.isClose = false
	iosk.isCanceled = false
	
	iosk.keyFocus = 1
	iosk.charFocus = 1
	iosk.table = 1
	
	if text ~= nil then
		iosk.text = iosk.explodeText(text)
	else
		iosk.text = {}
	end

	if tip_text ~= nil then
		iosk.tipText = tip_text
	else
		iosk.tipText = "1SHELL - iOSK - Enter Text"
	end
	if type then
		iosk.table = type
	--else
		--iosk.table = 1
	end
	
	if max_char ~= nil then
		iosk.maxChars = max_char
	else
		iosk.maxChars = 0
	end

	iosk.textFocus = #iosk.text
	
	iosk.tftimer:reset()
	iosk.tftimer:start()
	
	iosk.loadResources()
	iosk.hy = 0 - iosk.img.header:geth()
	--local tmpx,tmpy = cursor.xy()
	cursor.enable(false)
	while iosk.isRun do
		buttons.read()
		screenshot:blit(0,0)
		--back:blit(0,0)
		--cursor.enable(POPUP.state())
		--cursor.controls() -- Comprobamos Movimientos del cursor
		iosk.run()
		--POPUP.draw() -- Funciones del menu POPUP
		--cursor.draw() -- Funciones del Cursor
		if buttons.note then takeshot("OneShell") end -- Si presionan la tecla note, toma una captura! :D
		screen.flip()
		--CORE.run({ home = false })	-- Corremos el nucleo de fishell
	end
	--cursor.xy(tmpx,tmpy)
	cursor.enable(true)
	--postImage(screenshot)
	iosk.free()
	screenshot:blit(0,0)
	tiempo:start()
	if iosk.isCanceled == true then
		return nil
	else
		return iosk.getText()
	end
	
end

function iosk.run()
	
	if iosk.isClose == false then
		iosk.y = iosk.y - 4
		iosk.hy = iosk.hy + 3
		iosk.alfa = iosk.alfa + 7
	else
		iosk.y = iosk.y + 4
		iosk.hy = iosk.hy - 4
		iosk.alfa = iosk.alfa - 7
	end
	
	if iosk.alfa > 255 then
		iosk.alfa = 255
	end
	
	if iosk.hy > 0 then
		iosk.hy = 0
	end
	
	if iosk.y < 132 then
		iosk.y = 132
	end
	
	if iosk.isClose == true and iosk.alfa <= 0 then
		iosk.isRun = false
		return
	end
	
	iosk.draw()
end

function iosk.drawUpBar()
	local text = iosk.getText()
	
	if iosk.textFocus < 0 then
		iosk.textFocus = 0
	end
	
	if iosk.textFocus > #text then
		iosk.textFocus = #text
	end
	
	iosk.img.header:blit(0,iosk.hy,iosk.alfa)
	screen.print(16,iosk.hy + 39,text,0.65,color.new(30,30,30,iosk.alfa),0x0)
	
	screen.print(16,iosk.hy + 12,iosk.tipText,0.7,color.new(20,20,20,iosk.alfa),0x0)
	screen.print(16,iosk.hy + 11,iosk.tipText,0.7,color.new(230,230,320,iosk.alfa),0x0)
	
	if iosk.tfstate == 0 then
		if iosk.tftimer:time() >= 300 then
			iosk.tftimer:reset()
			iosk.tftimer:start()
			iosk.tfstate = 1
		end
	else
		local fx = 16 + screen.textwidth(utf8.sub(text,1,iosk.textFocus),0.65)
		draw.fillrect(fx,iosk.hy + 39,1,12,color.new(30,30,30,iosk.alfa))
		if iosk.tftimer:time() >= 450 then
			iosk.tftimer:reset()
			iosk.tftimer:start()
			iosk.tfstate = 0
		end
	end
	
	if buttons.l then
		iosk.textFocus = iosk.textFocus - 1
		iosk.renewTextFocus()
	end
	
	if buttons.r then
		iosk.textFocus = iosk.textFocus + 1
		iosk.renewTextFocus()
	end
end

function iosk.draw()

	iosk.drawUpBar()
	
	if iosk.table == 1 then
		iosk.img.keyboard_normal:blit(0,iosk.y,iosk.alfa)
	else
		iosk.img.keyboard_special:blit(0,iosk.y,iosk.alfa)
	end
	
	if iosk.y ~= 132 then return end
	
	local fx,fy = iosk.getFocusPosition()
	
	if buttons.held.cross then
		if iosk.keyFocus == 27 then elseif iosk.keyFocus == 28 then elseif iosk.keyFocus == 29 then else
			local ftx = fx - 8
			local fty = fy - 28
			
			local laa = 255 	-- Left Arrow Alfa
			local raa = 255		-- Right Arror Alfa
			
			if iosk.charFocus == 1 then laa = 150 end
			if iosk.charFocus == #iosk.charTable[iosk.table][iosk.keyFocus] then raa = 150 end
			
			iosk.img.letter_selector:blit(ftx,fty)
			
			iosk.img.leftArrow:blit(ftx + 3,fty + 11,laa)
			iosk.img.rightArrow:blit(ftx + 31,fty + 11,raa)
			
			screen.print(ftx + 20,fty + 11,iosk.charTable[iosk.table][iosk.keyFocus][iosk.charFocus],0.9,color.new(0,0,0),0x0,__ACENTER);
			
			if buttons.left then
				iosk.charFocus = iosk.charFocus - 1
			end
			
			if buttons.right then
				iosk.charFocus = iosk.charFocus + 1
			end
			
			if iosk.charFocus <= 0 then
				iosk.charFocus = 1
			end
			
			if iosk.charFocus >= #iosk.charTable[iosk.table][iosk.keyFocus] then
				iosk.charFocus = #iosk.charTable[iosk.table][iosk.keyFocus]
			end
		end
	else
		if iosk.keyFocus == 27 then
			iosk.img.medium_selector:blit(fx,fy,iosk.alfa)
		elseif iosk.keyFocus == 28 then
			iosk.img.space_selector:blit(fx,fy,iosk.alfa)
		elseif iosk.keyFocus == 29 then
			iosk.img.medium_selector:blit(fx,fy,iosk.alfa)
		else
			iosk.img.little_selector:blit(fx,fy,iosk.alfa)
		end
		
		if buttons.left then
			iosk.moveFocus("left")
		end
		
		if buttons.right then
			iosk.moveFocus("right")
		end
		
		if buttons.up then
			iosk.moveFocus("up")
		end
		
		if buttons.down then
			iosk.moveFocus("down")
		end
		
		if buttons.square then
			iosk.removeChar()
		end
		
		if buttons.triangle then
			iosk.enterChar(" ")
		end
	end
	
	if buttons.start then
		iosk.isClose = true
		return
	end
	
	if buttons.released.cross then
		if iosk.keyFocus >= 1 and iosk.keyFocus <= 26 then
			iosk.enterChar(iosk.charTable[iosk.table][iosk.keyFocus][iosk.charFocus])
		elseif iosk.keyFocus == 27 then
			if iosk.table == 1 then
				iosk.table = 2
			else
				iosk.table = 1
			end
			iosk.charFocus = 1
		elseif iosk.keyFocus == 28 then
			iosk.enterChar(" ")
		elseif iosk.keyFocus == 29 then
			iosk.isClose = true
		end
		return
	end
	
	if buttons.select then
		--[[opciones={
		{txt = "Copy", action = nil, args = nil, state = false, overClose = true},
		{txt = "Cut", action = nil, args = nil, state = false, overClose = true},
		{txt = "Paste", action = nil, args = nil, state = false, overClose = true},
		}
		POPUP.setElements(opciones)
		POPUP.activate(16,iosk.hy + 46)
		cursor.xy(18,iosk.hy + 48)]]
		if iosk.table == 1 then
			iosk.table = 2
		else
			iosk.table = 1
		end
		
		iosk.charFocus = 1
		return
	end
	
	if buttons.circle then
		iosk.isClose = true
		iosk.isCanceled = true
	end
end

------------------

function iosk.getText()
	return table.concat(iosk.text)
end

function iosk.explodeText(texto)
	local result = {}
		
	if texto == nil then return result end
	
	for i = 1,#texto do
		table.insert(result,string.sub(texto, i, i))
	end
		
	return result;
end

function iosk.getFocusPosition()
	local x,y = 0
	local f = iosk.keyFocus 
	
	if f >= 1 and f <= 10 then
		x = 35 + ((f - 1) * 43) 
		y = iosk.y + 8
	elseif f >= 11 and f <= 19 then
		x = 57 + ((f - 11) * 43) 
		y = iosk.y + 42
	elseif f >= 20 and f <= 26 then
		x = 100 + ((f - 20) * 43) 
		y = iosk.y + 76
	else
		if f == 27 then
			x = 20
			y = iosk.y + 108
		elseif f == 28 then
			x = 94
			y = iosk.y + 108
		elseif f == 29 then
			x = 401
			y = iosk.y + 108
		end
	end
	
	return x,y
end

function iosk.moveFocus(dir)
	iosk.charFocus = 1
	
	if dir == "left" then 
		if iosk.keyFocus == 1 then
			iosk.keyFocus = 10
			return
		end
		if iosk.keyFocus == 11 then
			iosk.keyFocus = 19
			return
		end
		if iosk.keyFocus == 20 then
			iosk.keyFocus = 26
			return
		end
		if iosk.keyFocus == 27 then
			iosk.keyFocus = 29
			return
		end
		iosk.keyFocus = iosk.keyFocus - 1
	elseif dir == "right" then
		if iosk.keyFocus == 10 then
			iosk.keyFocus = 1
			return
		end
		if iosk.keyFocus == 19 then
			iosk.keyFocus = 11
			return
		end
		if iosk.keyFocus == 26 then
			iosk.keyFocus = 20
			return
		end
		if iosk.keyFocus == 29 then
			iosk.keyFocus = 27
			return
		end
		iosk.keyFocus = iosk.keyFocus + 1
	elseif dir == "down" then
		if iosk.keyFocus == 11 then
			iosk.keyFocus = 20
			return
		end
		
		if iosk.keyFocus == 10 then
			iosk.keyFocus = 19
			return
		end
		
		if iosk.keyFocus == 19 then
			iosk.keyFocus = 26
			return
		end
		
		if iosk.keyFocus >= 1 and iosk.keyFocus <= 10 then
			iosk.keyFocus = iosk.keyFocus + 10
		elseif iosk.keyFocus >= 11 and iosk.keyFocus <= 19 then
			iosk.keyFocus = iosk.keyFocus + 8
		elseif iosk.keyFocus >= 20 and iosk.keyFocus <= 26 then
			iosk.keyFocus = 28
		else
			iosk.keyFocus = 1
		end
	elseif dir == "up" then
	
		if iosk.keyFocus >= 1 and iosk.keyFocus <= 10 then
			iosk.keyFocus = 28
		elseif iosk.keyFocus >= 11 and iosk.keyFocus <= 19 then
			iosk.keyFocus = iosk.keyFocus - 10
		elseif iosk.keyFocus >= 20 and iosk.keyFocus <= 26 then
			iosk.keyFocus = iosk.keyFocus - 8
		else
			iosk.keyFocus = 20
		end
	end
	
	if iosk.keyFocus < 1 then iosk.keyFocus = 1 end
	if iosk.keyFocus > 29 then iosk.keyFocus = 29 end
end

function iosk.enterChar(char)
	if iosk.maxChars ~= nil and #iosk.text >= iosk.maxChars and iosk.maxChars > 0 then
		return
	end
	
	iosk.textFocus = iosk.textFocus + 1
	table.insert(iosk.text,iosk.textFocus,char)
	iosk.renewTextFocus()
end

function iosk.removeChar(index)
	if index == nil then
		index = iosk.textFocus
	end
	
	if index == 0 then
		index = 1
	end
	
	if iosk.text[index] == nil then return end
	
	table.remove(iosk.text,index)
	iosk.textFocus = iosk.textFocus - 1
	iosk.renewTextFocus()
end

function iosk.renewTextFocus()
	iosk.tfstate = 1
	iosk.tftimer:reset()
	iosk.tftimer:start()
end
