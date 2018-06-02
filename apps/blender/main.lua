--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Modulo:	App
	Descripcion: Visor de escenas 3D
]]
app = sdk.newApp("Blender Plus Edition",0x0)
app.angles = {x = 0, y = 0, z = 20} -- variables de rotacion xD
function app.init(path,input)
	amg.perspective(35.0) -- ajuste de perspectiva
	if input and files.exists(input) then
		local ext = string.sub(input,-4,-1):lower()
		if ext == ".obj" then
			app.model = model3d.load(input)
		else
			local newroot = files.nofile(input)..""..files.nopath(input):sub(1,-4):lower().."obj"
			label.call("debug blender","root:"..tostring(newroot))
			if files.exists(newroot) then
				app.model = model3d.load(newroot)
			else
				app.model = model3d.load(path.."coordenadas.obj")
			end
		end
	else
		app.model = model3d.load(path.."coordenadas.obj")--"wall/pared.obj"
	end
	--app.perspective = model3d.load(path.."coordenadas.obj")
	app.camera = cam3d.new() -- Nuevo objeto camara
	cam3d.eye(app.camera,{0,0,0})
	amg.typelight(1,__DIRECTIONAL)
	amg.colorlight(1,color.new(250,250,250),color.new(40,40,40),color.new(80,80,80))
	amg.poslight(1,{1,1,1})
	app.back = image.load(path.."back.png")
end

function app.run(x,y)
	app.back:blit(x,y)
	sdk.enable3d(true) -- Apartir de aqui solo 3D
    cam3d.set(app.camera) --Activa camara 
    cam3d.position(app.camera,{0,0,app.angles.z}) --Posicion camara
	amg.light(1,1) --Enciende Luz 1	
	model3d.render(app.model,1) --Dibuja modelo
	--model3d.render(app.perspective)
	amg.light(1,0) --Apaga Luz 1
	sdk.enable3d(false)
		draw.fillrect(5, 21, 470, 20, color.new(55,72,251,220))
		screen.print(100,23,"X: "..string.format("%.2f",app.angles.x),0.7,color.white)	
		screen.print(180,23,"Y: "..string.format("%.2f",app.angles.y),0.7,color.white)	
		screen.print(260,23,"Z: "..string.format("%.2f",app.angles.z),0.7,color.white)	
	sdk.enable3d(true)
	
	model3d.rotation(app.model,1,{app.angles.x,app.angles.y,0}) --Rota el modelo
	--model3d.rotation(app.perspective,1,{app.angles.x,app.angles.y,0}) --Rota el perspectiva
	
	if buttons.square and sdk.underAppCursor() then
		cursor.hold(true)
	end
	if buttons.held.square and cursor.hold() then
		if buttons.held.right then app.angles.y = app.angles.y -0.6 end
		if buttons.held.left then app.angles.y = app.angles.y +0.6 end
		if buttons.held.up then app.angles.x = app.angles.x + 0.6 end
		if buttons.held.down then app.angles.x = app.angles.x - 0.6 end		
	end
	if buttons.released.square then
		cursor.hold(false)
	end
	
	if buttons.held.l then app.angles.z = app.angles.z + 0.6 end --aleja cam	
	if buttons.held.r then app.angles.z = app.angles.z - 0.6 end --acerca cam
	
	if app.angles.x > 360 then	app.angles.x=0
	elseif app.angles.x < 0 then	app.angles.x=360
	end
	
	if app.angles.y > 360 then	app.angles.y=0
	elseif app.angles.y < 0 then	app.angles.y=360
	end

	sdk.enable3d(false) -- Obligatorio regresar a su estado
end