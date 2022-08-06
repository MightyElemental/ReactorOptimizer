# Reactor Optimization

A script designed to find the optimal reactor control rod position for best reactor efficiency. Once the optimal level has been found, this script will attempt to manage the reactor to stay at the optimal level. It will automatically extract the rods if energy demand is higher than current power generation, then will try to find an equilibrium. Once the power demand reduces, the script will return to optimal rod insertion.

Writtin in Lua and designed to be used with ComputerCraft and BigReactors/ExtremeReactors.
* * *
The idea originated from the online BigReactor Simulator website found here: [https://br.sidoh.org/](https://br.sidoh.org/)
This site also has a built-in peak efficiency calculator, and can also calculate space efficiency. The main difference between this script and the online simulator is that it manages the reactor for you so you don't need to manually change the reactor settings. This script can be run on any reactor without needing to recreate it online.
* * *
## Example

The following data was generated from a [reactor of this design](https://br.sidoh.org/#reactor-design?length=3&width=3&height=3&activelyCooled=false&controlRodInsertion=0&layout=XCXCXCXCX):


[![https://imgur.com/KPch0ir.png](https://imgur.com/KPch0ir.png)](https://imgur.com/KPch0ir.png)

[![https://imgur.com/vN2NdRC.png](https://imgur.com/vN2NdRC.png)](https://imgur.com/vN2NdRC.png)

* * *

## How to use
1. [Build a reactor](https://ftbwiki.org/Big_Reactors) with a [com port](https://ftbwiki.org/Reactor_Computer_Port)
2. [Craft a computer](https://www.computercraft.info/) (Regular or advanced)
3. Place the computer next to the com port on the reactor
4. Copy the script files into the computer
5. Restart the computer (Hold Ctrl+R)
6. Let computer run through the initilization

* * *
## Good to know

- [The BigReactors mod](https://www.curseforge.com/minecraft/mc-mods/big-reactors) was discontinued after MC version 1.7.10 and was replaced with [the ExtremeReactors mod](https://www.curseforge.com/minecraft/mc-mods/extreme-reactors). 
Then again, who would want to play anything past that version? The MC dev team has added too much stuff. MC 1.7.10 is where it's at for modding.
- [The ComputerCraft mod](https://www.curseforge.com/minecraft/mc-mods/computercraft) was discontinued after MC version 1.8.9 but was thankfully [uploaded to GitHub](https://github.com/dan200/ComputerCraft) to allow anyone to continue the code. Computer Craft lives on after MC 1.8.9 in the form of [CC: Tweaked](https://www.curseforge.com/minecraft/mc-mods/cc-tweaked).
- You can actually [download github repos](http://www.computercraft.info/forums2/index.php?/topic/4072-github-repository-downloader/) in ComputerCraft
