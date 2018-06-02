CONSOLE = {}	-- Tabla de consola

function CONSOLE.new()
	local obj = {
		txt_color = color.new(255,255,255),
		data = {},
		h = 0,
		y = 0,
	}
	
	function obj.print(text,draw,flip) 
		if text == nil then text = "" end
		table.insert(obj.data,text)
		obj.h = obj.h + 10
		if obj.h > 260 then
			obj.y = obj.y - 10
		end
		
		if draw == true then
			obj.draw(flip)
		end
	end
	
	function obj.draw(flip)
		if #obj.data == 0 then return end
		
		local y = obj.y
		
		for i = 1,#obj.data do
			local sy = y + ((i - 1) * 10),obj.data[i]
			if sy < -10 then return end
			
			screen.print(5,y + ((i - 1) * 10),obj.data[i],0.5,obj.txt_color,0x0)
		end
		
		if flip == true then
			screen.flip()
			for i = 1,80 do
				screen.waitvblankstart()
			end
		end
	end
	
	return obj
end