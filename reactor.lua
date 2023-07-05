os.loadAPI("graph.lua")
os.loadAPI("optimize.lua")
local reactor = peripheral.find("BiggerReactors_Reactor")
local speaker = peripheral.find("speaker")
local dfpwm = require("cc.audio.dfpwm")

local powerUnit = {"RF", "KiRF", "MeRF", "GiRF"}

local mainRod = reactor.getControlRod(0)
local battery = reactor.battery()

if not fs.exists(optimize.OUTPUT_FILE) then
  optimize.runOptimization(reactor)
end

energyLastSec = 0

-- Get best efficiency under MAX_INSERTION% rod insertion
targetPos,minRodPos,_ = optimize.getBestEfficiency(optimize.MAX_INSERTION)

g = graph.newGraph(4, 0, battery.capacity())
graph.addLabel(g,"Energy")

-- TODO: Make graph adaptive
useGraph = graph.newGraph(3,0,10000)
graph.addLabel(useGraph,"Usage")
graph.changeType(useGraph,1)

term.clear()

function playSound(speaker, file)
  local decoder = dfpwm.make_decoder()
  for chunk in io.lines(file, 16 * 1024) do
      local buffer = decoder(chunk)

      while not speaker.playAudio(buffer) do
          os.pullEvent("speaker_audio_empty")
      end
  end
end

function pullRodOut()
  current = mainRod.level()
  if current > minRodPos then
    reactor.setAllControlRodLevels(current-1)
  end
end

function pushRodIn()
  current = mainRod.level()
  if current < targetPos then
    reactor.setAllControlRodLevels(current+1)
  end
end

function controlRods(usage, energy)
  if reactor.active() and (usage > 0 or energy == 0) then
    -- TODO: Lookup value from csv file to match demand
    pullRodOut()
  else
    pushRodIn()
  end
end

function warningSystem()
  if speaker ~= nil then
    tank = reactor.fuelTank()
    if tank.fuel() < tank.capacity()*0.5 then
      playSound(speaker, "alarm.dfpwm")
    end
  end
end

-- Format RF amounts as a human-readable string
function formatRF(value)
  index = 1
  while value >= 1000 do
    value = value/1000
    index = index + 1
  end
  return string.format("%.1f %s", value, powerUnit[index])
end

while true do
  local energy = battery.stored()
  local capacity = battery.capacity()
  if energy > capacity*0.8 then
    reactor.setActive(false)
  elseif energy < capacity*0.4 then
    reactor.setActive(true)
  end
  term.clear()
  term.setCursorPos(1,1)
  usage = (energyLastSec - energy)/20 - battery.producedLastTick()
  
  controlRods(usage, energy)

  warningSystem()
  
  rodPos = mainRod.level()
  chargePct = (energy/capacity)*100

  -- TODO: Verify values are accurate (sleep time may not be accurate)
  energyStr = string.format("Energy: %s (%.1f%%)", formatRF(energy), math.floor(chargePct*10)/10)
  print(energyStr)
  usageStr = string.format("Usage: %s/t", formatRF(usage))
  print(usageStr)
  if reactor.active() then
    print("> ACTIVE")
    effFuel = reactor.fuelTank().burnedLastTick()
    effEng = battery.producedLastTick()
    print(string.format("Efficiency: %s/mb", formatRF(effEng/effFuel)))
  else
    print("> OFF")
    print("Efficiency: N/A")
  end
  
  print("\n--- RODS ---")
  print(string.format("Max: %i | Min: %i", targetPos, minRodPos))
  print(string.format("Current Position: %i", rodPos))

  graph.addData(g,energy)
  graph.addLabel(g,"Energy: "..formatRF(energy))
  graph.renderGraph(g)
  
  graph.addData(useGraph, usage)
  graph.addLabel(useGraph, usageStr)
  graph.renderGraph(useGraph)
  
  sleep(1)
  energyLastSec = energy
end
