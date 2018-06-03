--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Modulo:	App
	Descripcion: Visor de Imagenes
]]
app = sdk.newApp("Gallery")

app.scaleimg = 50
app.ximg = 240
app.yimg = 131
app.inputpath = ""

function app.init(path,input)
	if input then
		sdk.setTitleApp(app,files.nopath(input).." - Gallery")
		app.inputpath = input
		app.imgdata = image.load(input)--sdk.loadImage
	else
		app.imgdata = image.load(path.."icon.png")
	end
	if app.imgdata then
	app.imgdata:resize(470,220)
	app.imgdata:center()
	end
	app.toolbar = image.load(path.."toolbar.png")
end

function app.run(x,y)
	
	if app.imgdata then
	--screen.bilinear(1)
	app.imgdata:blit(app.ximg,app.yimg)--creen.print(x,y,"Test Download MultiThreads",0.7,color.new(255,255,255),color.new(0,0,0))
	--screen.bilinear(0)
	if buttons.held.r then
		app.scaleimg = app.scaleimg + 1
		app.imgdata:scale(app.scaleimg)
		app.imgdata:center()
	elseif buttons.held.l then
		app.scaleimg = app.scaleimg - 1
		app.imgdata:scale(app.scaleimg)
		app.imgdata:center()
	end
	
	if sdk.underAppCursor() then
		if buttons.cross then
			cursor.set("select")
			cursor.limit(sdk.x,sdk.y,sdk.w,sdk.h) -- tamaño de la ventana :P
		elseif buttons.released.cross then
			cursor.set("normal")
			cursor.limit()
		end
	end
	if buttons.held.cross and cursor.restrict() then
		local mx,xy = sdk.getMotionCursor()
		app.yimg += xy
		app.ximg += mx
	end

	
	end
	app.toolbar:blit(x,y)

	if cursor.isOver(x + 2,y + 2,27,23) then
		draw.fillrect(x + 2,y + 2,27,23,color.shine)
	end
	if cursor.isOver(x + 2,y + 2+25,27,23) then
		draw.fillrect(x + 2,y + 2+25,27,23,color.shine)
	end
	if cursor.isOver(x + 2,y + 2+25+25,27,23) then
		draw.fillrect(x + 2,y + 2+25+25,27,23,color.shine)
		if buttons.cross and app.imgdata then
			local opciones = {
				{txt = "Set as Background", action = function () desk.tmpback = image.copy(app.imgdata) cfg.set("theme","backpath",app.inputpath) end, args = nil, state = false, overClose = true},
				{txt = "Edit Image", action = function () sdk.callApp("paint",app.inputpath) end, args = nil, state = true, overClose = true},
				{txt = "Reload Image", action = function () app.imgdata = image.load(app.inputpath) app.imgdata:center() end , args = nil, state = true, overClose = true},
				{txt = "Open Location", action = function () sdk.callApp("filer",app.inputpath) end , args = nil, state = true, overClose = true},
			}
			opciones[1].state = app.imgdata:getrealw() == 480 and app.imgdata:getrealh() == 272
			POPUP.setElements(opciones)
			POPUP.activate()
		end
	end
end

function app.term()
	
end
