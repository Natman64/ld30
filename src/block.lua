local config = require "config"
local color = require "color"
local rectangle = require "rectangle"

local function block(spriteSheet, map, blockColor, x, y, speed)
    local instance = { }

    instance.spriteSheet = spriteSheet
    instance.map = map

    instance.color = blockColor
    instance.x = x
    instance.y = y
    instance.speed = speed

    instance.active = false

    instance.keys = { }

    -- on initialization, make sure the block has an index and assign it controls
    if instance.color == color.blue then
        instance.index = 0
        
        instance.keys.upKey = "w"
        instance.keys.leftKey = "a"
        instance.keys.downKey = "s"
        instance.keys.rightKey = "d"
    elseif instance.color == color.orange then
        instance.index = 1

        instance.keys.upKey = "up"
        instance.keys.leftKey = "left"
        instance.keys.downKey = "down"
        instance.keys.rightKey = "right"
    end

    function instance:update(dt, level)
        self.active = false

        for key, value in pairs(self.keys) do
            if (love.keyboard.isDown(value)) then
                self.active = true
            end
        end

        if self.otherBlock then
            if self.otherBlock.active then

                local dx = 0
                local dy = 0

                if love.keyboard.isDown(self.keys.leftKey) then
                    dx = -self.speed * dt
                elseif love.keyboard.isDown(self.keys.rightKey) then
                    dx = self.speed * dt
                elseif love.keyboard.isDown(self.keys.upKey) then
                    dy = -self.speed * dt
                elseif love.keyboard.isDown(self.keys.downKey) then
                    dy = self.speed * dt
                end

                self.x = self.x + dx 
                self.y = self.y + dy

                -- collide with walls
                bx, by, bw, bh = self:getPixelBounds()
                bright = bx + bw
                bbottom = by + bh

                for c = 0, level.wallCount - 1 do
                    local wx = level.walls[c].x
                    local wy = level.walls[c].y
                    local ww = level.walls[c].w
                    local wh = level.walls[c].h
                    
                    if rectangle.intersects(bx, by, bw, bh, wx, wy, ww, wh) then
                        wright = wx + ww
                        wbottom = wy + wh

                        if dx < 0 then
                            -- check to the left
                            if bx < wright then
                                self.x = wright
                                self.active = false

                            end
                        elseif dx > 0 then
                            -- check to the right
                            if bright > wx then
                                self.x = wx - ww
                                self.active = false
                            end
                        end

                        if dy < 0 then
                            -- check up
                            if by < wbottom then
                                self.y = wbottom
                                self.active = false
                            end
                        elseif dy > 0 then
                            -- check down
                            if bbottom > wy then
                                self.y = wy - wh
                                self.active = false
                            end
                        end
                    end
                end

            end
        end
    end

    function instance:draw(spriteBatch)
        spriteBatch:add(self.spriteSheet:getQuad(self.index), self.x, self.y)
    end

    function instance:getPixelBounds()
        local padX = config.blockPadding.x
        local padY = config.blockPadding.y

        return self.x - padX, self.y - padY, config.tileWidth - 2 * padX, config.tileHeight - 2 * padY
    end

    return instance
end

return block
