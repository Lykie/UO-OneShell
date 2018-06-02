--[[
==	Libreria Kernel
==	Descripcion:
==	Esta nos permite un control de funciones de carga, tales a prueba de errores y con una pantalla de carga,
==	Ademas Nos brinda Algunas funciones que nos ayudan a la hora de simplificar!
==	Creada Por:
==	David Nuñez A. David.nunezaguilera.131@gmail.com
==	Version 1.0 -- 29/01/2015
==	Modificada Por:
==	Equipo OneShell para la utilizacion en el entorno.
==	version 2.0 -- Pendiente
]]
kernel = {}
kernel.Corrupted = false
if not color.white then	color.loadpalette()	end

function kernel.setloadscreen(back)
	kernel.backloadscreen = image.load(back)
	angle = 0
end
function kernel.loadscreen(txt)
	if not kernel.imgload then
		kernel.imgload = image.load("loader.png")
	end
	if kernel.backloadscreen then
		kernel.backloadscreen:blit(0,0)
	end 
angle = angle + 15
if kernel.imgload then
kernel.imgload:rotate(angle)
kernel.imgload:center()
kernel.imgload:blit(20,257)
end
screen.print(40,254,"Loading... "..txt,0.7,color.white,color.black)
screen.flip()
end
-- Dibuja un splash de imagen en pantalla
function kernel.splash(path,tiempo)
	local imagen = kernel.loadimage(path)
	
	for i = 0,255,4 do
		alfa = i
		image.blit(imagen,0,0,alfa)
		screen.flip()
	end

	os.delay(tiempo)	-- Detiene el tiempo en milisegundos (Requiere el nativeCore.lua de fishell)

	for i = 0,255,4 do
		alfa = 255 - i
		image.blit(imagen,0,0,alfa)
		screen.flip() 
	end

	imagen = nil
end
function kernel.loadsound(path)
	if files.exists(path) then
		kernel.loadscreen("Sounds")
		return sound.load(path)
	else
		kernel.Corrupted = true
	end
end
function kernel.loadimage(path,x,y)
	if files.exists(path) then
		kernel.loadscreen("Images")
		if x and y then
			return image.load(path,x,y)
		else
			return image.load(path)
		end
	else
		kernel.Corrupted = true
	end
end
function kernel.dofile(path)
	if files.exists(path) then
		kernel.loadscreen("Functions")
		dofile(path)
	else 
		kernel.Corrupted = true
	end
end
function kernel.fadeout(img)
	--Checar si con esto soluciono problemas
	--screen.flip()
	local capt = img or screen.toimage()
	local textura = image.new(480,272,color.new(0,0,0))
	for i = 0,255,11 do
		capt:blit(0,0,255)
		textura:blit(0,0,i)
		screen.flip()
	end	
return capt
end
function kernel.fadein(img)
	--Checar si con esto soluciono problemas
	--screen.flip()
	local capt = img or screen.toimage()
	local textura = image.new(480,272,color.new(0,0,0))
	for i = 255,0,-11 do
		--textura:blit(0,0,255)
		capt:blit(0,0,i)
		screen.flip()
	end	
return capt
end
function kernel.exit()
	kernel.fadeout()
	os.exit()
end
function kernel.message(modo,msn_titulo,msn_texto)
	if modo == 3 then
	--Retorna true/false segun la eleccion
	msn_icono = Question
	elseif modo == 1 then 
	msn_icono = Warning
	elseif modo == 2 then
	msn_icono = img_update
	end
	if mensaje == nil then dofile("system/mensajes.lua") end
	return mensaje.print(modo,msn_titulo,msn_icono,msn_texto,nil)
	--mensaje.free(true) Libera todo lo relacionado con mensajes
end
function kernel.roundsize(bytes)
	local size = "B"	
	if bytes > 1* 1024*1024*1024 then -- GB
		bytes = bytes/ 1024/1024/1024
		size = "Gb"
	elseif bytes > 1*1024*1024 then --MB
		bytes = bytes/1024/1024
		size = "Mb"
	elseif bytes > 1*1024 then --KB
		bytes = bytes/1024
		size = "Kb"
	else 
		bytes = bytes
		size = "B"
	end
	return string.format("%.2f"..size,bytes)
end
function loading()
kernel.loadscreen("unknow")
end

--- Encripta texto basandose en su llave
function kernel.encrypt(texto,llave)		
	if texto == nil or llave == nil then return end
	
	local result = "";
	
	for i = 1,#texto do
		local numByte = string.byte(string.sub(texto,i))
		local outByte = numByte + llave
		result = result..string.char(outByte)  
	end
	
	return result;
end 

--- Desencripta texto basandose en su llave
function kernel.desencrypt(codigo,llave)	
	if codigo == nil or llave == nil then return end
	
	local result = "";
	
	for i = 1,#codigo do
		local inByte = string.byte(string.sub(codigo,i))
		local realByte = inByte - llave
		result = result..string.char(realByte)
	end
	
	return result;
end

-- Protege archivos cifrando a hex y luego encrypt con pass
function kernel.filesprotect(txt,pass)
	return kernel.encrypt(kernel.txt2hex(txt),pass)
end
-- DesProtege archivos descifrando a dec y luego desencrypt con pass
function kernel.filesunprotect(txt,pass)
	return kernel.hex2txt(kernel.desencrypt(txt,pass))
end

-- Escribe un texto en la ruta especificada
function kernel.filesWrite(path,contenido,modo)
	
	local archivo = io.open(path,modo);
	
	if archivo == nil then return end
	
	archivo:write(contenido);
	archivo:flush();
	archivo:close();
end

-- Lee la linea seleccionada del archivo seleccionada (o todas las lineas si no se especifica una en especial)
function kernel.filesRead(path,index)
	if files.exists(path) == nil then return end
	local contenido = {}

	for linea in io.lines(path) do
		table.insert(contenido,linea)
	end
	
	if index == nil then
		return contenido
	else
		return contenido[index]
	end
	
end
--- Funcion Extra que escala una imagen en su porcentage pasado como argumento
function kernel.imageScale(imagen,porcent) 	-- retorna w,h
	if imagen == nil then return end

	if porcent == nil or porcent == 100 then
		imagen:reset()
	end

	local h = imagen:getrealh()
	local w = imagen:getrealw()

	local rh = math.ceil((h / 100) * porcent)
	local rw = math.ceil((w / 100) * porcent)

	--imagen:resize(rw,rh)

	return rw,rh
end
function kernel.Int2Bin(int)
	local _bin = {0,0,0,0,0,0,0,0}
	if int >= 128 then
		_bin[1] = 1
		int = int%128
	end
	if int >= 64 then
		_bin[2] = 1
		int = int%64
	end
	if int >= 32 then
		_bin[3] = 1
		int = int%32
	end
	if int >= 16 then
		_bin[4] = 1
		int = int%16
	end
	if int >= 8 then
		_bin[5] = 1
		int = int%8
	end
	if int >= 4 then
		_bin[6] = 1
		int = int%4
	end
	if int >= 2 then
		_bin[7] = 1
		int = int%2
	end
	if int >= 1 then
		_bin[8] = 1
	end
	
	return tostring(_bin[1])..tostring(_bin[2])..tostring(_bin[3])..tostring(_bin[4])..tostring(_bin[5])..tostring(_bin[6])..tostring(_bin[7])..tostring(_bin[8])
end
	
function kernel.Bin2Int(bin)
	local _int = {tonumber(string.sub(bin,1,1)),tonumber(string.sub(bin,2,2)),tonumber(string.sub(bin,3,3)),tonumber(string.sub(bin,4,4)),tonumber(string.sub(bin,5,5)),tonumber(string.sub(bin,6,6)),tonumber(string.sub(bin,7,7)),tonumber(string.sub(bin,8,8))}
	local _num = 0
	if _int[1] == 1 then
		_num = _num+128
	end
	if _int[2] == 1 then
		_num = _num+64
	end
	if _int[3] == 1 then
		_num = _num+32
	end
	if _int[4] == 1 then
		_num = _num+16
	end
	if _int[5] == 1 then
		_num = _num+8
	end
	if _int[6] == 1 then
		_num = _num+4
	end
	if _int[7] == 1 then
		_num = _num+2
	end
	if _int[8] == 1 then
		_num = _num+1
	end
	
return _num
end

-- facilidades de conversión hexadecimal a binario y viceversa

function sumBin(str) -- suma 1 a un número binario en string, añade bits en caso de ser necesario
    newstr = ""
    llevo = 1
    start = #str
    while llevo==1 or start>0 do
        i = start

        if i>=1 then
            car = str:sub(i,i)
        else
            car = "0"
        end

        res = tonumber(car)+llevo
        add = 0
        if res==2 then
            llevo = 1
        elseif res==1 then
            llevo = 0
            add = 1
        end
        newstr = add..newstr
        start = start - 1
    end
    
    for i=4-#newstr,1,-1 do
        newstr = "0"..newstr
    end

    return newstr
end

function hex2bin(hexstr) -- de hexa a binario
	binstr = ""
	for i=1,#hexstr do
		binstr = binstr..tblH2B[hexstr:sub(i,i):upper()]
	end
	return binstr
end

function bin2hex(binstr) -- de binario a hexa
	hexstr = ""
	p4 = #binstr/4

	while math.floor(p4)~=p4 do
		binstr = "0"..binstr
		p4 = #binstr/4
	end
	for i=1,p4 do
		act = (i-1)*4+1
		hexstr = hexstr..tblB2H[binstr:sub(act,act+3)]
	end
	return hexstr
end

function inithexlib() -- generar tablas de conversión
	tblH2B = {}
	tblB2H = {}
	hex = "0123456789ABCDEF"
	actBin = "0000"
	for i=1,#hex do
		rawset(tblH2B,hex:sub(i,i),actBin)
		rawset(tblB2H,actBin,hex:sub(i,i))
		actBin = sumBin(actBin)
	end
end

inithexlib() -- inicializar HexLib

function kernel.txt2hex(str)
	local tmp = ""
	for i=1,#str do 
		tmp = tmp..bin2hex(kernel.Int2Bin(string.byte(string.sub(str,i,i))))
	end
	return tmp
end

function kernel.hex2txt(str)
	local tmp = ""
	for i=1, #str,2 do
		tmp = tmp..string.char(kernel.Bin2Int(hex2bin(string.sub(str,i,i+1))))
	end
	return tmp
end

function kernel.exec(act)				
	if act == nil then return end
	
	if type(act) == "string" then
		return loadstring(act)();
	elseif type(act) == "function" then
		return act()
	end
	return nil
end
function kernel.clean(obj)

end
