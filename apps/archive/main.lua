app = sdk.newApp("New - WinRAR")
app.overfile = false
function app.init(path,input)
--	app.tmp = input or ""
	--label.call("debug winrar",input.dst)
	--if input then
		--if files.exists(input) then
			--files.threadextract(input.src,input.dst)
		--end
		--sdk.exitApp(app)
	--end
	--app.btt_new = sdk.newButtonImg(7,23,path.."new.png","Nuevo","cross",function() app.capa:clear(0x0) end)
	--app.btt_load = sdk.newButtonImg(26,23,path.."open.png","Abrir","cross",function() app.capa = image.load(app.loadroot.."img.png") end)
	--if not input then
	--	input = "ms0:/file.rar"
	--end
	if input then
		app.scan(input)
	else
	
	end
	--sdk.exitApp(app)
end
function app.run(x,y)
	--screen.print(x,y,app.tmp,0.7,color.gray)
	if app.overfile then
		for i=app.list.ini,app.list.lim do
			screen.print(x+10,y+(i*10),app.list.data[i].name,0.6,color.gray)
		end
	end
end
function app.scan(input) -- Escanemos una ruta y devolvemos la tabla de conenido
	app.list = {ini = 1,sel = 1,lim = 1}
	app.list.data = files.scan(input)
	if app.list.data then
		app.overfile = true
		if #app.list.data > 5 then
			app.list.lim = 5
		else
			app.list.lim = #app.list.data
		end
	end
end