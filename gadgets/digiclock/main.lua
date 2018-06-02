---- GADGET: reloj

gadget = {}
function gadget.init(path,input)
	gadget.font=font.load(path.."digital.pgf")
end

function gadget.run(x,y,trans)
	draw.fillrect(x,y+26,62,23,color.shadow)
	draw.rect(x,y+26,62,23,color.gray)
	screen.print(gadget.font,x+32,y+36,os.date("%H:%M"),1,color.white,color.black,512)
end
