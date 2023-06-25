OUTPUT_FILE = "reactor_optimization.csv"
MAX_INSERTION = 80

-- Used to block script from progressing until the reactor is at a stable temperature
-- This is important because the temperature change is not instantaneous once the rod is changed
-- Fuel consumption and energy output are dependent on the temperature so this is important for accuracy
local function waitUntilTemperatureStable(reactor)
  lastFuel = reactor.fuelTemperature()
  lastCase = reactor.casingTemperature()
  sleep(1)
  while math.abs(lastFuel - reactor.fuelTemperature()) > 2 or math.abs(lastCase-reactor.casingTemperature()) > 2 do
    lastFuel = reactor.fuelTemperature()
    lastCase = reactor.casingTemperature()
    sleep(1)
  end
  sleep(1)
end

function runOptimization(reactor)
  local file = fs.open(OUTPUT_FILE, "w")
  file.writeLine("Rod Pos, Power, Fuel Used, Efficiency")
  reactor.setActive(true)
  term.clear()
  bestEff = 0
  bestEffRodLevel = 0
  found = false
  for i=0,99 do
    term.setCursorPos(1,1)
    reactor.setAllControlRodLevels(i)
    rodLevel = reactor.getControlRod(0).level()
    
    waitUntilTemperatureStable(reactor)
    
    eff = getEfficiency(reactor)
    -- Efficiency may be higher after 80% rod insertion, but there is usually no point running a reactor at such a low power level
    -- TODO: Create config for this (currently doesn't impact performance - it's just a visual thing)
    if(eff < bestEff and i > MAX_INSERTION) then
      found = true
    end
    if(eff > bestEff and not found) then
      bestEff = eff
      bestEffRodLevel = rodLevel
    end
    saveResult(reactor,i,file)
    print(string.format("Reactor Rod Position: %i  ", rodLevel))
    print(string.format("Efficiency: %i      ", eff))
    print(string.format("Best Efficiency: %i @ %i       ", bestEff, bestEffRodLevel))
  end
  reactor.setAllControlRodLevels(bestEffRodLevel)
  file.flush()
end

-- Write rod insertion value to file
function saveResult(reactor,rodInsertLvl,file)
  energy, fuel, efficiency = getReactorStats(reactor)
  file.writeLine(string.format("%i,%f,%f,%f", rodInsertLvl, energy, fuel, efficiency))
end

-- Returns the energy, fuel usage, and efficiency of the reactor at this moment
function getReactorStats(reactor)
  fuelTank = reactor.fuelTank()
  fuel = fuelTank.burnedLastTick()
  energy = reactor.battery().producedLastTick()
  -- You don't want 0 fuel usage or 0 energy output!
  -- This will lead to div/0 error or an outlier efficiency value of 0
  while (fuel <= 0 or energy <= 0) do
    fuel = fuelTank.burnedLastTick()
    energy = reactor.battery().producedLastTick()
    sleep(0.5)
  end
  efficiency = energy/fuel

  return energy, fuel, efficiency
end

-- Get efficiency ratio at current moment
function getEfficiency(reactor)
  _,_,efficiency = getReactorStats(reactor)
  return efficiency
end

-- Gets the best efficiency under the maximum insertion level
function getBestEfficiency(maxInsertion)
  if not fs.exists(OUTPUT_FILE) then
    return -1
  end
  file = fs.open(OUTPUT_FILE, "r")
  hasNext = true
  file.readLine()
  bestEff = -1
  bestEffRodLevel = -1
  while hasNext do
    line = file.readLine()
    if line == nil then
      hasNext = false
    else
      rodPos,_,_,eff = getValues(line)
      rodPos=tonumber(rodPos)

      if(tonumber(eff) > bestEff) then
        bestEff = tonumber(eff)
        bestEffRodLevel = rodPos
      end

      -- Stop reading config file after max insertion level
      if(rodPos >= maxInsertion) then
        break
      end
    end
  end
  return bestEffRodLevel, bestEff
end

-- Used to split csv line into array
-- rod insertion level, energy, fuel, efficiency
function getValues(line)
  return line:match("([^,]+),([^,]+),([^,]+),([^,]+)")
end