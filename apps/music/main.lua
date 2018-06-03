app = sdk.newApp("Music Player",color.new(64,64,64))

app.Now_Play_Name = ""
app.datasound = nil
app.crono = 0
app.state = 1
app.infosound = {}
app.playlist = files.listfiles("ms0:/music/")
app.overlist = 1
if #app.playlist > 10 then app.lenlist = 10 else app.lenlist = #app.playlist end
function app.init(path,input)
	app.default_icon = image.load(path.."cover.png")
	app.actions = image.load(path.."actions.png",32,32)
	app.audioicon = image.load(path.."audio.png")
	app.loopicon = image.load(path.."loop.png")
	app.loadsound(input)
end

function app.run(x,y)
	for i=1,app.lenlist do
		if(i==app.overlist)then co = color.green else co = color.white end
		screen.print(x+5,y+(15*i-1),app.playlist[i].name,0.6,co)
	end
	-- ## Drawn from Cover ##
	draw.line(252,21,252,241,color.white)
	
	if app.infosound.cover then 
		app.infosound.cover:blit(253,y)
	else
		app.default_icon:blit(253,y)
	end
	draw.line(252,171,475,171,color.white)
	
	-- ## Action & Drawn by Play/Pause
	if cursor.isOver(347,210,32,32) then
		draw.fillrect(347,210,32,32,color.shine)
		if buttons.cross then
			app.datasound:pause()
		end
	end
	if app.datasound:playing() then
		app.state = 1
	else
		app.state = 0
	end
	app.actions:blitsprite(347,210,app.state)
	-- Next List Action
	if cursor.isOver(379,210,32,32) then
		draw.fillrect(379,210,32,32,color.shine)
		if buttons.cross then
			app.overlist = app.overlist + 1
			if app.overlist > #app.playlist then 
				app.overlist = #app.playlist
			end
			app.loadsound(nil)
		end
	end
	app.actions:blitsprite(379,210,4)
	--Previous List Action
	if cursor.isOver(315,210,32,32) then
		draw.fillrect(315,210,32,32,color.shine)
		if buttons.cross then
			app.overlist = app.overlist - 1
			if app.overlist < 1 then 
				app.overlist = 1
			end
			app.loadsound(nil)
		end
	end
	app.actions:blitsprite(315,210,3)
	--Music Player Volume
	if cursor.isOver(411,210,32,32) then
		draw.fillrect(411,210,32,32,color.shine)
		if buttons.cross then
			local opciones = {
				{txt = "0%", action = function () app.datasound:vol(0) end, args = nil, state = true, overClose = false},
				{txt = "25%", action = function () app.datasound:vol(25) end, args = nil, state = true, overClose = false},
				{txt = "50%", action = function () app.datasound:vol(50) end, args = nil, state = true, overClose = false},
				{txt = "75%", action = function () app.datasound:vol(75) end, args = nil, state = true, overClose = false},
				{txt = "100%", action = function () app.datasound:vol(100)  end, args = nil, state = true, overClose = false},
			}
			POPUP.setElements(opciones)
			POPUP.activate()
		end
	end
	app.audioicon:blit(411,210)
	--Looping
	if app.datasound:looping() then
		draw.fillrect(283,210,32,32,color.shine)
	end
	if cursor.isOver(283,210,32,32) then
		draw.fillrect(283,210,32,32,color.shine)
		if buttons.cross then
			app.datasound:loop()
		end
	end
	app.loopicon:blit(283,210)
	screen.print(363,175,app.Now_Play_Name,0.7,color.white,0x0,512)
	screen.print(363,y+5,app.layer[app.layer.pos],0.7,color.new(255,255,255,app.layer.trans),0x0,512)
	if app.layer.scale then
		app.layer.trans = app.layer.trans + 2
	else
		app.layer.trans = app.layer.trans - 2
	end 
	if app.layer.trans < 4 then 
		app.layer.scale = true
		app.layer.pos = app.layer.pos + 1
		if app.layer.pos > 2 then app.layer.pos = 1 end
	elseif app.layer.trans > 253 then
		app.layer.scale = false
	end
	draw.rect(257,200,213,10,color.white)
	if app.datasound then
		if app.datasound:endstream() and not app.datasound:looping() then
			app.overlist = app.overlist + 1
			if app.overlist > #app.playlist then 
				app.overlist = #app.playlist
			else
				app.loadsound(nil)
			end
		end
	end
end

function app.term()
	if app.datasound then
		app.datasound:stop()
	end
end
function app.loadsound(path)
	app.datasound = sound.load(path or app.playlist[app.overlist].path)
	app.infosound = sound.getid3(path or app.playlist[app.overlist].path)
	if app.infosound.cover then
		app.infosound.cover:resize(222,149)
	end
	if app.infosound.title then
		app.Now_Play_Name = app.infosound.title
	else
		app.Now_Play_Name = path or app.playlist[app.overlist].path
	end
	app.layer = {app.infosound.album or "unknow",app.infosound.artist or "unknow", trans = 255, pos = 1, scale = false}
	app.datasound:play(0)
end
