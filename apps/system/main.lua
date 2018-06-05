app = sdk.newApp("System",color.shadow)
app.AllRam = files.sizeformat(__SHELL_MAX_RAM)
function app.init(path,input)
	local root = path.."images/"
	app.folder ={
		image.load(root.."pictures.png"),
		image.load(root.."games.png"),
		image.load(root.."music.png"),
		image.load(root.."videos.png")
	}
	app.namefolder = {"Pictures","Games","Music","Videos"}
	app.roots = {__SHELL_IS_DEVROOT.."PICTURE/",__SHELL_IS_DEVROOT.."PSP/GAME/",__SHELL_IS_DEVROOT.."MUSIC/",__SHELL_IS_DEVROOT.."VIDEO/"}
	for i=1,#app.roots do
		if not files.exists(app.roots[i]) then
			files.mkdir(app.roots[i])
		end
	end
	app.focus = 0;
	app.pc_ic = image.load(root.."os.png")
	app.dev_ic = image.load(root.."ms.png")
	if __SHELL_IS_DEVROOT == "ms0:/" then
		app.dev_info = os.infoms0()
	else
		app.dev_info = os.infoef0()
	end
	app.dev_info.free_label = files.sizeformat(app.dev_info.free)
	app.dev_info.max_label = files.sizeformat(app.dev_info.max)
end
app.porcent = 0
function app.run(x,y)
	local i,len = 1,4
	local x,y,pos,s = x+5,y+5,0,7
	local w,h = 120,54
	local oneover = 0
	while i <= len do
		if app.focus == i then draw.fillrect(x-5, y-5, w, h-5, color.shine); draw.rect(x-5, y-5, w, h-5, color.white) end
		local overOn = cursor.isOver(x, y, w, h)
		if overOn then
			draw.fillrect(x-5, y-5, w, h-5, color.shine); draw.rect(x-5, y-5, w, h-5, color.white)
			oneover = i
		end
		if app.folder[i] then
			app.folder[i]:blit(x,y)
		end
		screen.print(x+45,y+20,app.namefolder[i],0.6,color.white,color.black)
		i,pos,y = i + 1, pos + 1, y + h + s
		if pos > 1 then
			pos = 0
			y = sdk.y+5
			x = x + w + s
		end
	end
	if oneover ~= 0 and app.focus == oneover and buttons.accept then sdk.callApp("filer",app.roots[app.focus]) end
	if oneover ~= 0 and app.focus ~= oneover and buttons.accept then app.focus = oneover end
	if cursor.isOver(5,145,155+70,55) then
		draw.fillrect(5,145,155+70,55, color.shine); draw.rect(5,145,155+70,55, color.white)
		if buttons.accept then
			sdk.callApp("filer",__SHELL_IS_DEVROOT)
		end
	end
	app.dev_ic:resize(60,38)
	app.dev_ic:blit(10,160)
	screen.print(10+30,160-15,__SHELL_IS_DEVROOT,0.6,color.white,color.black,512)
	draw.progress_bar(75,160+12,150,15,app.dev_info.max,app.dev_info.used,color.green,color.black)
	screen.print(75,160-3,app.dev_info.free_label.." / "..app.dev_info.max_label,0.6,color.white,color.black)
	draw.line(5,200,475,200,color.white)
	draw.line(200,200,200,241,color.white)
	app.pc_ic:blit(6,200)
	screen.print(46,205,"OneShell: "..__SHELL_VERSION)
	screen.print(46,220,"User: "..__SHELL_NICK)
	screen.print(205,205,"Model: "..__SHELL_OVER_MODEL)
	screen.print(205+150,205,"Core: "..__SHELL_SYS)
	screen.print(205,220,"BIOS: "..__SHELL_BIOS)
	screen.print(205+150,220,"RAM: "..app.AllRam)
end
