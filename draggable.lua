local Draggable = {}

local previous_relative_mode

local dragging = false

function Draggable.move(dx, dy)
  if dragging then
    local start_x, start_y, display_index = love.window.getPosition()
    local display_w, display_h = love.window.getDesktopDimensions(display_index)
    local win_w, win_h = love.window.getMode()

    local minimum_x = -win_w + 80
    local maximum_x = display_w - win_w + 60

    local minimum_y = 0
    local maximum_y = display_h - 60

    local target_x = math.max(minimum_x, math.min(maximum_x, start_x + dx))
    local target_y = math.max(minimum_y, math.min(maximum_y, start_y + dy))

    love.window.setPosition(target_x, target_y, display_index)
  end
end

function Draggable.start()
  dragging = {x = love.mouse.getX(), y = love.mouse.getY()}
  
  previous_relative_mode = love.mouse.getRelativeMode()
  love.mouse.setRelativeMode(true)
end

function Draggable.stop()
  love.mouse.setRelativeMode(previous_relative_mode)

  if dragging then
    love.mouse.setPosition(dragging.x, dragging.y)
    dragging = false
  end
end

function Draggable.dragging()
  return dragging
end

return Draggable
