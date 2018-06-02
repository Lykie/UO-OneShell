function onDebug(msg) -- OneShell screen debug
	amg.finish() -- Term 3D
	--if not color.white then color.loadpallete() end
	-- Decode Msg error.
	local path,errorline,details=msg:match("(.+):(%d+):(.+)")
	if path == nil then
		path,details=msg:match("(.+):(.+)")
		if path == nil then
			details=msg
		end
	end
	
	local res = os.message("Use FTP To debug?",1)
	if res == 1 then
		wlan.connect() -- Mostramos el dialogo de red
		local islivered = true
		local dgbip = "XX:XX:XX:XX"
		if not wlan.isconnected  (  )  then
			islivered = false
		end
		if islivered then
			ftp.init() -- iniciamos el ftp
			dgbip= wlan.getip()
		end
		while true do
			screen.print(10,10,"FTP Debug")
			screen.print(10,20,"Server FTP:/"..dgbip)
			screen.print(10,30,"File: "..tostring(path))
			screen.print(10,40,"Line: "..tostring(errorline))
			screen.print(10,50,"Error: "..tostring(details))
			screen.print(10,60,"Press X to restart or Press O to exit")
			screen.flip()
			buttons.read()
			if buttons.cross then
				os.restart()
			end
			if buttons.circle then
				os.exit()
			end
		end
	end
	
	local sel,x,y,t = 1,2,2,1
	local mode={"Normal","Shift","Numeric"}
	local layout={
	{	--normal
		{{"z","y","x",">"},{"w","v","u","<"},{"t","s","r","="}},
		{{"q","p","o","+"},{"ñ","n","m",","},{"l","k","j","."}},
		{{"i","h","g",")"},{"f","e","d","("},{"c","b","a",'"'}}
	},
	{	--shift
		{{"Z","Y","X","\\"},{"W","V","U","/"},{"T","S","R","%"}},
		{{"Q","P","O","-"},{"Ñ","N","M","*"},{"L","K","J",":"}},
		{{"I","H","G","]"},{"F","E","D","["},{"C","B","A","'"}}
	},
	{	--numerico
		{{"","9","","0"},{"","8","","^"},{"","7","","_"}},
		{{"","6","","}"},{"","5","","#"},{"","4","","{"}},
		{{"","3","",""},{"","2","","~"},{"","1","",""}}
	}
	}
	font.setdefault()
	usb.mstick() -- Enable USB
	local text = {}
	if path then
		for line in io.lines(path) do
			--line = string.gsub(line, '\t', '   ')
			if line:byte(#line) == 13 then line = line:sub(1,#line-1) end --Quitar CR == 13
			table.insert(text, line)
		end
		scroll.set("shellbug",text,15)
	end
	if errorline then --Si obtenemos linea la ajustamos
		for i=1,tonumber(errorline)-1 do
			scroll.down("shellbug")
		end
	end
	local dbg_bk = image.load("system/theme/debugback.png")--image.load("system/theme/DebugScreen.png")
	local dbg_kbd = image.load("system/theme/OneOSK.png",120,120)
	local dbg_kbd_kb = image.load("system/theme/OneOSKbk.png")
	local x_path,xdetail = 3,3
	local ch = 0
	local time = timer.new()
	time:start()
	local show_kbd = false
	local insert = ""
	local mod_txt = false
	while true do
		buttons.read()
		draw.fillrect(0,0,480,272,color.white) -- Fondo
		if dbg_bk then dbg_bk:blit(0,0,64) end -- Logo :P
		draw.gradrect(0,0,480,22,color.white,color.new(200,200,200),0) -- Barra superior
		x_path = screen.print(x_path,5,tostring(path),0.7,color.grey,0x0,__SLEFT,210) -- Ruta error
		if mod_txt then
			screen.print(220,5,"*",0.7,color.red,0x0,__ARIGHT)
		end
		draw.line(220, 0, 238-3-15, 21, color.gray)
		screen.print(240+68-15,5,"OneShell Debugger", 0.7, color.grey,0x0,512) -- title :P
		draw.line(308+68+5-15, 0, 308+68+5-15, 21, color.gray)
		screen.print(381-15, 5, os.date("%I:%M %p"), 0.6, color.grey) -- Date :P
		draw.line(430, 0, 430, 21, color.gray)
		screen.print(480-45, 5, string.format("%03d",batt.lifepercent()).."%", 0.7, color.grey) -- Batt :P
		--[[
		----.." | "..screen.fps().."f/s | ",
		--draw.gradrect(432, 0, 432, 22, color.new(255, 255, 255), color.new(200, 200, 200), 0)
		draw.line(432, 0, 432, 21, color.gray)
		draw.line(354, 0, 354, 21, color.gray)
		screen.print(432+4, 5, info_text, 0.7, color.grey)
		screen.print(355, 5, clock_text, 0.7, color.new(64, 64, 64))]]
		draw.line(0, 21, 480, 21, color.gray)
		-- Pie de página
		draw.fillrect(0, 252, 480, 20, color.new(230, 230, 230))
		xdetail = screen.print(xdetail, 256,tostring(details).." Line:"..tostring(errorline), 0.6, color.grey,0x0,__SLEFT,220)
		--draw.fillrect(230, 252, 480, 20, color.new(230, 230, 230))
		screen.print(233, 256, "Ln "..scroll["shellbug"].sel.." / "..scroll["shellbug"].maxim..", Ch "..ch.." / "..screen.fps().."f/s", 0.6, color.grey)
		draw.line(0, 252, 480, 252, color.gray)
		draw.line(230, 252, 230, 272, color.gray)
		
		if time:time() > 2000 or (buttons.up or buttons.down or buttons.right or buttons.left or buttons.r or buttons.l) then time:reset() time:start() end
		-- Draw Text Area
		local hy = 25
		for i=scroll["shellbug"].ini,scroll["shellbug"].lim do
			if i == scroll["shellbug"].sel then 
				draw.fillrect(0, hy, 480, 15, color.new(230,230,230))
			end
			local fixtxt = string.gsub(text[i], '\t', ' ')
			screen.print(10,hy,fixtxt,0.6,color.black)
			if i == scroll["shellbug"].sel and time:time() < 1000 then
				local w = screen.textwidth(utf8.sub(fixtxt, 1, ch),0.6)
				draw.line(w+10,  hy,w+10,hy+15, color.black)
			end
			
			hy += 15
		end
		if scroll["shellbug"].maxim> 15 then
			local pos_height = math.max(225/scroll["shellbug"].maxim, 5)
			draw.fillrect(475, 25, 5, 225, color.new(200,200,200))
			draw.fillrect(475, 25+((225-pos_height)/(scroll["shellbug"].maxim-1))*(scroll["shellbug"].sel-1), 5, pos_height, color.new(55,200,255))
		end
		--Swicht Kbd/editor
		if buttons.start then
			show_kbd = not show_kbd
		end
		insert = ""
		if show_kbd then -- Buttons Keyboard
			-- Draw
			--if dbg_kbd_kb then dbg_kbd_kb:blit(355,127,170) end
			draw.fillrect(355,127,120,120,color.new(200,200,200):a(225))
			draw.fillrect(475-x*40,247-y*40,40,40,color.gray)
			if dbg_kbd then dbg_kbd:blitsprite(355,127,t-1) end
			-- Move
			if buttons.held.up then	y = 3
			elseif buttons.held.down then y = 1
			else y = 2 end
			if buttons.held.right then x = 1
			elseif buttons.held.left then x = 3
			else x = 2 end
			-- Text
			if buttons.circle then insert = insert..layout[t][y][x][1]
			elseif buttons.cross then insert = insert..layout[t][y][x][2]
			elseif buttons.square then insert = insert..layout[t][y][x][3]
			elseif buttons.triangle then insert = insert..layout[t][y][x][4]
			end
			-- Modos del teclado
			if buttons.select then
				t+=1
				if t>3 then t=1 end
			end
		else -- Modo editor
			if buttons.up or buttons.held.l then
				scroll.up("shellbug")
			elseif buttons.down or buttons.held.r then
				scroll.down("shellbug")
			end
			if buttons.left and ch > 0 then
				ch -= 1
			elseif buttons.right and ch < utf8.len(text[scroll["shellbug"].sel]) then
				ch += 1
			end
			if buttons.cross then
			--elseif buttons.triangle then
				--insert = insert.." "
			elseif buttons.circle then
				insert = insert.."\t"
			elseif buttons.square then
				
			end
		end
		-- new Insert letter´s
			if insert ~= "" then
				local tmp = text[scroll["shellbug"].sel] -- move to tmp :P
				if ch<1 then
					ch = 1
					tmp = insert..utf8.sub(tmp, ch, utf8.len(tmp)) 
					ch = utf8.len(insert)
				else
					tmp = utf8.sub(tmp, 1, ch)..insert..utf8.sub(tmp, ch + 1, utf8.len(tmp))
					ch = ch + utf8.len(insert)
				end
				text[scroll["shellbug"].sel] = tmp -- refresh to tmp
				mod_txt = true -- alteraron el texto :P
			end
		--screen.print(240,10,"OneShell Debugger",0.7,color.gray,0x0,512)
		
		--"File: "..tostring(path).." Line:"..tostring(errorline).."\nDetails:"..tostring(details),0.7,color.gray)
		screen.flip()
		if (buttons.home or buttons.triangle) and not show_kbd then
			if mod_txt then -- Fue alterado :P
				if files.exists(path) then
					option = os.message("Rewrite the script?", 1)
					if option == 1 then
						tmp_file = io.open(path, "w+")
						for i=1,#text do
							tmp_file:write(text[i].."\n")
						end
						tmp_file:flush()
						tmp_file:close()
						mod_txt = false
						os.delay(50)
						os.restart()
					elseif option == 0 then
						os.exit()
					end
				end
			else -- No lo alteraron :P
				option=os.message("Return to XMB?", 1)
				if option == 1 then
					os.exit()
				else
					os.restart()
				end
			end
		end
	end
	--local report = {"File: "..tostring(path),"Line:"..tostring(errorline),"Details:"..tostring(details)}
	--if box  and box.isinit then box.new("OneShell not respond!",report)
	--else os.message(msg)
	--end
	os.restart()
end

