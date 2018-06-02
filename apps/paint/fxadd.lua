--[[
	FXAdd
	Library to extend OneLua visual effects

	Created by NEKERAFA on mon 24 ago 2015 14:04:59 (CEST)
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
]]

__FXNOALPHA = 0
__FXALPHA = 1

-- boolean, color.compare(color_1, color_2): Compare two color
function color.compare(c1, c2, alpha)
	if not alpha or alpha<0 or alpha>1 then alpha = 0 end
	if alpha == __FXALPHA then
		return (color.r(c1) == color.r(c2)) and (color.g(c1) == color.g(c2)) and (color.b(c1) == color.b(c2)) and (color.a(c1) == color.a(c2))
	elseif alpha == __FXNOALPHA then
		return (color.r(c1) == color.r(c2)) and (color.g(c1) == color.g(c2)) and (color.b(c1) == color.b(c2))
	end
end

-- color, color.grey(color): Changes true color to grey
function color.grey(col)
	local varcol = math.floor((color.r(col)+color.g(col)+color.b(col))/3)
	return color.new(varcol, varcol, varcol, color.a(col))
end

-- color, color.reverse(color): Reverses color
function color.reverse(col)
	return color.new(255-color.r(col), 255-color.g(col), 255-color.b(col), color.a(col))
end

-- color, color.mix(color_1, color_2, percentaje_1, percentaje_2): Mix colors with a percentaje
function color.mix(c1, c2, p1, p2)
	return color.new(p1*color.r(c1)/100+p2*color.r(c2)/100, p1*color.g(c1)/100+p2*color.g(c2)/100, p1*color.b(c1)/100+p2*color.b(c2)/100, p1*color.a(c1)/100+p2*color.a(c2)/100)
end

-- color, color.blend(color_1, color_2): Mix colours
function color.blend(c1, c2)
	return color.new((color.r(c1)+color.r(c2))/2, (color.g(c1)+color.g(c2))/2, (color.b(c1)+color.b(c2))/2, (color.a(c1)+color.a(c2))/2)
end

-- color, color.add(color_1, color_2): Add colours
function color.add(c1, c2)
	return color.new(color.r(c1)+color.r(c2), color.g(c1)+color.g(c2), color.b(c1)+color.b(c2), color.a(c1)+color.a(c2))
end

-- color, color.sub(color_1, color_2): Sub colours
function color.sub(c1, c2)
	return color.new(color.r(c1)-color.r(c2), color.g(c1)-color.g(c2), color.b(c1)-color.b(c2), color.a(c1)-color.a(c2))
end

-- image, image.fxgrey(image): Changes the image to black and white colors
function image.fxgrey(img)
	local pixel = 0
	local fxgrey = image.new(image.getrealw(img), image.getrealh(img), color.new(0, 0, 0, 0))
	local max = image.getrealw(img)*image.getrealh(img)-1

	while pixel <= max do
		local x, y = math.floor(pixel/image.getrealh(img)), pixel%image.getrealh(img)
		local grey = color.grey(image.pixel(img, x, y))
		local alpha = color.a(image.pixel(img, x, y))
		local col_pixel = color.a(grey, alpha)
		image.pixel(fxgrey, x, y, col_pixel)
		pixel = pixel+1
	end

	return fxgrey
end

-- image, image.fxsepia(image): Changes the image to sepia colors
function image.fxsepia(img)
	local pixel = 0
	local fxsepia = image.new(image.getrealw(img), image.getrealh(img), color.new(0, 0, 0, 0))
	local max = image.getrealw(img)*image.getrealh(img)-1

	while pixel <= max do
		local x, y = math.floor(pixel/image.getrealh(img)), pixel%image.getrealh(img)
		local grey = color.grey(image.pixel(img, x, y))
		local alpha = color.a(image.pixel(img, x, y))
		local mix = color.mix(grey, color.new(112, 66, 20, alpha), 100, 50)
		image.pixel(fxsepia, x, y, mix)
		pixel = pixel+1
	end

	return fxsepia
end

-- image, image.fxold(image, percentaje): Changes the color image to old colours
function image.fxold(img, per)
	local pixel = 0
	local fxold = image.new(image.getrealw(img), image.getrealh(img), color.new(0, 0, 0, 0))
	local max = image.getrealw(img)*image.getrealh(img)-1
	if not per or per<0 or per>100 then per = 75 end

	while pixel <= max do
		local x, y = math.floor(pixel/image.getrealh(img)), pixel%image.getrealh(img)
		local grey = color.grey(image.pixel(img, x, y))
		local alpha = color.a(image.pixel(img, x, y))
		local col_pixel = color.a(grey, alpha)
		local mix = color.mix(col_pixel, color.new(112, 66, 20, alpha), 100, math.random(per))
		local blend = color.blend(image.pixel(img, x, y), mix)
		image.pixel(fxold, x, y, blend)
		pixel = pixel+1
	end

	return fxold
end

-- image, image.fxreverse(image): Reverse image colors
function image.fxreverse(img)
	local pixel = 0
	local fxreverse = image.new(image.getrealw(img), image.getrealh(img), color.new(0, 0, 0, 0))
	local max = image.getrealw(img)*image.getrealh(img)-1

	while pixel <= max do
		x = math.floor(pixel/image.getrealh(img)); y = pixel%image.getrealh(img)
		reverse = color.reverse(image.pixel(img, x, y))
		image.pixel(fxreverse, x, y, reverse)
		pixel = pixel+1
	end

	return fxreverse
end

-- image, image.fxchangecolor(image, color to change, color): Change a color to other color
function image.fxchangecolor(img, col1, col2)
	local pixel = 0
	local imgchangecolor = image.new(image.getrealw(img), image.getrealh(img), color.new(0, 0, 0, 0))
	local max = image.getrealw(img)*image.getrealh(img)-1

	while pixel <= max do
		local x, y = math.floor(pixel/image.getrealh(img)), pixel%image.getrealh(img)
		if color.compare(image.pixel(img, x, y), col1) then image.pixel(imgchangecolor, x, y, col2)
		else image.pixel(imgchangecolor, x, y, image.pixel(img, x, y)) end
		pixel = pixel+1
	end

	return imgchangecolor
end

-- image, image.chr(image, type): Gets the red channel. Types (0: without transparency, 1: with transparency)
function image.chr(img, typ)
	if not typ or typ<0 or typ>1 then typ = 0 end
	local pixel = 0
	local imgchannel = image.new(image.getrealw(img), image.getrealh(img), color.new(0, 0, 0, 0))
	local max = image.getrealw(img)*image.getrealh(img)-1

	while pixel <= max do
		local x, y = math.floor(pixel/image.getrealh(img)), pixel%image.getrealh(img)
		if typ == __FXNOALPHA then chr = color.new(color.r(image.pixel(img, x, y)), 0, 0)
		elseif typ == __FXALPHA then chr = color.new(color.r(image.pixel(img, x, y)), 0, 0, math.floor(color.r(image.pixel(img, x, y))*color.a(image.pixel(img, x, y))/255)) end
		image.pixel(imgchannel, x, y, chr)		
		pixel = pixel+1
	end

	return imgchannel
end

-- image, image.chg(image, type): Gets the green channel. Types (0: without transparency, 1: with transparency)
function image.chg(img, typ)
	if not typ or typ<0 or typ>1 then typ = 0 end
	local pixel = 0
	local imgchannel = image.new(image.getrealw(img), image.getrealh(img), color.new(0, 0, 0, 0))
	local max = image.getrealw(img)*image.getrealh(img)-1

	while pixel <= max do
		local x, y = math.floor(pixel/image.getrealh(img)), pixel%image.getrealh(img)
		if typ == __FXNOALPHA then chg = color.new(0, color.g(image.pixel(img, x, y)), 0)
		elseif typ == __FXALPHA then chg = color.new(0, color.g(image.pixel(img, x, y)), 0, math.floor(color.g(image.pixel(img, x, y))*color.a(image.pixel(img, x, y))/255)) end
		image.pixel(imgchannel, x, y, chg)		
		pixel = pixel+1
	end

	return imgchannel
end

-- image, image.chb(image, type): Gets the blue channel. Types (0: without transparency, 1: with transparency)
function image.chb(img, typ)
	if not typ or typ<0 or typ>1 then typ = 0 end
	local pixel = 0
	local imgchannel = image.new(image.getrealw(img), image.getrealh(img), color.new(0, 0, 0, 0))
	local max = image.getrealw(img)*image.getrealh(img)-1

	while pixel <= max do
		local x, y = math.floor(pixel/image.getrealh(img)), pixel%image.getrealh(img)
		if typ == __FXNOALPHA then chb = color.new(0, 0, color.b(image.pixel(img, x, y)))
		elseif typ == __FXALPHA then chb = color.new(0, 0, color.b(image.pixel(img, x, y)), math.floor(color.b(image.pixel(img, x, y))*color.a(image.pixel(img, x, y))/255)) end
		image.pixel(imgchannel, x, y, chb)		
		pixel = pixel+1
	end

	return imgchannel
end

-- image, image.cha(image, type): Gets the transparency channel. Types (0: without transparency, 1: with transparency)
function image.cha(img, typ)
	if not typ or typ<0 or typ>1 then typ = 0 end
	local pixel = 0
	local imgchannel = image.new(image.getrealw(img), image.getrealh(img), color.new(0, 0, 0, 0))
	local max = image.getrealw(img)*image.getrealh(img)-1

	while pixel <= max do
		local x, y = math.floor(pixel/image.getrealh(img)), pixel%image.getrealh(img)
		if typ == 0 then cha = color.new(255-color.a(image.pixel(img, x, y)), 255-color.a(image.pixel(img, x, y)), 255-color.a(image.pixel(img, x, y)))
		elseif typ == 1 then cha = color.new(0, 0, 0, color.a(image.pixel(img, x, y))) end
		image.pixel(imgchannel, x, y, cha)		
		pixel = pixel+1
	end

	return imgchannel
end
