local draggable = require('draggable')
local dragging

function love.load()
	coolvetica = "fonts/coolvetica rg.ttf"
	icon = love.graphics.newImage("images/icon.png")
	icon:setFilter( "nearest", "nearest" )
	font = love.graphics.newFont( coolvetica, 40)
	titlefont = love.graphics.newFont( coolvetica, 15)
	max = false
	dragging = false
	resizing = false
	width, height = love.graphics.getDimensions()
	savedx, savedty = love.window.getPosition( )
	savedwidth = width
	savedheight = height
	barh = 20
	buttons = { 
		quit = {	x = width-barh, 
					y = 0, 
					sx = barh/100,
					sy = barh/100,
					normal = love.graphics.newImage("images/quit.png"),
					hovered = love.graphics.newImage("images/quit_hovered.png"),
					pressed = love.graphics.newImage("images/quit_pressed.png"),
					image = love.graphics.newImage("images/quit.png"),
					func = function()
						love.event.quit()
					end
				},
		max = {		x = width-barh*2, 
					y = 0, 
					sx = barh/100,
					sy = barh/100,
					normal = love.graphics.newImage("images/max.png"),
					hovered = love.graphics.newImage("images/max_hovered.png"),
					pressed = love.graphics.newImage("images/max_pressed.png"),
					image = love.graphics.newImage("images/max.png"),
					func = function()
						if max then
							max = false
							love.window.setMode(savedwidth, savedheight, {fullscreen=false,borderless=true,x=savedx,y=savedty})
							resize()
						else
							max = true
							local _, _, flags = love.window.getMode()
							savedx, savedty = love.window.getPosition( )
						    local newwidth, newheight = love.window.getDesktopDimensions(flags.display)
							local success = love.window.setMode(newwidth, newheight-40, {fullscreen=false,borderless=true})
							love.window.setPosition( 0, 0, flags.display )
							resize()
						end
					end
				},
		min = {		x = width-barh*3, 
					y = 0, 
					sx = barh/100,
					sy = barh/100,
					normal = love.graphics.newImage("images/min.png"),
					hovered = love.graphics.newImage("images/min_hovered.png"),
					pressed = love.graphics.newImage("images/min_pressed.png"),
					image = love.graphics.newImage("images/min.png"),
					func = function()
						if max then
							max = false
							local tx, ty = love.window.getPosition( )
							love.window.setMode(savedwidth, savedheight, {fullscreen=false,borderless=true,x=tx,y=ty})
							resize()
						end
						love.window.minimize()
					end
				},
		drag = {	x = width-barh*4, 
					y = 0, 
					sx = barh/100,
					sy = barh/100,
					normal = love.graphics.newImage("images/drag.png"),
					hovered = love.graphics.newImage("images/drag_hovered.png"),
					pressed = love.graphics.newImage("images/drag_pressed.png"),
					image = love.graphics.newImage("images/drag.png"),
					func = function()
						if not dragging then
							if max then
								max = false
								local tx, ty = love.window.getPosition( )
								local tempx = tx + width - savedwidth
								love.window.setMode(savedwidth, savedheight, {fullscreen=false,borderless=true,x=tempx,y=ty})
								resize()
							end
							dragging = true
							draggable.start()
						end
					end
				},
		resize = {	x = width-barh*5, 
					y = 0,
					sx = barh/100,
					sy = barh/100,
					normal = love.graphics.newImage("images/resize.png"),
					hovered = love.graphics.newImage("images/resize_hovered.png"),
					pressed = love.graphics.newImage("images/resize_pressed.png"),
					image = love.graphics.newImage("images/resize.png"),
					func = function()
						local tx, ty = love.window.getPosition( )
						if resizing then
							resizing = false
							love.window.setMode(width, height, {fullscreen=false,borderless=true,resizable=false,x=tx,y=ty})
							savedwidth = width
							savedheight = height
							buttons.resize.image = buttons.resize.normal
						else
							resizing = true
							love.window.setMode(savedwidth, savedheight, {fullscreen=false,borderless=true,resizable=true,minwidth=250,minheight=20,x=tx,y=ty})
							resize()
							buttons.resize.image = buttons.resize.pressed
						end
					end
				},
			}
end

function resize()
	width, height = love.graphics.getDimensions()
	barh = 20
	buttons.quit.x = width-barh
	buttons.max.x = width-barh*2
	buttons.min.x = width-barh*3
	buttons.drag.x = width-barh*4
	buttons.resize.x = width-barh*5
end

function love.draw()
	resize()
	love.graphics.setBackgroundColor(58, 58, 58)
	love.graphics.setColor(150,58,58)
	love.graphics.rectangle("fill", 0, 0, width, barh)

	love.graphics.setColor(200,200,200)
	love.graphics.setFont(titlefont)
	love.graphics.print(love.window.getTitle(),barh*1.1,0)
	love.graphics.setColor(255,255,255)
	love.graphics.draw(icon, 0, 0, 0, barh/icon:getWidth(), barh/icon:getHeight())
	--Création des boutons--
	for v,k in pairs(buttons) do
		love.graphics.draw(buttons[v].image, buttons[v].x, buttons[v].y, 0, buttons[v].sx, buttons[v].sy)
	end
	------------------------
end

function love.resize(w, h)
	resize()
end

function love.mousepressed(x, y, button)
	if button == 1 then
		for v,k in pairs(buttons) do
			if x >= buttons[v].x and x <= buttons[v].x+(buttons[v].image:getWidth()*buttons[v].sx) and y >= buttons[v].y and y <= buttons[v].y+(buttons[v].image:getHeight()*buttons[v].sy) then
				if buttons[v] == buttons.drag then
					buttons[v].func()
				end
				buttons[v].image = buttons[v].pressed
			end
		end
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
	if dragging then
		draggable.move(dx,dy)
		buttons.drag.image = buttons.drag.pressed
	elseif resizing then
		resize()
	else
		for v,k in pairs(buttons) do
			if x >= buttons[v].x and x <= buttons[v].x+(buttons[v].image:getWidth()*buttons[v].sx) and y >= buttons[v].y and y <= buttons[v].y+(buttons[v].image:getHeight()*buttons[v].sy) then
				buttons[v].image = buttons[v].hovered
			else
				buttons[v].image = buttons[v].normal
			end
		end
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then
		if dragging then
			dragging = false
			draggable.stop()
			buttons.drag.image = buttons.drag.normal
		end
		for v,k in pairs(buttons) do
			if buttons[v].image == buttons[v].pressed and x >= buttons[v].x and x <= buttons[v].x+(buttons[v].image:getWidth()*buttons[v].sx) and y >= buttons[v].y and y <= buttons[v].y+(buttons[v].image:getHeight()*buttons[v].sy) then
				if not (buttons[v] == buttons.drag) then
					buttons[v].image = buttons[v].normal
					buttons[v].func()
				end
			end
		end
	end
end
