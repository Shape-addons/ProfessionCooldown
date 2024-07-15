# Profession Cooldown v. 1.26
Profession Cooldown (PCD) tracks the cooldown of profession abilities across the characters on your account. It's fairly simple, and mostly consists of a simple overview.
The addon will track all cooldowns, that are chosen for the character (all by default - use /pcd filters to choose which ones).
It should support all wow client languages, but this is very new. If you are having issues, please let me know so I can fix them.
Currently it tracks:

- Leatherworking: Salt shaker.
- Alchemy: All transmutes, Northrend Research
- Jewelcrafting: Brilliant Glass, Icy Prism, Fire prism
- Tailoring: TBC cloths, WotLK cloths, Glacial Bag, Dreamcloth
- Enchanting: Void Sphere, Prismatic sphere
- Mining: Smelt Titansteel
- Inscription: Minor research, Northrend research, documents

## Commands:

- /pcd - toggles the visibility of the window.
- /pcd filters - opens the filtering menu.
- /pcd reset - resets the position of the window.
- /pcd resetalldata - resets all data for the addon.
- /pcd reset charactername - resets the data for the given charactername. Useful if changing professions or deleting a character.
- /pcd options - opens the options window.
- /pcd update - fetches cooldowns based on spell id. Still in development, and not considered stable.

## Feedback
Please leave any feedback you may have in the comments. You are also welcome to create issues on Github.
It also helps if you can DM me a link to pastebin, with the data from the addon. You can find this in:
WorldOfWarcraft\_classic_\WTF\Account\YourAccountName\SavedVariables\ProfessionCooldown.lua

## To do list: Currently no ETA.
- Alerts / notifications.
