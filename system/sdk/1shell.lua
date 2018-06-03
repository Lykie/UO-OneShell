--[[
	Funciones para utilizar en las aplicaciones externas.
	]]
sdk = {} -- modulo source dev kit

-- ## Contantes para los usos en las app ## (Utilidades mas que nada xD)
__SDK_VERSION = "1r0"
sdk.x=5 -- Punto de origen de bliteo en las app´s
sdk.y=21 -- Punto de origen de bliteo en las app´s
sdk.w=470 -- Ancho de bliteo en las app´s
sdk.h=220 -- Alto de bliteo en las app´s
--sdk.nick = os.nick()
sdk.clipboard = "Hola?"
__CLIP_MOVE = 1
__CLIP_COPY = 2
sdk.clipaction = 0
function sdk.setClipboard(t)
	if t then
		sdk.clipboard = t
		sdk.clipaction = 2
	end
end

function sdk.getClipboard()
	sdk.clipaction = 0
	return sdk.clipboard
end

function sdk.availableClipBoard()
	return sdk.clipaction
end

-- #### Creacion de Objetos ####

-- ## Categoria: extensiones de entorno ##
function sdk.newApp(title,backCol) -- crea un objeto aplicacion.
	local MyObjApp = dofile("system/obj/app.lua") -- cargamos el modelo de aplicacion.
	if not MyObjApp then box.new("Ocurrio un error","No se pudo crear la aplicacion") return end
	MyObjApp.attributes.title = title
	MyObjApp.attributes.backColor = backCol
	--MyObjApp.attributes.multiOpen = multi
	return MyObjApp -- Retornamos el objeto aplicacion seteado segun los argumentos.
end
function sdk.newPort() -- crea un objeto Portal (aplicacion llamada)
end
function sdk.newPlug() -- crea un objeto plug (aplicacion segundo grado)
end
function sdk.newGadget()-- crea un objeto gadget (add desk)
end
-- ## Categoria: extension de aplicaciones ##
function sdk.newButtonImg(x,y,img,desc,btt,func)
	if type(img) == "string" then img = image.load(img) end
	if not img then box.new("Hubo un error con la creacion de un boton icon","") return end
	--img:center()
	local obj = {x = x, y = y, w = img:getw(), h = img:geth(), ico = img, key = btt or "cross", act = func, desc = desc or ""}
	function obj:xy(x,y)
		obj.x,obj.y = x,y
	end
	function obj:draw()
		local over = cursor.isOver(obj.x,obj.y,obj.w,obj.h)
		if over then 
			draw.fillrect(obj.x-1,obj.y-1,obj.w+2,obj.h+2,color.shine)
			cursor.label(obj.desc)
		end
		obj.ico:blit(obj.x,obj.y)
		if over and buttons.released[obj.key] then obj.act() end
	end
	return obj
end
function sdk.newButton(x,y,w,h,txt,desc,btt,func)
	local obj = {x = x, 
				y = y, 
				w = w, 
				h = h, 
				text = txt, 
				key = btt, 
				act = func,
				desc = desc,
				csel = color.new(0,72,220,50),
				cpress = color.new(0,72,220,100),
				cg = color.new(128,128,128),
				xt = x+(w/2),
				yt = y+(h/4)}
	function obj:draw()
		local col = color.gray 
		local over = cursor.isOver(obj.x,obj.y,obj.w,obj.h)
		draw.gradrect(obj.x,obj.y,obj.w,obj.h,color.white,color.new(180,180,180),0)
		draw.rect(obj.x,obj.y,obj.w,obj.h,obj.cg)
		local cf = obj.csel
		if buttons.held[obj.key] then cf = obj.cpress end
		if over then draw.fillrect(obj.x,obj.y,obj.w,obj.h,cf) cursor.label(obj.desc) end
		screen.print(obj.xt,obj.yt,obj.text,0.7,obj.cg,0x0,512)
		local resp = nil
		if over and buttons.released[obj.key] then -- Se presiona
			if obj.act then --Hay funcion?
				resp = obj.act()  -- Si hay Se ejecuta y retorna algun resultado de la misma
			else 
				resp = true -- Retorna true de que fue presionado
			end
		end
		return resp
	end
	return obj
end
sdk.src = {}
sdk.src.Tf = {
	simple = image.load("system/theme/textfield/default.png"),
	focus = image.load("system/theme/textfield/focus.png"),
}
function sdk.newTextField()
	local obj = {
	x = sdk.x,
	y = sdk.y,
	w = 400,
	h = 22,
	txtbuff = "",
	tip = "",
	ispass = false,
	img = sdk.src.Tf.simple,
	imgf = sdk.src.Tf.focus,
	}
	function obj:iosk(tip,buff)
		if tip then
			obj.tip = tip
		end
		if buff then
			obj.txtbuff = buff
		end
	end
	function obj:txt(txt)
		if txt then
			obj.txtbuff = txt
		else
			return obj.txtbuff
		end
	end
	function obj:xy(x,y)
		if x and y then
			obj.x,obj.y = x,y
		else
			return obj.x,obj.y
		end
	end
	function obj:setw(w)
		obj.w = 400
		if w then obj.w = w end
		obj.img:resize(obj.w,obj.h)
		obj.imgf:resize(obj.w,obj.h)
	end
	function obj:seth(h)
		obj.h = 22
		if h then obj.h = h end
		obj.img:resize(obj.w,obj.h)
		obj.imgf:resize(obj.w,obj.h)
	end
	function obj:event(f)
		obj.callback = f
	end
	function obj.recvtxt(txt)
		if txt then
			obj.txtbuff = txt
		end
	end
	function obj.cuttxt()
		local t = obj.txtbuff
		obj.txtbuff = ""
		sdk.setClipboard(t)
	end
	function obj:draw()
		obj.img:blit(obj.x,obj.y)
		if cursor.isOver(obj.x,obj.y,obj.w,obj.h) then
			obj.imgf:blit(obj.x,obj.y)
			if buttons.cross then
				local resp = sdk.iosk(obj.txtbuff,obj.tip)
				if resp then
					obj.txtbuff = resp
					if obj.callback then obj.callback(obj.txtbuff) end
				end
			end
			if buttons.triangle then
				local opciones = {
					{txt = "Copy", action = kernel.exit, args = nil, state = true, overClose = true},
					{txt = "Cut", action = obj.cuttxt, args = nil, state = true, overClose = true},
					{txt = "Clear", action = obj.recvtxt, args = "", state = true, overClose = true},
					{txt = "Paste", action = obj.recvtxt, args = sdk.getClipboard(), state = true, overClose = true},
				}
				POPUP.setElements(opciones)
				POPUP.activate()
			end
			cursor.set("text")
		else
			cursor.set("normal")
		end
		if obj.ispass then
			screen.print(obj.x + 5,obj.y + 3,string.rep("*",#obj.txtbuff),0.5,color.new(30,30,30),0x0,__SLEFT,obj.w - 8)
		else
			screen.print(obj.x + 5,obj.y + 3,obj.txtbuff,0.5,color.new(30,30,30),0x0,__SLEFT,obj.w - 8)
		end
	end
	return obj
end
function sdk.newPanel(array,col) -- Creamos un objeto panel (array bidimensional) con sus utilidades
	local obj = {} -- Objeto temporal
    local len = #array -- Largo del array o entradas..
    --local filas = math.ceil((obj.leng/col)) -- numero de filas posibles, si hay un solo contenido en una no importa ya es una mas..
    local i,f = 1,1
    obj.data = {} -- creamos un contenedor de data donde la reordenaremos
    obj.data[f] = {}
    while i < len do -- Ordenador del array
        obj.data[f][i] = array[i] -- Asignamos el index i a el bidimensional data
        i += 1;
        if i > col then 
            i = 1
            f += 1
            obj.data[f] = {}
        end
    end
    obj.len = len; -- Numero de contenidos
    obj.lines = f; -- Numero de filas
	return obj
end
function sdk.createScroll(max_val,size,vew_port,value)
	if value == nil then value = 0 end
	
	local obj = {
		max_val = max_val,		-- Valor maximo admitido a la scrollbar
		max_size = size,		-- Tamaño del largo de la scrollbar (en pixeles)
		value = 0,				-- Valor actual
		vew_port = vew_port,	-- largo del campo de mira (en pixeles)
		vew_time = 140 ,		-- Duracion de la visibilidad
		cronos = 0,				
		alfa = 0				-- Transparenca
	}
	
	--dibuja el scrollbar
	function obj.blit(x,y)
		if obj.alfa == 0 and obj.cronos == obj.vew_time then 
			return
		end
		
		if obj.cronos < obj.vew_time then
			obj.cronos = obj.cronos + 1
			obj.alfa = obj.alfa + 10
			if obj.alfa > 255 then obj.alfa = 255 end
		else
			obj.cronos = obj.vew_time
			obj.alfa = obj.alfa - 8
			if obj.alfa < 0 then obj.alfa = 0 end
		end
		
		--screen.blendmode(fx.alpha,obj.alfa)
		sdk.ui.scrollBar:blit(x,y + obj.barLocation,0,0,sdk.ui.scrollBar:getw(),obj.barSize - 4,obj.alfa)
		draw.fillrect(x,y + obj.barLocation + (obj.barSize - 4),sdk.ui.scrollBar:getw(),4,color.new(205,205,205))
		--screen.blendmode(fx.alpha,255)
	end
	
	-- Revalua la posicion del scrollbar y llama al metodo scroll.show()
	function obj.setValue(value)
		if value == nil or value < 0 then 
			value = 0
		end
		
		if value > obj.max_val then
			value = obj.max_val
		end
		
		obj.value = value
		
		local barsize = (100 / obj.max_val) * obj.vew_port 
		barsize = (obj.max_size / 100) * barsize
		barsize = math.ceil(barsize)
		local barlocat = ((obj.max_size) / obj.max_val) * obj.value	-- locacion de la scrollbar
		barlocat = math.ceil(barlocat)
		
		if barsize < 6 then barsize = 6 end
		if barsize > obj.max_size then barsize = obj.max_size end
		if barlocat < 0 then barlocat = 0 end
		if barlocat + barsize > obj.max_size then barlocat = obj.max_size - barsize end
		
		obj.barSize = barsize
		obj.barLocation = barlocat
		
		obj.show()
	end
	
	-- Reajusta la interfaz del scrollbar sin llamar al metodo scroll.show()
	function obj.adjust(max_val)	
		if max_val ~= nil then obj.max_val = max_val end
		
		if obj.value > obj.max_val then
			obj.value = obj.max_val
		end

		local barsize = (100 / obj.max_val) * obj.vew_port 
		barsize = (obj.max_size / 100) * barsize
		barsize = math.ceil(barsize)
		local barlocat = ((obj.max_size) / obj.max_val) * obj.value
		barlocat = math.ceil(barlocat)
		
		if barsize < 6 then barsize = 6 end
		if barsize > obj.max_size then barsize = obj.max_size end
		if barlocat < 0 then barlocat = 0 end
		if barlocat + barsize > obj.max_size then barlocat = obj.max_size - barsize end
		
		obj.barSize = barsize
		obj.barLocation = barlocat
	end
	
	-- Muestra la scrollbar (la vuelve visible)
	function obj.show()
		obj.cronos = 0
	end
	
	obj.setValue(value)
	obj.show()
	
	return obj
end

function sdk.delay(ms)
end
function sdk.wlan() -- inicia el wifi
	if os.nick() ~= "PPSSPP" and not wlan.isconnected() then
		if wlan.connect() == 1 then
			return true -- Si se conecto de manera correcta ok true
		end
	end
	return false
end
-- Funciones de Cursor para App´s
function sdk.getCursor() -- retorna las posicion xy del cursor actuales
	return cursor.xy()
end

function sdk.getMotionCursor() -- change to motion Cursor
	return cursor.motion()
end
function sdk.underCursor(x,y,w,h)
	if cursor.isOver(5,21,470,220) and cursor.isOver(x, y, w, h) then
		return true
	end
	return false
end
function sdk.underAppCursor()
	if cursor.isOver(5,21,470,220) then
		return true
	end
	return false
end

-- ## Llamadas a otras aplicaciones ##
function sdk.callApp(id,input)
	app_mgr.create(id,input)
end

function sdk.runGame(path)
	local ext = string.sub(path,-4,-1):lower()--files.ext(path)
	--label.call("Test Run Game Debug",tostring(ext))
	if ext == ".dax" and not __SHELL_SOPORT_DAX then
		label.call("No Suport", "Your model not can lauch dax!")
	end
end

---
function sdk.DrawIconList()
	
end

function sdk.iosk(init_txt,tip_txt)
	screen.clip()
	local resp = iosk.init(tip_txt,init_txt,100,nil)
	screen.clip(5,21,470,220) -- Limitamos a dibujar en el area de ventana
	return resp
end
function sdk.clip(x,y,w,h)
	if x and y and w and h then
		screen.clip(x,y,w,h)
	else
		screen.clip(5,21,470,220) -- Limitamos a dibujar en el area de ventana
	end
end
function sdk.showPmf(path)
	screen.clip()
	pmf.run(path)
	screen.clip(5,21,470,220) -- Limitamos a dibujar en el area de ventana
end
function sdk.enable3d(enable) -- habilita el renderizado 3D
	if enable then -- Mas claro imposible si es true es true xD
		amg.mode2d(0)
	else
		amg.mode2d(1)
	end
end
function sdk.setTitleApp(app,title)
	app.attributes.title = title
end
function sdk.exitApp(app)
	app_mgr.free(app.attributes.index)
end
function sdk.loadImage(path)
	ext = string.sub(path,-3,-1):lower()
	--ext = files.ext(path) -- raro, no me funciona bien
	if ext == "bmp" then
		return bmp.load(path)
	else
		return image.load(path)
	end
end
--[[function sdk.runInternalApp(id,args)
	app_mgr.create(id,args)
end]]


sdk.ui ={scrollBar = kernel.loadimage("system/sdk/scrollbar.png")}


function sdk.textSetWide(txt,space,size)
	if not size then size = 0.6 end
	local width = screen.textwidth(txt,size)
	if width > space then -- El tamaño es mayor a el espacio1
		local ch_end = #txt -- Cargamos el largo a ch_end
		while width > space-6 do -- Mientras el width sea mayor al space - el ancho del ".."
			width = screen.textwidth(string.sub(txt,1,ch_end),0.6)
			ch_end -= 1 -- vamos quitando un char en cada prueba
		end
		return string.sub(txt,1,ch_end).."..." -- regresamos el texto con espacio ajustado
	end
	return txt -- regresamos el texto igual pues al parecer no hubo cambios.
end

--Mimes Icons :D
sdk.mime = {
	type = { --'molde','pnga','prxb',,'mp32','foldera',
		'unknown',
		'7z','at3','bgm','bin','bmp','cso','dax','fixer',
		'folder','fpt','gif','html','htmlb','ini','iso',
		'jpg','js','lua','lue','mp3','mp4','mp4a','mtl',
		'obj','pbp','pdf','pgf','pmf','png','prx','rar',
		'smc','tar','ttf','txt','wav','xml','zip',
	},
	icon = {},
}
function sdk.mime.load(path)
	for i=1,#sdk.mime.type do
		sdk.mime.icon[sdk.mime.type[i]] = image.load(path..sdk.mime.type[i]..".png")
		if not sdk.mime.icon[sdk.mime.type[i]] then sdk.mime.icon[sdk.mime.type[i]] = image.new(1,1,color.shine) end
		sdk.mime.icon[sdk.mime.type[i]]:resize(40,36)
	end
end

sdk.mime.load("system/theme/mimes/")

function sdk.mime.get() -- acceso a las img :D
	
	--return sdk.mime.icon
	local tmp = {} -- esto es para que al limpiar ese puntero no sea el real.
	for i=1,#sdk.mime.type do
		tmp[sdk.mime.type[i]] = sdk.mime.icon[sdk.mime.type[i]]
		----if not tmp[sdk.mime.type[i]] then tmp[sdk.mime.type[i]] = image.new(1,1,color.shine) end
		--sdk.mime.icon[i]:resize(40,36)
	end
	return tmp
end
