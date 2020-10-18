local function waitUntilTemperatureStable(reactor)
  lastFuel = reactor.getFuelTemperature()
  lastCase = reactor.getCasingTemperature()
  sleep(1)
  while math.abs(lastFuel - reactor.getFuelTemperature()) > 4 or math.abs(lastCase-reactor.getCasingTemperature()) > 4 do
    lastFuel = reactor.getFuelTemperature()
    lastCase = reactor.getCasingTemperature()
    sleep(1)
  end
  sleep(1)
end

function runOptimization(reactor)
  local file = fs.open("reactorOptimization", "w")
  file.writeLine("Rod Pos, Power, Fuel Used, Efficiency")
  reactor.setActive(true)
  term.clear()
  bestEff = 0
  bestEffRodLevel = 0
  found = false
  for i=0,99 do
    term.setCursorPos(1,1)
    reactor.setAllControlRodLevels(i)
    rodLevel = reactor.getControlRodLevel(1)
    
    waitUntilTemperatureStable(reactor)
    
    eff = getEfficiency(reactor)
    if(eff < bestEff and i > 80) then
      found = true
    end
    if(eff > bestEff and not found) then
      bestEff = eff
      bestEffRodLevel = i
    end
    saveResult(reactor,i,file)
    print("reactor rod position: "..tostring(rodLevel))
    print("efficiency : "..tostring(eff).."      ")
    print("best efficiency: "..tostring(bestEff).." @ "..tostring(bestEffRodLevel).."      ")
  end
  reactor.setAllControlRodLevels(bestEffRodLevel)
  file.flush()
end

function saveResult(reactor,i,file)
  ener = reactor.getEnergyProducedLastTick()
  fuel = reactor.getFuelConsumedLastTick()
  file.writeLine(tostring(i)..","..tostring(ener)..","..tostring(fuel)..","..tostring(getEfficiency(reactor)))
end

function getEfficiency(reactor)
  fuel = reactor.getFuelConsumedLastTick()
  energy = reactor.getEnergyProducedLastTick()
  return energy/fuel
end

function getBestEfficiencyFromFile()
  if not fs.exists("reactorOptimization") then
    return -1
  end
  file = fs.open("reactorOptimization", "r")
  hasNext = true
  file.readLine()
  bestEff = 0
  bestEffRodLevel = 0
  while hasNext do
    line = file.readLine()
    if line == nil then
      hasNext = false
    else
      rodPos,en,fu,eff = getValues(line)
      if(tonumber(eff) > bestEff) then
        bestEff = tonumber(eff)
        bestEffRodLevel = rodPos
      end
    end
  end
  return bestEffRodLevel,bestEff
end

function getValues(line)
  return line:match("([^,]+),([^,]+),([^,]+),([^,]+)")
end