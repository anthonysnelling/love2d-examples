function love.load()
  anim8 = require('libraries/anim8/anim8')
  
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

  player = world:newRectangleCollider(360, 100, 40, 100, {collision_class = "Player"})
  player:setFixedRotation(true)
  player.speed = 240
  player.animation = animations.idle
  player.isMoving = false

  platform = world:newRectangleCollider(259,400, 300,100, {collision_class = "Platform"})
  platform:setType('static')

  dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = 'Danger'}) 
  dangerZone:setType('static')
end

function love.update(dt)
   world:update(dt) 

    if player.body  then
      player.isMoving = false
       local px, py = player:getPosition()

    if love.keyboard.isDown('d') or love.keyboard.isDown('right') then
       player:setX(px + (player.speed * dt)) 
       player.isMoving = true
    end
    if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
       player:setX(px - (player.speed * dt)) 
       player.isMoving = true
    end

    if player:enter('Danger') then
       player:destroy()
    end
   end

   if player.isMoving == true then
      player.animation = animations.run      
   elseif player.isMoving == false then 
      player.animation = animations.idle
   end 

   player.animation:update(dt)

end

function love.draw()
   world:draw() 

   local px,py = player:getPosition()
   player.animation:draw(sprites.playerSheet,px, py, nil, 0.25, nil, 130, 300)
end

function love.keypressed(key)
    if key == 'space' then
        local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 40, 2, {'Platform'})
        if #colliders > 0 then
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