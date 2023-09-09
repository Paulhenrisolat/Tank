-- Débogueur Visual Studio Code tomblind.local-lua-debugger-vscode
if pcall(require, "lldebugger") then
  require("lldebugger").start()
end

io.stdout:setvbuf('no') --Debug
love.graphics.setDefaultFilter("nearest") --No blurry pixel

local Tank = {
  x = 0,
  y = 0,
  rotation = math.rad(-90),
  speed = 50,
  img = love.graphics.newImage("images/tank.png")
}

local Mouse = {
  x = 0,
  y = 0,
  img = love.graphics.newImage("images/pointer.png")
}

local Cannon = {
  x = 0,
  y = 0,
  img = love.graphics.newImage("images/cannon.png")
}

local projectiles = {}
  projectiles.img = love.graphics.newImage("images/projectile.png")
  projectiles.speed = 250

function Input(dt)
  if love.keyboard.isDown("up") or love.keyboard.isDown("z") then    
    local vx = Tank.speed * math.cos(Tank.rotation) * dt
    local vy = Tank.speed * math.sin(Tank.rotation) * dt
    Tank.x = Tank.x  + vx
    Tank.y = Tank.y  + vy
  end
  if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
    Tank.rotation = Tank.rotation + 1 * dt
  end
  if love.keyboard.isDown("left") or love.keyboard.isDown("q") then
    Tank.rotation = Tank.rotation - 1 * dt
  end
end

function Shoot(px, py, prot)
  local projectile = {}
  projectile.x = px
  projectile.y = py
  projectile.rotation = prot
  table.insert(projectiles, projectile)
end

function love.keypressed(key)
  if key == "space" then
    Shoot(Tank.x, Tank.y, Tank.rotation)
  end
end

function love.load()
  Tank.x = love.graphics.getWidth()/2
  Tank.y = love.graphics.getHeight()/2
end

function love.update(dt)
  Input(dt)

  for n=#projectiles,1,-1 do 
    local b = projectiles[n]
    b.x = b.x + dt * projectiles.speed * math.cos(b.rotation)
    b.y = b.y + dt * projectiles.speed * math.sin(b.rotation)
  end

  Mouse.x = love.mouse.getX()
  Mouse.y = love.mouse.getY()
  
  pointRadians = math.atan2(Cannon.y - Mouse.y, Cannon.x - Mouse.x)
end

function love.draw()
  love.graphics.draw(Tank.img, Tank.x, Tank.y, Tank.rotation, 1, 1,Tank.img:getWidth()/2, Tank.img:getHeight()/2)
  love.graphics.draw(Mouse.img, Mouse.x, Mouse.y, 0, 1, 1, Mouse.img:getWidth()/2, Mouse.img:getHeight()/2)
  love.graphics.draw(Cannon.img, Tank.x, Tank.y, pointRadians, 1, 1,Cannon.img:getWidth()/2, Cannon.img:getHeight())
  for bullet=#projectiles,1,-1 do
    local bullet = projectiles[bullet]
    love.graphics.draw(projectiles.img, bullet.x, bullet.y, bullet.rotation)
  end
  --Debug
  love.graphics.line(Tank.x, Tank.y, Mouse.x, Mouse.y)
  love.graphics.print("Tank Angle: "..Tank.rotation.." Tank speed: "..Tank.speed)
end