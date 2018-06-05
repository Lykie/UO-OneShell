desk = {}
desk.apps = {}
desk.open = 0
desk.state = 1
desk.imenu = kernel.loadimage("system/images/desktop/menu.png")
desk.power = kernel.loadimage("system/images/desktop/power.png")

__DEFBACKPATH = "system/images/wallpaper/wallpaper_1.png"
local rootto = __DEFBACKPATH
	if files.exists(cfg.get("theme","backpath")) then
		rootto = cfg.get("theme","backpath")
	end
desk.background = kernel.loadimage(rootto)

desk.brillo = color.shine
desk.barcolor = color.new(44,86,129,100)
desk.linecolor = color.gray

__DESKOVERAPP = 3
__DESKOVERMENU = 2
__DESKOVERNOTHING = 1

__DESKACCESSAPP = 1
__DESKACCESSFILE = 2
__DESKACCESSFOLDER = 3
__DESKACCESSGAME = 4


function desk.registerapp(index,icoimg,name)
	local sh = icoimg:getrealh()
	local sw = icoimg:getrealw()
	local deskbicon = image.copy(icoimg)
	deskbicon:resize(20,(sh*20)/sw)
	deskbicon:center()
	
	desk.open = desk.open + 1
	desk.apps[#desk.apps+1] = {index = index,bico = deskbicon,label = name}
	desk.state = __DESKOVERAPP
	return #desk.apps
end
desk.drawsel = false
desk.xsel=0
desk.ysel=0
desk.wsel=0
desk.hsel=0
function desk.run()
	desk.drawback()
	desk.drawbottombar()
	driver.run_low()
	if desk.state == __DESKOVERMENU then
		menu_start.run()
	else
		if desk.state == __DESKOVERNOTHING then
			gadget_mgr.run()
			if __SHELL_DEBUG then
				desk.debug()
			end
			if buttons.held.accept and desk.drawsel then
				local tx,ty = cursor.motion()
				desk.wsel += tx
				desk.hsel += ty
				draw.fillrect(desk.xsel,desk.ysel,desk.wsel,desk.hsel,color.shine)
				draw.rect(desk.xsel,desk.ysel,desk.wsel,desk.hsel,color.white)
			end
			access_mgr.draw()
			desk.menu()
			if buttons.accept and cursor.isOver(0,0,480,247) and access_mgr.focus == 0 and not desk.drawsel then
				desk.drawsel = true
				desk.xsel,desk.ysel = cursor.xy()
				desk.wsel,desk.hsel = 0,0
			end
			if buttons.released.accept and desk.drawsel then
				desk.drawsel = false
			end
		elseif desk.state == __DESKOVERAPP then
			app_mgr.run_app()
		end
	end
	driver.run_high()
	label.run()
end
desk.tmpalfa = 0
desk.tmpback = nil
function desk.drawback()
	if desk.background then
		desk.background:blit(0,0)
	end
	if desk.tmpback then
		desk.tmpback:blit(0,0,desk.tmpalfa)
		if desk.tmpalfa < 255 then
			desk.tmpalfa += 11
		else
			desk.tmpalfa = 0
			desk.background = nil
			collectgarbage()
			desk.background = desk.tmpback
			desk.tmpback = nil
			collectgarbage()
		end
	end
end
desk.randombacks = {"system/images/wallpaper/wallpaper_1.png","system/images/wallpaper/wallpaper_2.png","system/images/wallpaper/wallpaper_3.png","system/images/wallpaper/wallpaper_4.png","system/images/wallpaper/wallpaper_5.png"}
function desk.setback(root)
	math.randomseed(os.clock())
	desk.tmpback = image.load(desk.randombacks[math.random(1,#desk.randombacks)])
end

function desk.drawbottombar()
	
	draw.fillrect(0,247,480,25,desk.barcolor)
	draw.line(0,247,480,247,desk.linecolor)
	if buttons.home then 
			if desk.state ~= __DESKOVERMENU then
				desk.laststate = desk.state
				desk.state = __DESKOVERMENU
			else
				desk.state = desk.laststate
			end
		end
	if cursor.isOver(0,247,35,25) then
		draw.fillrect(0,247,35,25,desk.brillo)
		cursor.label("Start Menu")
		if buttons.menu then 
			power.menu()
		end
		if buttons.accept then
			if desk.state ~= __DESKOVERMENU then
				desk.laststate = desk.state
				desk.state = __DESKOVERMENU
			else
				desk.state = desk.laststate
			end
		end
	end
	desk.imenu:blit(5,249)
	desk.imenu:blitadd(5,249,50)
	draw.line(35,247,35,272,desk.linecolor)
	
	local ejex = 5
	if desk.open > 0 then
		local i=1
		while i<=desk.open do
			if cursor.isOver(ejex+(i*35),249,25,25) then
				draw.fillrect(ejex+(i*35)-5,247,35,25,desk.brillo)
				if buttons.accept then 
					
					if app_mgr.focus == desk.apps[i].index then
						if desk.state == __DESKOVERNOTHING then
							desk.state = __DESKOVERAPP
						elseif desk.state == __DESKOVERAPP then
							desk.state = __DESKOVERNOTHING
						end
					else
						if desk.state == __DESKOVERNOTHING then
							desk.state = __DESKOVERAPP
						end
					end
					
					app_mgr.focus = desk.apps[i].index 
				end
				if buttons.menu then
					local opciones = {
						{txt = "Close", action = function (index) app_mgr.free(desk.apps[index].index) end, args = i, state = true, overClose = false},
						{txt = "Minimize", action = function () desk.state = __DESKOVERNOTHING end, args = i, state = true, overClose = false},
						}
					if desk.state == __DESKOVERNOTHING or app_mgr.focus ~= desk.apps[i].index then
						opciones[2].txt = "Maximize"
						opciones[2].action = function (index) app_mgr.focus = desk.apps[index].index; desk.state = __DESKOVERAPP end
					end
					POPUP.setElements(opciones)
					POPUP.activate()
				end
				cursor.label(desk.apps[i].label)
			end
			if desk.apps[i].index == app_mgr.focus then
				draw.fillrect(ejex+(i*35)-5,247,35,25,desk.brillo)
			end
			desk.apps[i].bico:blit(ejex+(i*35)+12,259)
			draw.line(ejex+(i*35)-5+35,247,ejex+(i*35)-5+35,247+25,color.gray)
			i = i + 1
		end
	end
	
	draw.line(398,247,398,272,desk.linecolor)
	screen.print(434,247,os.date("%I:%M %p"),0.5,color.white,0x0,__ACENTER)
	screen.print(434,257,os.date("%m/%d/%y"),0.5,color.white,0x0,__ACENTER)
	draw.line(470,247,470,272,desk.linecolor)
	if cursor.isOver(470,247,10,25) then
		draw.fillrect(470,247,10,25,desk.brillo)
		if buttons.accept then
			if desk.state == __DESKOVERNOTHING and app_mgr.open ~= 0 then
				desk.state = __DESKOVERAPP
			elseif desk.state == __DESKOVERAPP and app_mgr.open ~= 0 then
				desk.state = __DESKOVERNOTHING 
			elseif desk.state == __DESKOVERMENU then
				desk.state = __DESKOVERNOTHING 
			end
		end
	end

end
function desk.drawupperbar()
	draw.fillrect(0,0,480,20,desk.barcolor)
	draw.line(0,20,480,20,desk.linecolor)
end

function desk.menu()
	if cursor.isOver(0,0,480,247) and POPUP.state() == false and buttons.menu then
		access_mgr.focus = 0
		POPUP.setElements({
		{txt = "Random Wallpaper", action = desk.setback, args = nil, state = true, overClose = false},
		{txt = "Random Window Border", action = function () window.theme += 1; if window.theme > 4 then window.theme = 0 end end, args = nil, state = true, overClose = false},
		})
		POPUP.activate()
	end
end

function power.menu()
	local opciones = {
		{txt = "Suspend", action = kernel.suspend, args = nil, state = true, overClose = true},
		{txt = "Restart", action = kernel.restart, args = nil, state = true, overClose = true},
		{txt = "Shutdown", action = kernel.off, args = nil, state = true, overClose = true},
		{txt = "Return to XMB", action = kernel.exit, args = nil, state = true, overClose = true},
	}
	POPUP.setElements(opciones)
	POPUP.activate()
end



function desk.debug()
local debugtext = "fps:"..screen.fps().." | "..math.round(os.clock()*1000).."\n"
debugtext = debugtext.."Cursor:\n"
debugtext = debugtext.."X:"..cursor.x.."\n"
debugtext = debugtext.."Y:"..cursor.y.."\n"
debugtext = debugtext.."DX:"..cursor.despX.."\n"
debugtext = debugtext.."DY:"..cursor.despY.."\n"
debugtext = debugtext.."SX:"..desk.xsel.."\n"
debugtext = debugtext.."SY:"..desk.ysel.."\n"
debugtext = debugtext.."SW:"..desk.wsel.."\n"
debugtext = debugtext.."SH:"..desk.hsel.."\n"
debugtext = debugtext.."Windows:".."\n"
debugtext = debugtext.."Current:"..app_mgr.focus.."\n"
debugtext = debugtext.."Open:"..app_mgr.open.."\n"
screen.print(400,100,debugtext,0.6,color.white,0x0,__ARIGHT)
end
