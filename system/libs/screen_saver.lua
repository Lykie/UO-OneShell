-- ## Screen Saver 3D ##
-- Agradecimientos a mills :D
screen_saver_init = false
function  screen.saver()
	if screen_saver_init == false then -- inicializa los parametros
		screen_saver_donut = model3d.load("system/images/screensaver/torus.obj")
		amg.typelight(1,__DIRECTIONAL)
		amg.colorlight(1,color.new(250,250,250),color.new(90,90,90),color.new(250,250,250))
		amg.poslight(1,{0,1,1})
		screen_saver_camera1 = cam3d.new()
		cam3d.position(screen_saver_camera1,{0,450,-604})
		cam3d.eye(screen_saver_camera1,{0,0,0})
		cam3d.set(screen_saver_camera1)
		screen_saver_x = 0;
		screen_saver_y = 0;
		screen_saver_z = 0;
		screen_saver_init = true
	else
		screen.clear(color.black) -- fondo negro :D
		amg.mode2d(0) -- comienza el dibujado 3D
		amg.perspective(35.0)
		amg.light(1,1);
		amg.fog(8,17,color.black)	
		--Donuts
		if type(screen_saver_donut) == "string" then amg.mode2d(1) box.new("Screensaver Error",tostring(screen_saver_donut)) screen_saver_init = false amg.mode2d(0) return end
		model3d.rotation(screen_saver_donut,1,{screen_saver_x,screen_saver_y,screen_saver_z})
		model3d.render(screen_saver_donut,1)
		amg.fog()		
		amg.light(1,0);
		amg.mode2d(1) -- termina el 3D y vuelve a 2D
		screen_saver_x = screen_saver_x +0.1; 
		screen_saver_y = screen_saver_y -0.2; 
		screen_saver_z = screen_saver_x + 0.3;	
	end
end
