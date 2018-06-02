kernel.enableScreen(false)
--local path_to_core = "system/core/"
kernel.include("cfg_manager.lua",cfg)

recovery = {} -- Modulo recovery
recovery.over = 1
recovery.menu_principal = {
	{name = "Enable USB",nametwo = "Disable USB",checking = usb.isactive,action = usb.mstick, state = true},
	{name = "Enable AutoBoot",nametwo = "Disable AutoBoot",action = nil, state = true},
	{name = "Config OneShell",nametwo = "Config OneShell",action = function () recovery.over = 1; recovery.options = recovery.menu_configs end , state = true},
	{name = "Update OneShell",nametwo = "Disable USB",action = nil, state = true},
	{name = "Patch OneShell",nametwo = "Disable USB",action = nil, state = true},
	{name = "Restore OneShell",nametwo = "Disable USB",action = nil, state = true},
	{name = "Uninstall OneShell",nametwo = "Disable USB",action = nil, state = true},
	{name = "Restart Console",nametwo = "Disable USB",action = kernel.restart, state = true},
	{name = "Suspend Console",nametwo = "Suspend Console",action = kernel.suspend, state = true},
	{name = "Shutdown Console",nametwo = "Disable USB",action = kernel.off, state = true},
	{name = "Exit to OneShell",nametwo = "Disable USB",action = function () recovery.isrun = false end, state = true},
	{name = "Exit to XMB",nametwo = "Disable USB",action = kernel.exit, state = true},
}
recovery.menu_configs = {
	{name = "Enable Analog",nametwo = "Disable Analog",checking = function () return cfg.get("cursor","analog") end,action = function () cfg.set("cursor","analog",not cfg.get("cursor","analog")) end, state = true},
	{name = "Change Theme",action = nil, state = true},
}
recovery.options = recovery.menu_principal
recovery.last_options = recovery.menu_principal
recovery.label = string.rep(" ",20).."OneShell - Multitasking Graphical Environment"..string.rep(" ",20)
recovery.x = 20
recovery.back = image.load("system/theme/recovery.png")
recovery.isrun = true
while recovery.isrun do
	buttons.read()
	if buttons.up then 
		recovery.over -= 1
	elseif buttons.down then
		recovery.over += 1
	end
	if recovery.over > #recovery.options then
		recovery.over = 1
	end
	if recovery.over < 1 then 
		recovery.over = #recovery.options
	end
	recovery.back:blit(0,0)
	--recovery.back:blit(40,40)
	--recovery.back:blitadd(40,40,60)
	screen.print(240,5,"== Recovery Menu ==",0.7,color.white,0x0,__ACENTER)
	for i = 1,#recovery.options do
		if recovery.over == i then
			screen.print(5,20 + ((i - 1) * 13),"->",0.6,color.white,0x0)
			if recovery.options[i].checking and recovery.options[i].checking() then
				screen.print(20,20 + ((i - 1) * 13),recovery.options[i].nametwo,0.6,color.new(255,0,0),0x0)
			else
				screen.print(20,20 + ((i - 1) * 13),recovery.options[i].name,0.6,color.new(255,0,0),0x0)
			end
		else
			if recovery.options[i].checking and recovery.options[i].checking() then
				screen.print(20,20 + ((i - 1) * 13),recovery.options[i].nametwo,0.6,color.white,0x0)
			else
				screen.print(20,20 + ((i - 1) * 13),recovery.options[i].name,0.6,color.white,0x0)
			end
		end
	end
	if buttons.cross then 
		if recovery.options[recovery.over].action then
			recovery.options[recovery.over].action()
		end
	end
	recovery.x = screen.print(recovery.x,255,recovery.label,0.6,color.white,0x0,__STHROUGH,440)
	screen.flip()
	if buttons.circle then
		recovery.options = recovery.last_options
		--break 
	end
end
buttons.read()
kernel.enableScreen(true)