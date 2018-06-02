--[[
	ONE SHELL - SimOS
	Entorno de Ventanas Multitareas.
	
	Licenciado por Creative Commons Reconocimiento-CompartirIgual 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Modulo:	App
	Descripcion: Lanzador de Aplicaciones (Homebrews/isos/cso)
]]
app = sdk.newApp("Launcher",color.new(27,64,92))
--[[
	Modos:
	0 Over list
	1 Over title
]]
app.mode = 0
app.pic = nil
app.icon = nil
app.root = nil


lang["menu"] = {
"Play",
"Show in Folder",
}
lang["categories"] = {
"Games",
"Homebrew",
"PS One",
}
function app.init(path)
	app.keyscroll = app.attributes.index--app.fnt = font.load(path.."Roboto-Condensed.pgf")
	app.unk = image.load(path.."unk.png")
	app.data = {
	{},
	{},
	{},
	{},
	}
	app.cat = 1
	local listtemp = files.list("ms0:/iso/")
	for i=1,#listtemp do
		if listtemp[i].ext and listtemp[i].ext == "iso" or listtemp[i].ext == "cso" then
			local infotemp = game.info(listtemp[i].path)
			table.insert(app.data[1],{region = infotemp.REGION,name = infotemp.TITLE,icon = game.geticon0(listtemp[i].path), path = listtemp[i].path})
		end
		--if listtemp[i].ext and listtemp[i].ext == "dax" then
		--	table.insert(app.data[1],{region = "unk",name = files.nopath(listtemp[i].path):sub(1,-5),icon = nil, path = listtemp[i].path})
		--end
	end
	local listtemp = files.listdirs("ms0:/psp/game/")
	for i=1,#listtemp do
		if files.exists(listtemp[i].path.."/EBOOT.PBP") then
			local infotemp = game.info(listtemp[i].path.."/EBOOT.PBP")
			table.insert(app.data[2],{region = infotemp.REGION,name = infotemp.TITLE,icon = game.geticon0(listtemp[i].path.."/EBOOT.PBP"), path = listtemp[i].path.."/EBOOT.PBP"})
		end
	end
	scroll.set(app.keyscroll,app.data[app.cat],16)
end
function app.draw_back(x,y)
	draw.fillrect(5,20,313,20,color.new(0,0,0,100))
	draw.fillrect(5,41,313,4,color.cyan)
	local over_cat = 0
	for i=1,3 do
		if cursor.isOver(x+6+((i-1)*100),y,100,20) then
			over_cat = i
		end
		if i==app.cat then
			draw.fillrect(x+((i-1)*107)-1,y,100,20,color.cyan)
		end
		screen.print(x+8+((i-1)*110),y+3,lang["categories"][i])
		
	end
	if buttons.cross and over_cat > 0 then
		app.cat = over_cat
		scroll.set(app.keyscroll,app.data[app.cat],16)
	end
end

function app.run(x,y)
	--draw.fillrect(5,21,470,220,color.new(27,64,92))
	
	--app.bk:blit(5,21)
	
	if app.mode == 0 then
		app.draw_back(x,y)
		local over_opt = 0
		if buttons.r then
			scroll.down(app.keyscroll)
		elseif buttons.l then
			scroll.up(app.keyscroll)
		end
		local over = app.draw_Apps(x,y+5)
		if over > 0 then
			if buttons.cross then
				app.pic = game.getpic1(app.data[app.cat][over].path)
				app.icon = app.data[app.cat][over].icon
				if not app.icon then
					app.icon = app.unk
					--app.unk:resize(144,80)
				end
				app.title = app.data[app.cat][over].name
				app.root = app.data[app.cat][over].path
				app.region = app.data[app.cat][over].region
				if app.cat == 1 then
					app.size = files.sizeformat(files.size(app.data[app.cat][over].path))
				else
					app.size = files.sizeformat(files.size(files.nofile(app.data[app.cat][over].path)))
				end
				app.mode = 1
			end
		end
	elseif app.mode == 1 then
		if app.pic then
			app.pic:resize(470,220)
			app.pic:blit(5,21)
		end
		if app.icon then
			app.icon:resize(144,80)
			app.icon:blit(x,y)
		end
		screen.print(x+8,y+85,app.title,0.6,color.white,color.black)
		screen.print(x+8,y+100,app.root,0.5,color.white,color.black)
		screen.print(x+8,y+130,app.size,0.5,color.white,color.black)
		screen.print(x+9,y+145,app.region,0.5,color.white,color.black)
		
		
		draw.fillrect(305+25,y+36,140,125,color.shadow)
		local over = 0
		for i=1,2 do
			if cursor.isOver(305+25,y+52+(25*(i-1))-5,140,25) then
				over = i
				draw.fillrect(305+25,y+55+(25*(i-1))-5,140,25,color.cyan)
			end
			screen.print(315+25,y+52+(25*(i-1)),lang["menu"][i])
		end
		if buttons.cross and over == 1 then
			sdk.showPmf("gameboot.pmf")
			sdk.runGame(app.root)
		elseif buttons.cross and over == 2 then
			sdk.callApp("filer",app.root)
		end
		if buttons.circle and sdk.underAppCursor() then
			app.mode = 0
		end
	end
	screen.print(x,y,#app.data[app.cat],0.7,color.red)
end

function app.term()
end
-- Funciones extras ..
function app.draw_Apps(x,y)
	local i,len,pos = scroll[app.keyscroll].ini,scroll[app.keyscroll].lim,0
	local sel = 0
	while i<=len do
		if cursor.isOver(7+(pos*94),y+21,90,50) then
			draw.fillrect(9+(pos*94)-2,y+20,90,50+2,color.new(255,255,255,100))
			sel = i
		end
		if app.data[app.cat][i].icon then	
			app.data[app.cat][i].icon:resize(90,50)	
			app.data[app.cat][i].icon:blit(7+(pos*94),y+21) 
		else
			app.unk:resize(90,50)
			app.unk:blit(7+(pos*94),y+21) 
		end
		i = i + 1
		pos = pos + 1
		if pos > 4 then
			pos = 0
			y = y + 51
		end
	end
	return sel
end
