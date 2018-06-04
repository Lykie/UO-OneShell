--[[
	Libreria Kernel;
	Encargada del manejo de carga de archivos, aportando un exelente previsor de errores.
	ademas ofrece un buen abanico de funciones para la facilitacion de creacion de apps. 
	Esta Fue Escrita por David Nunez Aguilera @ 1:45:00 pm 24/05/15
	]]
	
kernel = {} -- Tabla Principal.
if not color.white then	color.loadpalette()	end -- Si No esta cargada la paleta de colores la cargamos.
color.shine = color.new(255,255,255,100) -- Color Blanco desvanecido (Brillo)
color.shadow = color.new(0,0,0,100) -- Color Negro desvanecido (Sombre)
color.grey = color.new(64, 64, 64) -- Color gris oscuro -- opuesto a color.gray gris claro

kernel.Corrupted = false -- Valor indicador de Sistema Corrupto.
kernel.imageprotect = image.new(1,1,color.white) -- Para proteccion del shell :D

kernel.loadscr = {-- Configuramos la screen boot.
	back = image.load("system/images/boot/startup.png"), -- imagen de fondo
	ani = image.load("system/images/boot/loading.png"), -- Animacion de giro loading
	angle = 0, -- Angulo de giro de anim
	label = "",
	fx = 0
	}

function kernel.loadscr.fadein() -- Efecto de entrada boot
	kernel.fade_in(kernel.loadscr.back)
end

function kernel.loadscr.print(txt)
	if txt then kernel.loadscr.label = txt end
end
kernel.loadscr.enable_state = true
function kernel.enableScreen(state)
	if state then
		kernel.loadscr.enable_state = true
	else
		kernel.loadscr.enable_state = false
	end
end

function kernel.loadscr.refresh() -- Impresion o Dibujo del Boot Screen
	if not kernel.loadscr.enable_state then return end
	if kernel.loadscr.back then
		kernel.loadscr.back:blit(0,0)
	end
	--if kernel.loadscr.ani then
		--kernel.loadscr.angle = kernel.loadscr.angle + 15
		--kernel.loadscr.ani:rotate(kernel.loadscr.angle)
		--kernel.loadscr.ani:center()
		--kernel.loadscr.ani:blit(240,200)
	--end
	screen.print(240,200,"Loading"..string.rep(".",math.ceil(kernel.loadscr.fx)),0.7,color.white,0x0,512)
	screen.print(240,220,kernel.loadscr.label,0.7,color.white,0x0,512)
	screen.flip()
	kernel.loadscr.fx = kernel.loadscr.fx + 0.5
	if kernel.loadscr.fx > 3 then kernel.loadscr.fx = 0 end
end

function kernel.loadscr.fadeout() -- Efecto de salida boot
	kernel.fade_out(kernel.loadscr.back)
end

function kernel.loadsound(path)
	if files.exists(path) then
		kernel.loadscr.refresh()
		return sound.load(path)
	else
		kernel.Corrupted = true
		os.message("Error Loading,\n"..path)
	end
end
function kernel.loadimage(path,x,y)
	if files.exists(path) then
		kernel.loadscr.refresh()
		if x and y then
			return image.load(path,x,y)
		else
			return image.load(path)
		end
	else
		kernel.Corrupted = true
		os.message("Error Loading,\n"..path.."\nIt will load a backup image, allowing to continue even if it does not guarantee 100% functionality")
		return kernel.imageprotect
	end
end
kernel.roottoinclude = "" -- modulos
function kernel.setinclude(path)
	kernel.roottoinclude = path
end
function kernel.include(root,mod)
	local path = kernel.roottoinclude..root
	if not mod then 
		return kernel.dofile(path)
	end
end
kernel.roottolibs = ""
function kernel.setlibs(path)
	kernel.roottolibs = path
end
function kernel.lib(root,mod)
	local path = kernel.roottolibs..root
	if not mod then
		return kernel.dofile(path)
	end
end
function kernel.dofile(path)
	if files.exists(path) then
		kernel.loadscr.refresh()
		return dofile(path)
	else 
		kernel.Corrupted = true
		os.message("Error Loading,\n"..path)
	end
end
function kernel.loadmod(path,pass)
	if files.exists(path) then
		local _ftn = loadstring(kernel.desencrypt(files.read(path),pass or 4))
		if _ftn then _ftn() end
	end
end
function kernel.run(f,name)
	if f then 
		if type(f) == "string" then
			if name then
				assert(loadstring(f,name))()
			else
				assert(loadstring(f))()
			end
			--box.new("se activo una funcion","")
		elseif type(f) == "function" then
			f()
		end
	end
	--return nil
end

--kernel.buttons_read = buttons.read
--kernel.siopress = {sel = false}
--kernel.sioreleased = {sel = false}
--sio.init() -- cargamos el modulo
--sio.baud(19200) -- velocidad 19200 baud/s
--function buttons.read()
	--kernel.buttons_read() -- lectura original.
	--sio.write(0x34) -- enviamos peticion de datos seriales
	--while sio.available() < 8 do sio.write(0x34) end -- esperamos mientras no recibamos todo
	--local tmp = sio.read()
	--local key,nums,b1,b2,ax2,ay2,ax1,ay2 = string.byte(tmp,1,-1)
	--screen.print(10,10,"test read sio ctrl")
	--if key == 0xAC and nums == 6 then
		--buttons.analogx = ax1
		--buttons.analogy = ay2
	--end
--end

-- ## File Size Format 'B,KB,MB,GB' ##
function files.sizeformat(bytes) -- Add files module function, esta retorna el size en unidad 
	local u,c = {"B","KB","MB","GB"},1
	while bytes>1024 do
		bytes=bytes/1024
		c=c+1
	end
	return string.format("%.2f "..u[c],bytes)
end
-- ## Sort By Index ##
function sortby(array, index)--do 
	table.sort(array, function(a,b) if not a[index] or not b[index] then return true end return a[index] < b[index]; end) 
end 

-- ## List File Sort By name ##
function files.listsort(path,orden)
	--if not orden then orden = "name" end
	local tmp1 = files.listdirs(path)
	if tmp1 and  #tmp1 > 0 and tmp1[1][orden] then 
		sortby(tmp1,orden)
	elseif not tmp1 then
		tmp1 = {}
	end
	local tmp2 = files.listfiles(path) 
	if tmp2 then
		if #tmp2 > 0 and tmp2[1][orden] then 
			sortby(tmp2,orden)--table.sort(tmp2,function(a,b) return string.lower(a.name)<string.lower(b.name) end)
		end
		for s,t in pairs(tmp2) do
			t.size = files.sizeformat(t.size)
			table.insert(tmp1,t)-- esto es por que son subtablas, realmente no puedo hacer un cont con tmp2
		end
	end
	return tmp1
end
--Fade Out
function kernel.fadeout(img)
	--Checar si con esto soluciono problemas
	--screen.flip()
	local capt = img or screen.toimage()
	local textura = image.new(480,272,color.black)
	for i = 0,255,11 do
		capt:blit(0,0,255)
		textura:blit(0,0,i)
		screen.flip()
	end	
	return capt
end
--Salida con fadeout
function kernel.exit()
	kernel.fadeout()
	os.exit()
end
function kernel.suspend()
	kernel.fadeout()
	power.suspend()
end
function kernel.off()
	kernel.fadeout()
	power.off()
end
function kernel.restart()
	kernel.fadeout()
	os.restart()
end
-- ## Manipulacion Cadenas De texto ##
function wordwrap(text,width,w)--Ajusta un string pasado como argumento y retorna el string seteado con saltos para el espacio designado
	if not w then w = 0.7 end
	lines = 1                                     
	out = ""                                       
	int = ""                                      
  	for word in string.gmatch(text,"%S+") do       
    		if screen.textwidth (int.." "..word,w) > width then
      			out = out..'\n'                            
     			int = ""                                   
     			lines = lines + 1                         
    		end
  		out = out.." "..word                           
  		int = int.." "..word                           
  	end
  	return out                            
end
function string.explode(str, div) -- Crea una tabla apartir de particiones en patrones ("a,b,c",",") = {a,b,c}
    assert(type(str) == "string" and type(div) == "string", "Invalid Arguments")
    local o = {}
    while true do
        local pos1,pos2 = str:find(div)
        if not pos1 then
            o[#o+1] = str
            break
        end
        o[#o+1],str = str:sub(1,pos1-1),str:sub(pos2+1)
    end
    return o
end
function string.implode(tab, div) -- crea un string apartir de una tabla uniendo con un patrones
	if not tab or not div then return nil end
	return table.concat(tab, div)
end
-- ## Efectos de desvanecimiento ##
function kernel.fade_in(img) -- desvanecimiento de entrada
	if not img then
		img = screen.toimage()
	end
	for i = 0,255,6 do
		img:blit(0,0,i)
		screen.flip()
	end
end
function kernel.fade_out(img) -- desvanecimiento de salida
	if not img then
		img = screen.toimage()
	end
	for i = 255,0,-6 do
		img:blit(0,0,i)
		screen.flip()
	end
end
-- ## Efecto de Splash ##
function kernel.splash(path,tiempo) -- Splash Fade
	local imagen = kernel.loadimage(path)
	for i = 0,255,4 do
		alfa = i
		image.blit(imagen,0,0,alfa)
		screen.flip()
	end
	os.delay(tiempo)
	for i = 0,255,4 do
		alfa = 255 - i
		image.blit(imagen,0,0,alfa)
		screen.flip() 
	end
	imagen = nil
end
-- ## Funciones De Encriptacion ##
function kernel.encrypt(texto,llave) -- Encripta texto basandose en su llave
	if texto == nil or llave == nil then return end
	local result = "";
	for i = 1,#texto do
		local numByte = string.byte(string.sub(texto,i))
		local outByte = numByte + llave
		result = result..string.char(outByte)  
	end
	return result;
end 
function kernel.desencrypt(codigo,llave) -- Desencripta texto basandose en su llave
	if codigo == nil or llave == nil then return end
	local result = "";
	for i = 1,#codigo do
		local inByte = string.byte(string.sub(codigo,i))
		local realByte = inByte - llave
		result = result..string.char(realByte)
	end
	return result;
end
function files.encrypt(path,pass) -- encripta un file con un pass del os o con uno propio
	if files.exists(path) then
		local fp = io.open(path, "r")
		local fd = fp:read("*a")
		fp:close()
		local fp = io.open(path,"w+")
		fp:write(kernel.encrypt(fd,pass or 4))
		fp:close()
		return true
	end
		return false
end
function files.desencrypt(path,pass) -- Desencripta un file con un pass del os o con uno propio
	if files.exists(path) then
		local fp = io.open(path, "r")
		local fd = fp:read("*a")
		fp:close()
		local fp = io.open(path,"w+")
		fp:write(kernel.desencrypt(fd,pass or 4))
		fp:close()
		return true
	end
		return false
end
-- ## Manipulacion de Files ##
function files.new(path)
	files.write(path,"")
end
function files.write(path,contenido,modo) -- Escribe un string en un file en modo borrador default 
	local archivo = io.open(path,modo or "w+");
	if archivo == nil then return end
	archivo:write(contenido);
	archivo:flush();
	archivo:close();
end
function files.read(path,modo) -- Lee un file en totalidad y retorna el string
	if files.exists(path) then
		local fp = io.open(path,modo or "r")
		local fd = fp:read("*a")
		fp:close()
		return fd
	end
end
function files.readlines(path,index) -- Lee un table o string si se especifica linea
	if files.exists(path) then
		local contenido = {}
		for linea in io.lines(path) do
			table.insert(contenido,linea)
		end
		if index == nil then
			return contenido -- tabla
		else
			return contenido[index] -- string
		end
	end
end
-- ## Efecto Scale ##
--image.scale = image.scaled
--[[function image.scale(imagen,porcent)-- Escala una img segun porcentaje, retorna w,h
	if imagen == nil then return end
	if porcent == nil or porcent == 100 then imagen:reset() end
	local h = imagen:getrealh()
	local w = imagen:getrealw()
	local rh = math.ceil((h / 100) * porcent)
	local rw = math.ceil((w / 100) * porcent)
	imagen:resize(rw,rh)
	return rw,rh
end]]
-- ## Utilidades Menu Desplegados ##
scroll = {}
function scroll.set(num,tab,mxn,modemintomin)
	scroll[num] = {ini=1,sel=1,lim=1,maxim=1,minim = 1}
	if #tab > mxn then scroll[num].lim=mxn else scroll[num].lim=#tab end
	scroll[num].maxim = #tab
	if modemintomin then
		scroll[num].minim = scroll[num].lim
	end
end
function scroll.max(num,mx)
scroll[num].maxim = #mx
end
function scroll.up(num)
	if scroll[num].sel>scroll[num].ini then scroll[num].sel=scroll[num].sel-1
	elseif scroll[num].ini-1>=scroll[num].minim then
		scroll[num].ini,scroll[num].sel,scroll[num].lim=scroll[num].ini-1,scroll[num].sel-1,scroll[num].lim-1
	end
end
function scroll.down(num)
	if scroll[num].sel<scroll[num].lim then scroll[num].sel=scroll[num].sel+1
	elseif scroll[num].lim+1<=scroll[num].maxim then
		scroll[num].ini,scroll[num].sel,scroll[num].lim=scroll[num].ini+1,scroll[num].sel+1,scroll[num].lim+1
	end
end
function scroll.print(num,x,y,h,tabla,color1,color2,tam)--Funcion de prueba
	scroll[num].y = y
	for i=scroll[num].ini,scroll[num].lim do 
		if i==scroll[num].sel then
			screen.print(x,scroll[num].y,tabla[i],tam,color1)
		else
			screen.print(x,scroll[num].y,tabla[i],tam,color2)
		end
		scroll[num].y = scroll[num].y + h
	end
end
-- ## Mensajes Style Box ##
-- requiere el archivo box.png
box = {} -- Unidad llamada box
box.isinit = false -- no se ah iniciado? no se puede utilizar :D
box.lng = {"X: Okay","O: Cancel"}
box.running = false -- para utilizar en la api
function box.init(path) -- iniciamos la libreria :D, mas que nada cargar la img 
	if files.exists(path) then
		box.back = kernel.loadimage(path.."desktop/box.png")
		if box.back then
			box.isinit = true
		end
	end
end

function box.ine(capt) -- efecto de entrada de una caja box
	for i=0,100,6 do
		if capt then capt:blit(0,0) end
		image.scale(box.back,i)
		box.back:center()
		box.back:blit(240,136)
		screen.flip()
	end
end
function box.out(capt) -- efecto de salida de una caja box
	for i=100,0,-6 do
		if capt then capt:blit(0,0) end
		image.scale(box.back,i)
		box.back:center()
		box.back:blit(240,136)
		screen.flip()
	end
end
function box.new(title,txt,cent) -- crea una caja de texto y la muestra
	if not txt or box.isinit == false then return end
	if type(txt) == "string" then -- de lo contrario en una tabla :D
		txt = string.explode(wordwrap(txt,300,0.6),"\n")
	end
	scroll.set(995,txt,5)
	local capt = screen.buffertoimage()
	box.ine(capt)
	box.running = true
	local response = false
	while box.running do
		buttons.read()
		if buttons.held.up then scroll.up(995) end
		if buttons.held.down then scroll.down(995) end
		if buttons.circle then
			box.running = false
			response = false
		end
		if buttons.cross then
			box.running = false
			response = true
		end
		capt:blit(0,0)
		box.back:blit(240,136)
		screen.print(240,84,title,0.6,color.white,color.black,512)
		local myhvalue = 100
		for i=scroll[995].ini,scroll[995].lim do
			if cent then
				screen.print(240,myhvalue,txt[i],0.6,color.white,color.black,512)
			else
				screen.print(85,myhvalue,txt[i],0.6,color.white,color.black)
			end
			myhvalue = myhvalue + 15
		end
		screen.print(151,175,box.lng[indexLang][1],0.6,color.white,color.black,512)
		screen.print(327,175,box.lng[indexLang][2],0.6,color.white,color.black,512)
		-- ## Impresion Barra Lateral ##
		if scroll[995].maxim> 4 then 
			local pos_height = math.max(75/scroll[995].maxim, 8)
			draw.fillrect(390, 100, 5, 75, color.new(0,0,0,100))
			draw.fillrect(390, 100+((75-pos_height)/(scroll[995].maxim-1))*(scroll[995].sel-1), 5, pos_height, color.new(0,72,251))
		end
		screen.flip()
	end
	box.out(capt)
	capt:blit(0,0)
	return response
end
function box.api(func,efect) -- permite a una funcion ajena utilizar el api del box, y le manda las coordenadas del title y text
	if not func or box.isinit == false then return end
	local capt = screen.buffertoimage()
	box.ine(capt)
	box.running = true
	local efectblack = 255
	while box.running do
		buttons.read()
		capt:blit(0,0,efectblack)
		box.back:blit(240,136)
		func(240,84,85,100) -- xy title, xy text
		screen.flip()
		if (efectblack > 104) and efect == true then efectblack = efectblack - 4 end
	end
	box.out(capt)
	capt:blit(0,0)
end
function box.close() -- para cerrar la caja en la api
	box.running = false
end
-- ## Creacion De Poligonos ##
function draw.polygon(points,x,y,col,closed)
	for i = 2, #points do
		draw.line(points[i][1]+x,points[i][2]+y,points[i-1][1]+x,points[i-1][2]+y,col)
	end
	if closed then draw.line(points[#points][1]+x,points[#points][2]+y,points[1][1]+x,points[1][2]+y,col) end
end
-- ## Barras de Progreso ##
function draw.progress_bar(x,y,w,h,max,val,col,lin)
	if not col then col = color.green end
	if not lin then lin = color.white end
	draw.fillrect(x,y,(w*val)/max,h,col)
	draw.rect(x-1,y-1,w+2,h+2,lin)
end
--[[batt={
	{0,0},
	{20,0},
	{20,2},
	{22,2},
	{22,6},
	{20,8},
	{20,10},
	{0,10}
	}
draw.polygon(batt,10,10,color.new(255,255,255),true)
--draw.fillrect(12,12,36,16,color.new(255,255,255))
screen.flip()
buttons.waitforkey()]]
--## Compilacion de Programas LUA ##
function files.compile(path) -- crea un .lue script compilado de otro
	local newpath = files.nopath(path):sub(1,-5)..".lue"
	local fp, fd, err, str
	-- Lee el script a compilar
	fp = io.open(path, "r")
	fd = fp:read("*a")
	fp:close()
	-- Archivo temporal para compilar
	local fn = files.nopath(os.tmpname())
	fp = io.open(fn, "w+")
	fp:write("function __tmp()\n")
	fp:write(fd.."\n".."end\n")
	fp:write('fp = io.open("'..newpath..'","w+")\n')
	fp:write('fp:write(string.dump(__tmp))\n')
	fp:write('fp:close()\n')
	fp:write('__tmp = nil')
	fp:close()
	-- Inicio el anterior archivo a prueba de errores
	err, str = pcall(dofile, fn)
	-- Elimino el archivo temporal
	files.delete(fn)
	-- Obtengo los distintos resultados de error
	if not err then
		if string.find(str, "Unexpected symbol near char(27)") then return -1 else return str end
	else return 0 end
end
-- # Manipulacion de archivos ini #
function ini.save(path, data, exclude) -- guarda una tabla en un archivo ini
    if type(data) ~= "table" then return nil end
	--if not exclude then exclude = "" end
    local fp = io.open(path, "w+")
    if not fp then return nil end
    for s,t in pairs(data) do
		if type(t) == "table" then
			fp:write(string.format("[%s]\n", s))
			for k,v in pairs(t) do
				--if not (tostring(k) == exclude) then
					fp:write(string.format('%s="%s"\n', tostring(k), tostring(v)))-- parche para darle espacio al =
				--end
			end
			fp:write("\n") -- le da orden eso creo xD
		else
			--if not (tostring(s) == exclude) then
				fp:write(string.format('%s="%s"\n', tostring(s), tostring(t)))-- parche para darle espacio al =
			--end
		end
    end
    fp:close()
    return true
end
function ini.load(path) -- carga una tabla de un archivo ini
    if not files.exists(path) then return nil end
    local fp = io.open(path, "r")
    local data = {}
    local rejected = {}
    local parent = data
    local i = 0
    local m, n

    local function parse(line)
        local m, n

        -- kv-pair
        m,n = line:match('^([%w%p]-)="(.*)"') -- parche para darle espacio al =
        if m then
			if tonumber(n) then
				if not(string.len(n) > 1 and tonumber(n) == 0) then -- parche para que reconosca 0000 como string xD pues si no retorna solo 0 como numero, 
					n = tonumber(n) 
				end
			end
			if n == "true" then n = true end
			if n == "false" then n = false end
            parent[tonumber(m) or m] = n
            return true
        end

        -- section opening
        m = line:match("^%[([%w%p]+)%][%s]*")
        if m then
			if tonumber(m) then m = tonumber(m) end
            data[m] = {}
            parent = data[m]
            return true
        end

        if line:match("^$") then
            return true
        end

        -- comment
        if line:match("^#") then
            return true
        end

        return false
    end

    for line in fp:lines() do
        i = i + 1
        if not parse(line) then
            table.insert(rejected, i)
        end
    end
    fp:close()
    return data
end
-- ## Extract w/bar total ##
	extract_total_size = 0
	extract_total_write = 0
	antbytes = 0
	fileant = ""
function files.extract_w_bar(path,dest,cb)
	--Limpiamos todas las variables de extraccion
	if not tiempo then tiempo = timer.new() end
	extract_total_size = 0
	extract_total_write = 0
	antbytes = 0
	fileant = ""
	if files.exists(path) then -- Si existe entonces procede
		local lect = files.scan(path) --Escanea los files contenidos
		if lect then
			local i = 1
			while i <= #lect do
				extract_total_size = extract_total_size + lect[i].size
				i = i + 1
			end
			tiempo:reset()
			tiempo:start()
			if cb then --mandan un callback especifico
				onExtractFiles = cb
			elseif not onExtractFiles then
				function onExtractFiles(size,bytes,file)
					screen.print(10,10,"Extract:"..file.."\n"..bytes.."/"..size)
					screen.flip()
				end
			end
			local state = files.extract(path,dest)
			tiempo:stop()
			return state
		end
	end
	return nil
end
function files.compress_size(path)
	if files.exists(path) then -- Si existe entonces procede
		local __size = 0
		local lect = files.scan(path) --Escanea los files contenidos
		if lect then
			local i = 1
			while i <= #lect do
				__size = __size + lect[i].size
				i = i + 1
			end
			return __size -- total size real de un comprimido
		end
	end
	return nil
end

function takeshot(id)--files.cdir():sub(1,5)
	local root = files.cdir():sub(1,5).."PICTURE/"
	files.mkdir(root)
	root=root..id.."/"
	files.mkdir(root)
	local i=1
	while files.exists(root..string.format("%03d",i)..".png") do
		i+=1
	end
	screen.shot(root..string.format("%03d",i)..".png")
end
-- ## ##
function millis()
	return math.round(os.clock()*1000)
end
