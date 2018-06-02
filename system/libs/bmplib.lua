--[[
	BMP Lib - v1.0
	Autor: David Nunez Aguilera
	Tipo: Grafica
	Descripcion:
	Permite cargar imagenes bmp de 24 y 32 bits
	Documentacion:
	IMAGE bmp.load(path) -- Carga un file bmp y retorna un objeto image
	path: ruta a la imagen a cargar.
	return: el objeto image o nil en caso de error.
	nota: permite utilizar el callback "onBmpLoad(porcent,img)"
	Notas:
		Suport: 
			Compression: 0
		Depth:
			24 bits
			32 bits
		Dimension:
			=> 512px , 512px
]]

bmp = {} -- Modulo


function bmp.load(path) -- Carga una img bmp y retorna un obj img
	--box.new("se intenta cargar una bmp XD","")
	return bmp.loadImage(path)
end

function bmp.loadImage(path)

	if not files.exists(path) then return end
	
	local outimg					-- Objeto de imagen que vamos a devolver
	
	local header = {} 				-- Inicializamos el header del bmp
	local infoHeader = {}			-- Inicializamos info header del bitmap
	
	local imageData = {}			-- Galeria de pixeles para el bitmap
	
	fp = io.open(path,"rb")			-- Establecemos un descriptor de fisheros
	if fp == nil then fp:close(); return end 	-- Error al abrir este archivo
	
	header = bmp.getHeader(fp)					-- Obtenemos header 
	infoHeader = bmp.getInfoHeader(fp)			-- Obtenemos header info
	
	if infoHeader.height > 512 or infoHeader.width > 512 then 
		fp:close(); return 																	-- La imagen es muy grande
	end 
	
	if infoHeader.compression ~= 0 then fp:close(); return end 								-- Solo soportamos archivos sin compresion
	
	if infoHeader.colorDepth == 24 then 
		outimg = bmp.getImageFrom24(fp,infoHeader)	
	elseif infoHeader.colorDepth == 32 then
		outimg = bmp.getImageFrom32(fp,infoHeader,view)	
	else
		return nil																			-- Formato de imagen no soportado
	end

	if outimg == nil then fp:close(); return end
	
	fp:close();
	collectgarbage()
	
	return outimg;

end

-- Esta funcion obtiene el valor real de los bytes leidos (convierte los valores signed a unsigned)
function bmp.sizeof(f,n)
	n = tonumber(n)
	
	local z = {0,0,0,0}
	local t = { 1 , 256 , (256*256) , (256*256*256) }

	for a = 1,n do
		local b = string.byte(f:read(1))
		z[a]= b * t[a]
	end
 
	return z[1]+z[2]+z[3]+z[4]
end

function bmp.getHeader(fp)	-- Leemos el header del descriptor pasado como argumento, devolvemos una tabla con el header
		fp:seek("set",0)
		
		local header = {
		
		identity = fp:read(2),							-- Tabla de identidad tamaño (String)
		size = string.byte(fp:read(4)),					-- 4 bytes | the size of the BMP file in bytes
		reserved = string.byte(fp:read(4)),				-- 4 bytes (no seran utilizados) (Esto incluye 2 secciones del header)
		offset = string.byte(fp:read(4)),				-- 4 bytes 
		
	}
	
	return header
end

function bmp.getInfoHeader(fp)
	fp:seek("set",14)
	
	local header = {			-- Inicializamos info header del bitmap
	
		size = string.byte(fp:read(4)),
		width = bmp.sizeof(fp,4),
		height = bmp.sizeof(fp,4),
		colorPlanes = string.byte(fp:read(2)),
		colorDepth = string.byte(fp:read(2)),
		compression = string.byte(fp:read(4)),
		imageSize = string.byte(fp:read(4)),
		hRes = string.byte(fp:read(4)),
		vRes = string.byte(fp:read(4)),
		nColors = string.byte(fp:read(4)),
		nIColors = string.byte(fp:read(4))
		
	}
	
	return header
end

function bmp.getImageFrom24(fp,infoHeader)
	--- 24 bits (3 bytes por pixel RGB) Este formato no soporta alfa
	
	local img = image.new(infoHeader.width,infoHeader.height,0x0)	-- Creamos nuestra nueva imagen
	local x,y = 1,1
	local paso = 1
	
	local totalSize = fp:seek("end")									-- Entero total en tamaño del archivo
	local totalRead = 54												-- Entero total en tamaño leido
	local store = totalSize 
	
	if infoHeader.height < 0 then
		y = 1
		paso = 1
	else
		y = infoHeader.height
		paso = -1
	end	

	fp:seek("set",54)
	 
	while totalRead < totalSize do
		local RGB = fp:read(3)
		
		local B = string.byte(string.sub(RGB,1))
		local G = string.byte(string.sub(RGB,2))
		local R = string.byte(string.sub(RGB,3))
		local A = 255
		
		img:pixel((x - 1),(y - 1),color.new(R,G,B,A));
		
		totalRead = totalRead + 3;
		
		x = x + 1;
		
		if x > infoHeader.width then
			if onBmpLoad then
				onBmpLoad(math.floor((100*totalRead)/totalSize),img)
				screen.flip()
			end
			x = 1;
			y = y + paso;
		end

	end
	
	return img
end

function bmp.getImageFrom32(fp,infoHeader)-- 32 bits (4 bytes por pixel RGBA)

	local img = image.new(infoHeader.width,infoHeader.height,color.new(0,0,0,0))	-- Creamos nuestra nueva imagen
	local x,y = 1,1
	local paso = 1
	
	local totalSize = fp:seek("end")									-- Entero total en tamaño del archivo
	local totalRead = 54												-- Entero total en tamaño leido
	local store = totalSize 
	
	if infoHeader.height < 0 then
		y = 1
		paso = 1
	else
		y = infoHeader.height
		paso = -1
	end	

	fp:seek("set",54)

	local toread = totalSize - 54
	local databin = fp:read(toread) -- meto a ram toda la data para mejorar tiempo carga
	while totalRead < totalSize do
		--local RGBA = fp:read(4) -- string.byte(RGBA,1,-1) -- index de todo a todo
		local B,G,R,A = string.byte(databin,totalRead-53,totalRead-50) -- byte en lugar de varios subs y bytes, recuerda usar el rango (david)
		
		img:pixel((x - 1),(y - 1),color.new(R,G,B,A));
		
		totalRead = totalRead + 4;
		
		x = x + 1;
		
		if x > infoHeader.width then
			--if onBmpLoad then
			--	onBmpLoad(math.floor((100*totalRead)/totalSize),img)
			--	screen.flip()
			--end
			x = 1;
			y = y + paso;
		end
	end
	return img
end


--[[
function bmp.save(image,path) -- tratare guardar a 32 bits un obj img
	fp = io.open(path,"wb")
	local ftp = io.open("back.bmp","rb")
	local ftd = ftp:read(54)
	ftp:close()
	fp:write(ftd)
	ejex,ejey = 1,272
	while ejey > 0 do
		local pixelcolor = image:pixel(ejex,ejey)
		fp:write(string.char(color.b(pixelcolor)))
		fp:write(string.char(color.g(pixelcolor)))
		fp:write(string.char(color.r(pixelcolor)))
		fp:write(string.char(255))
		ejex = ejex + 1
		if ejex > 480 then
			ejex = 1
			ejey = ejey - 1
		end
	end
	os.message("x,y:"..ejex..","..ejey)
	fp:close()
end]]
