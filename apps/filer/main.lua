--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Modulo:	App
	Descripcion: Explorador de archivos.
]]
app = sdk.newApp("File Explorer",color.new(64,64,64,100))
app.count_cycle = 0;
app.list = nil
app.icons = sdk.mime.get()--{}
app.xscroll = 0
app.ruta = __SHELL_IS_DEVROOT

function app.loadicons(path)
	--[[os.delay(250)
	local lista_files = files.listfiles(path)
	for i=1,#lista_files do
		local index = string.lower(lista_files[i].name:sub(1,-5))
		if index == "photothumb" then
		else
		files.write("logmime.txt","'"..index.."'"..",","a+")
		app.icons[index] = image.load(lista_files[i].path)
		app.icons[index]:resize(40,36)
		end
		--app.icons[lista_files[i].name:sub(1,-5)]:blit(0,0)
		--screen.print(10,60,lista_files[i].name:sub(1,-5))
		--screen.flip()
		--buttons.waitforkey()
	end]]
end

function app.find(input)
	local findname = files.nopath(input)
	if not findname then findname = "" end
	findname = findname:lower()
	for y=1,#app.list do
		for x=1,#app.list[y] do
			if app.list[y][x].name:lower() == findname then
				app.focus[1] = y
				app.focus[2] = x
			end
		end
	end
end
function app.init(path,input)
--app.go_forwardicon = image.load(path.."go-forward.png")

app.keyscroll = app.attributes.index
	local search = false
	if input then
		local fp = io.open(input,"rb")
		if fp then -- archivo
			fp:close()
			app.ruta = files.nofile(input)
			search = true
		else -- carpeta
			app.ruta = input
		end
	end
	app.loadicons(path.."files/")
	app.refresh(app.ruta)--files.list("ms0:/")
	if input and search then
		app.find(input)
	end
	app.go_forwardbtt = sdk.newButtonImg(10,sdk.y,path.."go-forward.png","Ir atras","cross",function() local tmp = app.ruta; app.refresh(files.nofile(tmp)); app.find(tmp) end)
	app.go_nextbtt = sdk.newButtonImg(36,sdk.y,path.."go-next.png","Ir Adelante","cross",function() end)
	app.go_homebtt = sdk.newButtonImg(62,sdk.y,path.."go-home.png","Ir A Raiz","cross",function() app.refresh("ms0:/") end)
	--if app.list then box.new("lista creada","")end
end
function app.refresh(path,sort)
	if not path then path = app.ruta end
	if not sort then sort = "name" end
	sdk.setTitleApp(app,path.." - File Explorer")
	app.ruta = path
	app.list = files.listsort(path,sort)
	local len = #app.list
	 local i,f = 1,1
   local tmp = {} -- creamos un contenedor de data donde la reordenaremos
    tmp[f] = {}
	local c = 1
    while c <= len do -- Ordenador del array
		local wspace = screen.textwidth(app.list[c].name,0.6)
		if wspace > 76 then
			local plim = #app.list[c].name
			while wspace > 70 do
				wspace = screen.textwidth(string.sub(app.list[c].name,1,plim),0.6)
				plim -= 1
			end
			app.list[c].title = app.list[c].name
			app.list[c].name = string.sub(app.list[c].name,1,plim).."..."
		end
        tmp[f][i] = app.list[c] -- Asignamos el index i a el bidimensional data
        c += 1;
		i +=1
        if i > 5 then 
            i = 1
            f += 1
            tmp[f] = {}
        end
    end
	app.list = tmp
	scroll.set(app.keyscroll,tmp,3)
end

app.focus = {0,0}

function app.run(x,y)
	--draw.fillrect(x,y,sdk.w-1,24,color.gray)--color.new(245,246,247))
	draw.gradrect(x,y,sdk.w-1,24,color.white,color.new(200,200,200),0) -- Barra superior
	app.go_forwardbtt:draw()
	app.go_nextbtt:draw()
	app.go_homebtt:draw()
	local i = scroll[app.keyscroll].ini
	local x,y,pos,s = 4,22+24,0,7 -- set
	local w,h = 80,54 -- espacio de seleccion.
	local oneover = {0,0} -- sobre ninguno por default
	while i <= scroll[app.keyscroll].lim do -- busqueda de que estemos sobre un acceso y cual?
		for ho=1,#app.list[i] do
			if i == app.focus[1] and ho == app.focus[2] then draw.fillrect(x, y, w, h, color.new(255,255,255,100)); draw.rect(x, y, w, h, color.white) end
			local overOn = sdk.underCursor(x, y, w, h)
			if overOn then -- si estamos sobre uno, Draw contorno
				draw.fillrect(x, y, w, h, color.new(255,255,255,100)); draw.rect(x, y, w, h, color.white)
				oneover = {i,ho} -- ok hubo al menos una coincidencia la parseamos a oneover
			end
			
			if not app.list[i][ho].size then
				app.icons["folder"]:center()
				app.icons["folder"]:blit(x+(w/2),y+((h-10)/2))
			elseif app.list[i][ho].ext and app.icons[app.list[i][ho].ext] then
				app.icons[app.list[i][ho].ext]:center()
				app.icons[app.list[i][ho].ext]:blit(x+(w/2),y+((h-10)/2))
			else
				app.icons["unknown"]:center()
				app.icons["unknown"]:blit(x+(w/2),y+((h-10)/2))
			end
			if i == app.focus[1] and ho == app.focus[2] and app.list[i][ho].title then
				if math.floor(app.xscroll) != x+3 then
				app.xscroll = x+3--+(w/2)+(w/2)
				end
				app.xscroll = screen.print(app.xscroll,y+h-15,app.list[i][ho].title,0.6,color.white,color.black,__SLEFT,70)
			else
				screen.print(x+(w/2),y+h-15,app.list[i][ho].name,0.6,color.white,color.black,__ACENTER)
			end
			
			pos,x = pos + 1, x + w + s
			--if pos > 4 then
			--end
		end
		i += 1
		pos = 0
		x = 4
		y = y + h + s
	end
	if scroll[app.keyscroll].maxim> 3 then
		local pos_height = math.max(220/scroll[app.keyscroll].maxim, 5)
		draw.fillrect(465, 21, 10, 220, color.new(200,200,200))
		draw.fillrect(465, 21+((220-pos_height)/(scroll[app.keyscroll].maxim-1))*(scroll[app.keyscroll].sel-1), 10, pos_height, color.new(55,200,255))
	end
	if buttons.cross and sdk.underAppCursor() and POPUP.activado == false and (app.focus[1] ~= oneover[1] or app.focus[2] ~= oneover[2]) then -- sobre ninguno
		app.focus = oneover
	elseif buttons.cross and  oneover[1] ~= 0 and oneover[2] != 0 and app.focus[1] == oneover[1] and app.focus[2] == oneover[2] then
		if not app.list[app.focus[1]][app.focus[2]].size then -- Avanze de folder..
			app.refresh(app.list[app.focus[1]][app.focus[2]].path.."/")
			app.focus[1] = 0
			app.focus[2] = 0
		else
			if app.list[app.focus[1]][app.focus[2]].ext and app.list[app.focus[1]][app.focus[2]].ext == "mp3" or app.list[app.focus[1]][app.focus[2]].ext == "ogg" or app.list[app.focus[1]][app.focus[2]].ext == "wav" or app.list[app.focus[1]][app.focus[2]].ext == "bgm" or app.list[app.focus[1]][app.focus[2]].ext == "at3" or app.list[app.focus[1]][app.focus[2]].ext == "s3m" then
				sdk.callApp("winamp",app.list[app.focus[1]][app.focus[2]].path)
			elseif app.list[app.focus[1]][app.focus[2]].ext and app.list[app.focus[1]][app.focus[2]].ext == "ini" or app.list[app.focus[1]][app.focus[2]].ext == "lua" or app.list[app.focus[1]][app.focus[2]].ext == "txt" then
				sdk.callApp("notepad",app.list[app.focus[1]][app.focus[2]].path)
			elseif app.list[app.focus[1]][app.focus[2]].ext and app.list[app.focus[1]][app.focus[2]].ext == "png" or app.list[app.focus[1]][app.focus[2]].ext == "bmp" or app.list[app.focus[1]][app.focus[2]].ext == "gif" or app.list[app.focus[1]][app.focus[2]].ext == "jpg" then
				sdk.callApp("gallery",app.list[app.focus[1]][app.focus[2]].path)
			elseif app.list[app.focus[1]][app.focus[2]].ext and app.list[app.focus[1]][app.focus[2]].ext == "zip" or app.list[app.focus[1]][app.focus[2]].ext == "rar" then
				sdk.callApp("winrar",{src=app.list[app.focus[1]][app.focus[2]].path,dst=string.sub(app.list[app.focus[1]][app.focus[2]].path,1,-5).."/"})
				--sdk.callApp("winrar",b) end, args = {src=app.list[app.focus[1]][app.focus[2]].path,dst=string.sub(app.list[app.focus[1]][app.focus[2]].path,1,-5)}
			elseif app.list[app.focus[1]][app.focus[2]].ext and app.list[app.focus[1]][app.focus[2]].ext == "iso" or app.list[app.focus[1]][app.focus[2]].ext == "cso" or app.list[app.focus[1]][app.focus[2]].ext == "pbp" or (app.list[app.focus[1]][app.focus[2]].ext == "dax") then
				sdk.showPmf("gameboot.pmf")
				sdk.runGame(app.list[app.focus[1]][app.focus[2]].path)
			elseif app.list[app.focus[1]][app.focus[2]].ext and app.list[app.focus[1]][app.focus[2]].ext == "pmf" then
				sdk.showPmf(app.list[app.focus[1]][app.focus[2]].path)
			else
				local opciones = {
				{txt = "Open with Notepad", action = function (b) sdk.callApp("notepad",b) end, args = app.list[app.focus[1]][app.focus[2]].path, state = true, overClose = true},
				{txt = "Open with Gallery", action = function (b) sdk.callApp("gallery",b) end, args = app.list[app.focus[1]][app.focus[2]].path, state = true, overClose = true},
				{txt = "Open with GIMP", action = function (b) sdk.callApp("gimp",b) end, args = app.list[app.focus[1]][app.focus[2]].path, state = true, overClose = true},
				{txt = "Open with WinRAR", action = function (b) sdk.callApp("winrar",b) end, args = {src=app.list[app.focus[1]][app.focus[2]].path,dst=string.sub(app.list[app.focus[1]][app.focus[2]].path,1,-5)}, state = true, overClose = true},
				{txt = "Open with Blender", action = function (b) sdk.callApp("blender",b) end, args = app.list[app.focus[1]][app.focus[2]].path, state = true, overClose = true},
				}
				POPUP.setElements(opciones)
				POPUP.activate()
			end
		end
	end
	if buttons.triangle and  oneover[1] ~= 0 and oneover[2] != 0  then -- sobre un archivo
		app.focus[1] = oneover[1] 
		app.focus[2] = oneover[2]
		local pathToF = app.list[app.focus[1]][app.focus[2]].path
		local opciones = {
		--{txt = "Edit Image", action = function () sdk.callApp("gimp",id_viewimg.inputpath) end, args = nil, state = true, overClose = true},
		--{txt = "Reload Image", action = function () id_viewimg.imgdata = image.load(id_viewimg.inputpath) id_viewimg.imgdata:center() end , args = nil, state = true, overClose = true},
		--{txt = "Open Location", action = function () sdk.callApp("app",id_viewimg.inputpath) end , args = nil, state = true, overClose = true},
		}
		--Funciones Folder
		if not app.list[app.focus[1]][app.focus[2]].size then
			table.insert(opciones,{txt = "Open in New Window", action = function (path) sdk.callApp("filer",path) end, args = pathToF, state = true, overClose = true})
		end
		--Funciones Text Plano
		if app.list[app.focus[1]][app.focus[2]].ext and app.list[app.focus[1]][app.focus[2]].ext == "ini" or app.list[app.focus[1]][app.focus[2]].ext == "lua" or app.list[app.focus[1]][app.focus[2]].ext == "txt" or app.list[app.focus[1]][app.focus[2]].ext == "c" or app.list[app.focus[1]][app.focus[2]].ext == "cpp" or app.list[app.focus[1]][app.focus[2]].ext == "html" or app.list[app.focus[1]][app.focus[2]].ext == "php" then
			table.insert(opciones,{txt = "Open with Notepad", action = function (path) sdk.callApp("notepad",path) end, args = pathToF, state = true, overClose = true})
			table.insert(opciones,{txt = "Open with Notepad++", action = function (path) sdk.callApp("notepadplus",path) end, args = pathToF, state = true, overClose = true})
		end
		--Funciones IMG
		if app.list[app.focus[1]][app.focus[2]].ext and app.list[app.focus[1]][app.focus[2]].ext == "png" or app.list[app.focus[1]][app.focus[2]].ext == "bmp" or app.list[app.focus[1]][app.focus[2]].ext == "gif" or app.list[app.focus[1]][app.focus[2]].ext == "jpg" then	
			table.insert(opciones,{txt = "Open with Gallery", action = function (path) sdk.callApp("gallery",path) end, args = pathToF, state = true, overClose = true})
			table.insert(opciones,{txt = "Open with GIMP", action = function (path) sdk.callApp("gimp",path) end, args = pathToF, state = true, overClose = true})
			table.insert(opciones,{txt = "Set as Wallpaper", action = function (path) desk.tmpback = image.load(path) cfg.set("theme","backpath",path) end, args = pathToF, state = true, overClose = true})
		end
		--Funciones Rar&ZIP
		if app.list[app.focus[1]][app.focus[2]].ext and app.list[app.focus[1]][app.focus[2]].ext == "zip" or app.list[app.focus[1]][app.focus[2]].ext == "rar" then
			local nameoffile = files.nopath(pathToF)
			local dest = string.sub(nameoffile,1,-5).."/"
			local argtmp = {src=pathToF,dst=string.sub(pathToF,1,-5).."/"}
			table.insert(opciones,{txt = "Open with WinRAR", action = function (b) sdk.callApp("winrar",b) end, args = pathToF, state = true, overClose = true})
			table.insert(opciones,{txt = "Extract Here", action = function (input) files.threadextract(input.src,input.dst) end, args = {src=pathToF,dst=app.ruta}, state = true, overClose = true})
			table.insert(opciones,{txt = "Extract To..."..dest, action = function (input) files.threadextract(input.src,input.dst) end, args = argtmp, state = true, overClose = true})
			--sdk.callApp("winrar",{src=pathToF,dst=})
		end
		
		table.insert(opciones,{txt = "Create Shortcut", action = app.toDesk, args = pathToF, state = true, overClose = true})
		table.insert(opciones,{txt = "Rename", action = function (path) local txt = sdk.iosk(files.nopath(path),"Name of Access"); if txt then files.rename(path,txt) app.refresh()  end end, args = pathToF, state = true, overClose = true})
		table.insert(opciones,{txt = "Copy", action = function (path) sdk.clipboard=path; sdk.clipaction=__CLIP_COPY end, args = pathToF, state = true, overClose = true})
		table.insert(opciones,{txt = "Move", action = function (path) sdk.clipboard=path; sdk.clipaction=__CLIP_MOVE end, args = pathToF, state = true, overClose = true})
		table.insert(opciones,{txt = "Delete", action = function (path) files.delete(path) app.refresh() end, args = pathToF, state = true, overClose = true})
		
		--opciones[1].state = id_viewimg.imgdata:getrealw() == 480 and id_viewimg.imgdata:getrealh() == 272
		POPUP.setElements(opciones)
		POPUP.activate()
	elseif buttons.triangle and sdk.underAppCursor() and oneover[1] == 0 and oneover[2] == 0  then -- sobre la ventana
		local opciones = {
			{txt = "New File", action = function (path) local txt = sdk.iosk("","Name of File"); if txt then files.new(path..txt) app.refresh() end end, args = app.ruta, state = true, overClose = true},
			{txt = "New Folder", action = function (path) local txt = sdk.iosk("","Name of Folder"); if txt then files.mkdir(path..txt) app.refresh() end end, args = app.ruta, state = true, overClose = true},
			{txt = "Sort By", action = nil, args = app.ruta, state = false, overClose = true},
			{txt = "Refresh", action = app.refresh, args = nil, state = true, overClose = true},
		}
		
		if sdk.clipaction != 0 then--#sdk.clipboard > 0 then -- Hay algo en el clipboard
			local ftmp = nil
			if sdk.clipaction == __CLIP_COPY then
				ftmp = function (path) files.copy(sdk.clipboard,path) sdk.clipaction = 0; sdk.clipboard=""; app.refresh() end
			elseif sdk.clipaction == __CLIP_MOVE then--..files.nopath(sdk.clipboard)
				ftmp = function (path) files.move(sdk.clipboard,path) sdk.clipaction = 0; sdk.clipboard=""; app.refresh() end
			end
			table.insert(opciones,{txt = "Paste", action = ftmp, args = app.ruta, state = true, overClose = true})
		end
		POPUP.setElements(opciones)
		POPUP.activate()
	end
	if buttons.circle and sdk.underAppCursor() then
		local tmp = app.ruta
		app.refresh(files.nofile(tmp))--.."/"
		app.find(tmp)
	end
	if app.count_cycle > 20 then
		app.count_cycle = 0;
		buttons.l,buttons.r = buttons.held.l,buttons.held.r
	end
	if buttons.l then
		scroll.up(app.keyscroll)
	elseif buttons.r then
		scroll.down(app.keyscroll)
	end
	if buttons.held.l or buttons.held.r then
	app.count_cycle += 1
	end
	--screen.print(15,25,"fila|columna: "..app.focus[1].."|"..app.focus[2],0.7,color.red)
	--screen.print(15,35,"ini|sel|lim: "..scroll[app.keyscroll].ini.."|"..scroll[app.keyscroll].sel.."|"..scroll[app.keyscroll].lim,0.7,color.red)
	--screen.print(240,200,sdk.clipboard.." - "..app.ruta,0.6,color.white,color.black,__ACENTER)
	--if buttons.start then sdk.exitApp(app) end
end

function app.term()
	
end

function app.toDesk(id_o_path) 
	local type = string.sub(id_o_path,-4,-1):lower()--files.ext(id_o_path)
	
	if type and (type == ".pbp" or type == ".iso" or type == ".cso") then
		local data = game.info(id_o_path)
		local title = ""--string.sub(files.nopath(id_o_path),1,"/")
		if data then
			title = data.TITLE
		end
		access_mgr.create(title,id_o_path)
		label.call("Debug to Desk","Game - "..tostring(type))
	else
		local fp = io.open(id_o_path,"rb")
		if fp then -- archivo
			fp:close()
			access_mgr.create(files.nopath(id_o_path),id_o_path)
			label.call("Debug to Desk","File - "..tostring(type))
		else -- carpeta
			--local txt = id_o_path
			--local pos = string.find(txt,"/",-1,false)
			access_mgr.create(files.nopath(id_o_path),id_o_path)
			label.call("Debug to Desk","Folder - "..tostring(type))
		end
		--[[local txt = sdk.iosk("","Name of Access");
		if txt then
			access_mgr.create(txt,id_o_path)
		end]]
	end
end