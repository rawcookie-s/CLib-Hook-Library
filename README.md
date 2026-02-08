# CLib
## Info
This is an advanced hook wrapper library that allows for hooks to be seperate from the hook library. It has an alias system to tie cleaner names to engine hooks that will be wrapped.

Clean event & base system, you can write hooks with only a couple of arguments while being on its own base, for example,
```lua
CLib:Add("Gmod::CalcView", "Example", function(...) end)
```
Handles returning values which is helpful for modifying behavior.

Extensible, allows you to add new bases dynamically with an easy to follow set of rules.

## License
This project is licensed under the GNU General Public License v3.0
