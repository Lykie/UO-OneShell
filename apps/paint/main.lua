--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Modulo:	App
	Descripcion: Editor Grafico
]]
app = sdk.newApp("New - Paint",0x0)
function app.init(path,input)
	--os.message(0x8000)
	--dofile(path.."fxadd.lua")
	app.loadroot = path
	app.back = image.load(path.."back.png") 
	if input then
		app.capa = image.load(input)
		sdk.setTitleApp(app,input.." - Paint")
	end
	if not app.capa then app.capa = image.new(470,220,0x0) end
	app.savepath = input
	app.btt_new = sdk.newButtonImg(7,23,path.."new.png","New","cross",function() app.capa:clear(0x0) end)
	app.btt_load = sdk.newButtonImg(26,23,path.."open.png","Open","cross",function() app.capa = image.load(app.loadroot.."img.png") end)
	app.btt_save = sdk.newButtonImg(45,23,path.."save.png","Save","cross",function() app.capa:save(app.savepath or "ms0:picture/proyecto1.png") end)
	app.btt_grey = sdk.newButtonImg(64,23,path.."grey.png","Grayscale","cross",function() app.capa:fxgrey() end)
	app.btt_sepia = sdk.newButtonImg(83,23,path.."sepia.png","Sepia Effect","cross",function() app.capa:fxsepia() end)
	app.btt_old = sdk.newButtonImg(102,23,path.."old.png","Old Effect","cross",function() app.capa:fxold() end)
	app.btt_neg = sdk.newButtonImg(121,23,path.."negative.png","Invert Colors","cross",function() app.capa:fxinvert() end)
end
function app.run(x,y)
	app.back:blit(x,y+20)
	app.capa:blit(x,y+20)
	cx,cy = sdk.getCursor()
	if buttons.held.cross and cx > 5 and cx < 475 and cy > 41 and cy < 241 then
		for u=cy-41-2,cy-41+5 do
		for i=cx-5-2, cx+6 do
			app.capa:pixel(i,u,color.black)
		end
		end
	end
	if buttons.held.circle and cx > 5 and cx < 475 and cy > 41 and cy < 241 then
		for u=cy-41-2,cy-41+5 do
		for i=cx-5-2, cx+6 do
			app.capa:pixel(i,u,color.new(255,255,255,0))
		end
		end
	end
	draw.fillrect(x,y,470,20,color.new(200,200,200)) -- Barra de menu o accesos rapidos
	app.btt_new:draw()
	app.btt_load:draw()
	app.btt_save:draw()
	app.btt_grey:draw()
	app.btt_sepia:draw()
	app.btt_old:draw()
	app.btt_neg:draw()
end
