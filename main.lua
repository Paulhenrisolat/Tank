io.stdout:setvbuf('no')

Tank = {}
Tank.x = 0
Tank.y = 0
Tank.speed = 70
Tank.rotation = math.rad(90)
Tank.img = love.graphics.newImage("images/tank.png")
Tank.imgW = Tank.img:getWidth()
Tank.imgH = Tank.img:getHeight()

Mouse = {}
Mouse.x = 0
Mouse.y = 0
Mouse.img = love.graphics.newImage("images/pointer.png")

function Input(dt)
  if love.keyboard.isDown("up") or love.keyboard.isDown("z") then
    Tank.y = Tank.y - Tank.speed * dt
  end
  if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
    Tank.y = Tank.y + Tank.speed * dt
  end
  if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
    Tank.x = Tank.x + Tank.speed * dt
  end
  if love.keyboard.isDown("left") or love.keyboard.isDown("q") then
    Tank.x = Tank.x - Tank.speed * dt
  end
  if love.keyboard.isDown("space") then
    print("Bang !")
  end
  if love.keyboard.isDown("kp+") then
    Tank.speed = Tank.speed + 10
  end
  if love.keyboard.isDown("kp-") and Tank.speed > 0 then
    Tank.speed = Tank.speed - 10
  end
end

function canonRotation()
  return math.atan2(Tank.x - Tank.y, love.mouse.getX() - love.mouse.getY())
end
function love.load()

end
function love.update(dt)
  Input(dt)
  --canonRotation()
  Mouse.x = love.mouse.getX()
  Mouse.y = love.mouse.getY()
end
function love.draw()
  love.graphics.draw(Tank.img, Tank.x, Tank.y, Tank.rotation, 1, 1, Tank.imgW/2, Tank.imgH/2)
  love.graphics.draw(Mouse.img, Mouse.x, Mouse.y, 0, 1, 1, Tank.imgW/2, Tank.imgH/2)
  --Debug
  love.graphics.line(Tank.x, Tank.y, Mouse.x, Mouse.y)
  love.graphics.print("Tank speed :"..Tank.speed.."(Increase/Decrease + -)")
end