# kirshlib

## loadstring

```lua
local kirshlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/KirshWasHere/roblox-ui-lib/refs/heads/main/kirshlib.lua"))()
```

## usage

```lua
local kirshlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/KirshWasHere/roblox-ui-lib/refs/heads/main/kirshlib.lua"))()

local window = kirshlib:window({
    Title = "Custom Hub",
    Size = UDim2.new(0, 400, 0, 260)
})

local tab = window:tab("Main")

tab:label("Welcome to Kirshlib")

tab:button("Click Me", function()
    print("Button pressed")
end)

tab:toggle("Test Toggle", false, function(state)
    print("Toggle", state)
end)

tab:slider("Test Slider", 0, 100, 50, function(value)
    print("Slider", value)
end)

tab:input("Test Input", "Enter text", function(text)
    print("Input", text)
end)

tab:bind("Test Keybind", Enum.KeyCode.E, function()
    print("Key pressed")
end)
```
