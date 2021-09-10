function love.load()
   love.window.setMode(1000,768)

  anim8 = require('libraries/anim8/anim8')
  sti = require('libraries/Simple-Tiled-Implementation/sti')
  cameraFile = require('libraries/hump/camera')
  
   --creates a camera object
  cam = cameraFile()

   sprites = {}
   sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')

   local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

   animations = {}
   animations.idle = anim8.newAnimation(grid('1-15',1), 0.05)
   animations.jump = anim8.newAnimation(grid('1-7',2), 0.05)
   animations.run = anim8.newAnimation(grid('1-15',3), 0.05)

  wf = require 'libraries/windfield/windfield'  

  world = wf.newWorld(0,980, false)
  world:setQueryDebugDrawing(true)

  world:addCollisionClass('Platform')
  world:addCollisionClass('Player' --[[  the code in the brackets would ignore the platform,{ignores = {'Platform'}} ]] )
  world:addCollisionClass('Danger')

  require('player')

  dangerZone = world:newRectangleCollider(-500, love.graphics.getHeight() - 50, love.graphics.getWidth() *10, 50, {collision_class = 'Danger'}) 
  dangerZone:setType('static')

  platforms = {}

  loadMap()
end

function love.update(dt)
   world:update(dt) 
   gameMap:update(dt)
   playerUpdate(dt)

   -- camera setup, get player postion and makes camera look at that
   if player.dead == false then
      local px, py = player:getPosition()
      cam:lookAt(px, love.graphics.getHeight()/2)
   end
end


function love.draw()
  
   -- everything between these functions moves according to the camera, outside is fixed like a hud
   cam:attach()
      gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
      world:draw() 
      drawPlayer()
   cam:detach()
end

function love.keypressed(key)
    if key == 'space' then
        if player.grounded == true then
         player:applyLinearImpulse(0, -5000)
        end
    end
end

function love.mousepressed(x,y,button)
   if button == 1  then
      local colliders = world:queryCircleArea(x, y, 200, {'Platform', 'Danger'})
      for i, c in ipairs(colliders) do
         c:destroy()
      end
   end
end

function spawnPlatforms(x, y, width, height)
   if width > 0 and height > 0 then
      local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
      platform:setType('static')
      table.insert(platforms, platform)
  end
end

function loadMap()
   gameMap = sti("Maps/level1.lua")
   for i, obj in pairs(gameMap.layers["Platforms"].objects) do
     spawnPlatforms(obj.x, obj.y, obj.width, obj.height) 
   end
end