# kirshlib
A restoration project for the [Iris](https://github.com/SirMallard/Iris) immediate-mode UI library, designed to run on executors.
Source recovered from [GhostDuckyy/UI-Libraries](https://github.com/GhostDuckyy/UI-Libraries/tree/main/ImGui/Iris)  
Upstream: [SirMallard/Iris](https://github.com/SirMallard/Iris) — all credit to the original authors

## Loadstring
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/KirshWasHere/roblox-ui-lib/refs/heads/main/kirshlib.lua"))()
```
## Example/demo Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/KirshWasHere/roblox-ui-lib/refs/heads/main/example.lua"))()
```
## preview
<img width="1025" height="545" alt="image" src="https://github.com/user-attachments/assets/afa29bc0-0b17-4195-a5f4-2a618c8f8c60" /> <img width="1024" height="546" alt="image" src="https://github.com/user-attachments/assets/142089b8-e750-4934-8479-920bc7197c10" />


### The render loop

Your connected function runs **every frame** (Heartbeat by default). You describe the UI imperatively each frame; Iris diffs against the previous frame and only creates/updates what changed. Widgets are identified by the **line of code** that created them — the same line across frames is the same widget.

### Arguments, states, events

Every widget call is `Iris.Widget({ arguments }, { states })`:

- `{ arguments }` — a **positional** array following the widget's argument order (see reference below). You may also pass named arguments with `Iris.Args`:

  ```lua
  Iris.Window({ "Settings", [Iris.Args.Window.NoResize] = true })
  Iris.Text({ "<b>rich</b>", [Iris.Args.Text.RichText] = true })
  ```

- `{ states }` — optional table of `Iris.State` objects to bind the widget's value to.
- The widget call **returns the widget object**. Events are methods that return a boolean for this frame (`widget.clicked()`, `widget.hovered()`), and widget state is reachable at `widget.state.<name>.value`:

  ```lua
  local window = Iris.Window({ "Many Widgets Window" })
  if window.state.isOpened.value and window.state.isUncollapsed.value then
      Iris.Text({ "only drawn while open" })
  end
  Iris.End() -- always call End(), even when the window is closed
  ```

### End() pairing

Widgets that can hold children — `Window`, `MenuBar`, `Menu`, `SameLine`, `Group`, `Indent`, `Tree`, `CollapsingHeader`, `TabBar`, `Tab`, `Combo`, `Table` — **must** be paired with `Iris.End()`, even if they have no children. Helpers like `ComboArray`/`ComboEnum` call `End()` for you.

---

## State

```lua
local n = Iris.State(0)          -- persistent value, keyed by source line
n:get()                          -- read (n.value also works)
n:set(n:get() + 1)               -- write (updates bound widgets)
n:onChange(function(v) end)      -- callback on change (call ONCE, not every frame)
n:changed()                      -- true if changed this frame
```

| Constructor | Purpose |
|---|---|
| `Iris.State(value)` | Standard persistent state. |
| `Iris.WeakState(value)` | Resets to `value` whenever no widget is bound to it (e.g. after `ForceRefresh`). |
| `Iris.VariableState(variable, callback)` | Two-way binding with a local variable. `callback(newValue)` writes back to your variable; external variable edits sync into the state. |
| `Iris.TableState(table, key, callback?)` | Two-way binding with `table[key]`. Optional `callback(newValue)` — return `false` to block the write. |
| `Iris.ComputedState(state, fn)` | Derived state; recomputed via `fn(stateValue)` whenever `state` changes. |

```lua
local config = { volume = 50 }
Iris.SliderNum({ "Volume", 1, 0, 100 }, { number = Iris.TableState(config, "volume") })

local enabled = Iris.State(false)
local disabled = Iris.ComputedState(enabled, function(v) return not v end)
```

---

## Widget reference

Arguments are listed in **positional order**. `?` = optional. Every widget also supports a `hovered()` event unless noted.

### Window

```lua
local win = Iris.Window({ Title, NoTitleBar?, NoBackground?, NoCollapse?, NoClose?, NoMove?, NoScrollbar?, NoResize?, NoNav?, NoMenu? })
```

- **States:** `size` (Vector2), `position` (Vector2), `isUncollapsed`, `isOpened`, `scrollDistance`
- **Events:** `opened`, `closed`, `collapsed`, `uncollapsed`, `hovered`
- Windows always render at screen level (never nested inside other widgets). Pass `position`/`size` states to place windows deterministically:

  ```lua
  Iris.Window({ "Panel" }, {
      position = Iris.State(Vector2.new(20, 20)),
      size = Iris.State(Vector2.new(400, 300)),
  })
  ```

`Iris.SetFocusedWindow(widget)` brings a window to the front programmatically.

### Format & layout

| Widget | Arguments | Notes |
|---|---|---|
| `Iris.Text` | `Text, Wrapped?, Color?, RichText?` | RichText enables `<b> <i> <stroke>` markup. |
| `Iris.TextWrapped` / `Iris.TextColored` | deprecated aliases for the above | |
| `Iris.SeparatorText` | `Text` | Line with a heading label. |
| `Iris.Separator` | *(none)* | Horizontal line. |
| `Iris.SameLine` | `Width?, VerticalAlignment?, HorizontalAlignment?` | Children laid out in a row. |
| `Iris.Group` | *(none)* | Groups children into one block. |
| `Iris.Indent` | `Width?` | Indents children. |
| `Iris.Tooltip` | `Text` | Renders next to the cursor **on frames where you call it**. Pair with the previous widget's `hovered()`: |

```lua
local btn = Iris.Button({ "Hover me" })
if btn.hovered() then
    Iris.Tooltip({ "Helpful text" })
end
```

### Basic

| Widget | Arguments | States | Events |
|---|---|---|---|
| `Iris.Button` | `Text, Size?` | — | `clicked`, `rightClicked`, `doubleClicked`, `ctrlClicked` |
| `Iris.SmallButton` | `Text, Size?` | — | same as Button |
| `Iris.ImageButton` | `Image, Size, Rect?, ScaleType?, ResampleMode?, TileSize?, SliceCenter?, SliceScale?` | — | same as Button |
| `Iris.Checkbox` | `Text` | `isChecked` | `checked`, `unchecked` |
| `Iris.RadioButton` | `Text, Index` | `index` (shared) | `selected`, `unselected`, `active` |
| `Iris.Selectable` | `Text, Index?, NoClick?` | `index` | `selected`, `unselected`, `active` |

```lua
local choice = Iris.State("B")
Iris.SameLine({})
    Iris.RadioButton({ "A", "A" }, { index = choice })
    Iris.RadioButton({ "B", "B" }, { index = choice })
Iris.End()
```

### Menus

```lua
Iris.MenuBar()
    Iris.Menu({ "File" })
        if Iris.MenuItem({ "New", Enum.KeyCode.N, Enum.ModifierKey.Ctrl }).clicked() then end
        Iris.MenuToggle({ "Autosave" }, { isChecked = Iris.State(true) })
        Iris.Menu({ "Recent" })          -- nested submenu
            Iris.MenuItem({ "project1.rbxl" })
        Iris.End()
    Iris.End()
Iris.End()
```

| Widget | Arguments | States | Events |
|---|---|---|---|
| `Iris.MenuBar` | *(none)* | — | — |
| `Iris.Menu` | `Text` | `isOpened` | `clicked`, `opened`, `closed` |
| `Iris.MenuItem` | `Text, KeyCode?, ModifierKey?` | — | `clicked` |
| `Iris.MenuToggle` | `Text, KeyCode?, ModifierKey?` | `isChecked` | `checked`, `unchecked` |

### Trees & tabs

| Widget | Arguments | States | Events |
|---|---|---|---|
| `Iris.Tree` | `Text, SpanAvailWidth?, NoIndent?, DefaultOpen?` | `isUncollapsed` | `collapsed`, `uncollapsed` |
| `Iris.CollapsingHeader` | `Text, DefaultOpen?` | `isUncollapsed` | `collapsed`, `uncollapsed` |
| `Iris.TabBar` | **(none — TabBar takes no arguments)** | `index` (active tab, 1-based) | — |
| `Iris.Tab` | `Text, Hideable?` | `isOpened` | `clicked`, `selected`, `unselected`, `active`, `opened`, `closed` |

```lua
Iris.TabBar({}, { index = Iris.State(1) })
    Iris.Tab({ "Page 1" })
        Iris.Text({ "first" })
    Iris.End()
    Iris.Tab({ "Page 2" })
        Iris.Text({ "second" })
    Iris.End()
Iris.End()
```

### Number & typed inputs

Shared by `Input*`, `Drag*` and `Slider*` families:

**Arguments:** `Text?, Increment?, Min?, Max?, Format?` (format is a `string.format` pattern; Iris auto-generates one if omitted)
**State:** `number` — regardless of data type
**Events:** `numberChanged`

| Family | Widgets |
|---|---|
| Input (type a value) | `InputNum` (extra arg `NoButtons?`), `InputVector2`, `InputVector3`, `InputUDim`, `InputUDim2`, `InputRect` |
| Drag (slide to change, ctrl+click to type) | `DragNum`, `DragVector2`, `DragVector3`, `DragUDim`, `DragUDim2`, `DragRect` |
| Slider | `SliderNum`, `SliderVector2`, `SliderVector3`, `SliderUDim`, `SliderUDim2`, `SliderRect` |

```lua
Iris.SliderNum({ "Speed", 0.1, 0, 10 }, { number = Iris.State(5) })
Iris.DragVector3({ "Velocity" }, { number = Iris.State(Vector3.zero) })
Iris.InputNum({ "HP", 1, 0, 100 }, { number = Iris.State(100) })
```

Increment/Min/Max/Format accept the widget's data type where applicable (e.g. `Vector2.new(1, 1)` for `InputVector2`).

### Text & color inputs

| Widget | Arguments | States | Events |
|---|---|---|---|
| `Iris.InputText` | `Text?, TextHint?, ReadOnly?, MultiLine?` | `text` | `textChanged` |
| `Iris.InputColor3` | `Text?, UseFloats?, UseHSV?, Format?` | `color` | `numberChanged` |
| `Iris.InputColor4` | `Text?, UseFloats?, UseHSV?, Format?` | `color`, `transparency` | `numberChanged` |

### Dropdowns

| Widget | Arguments | States | Events |
|---|---|---|---|
| `Iris.Combo` | `Text?, NoButton?, NoPreview?` | `index`, `isOpened` | `opened`, `closed`, `changed` |
| `Iris.ComboArray` | `(arguments, states, selectionArray)` | `index` | builds Selectable children + `End()` for you |
| `Iris.ComboEnum` | `(arguments, states, enum)` | `index` (EnumItem) | same as ComboArray |

```lua
local pick = Iris.ComboArray({ "Pick one" }, { index = Iris.State("Two") }, { "One", "Two", "Three" })
print(pick.state.index.value)

Iris.ComboEnum({ "Material" }, { index = Iris.State(Enum.Material.Neon) }, Enum.Material)

-- manual combo with custom children
local sel = Iris.State("Apple")
Iris.Combo({ "Fruit" }, { index = sel })
    Iris.Selectable({ "Apple", "Apple" }, { index = sel })
    Iris.Selectable({ "Banana", "Banana" }, { index = sel })
Iris.End()
```

### Images & plots

| Widget | Arguments | States | Events |
|---|---|---|---|
| `Iris.Image` | `Image, Size, Rect?, ScaleType?, ResampleMode?, TileSize?, SliceCenter?, SliceScale?` | — | `hovered` |
| `Iris.ProgressBar` | `Text?, Format?` | `progress` (0–1) | `changed` |
| `Iris.PlotLines` | `Text?, Height?, Min?, Max?, TextOverlay?` | `values` (`{number}`) | `hovered` |
| `Iris.PlotHistogram` | `Text?, Height?, Min?, Max?, TextOverlay?, BaseLine?` | `values` (`{number}`) | `hovered` |

```lua
local values = Iris.State({ 0.5, 0.8, 0.2, 0.9 })
Iris.PlotLines({ "FPS", 80, 0, 240, "fps" }, { values = values })
```

When updating a plot's `values`, `:set()` a **new table** (`values:set(table.clone(buffer))`) — `set()` ignores writes of the same table reference.

### Tables

```lua
Iris.Table({
    3,                                  -- NumColumns (cannot change after creation)
    [Iris.Args.Table.Header] = true,    -- header row
    [Iris.Args.Table.RowBackground] = true,
    [Iris.Args.Table.InnerBorders] = true,
    [Iris.Args.Table.Resizable] = true, -- drag column edges
})
do
    Iris.SetHeaderColumnIndex(1)
    for row = 0, 4 do
        for column = 1, 3 do
            Iris.Text({ ("R%d C%d"):format(row, column) })
            Iris.NextColumn()
        end
    end
Iris.End()
```

**Arguments:** `NumColumns, Header?, RowBackground?, OuterBorders?, InnerBorders?, Resizable?, FixedWidth?, ProportionalWidth?, LimitTableWidth?` — **State:** `widths` (`{number}`)

**Cell helpers:** `NextColumn()`, `NextRow()`, `SetColumnIndex(i)`, `SetRowIndex(i)`, `NextHeaderColumn()`, `SetHeaderColumnIndex(i)`, `SetColumnWidth(i, width)` — widths are 0–1 floats, or pixels when `FixedWidth` is set.

---

## Styling

```lua
Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorDark)   -- themes: colorDark, colorLight
Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeDefault) -- sizes: sizeDefault, sizeClear
```

`UpdateGlobalConfig` triggers a full UI rebuild — call it on user action, never every frame.

**Scoped styles** with `PushConfig` / `PopConfig` (each push needs one pop):

```lua
Iris.PushConfig({ TextColor = Color3.fromRGB(255, 120, 120) })
    Iris.Text({ "red text" })
    Iris.PushConfig({ ItemWidth = UDim.new(0, 160) })
        Iris.SliderNum({ "narrow", 1, 0, 100 }, { number = Iris.State(75) })
    Iris.PopConfig()
Iris.PopConfig()
```

Common keys: `TextColor`, `TextSize`, `TextFont` (`{ Family, Weight, Style }`), `ContentWidth`, `ContentHeight`, `ItemWidth`, `ItemSpacing`, `FramePadding`, `WindowTitleAlign`, plus every color as a `<Name>Color` / `<Name>Transparency` pair (`ButtonColor`, `FrameBgColor`, `WindowBgColor`, `HeaderColor`, `BorderColor`, `SliderGrabColor`, ...). The full set is in `Iris.TemplateConfig.colorDark`.

---

## Library API

| Function / property | Description |
|---|---|
| `Iris.Init(parent?, eventConnection?, allowMultipleInits?)` | Start Iris. Parents to `gethui()`/`CoreGui` by default. `eventConnection` defaults to `Heartbeat`; pass `false` to drive cycles yourself. |
| `Iris:Connect(callback)` | Register a render function. Returns a disconnect function. |
| `Iris.Shutdown()` | Stop Iris and destroy everything. Cannot restart. |
| `Iris.Disabled` | `true` freezes all rendering without destroying widgets. |
| `Iris.ForceRefresh()` | Destroy + rebuild every widget (propagates style/config changes). |
| `Iris.ShowDemoWindow()` | Built-in reference demo of every widget — `Iris:Connect(Iris.ShowDemoWindow)`. |
| `Iris.Append(instance)` | Parent a raw Roblox GuiObject into the current widget position. |
| `Iris.SetFocusedWindow(windowWidget)` | Focus a window programmatically. |
| `Iris.SetNextWidgetID(id)` | Force the next widget to use a specific ID — two calls under one ID continue the same widget (e.g. build one window from two code paths). |
| `Iris.PushId(id)` / `Iris.PopId()` | Namespace all subsequent widget IDs (must be balanced). |
| `Iris.State` / `WeakState` / `VariableState` / `TableState` / `ComputedState` | See [State](#state). |
| `Iris.TemplateConfig` | `colorDark`, `colorLight`, `sizeDefault`, `sizeClear`, `utilityDefault`. |
| `Iris.Args.<Widget>` | Argument-name → position map for named arguments. |

---

## Executor behaviour

- **Parenting:** with no parent passed, the root is parented to `gethui()` if available, else `CoreGui`, and wrapped in `syn.protect_gui`/`protect_gui` when the executor provides it. Falls back to `PlayerGui` last.
- Opt out (upstream behaviour) either way:

  ```lua
  Iris._config.ExecutorParenting = false   -- or...
  Iris.Init(game:GetService("CoreGui").SomeFolder)
  ```

- Other root options: `Iris._config.UseScreenGUIs`, `Iris._config.DisplayOrderOffset`, `Iris._config.IgnoreGuiInset`, `Iris._config.ScreenInsets`.

---

## Images: decal vs image ids

`Iris.Image` / `Iris.ImageButton` need an **image asset id**. A **decal** id (catalog "decal" items) renders blank — resolve it to the image id first. Executors can do this with `GetObjects`:

```lua
local function decalToImage(id)
    local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
    if ok and typeof(objects) == "table" then
        for _, object in objects do
            if object:IsA("Decal") then
                return object.Texture
            end
        end
    end
    return "rbxassetid://" .. id
end

Iris.Image({ decalToImage(29347007), UDim2.fromOffset(96, 96) })
```

