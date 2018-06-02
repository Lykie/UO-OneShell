--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
		http://creativecommons.org/licenses/by-sa/4.0/
	]]
-- ## Home Menu ##
home = {} -- modulo home
home.pos = 0
function home.api(x1,y1,x2,y2) -- funciones del menu home
	screen.print(x1,y1,"OneShell Menu",0.6,color.white,color.black,512) -- titulo
	draw.fillrect(x2,(home.pos*15)+y2,310,15,color.new(255,255,255,100))
	if usb.isactive() then
		screen.print(x1,y2,"Deshabilitar USB",0.6,color.white,color.black,512)
	else
		screen.print(x1,y2,"Habilitar USB",0.6,color.white,color.black,512)
	end
	y2 = y2 + 15
	screen.print(x1,y2,"Restart",0.6,color.white,color.black,512)
	y2 = y2 + 15
	screen.print(x1,y2,"Suspend",0.6,color.white,color.black,512)
	y2 = y2 + 15
	screen.print(x1,y2,"Shutdown",0.6,color.white,color.black,512)
	y2 = y2 + 15
	screen.print(x1,y2,"Return to XMB",0.6,color.white,color.black,512)
	y2 = y2 + 15
	screen.print(x1,y2,"Cancel",0.6,color.white,color.black,512)
	if buttons.up and home.pos > 0 then
	home.pos = home.pos - 1
	elseif buttons.down and home.pos < 5  then
	home.pos = home.pos + 1
	end
	if buttons.circle then
		box.close()
		home.pos = 0
	end
	if buttons.cross then
		if home.pos == 0 then
			if usb.isactive() then
				usb.stop  (  ) 
			else
				usb.mstick  (  ) 
			end
		elseif home.pos == 1 then
			kernel.fadeout()
			os.restart()
		elseif home.pos == 2 then
			kernel.fadeout()
			power.suspend()
		elseif home.pos == 3 then
			kernel.fadeout()
			power.off  (  ) 
		elseif home.pos == 4 then
			kernel.exit()
		end
		--game.add("eboot.pbp","ICON0.PNG",__ICON0)
		--game.add("eboot.pbp","SND0.AT3",__AT3)
		box.close()
		home.pos = 0
	end
end

function home.init() -- inicia el menu home
	box.api(home.api,true)
end	
