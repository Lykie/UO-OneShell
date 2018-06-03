app = sdk.newApp("Text Viewer")
app.data = {}

function app.init(path,input)
	if not input then input = path.."main.lua" end
	if files.exists(input) then
		app.data = files.readlines(input)
		app.scroll = files.nopath(input)
		scroll.set(app.scroll,app.data,14)
		app.bar = sdk.createScroll(#app.data,220,220,1)
	end
end
function app.run(x,y)
--os.message(y)
--y = 21
	--draw.fillrect(0,0,480,272,desk.barcolor)
	--screen.print(x,y,"",0.7,color.new(255,255,255),color.new(0,0,0))
	local i = scroll[app.scroll].ini
	local pos = 0
	while i<=scroll[app.scroll].lim do
		screen.print(x,y+(pos*15),i,0.5,color.gray,0x0)
		local ctxt = color.gray
		if i == scroll[app.scroll].sel then
		ctxt = color.red
		end
	screen.print(x+15,y+(pos*15),string.gsub(app.data[i],"\t"," "),0.7,ctxt,0x0)
	i = i + 1
	pos = pos + 1
	end
	if buttons.held.r then
		scroll.down(app.scroll)
	elseif buttons.held.l then
		scroll.up(app.scroll)
	end
	app.bar.show()
	app.bar.blit(465,21)
end
--function app.term() end
