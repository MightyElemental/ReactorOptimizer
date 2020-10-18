# Reactor Optimization

A script designed to find the optimal reactor control rod position for best reactor efficiency. Once the optimal has been found, this script will attempt to manage the reactor to stay at the optimal. Will automatically extract the rods if energy demand is higher than current power generation, then will try to find an equilibrium. Once the power demand reduces, the script will return to optimal rod insertion.

Writtin in Lua and designed to be used with ComputerCraft and BigReactors/ExtremeReactors.
* * *
## Example

The following graph was generated from a [reactor of this design](https://br.sidoh.org/#reactor-design?length=3&width=3&height=3&activelyCooled=false&controlRodInsertion=0&layout=XCXCXCXCX):
[![https://imgur.com/KPch0ir.png](https://imgur.com/KPch0ir.png)](https://imgur.com/KPch0ir.png)

[![https://imgur.com/3AvGtSK](https://imgur.com/3AvGtSK)](https://imgur.com/3AvGtSK)

* * *

## How to use
1. [Build a reactor](https://ftbwiki.org/Big_Reactors) with a com port
2. [Craft a computer](https://www.computercraft.info/) (Regular or advanced)
3. Place the computer next to the com port on the reactor
4. Copy the script files into the computer
5. Restart the computer (Hold Ctrl+R)
6. Let computer run through the initilization