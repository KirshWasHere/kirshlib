local KIRSHLIB_URL = "https://raw.githubusercontent.com/KirshWasHere/kirshlib/refs/heads/main/kirshlib.lua"

local ok, Iris = pcall(function()
    return loadstring(game:HttpGet(KIRSHLIB_URL))()
end)
assert(ok and type(Iris) == "table", "[kirshlib example] failed to load kirshlib.lua: " .. tostring(Iris))

local UserInputService = game:GetService("UserInputService")

local logLines = {}
local function addLog(message)
    table.insert(logLines, 1, ("[%d] %s"):format(math.floor(os.clock() * 1000) % 10000, message))
    if #logLines > 24 then
        table.remove(logLines)
    end
    print("[kirshlib example] " .. message)
end

local resolvedImages = {}
local function resolveImageId(id)
    id = tostring(id)
    if not id:match("^%d+$") then
        return id
    end
    if resolvedImages[id] then
        return resolvedImages[id]
    end

    local resolved = "rbxassetid://" .. id
    local ok, objects
    if type(getobjects) == "function" then
        ok, objects = pcall(getobjects, "rbxassetid://" .. id)
    elseif type(game.GetObjects) == "function" then
        ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
    end
    if ok and type(objects) == "table" then
        for _, object in objects do
            if typeof(object) == "Instance" and object:IsA("Decal") then
                resolved = object.Texture
                break
            end
        end
    end

    resolvedImages[id] = resolved
    print(("[kirshlib example] asset %s -> %s"):format(id, resolved))
    return resolved
end

local example_IMAGE = resolveImageId(29347007)

local customFrame
local function buildCustomFrame()
    customFrame = Instance.new("Frame")
    customFrame.Size = UDim2.new(1, 0, 0, 44)
    customFrame.BackgroundColor3 = Color3.fromRGB(62, 122, 84)
    customFrame.BorderSizePixel = 0
    Instance.new("UICorner", customFrame).CornerRadius = UDim.new(0, 6)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "Plain Roblox Frame injected via Iris.Append()"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.Parent = customFrame
end
buildCustomFrame()

local exampleVariable = 10
local exampleTable = { volume = 50 }

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    if input.KeyCode == Enum.KeyCode.P then
        Iris.Disabled = not Iris.Disabled
        print("[kirshlib example] Iris.Disabled =", Iris.Disabled)
    end
end)

local plotBuffer = table.create(64, 0)
local shutdownRequested = false

Iris.Init()
print(("[kirshlib example] loaded kirshlib v%s (Iris 2.5.1 port)"):format(tostring(Iris.Internal._version)))

local lastTime = os.clock()
local smoothedFps = 60
local plotAccum = 0

Iris:Connect(function()
    local now = os.clock()
    local deltaTime = now - lastTime
    lastTime = now
    if deltaTime > 0 then
        smoothedFps = smoothedFps * 0.9 + (1 / deltaTime) * 0.1
    end

    local plotValues = Iris.State(plotBuffer)
    local progress = Iris.State(0)
    progress:set((progress:get() + deltaTime * 0.15) % 1)

    plotAccum += deltaTime
    if plotAccum >= 0.1 then
        plotAccum = 0
        table.remove(plotBuffer, 1)
        table.insert(plotBuffer, math.clamp(smoothedFps + math.random(-5, 5), 0, 240))
        plotValues:set(table.clone(plotBuffer))
    end

    local logWindow = Iris.Window({ "Event Log" }, {
        position = Iris.State(Vector2.new(716, 8)),
        size = Iris.State(Vector2.new(300, 540)),
    })
    if logWindow.opened() then
        addLog("Event Log window opened")
    end
    if logWindow.closed() then
        addLog("Event Log window closed")
    end
    if logWindow.state.isOpened.value then
        Iris.Text({ ("Window / state events print here (%d entries)."):format(#logLines) })
        if Iris.SmallButton({ "Clear log" }).clicked() then
            table.clear(logLines)
        end
        Iris.Separator({})
        if #logLines == 0 then
            Iris.Text({ "(no events yet - click things!)" })
        else
            for i = 1, #logLines do
                Iris.Text({ logLines[i] })
            end
        end
    end
    Iris.End()

    local mainWindow = Iris.Window({ "kirshlib example" }, {
        size = Iris.State(Vector2.new(700, 540)),
        position = Iris.State(Vector2.new(8, 8)),
    })
    if mainWindow.opened() then
        addLog("Main window opened")
    end
    if mainWindow.closed() then
        addLog("Main window closed")
    end
    if mainWindow.collapsed() then
        addLog("Main window collapsed")
    end
    if mainWindow.uncollapsed() then
        addLog("Main window uncollapsed")
    end

    Iris.Text({
        ("kirshlib v%s | FPS: %.0f | every widget here is re-evaluated every frame"):format(
            tostring(Iris.Internal._version),
            smoothedFps
        ),
    })
    Iris.Separator({})

    Iris.MenuBar()
        Iris.Menu({ "File" })
            if Iris.MenuItem({ "New", Enum.KeyCode.N, Enum.ModifierKey.Ctrl }).clicked() then
                addLog("File > New clicked")
            end
            if Iris.MenuItem({ "Open..." }).clicked() then
                addLog("File > Open clicked")
            end
            Iris.Separator({})
            Iris.Menu({ "Recent" })
                if Iris.MenuItem({ "project1.rbxl" }).clicked() then
                    addLog("opened project1.rbxl")
                end
                if Iris.MenuItem({ "project2.rbxl" }).clicked() then
                    addLog("opened project2.rbxl")
                end
            Iris.End()
            Iris.Separator({})
            if Iris.MenuItem({ "Quit" }).clicked() then
                addLog("File > Quit clicked (use the Danger tab to actually shutdown)")
            end
        Iris.End()
        Iris.Menu({ "Options" })
            Iris.MenuToggle({ "Autosave" }, { isChecked = Iris.State(true) })
            Iris.MenuToggle({ "Verbose logging" }, { isChecked = Iris.State(false) })
        Iris.End()
    Iris.End()

    Iris.TabBar({}, { index = Iris.State(1) })

        Iris.Tab({ "Basics" })
            Iris.SeparatorText({ "Text" })
            Iris.Text({ "Plain Text" })
            Iris.Text({
                "Rich text: <b>bold</b>, <i>italic</i>, <stroke>outlined</stroke>",
                [Iris.Args.Text.RichText] = true,
            })
            Iris.TextColored({ "TextColored (deprecated alias)", Color3.fromRGB(255, 170, 0) })
            Iris.TextWrapped({
                "TextWrapped (deprecated alias): long text wraps to the parent width instead of being cut off. "
                    .. "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.",
            })

            Iris.SeparatorText({ "Buttons & events" })
            Iris.SameLine({})
                local button = Iris.Button({ "Button" })
                if button.hovered() then
                    Iris.Tooltip({ "Button events: clicked / rightClicked / doubleClicked / ctrlClicked" })
                end
                Iris.SmallButton({ "SmallButton" })
                local imageButton = Iris.ImageButton({ example_IMAGE, UDim2.fromOffset(32, 32) })
                if imageButton.hovered() then
                    Iris.Tooltip({ "ImageButton, same events as Button" })
                end
            Iris.End()
            if button.clicked() then
                addLog("Button clicked")
            end
            if button.rightClicked() then
                addLog("Button right-clicked")
            end
            if button.doubleClicked() then
                addLog("Button double-clicked")
            end
            if button.ctrlClicked() then
                addLog("Button ctrl-clicked")
            end
            if imageButton.clicked() then
                addLog("ImageButton clicked")
            end

            Iris.SeparatorText({ "Checkbox, Radio, Selectable" })
            local checkbox = Iris.Checkbox({ "Checkbox with tooltip" })
            if checkbox.hovered() then
                Iris.Tooltip({ "Tooltips render on frames where the previous widget reports hovered()" })
            end
            if checkbox.checked() then
                addLog("Checkbox checked")
            end
            if checkbox.unchecked() then
                addLog("Checkbox unchecked")
            end

            local radioSelection = Iris.State("B")
            Iris.SameLine({})
                Iris.Text({ "RadioButton:" })
                Iris.RadioButton({ "A", "A" }, { index = radioSelection })
                Iris.RadioButton({ "B", "B" }, { index = radioSelection })
                Iris.RadioButton({ "C", "C" }, { index = radioSelection })
            Iris.End()
            Iris.Text({ ("selected: %s"):format(tostring(radioSelection:get())) })

            local selectableState = Iris.State(1)
            Iris.Selectable({ "Selectable (standalone, click me)", 1 }, { index = selectableState })

            Iris.SeparatorText({ "Trees & layout" })
            Iris.CollapsingHeader({ "CollapsingHeader" }, { isUncollapsed = Iris.State(true) })
                Iris.Text({ "header children" })
                Iris.Indent({})
                    Iris.Text({ "children inside Indent" })
                Iris.End()
                Iris.Group({})
                    Iris.Text({ "children inside a Group" })
                    Iris.Text({ "(groups keep their children together)" })
                Iris.End()
            Iris.End()

            Iris.Tree({
                "Tree (spans width, open by default)",
                [Iris.Args.Tree.SpanAvailWidth] = true,
                [Iris.Args.Tree.DefaultOpen] = true,
            })
                Iris.Text({ "tree children" })
            Iris.End()

            Iris.SeparatorText({ "Image (asset 29347007)" })
            Iris.Image({ example_IMAGE, UDim2.fromOffset(96, 96) })
        Iris.End()

        Iris.Tab({ "Inputs" })
            Iris.SeparatorText({ "InputText" })
            local textState = Iris.State("hello kirshlib")
            Iris.InputText({ "InputText" }, { text = textState })
            Iris.Text({ ("you typed: %s"):format(textState:get()) })
            if textState:changed() then
                addLog(("InputText changed -> %s"):format(textState:get()))
            end

            Iris.InputText({ "InputText with hint", "type here..." }, { text = Iris.State("") })
            Iris.InputText({
                "InputText multiline",
                [Iris.Args.InputText.MultiLine] = true,
            }, { text = Iris.State("line one\nline two") })

            Iris.SeparatorText({ "Typed number inputs" })
            Iris.InputNum({ "InputNum (clamped 0-120)", 1, 0, 120 }, { number = Iris.State(42) })
            Iris.InputVector2({ "InputVector2" }, { number = Iris.State(Vector2.new(1, 2)) })
            Iris.InputVector3({ "InputVector3" }, { number = Iris.State(Vector3.new(1, 2, 3)) })
            Iris.InputUDim({ "InputUDim" }, { number = Iris.State(UDim.new(0, 16)) })
            Iris.InputUDim2({ "InputUDim2" }, { number = Iris.State(UDim2.fromOffset(64, 64)) })
            Iris.InputRect({ "InputRect" }, { number = Iris.State(Rect.new(0, 0, 100, 100)) })

            Iris.SeparatorText({ "Color inputs" })
            Iris.InputColor3({ "InputColor3" }, { color = Iris.State(Color3.fromRGB(180, 80, 255)) })
            Iris.InputColor4({ "InputColor4" }, {
                color = Iris.State(Color3.fromRGB(80, 200, 120)),
                transparency = Iris.State(0.25),
            })
        Iris.End()

        Iris.Tab({ "Drag & Sliders" })
            Iris.SeparatorText({ "Drag widgets (ctrl + click to type)" })
            Iris.DragNum({ "DragNum (0-100)", 1, 0, 100 }, { number = Iris.State(50) })
            Iris.DragVector2({ "DragVector2" }, { number = Iris.State(Vector2.new(10, 20)) })
            Iris.DragVector3({ "DragVector3" }, { number = Iris.State(Vector3.new(1, 2, 3)) })
            Iris.DragUDim({ "DragUDim" }, { number = Iris.State(UDim.new(0, 8)) })
            Iris.DragUDim2({ "DragUDim2" }, { number = Iris.State(UDim2.fromScale(0.5, 0.5)) })
            Iris.DragRect({ "DragRect" }, { number = Iris.State(Rect.new(0, 0, 50, 50)) })

            Iris.SeparatorText({ "Slider widgets" })
            Iris.SliderNum({ "SliderNum (0-100)", 1, 0, 100 }, { number = Iris.State(25) })
            Iris.SliderVector2({ "SliderVector2" }, { number = Iris.State(Vector2.new(0.25, 0.75)) })
            Iris.SliderVector3({ "SliderVector3" }, { number = Iris.State(Vector3.new(0.1, 0.5, 0.9)) })
            Iris.SliderUDim({ "SliderUDim" }, { number = Iris.State(UDim.new(0.5, 0)) })
            Iris.SliderUDim2({ "SliderUDim2" }, { number = Iris.State(UDim2.fromScale(0.3, 0.6)) })
            Iris.SliderRect({ "SliderRect" }, { number = Iris.State(Rect.new(0, 0, 10, 10)) })
        Iris.End()

        Iris.Tab({ "Choices & Plots" })
            Iris.SeparatorText({ "Combos" })
            local manualSelection = Iris.State("Apple")
            Iris.Combo({ "Manual Combo (Selectable children)" }, { index = manualSelection })
                Iris.Selectable({ "Apple", "Apple" }, { index = manualSelection })
                Iris.Selectable({ "Banana", "Banana" }, { index = manualSelection })
                Iris.Selectable({ "Cherry", "Cherry" }, { index = manualSelection })
            Iris.End()

            Iris.ComboArray({ "ComboArray" }, { index = Iris.State("Two") }, { "One", "Two", "Three" })
            Iris.ComboEnum(
                { "ComboEnum / InputEnum (Enum.Material)" },
                { index = Iris.State(Enum.Material.Neon) },
                Enum.Material
            )

            Iris.SeparatorText({ "ProgressBar" })
            Iris.ProgressBar({ "Auto progress" }, { progress = progress })
            local manualProgress = Iris.State(0.42)
            Iris.ProgressBar({ "Manual progress" }, { progress = manualProgress })
            Iris.SliderNum({ "Drag to set progress", 0.01, 0, 1 }, { number = manualProgress })

            Iris.SeparatorText({ "Plots" })
            Iris.PlotLines({ "FPS (PlotLines)", 80, 0, 240, ("%.0f fps"):format(smoothedFps) }, { values = plotValues })
            Iris.PlotHistogram({ "FPS (PlotHistogram)", 80, 0, 240, "fps" }, { values = plotValues })
        Iris.End()

        Iris.Tab({ "Table" })
            Iris.Text({ "Table with header row, row background, inner borders. Drag column edges to resize." })
            Iris.Table({
                3,
                [Iris.Args.Table.Header] = true,
                [Iris.Args.Table.RowBackground] = true,
                [Iris.Args.Table.InnerBorders] = true,
                [Iris.Args.Table.Resizable] = true,
            })
            do
                Iris.SetHeaderColumnIndex(1)
                for row = 0, 4 do
                    for column = 1, 3 do
                        if row == 0 then
                            Iris.Text({ ("Column %d"):format(column) })
                        elseif column == 1 then
                            Iris.Text({ ("Row %d"):format(row) })
                        elseif column == 2 then
                            Iris.Checkbox({ ("Check %d"):format(row) })
                        else
                            if Iris.Button({ ("Btn %d"):format(row) }).clicked() then
                                addLog(("table button row %d clicked"):format(row))
                            end
                        end
                        Iris.NextColumn()
                    end
                end
            end
            Iris.End()
        Iris.End()

        Iris.Tab({ "State & API" })
            Iris.SeparatorText({ "State helpers" })
            local variableState = Iris.VariableState(exampleVariable, function(newValue)
                exampleVariable = newValue
            end)
            Iris.DragNum({ "VariableState <-> local variable (0-100)", 1, 0, 100 }, { number = variableState })
            Iris.Text({ ("exampleVariable = %s (widget edits it, external edits sync back)"):format(tostring(exampleVariable)) })
            if Iris.SmallButton({ "randomize exampleVariable externally" }).clicked() then
                exampleVariable = math.random(0, 100)
                addLog(("exampleVariable set externally to %d"):format(exampleVariable))
            end

            Iris.SliderNum(
                { 'TableState(exampleTable, "volume")', 1, 0, 100 },
                { number = Iris.TableState(exampleTable, "volume") }
            )
            Iris.Text({ ("exampleTable.volume = %s"):format(tostring(exampleTable.volume)) })

            local baseState = Iris.State(false)
            local computedState = Iris.ComputedState(baseState, function(value)
                return not value
            end)
            Iris.Checkbox({ "base state" }, { isChecked = baseState })
            Iris.Checkbox({ "ComputedState(NOT base)" }, { isChecked = computedState })

            local watched = Iris.State(0)
            Iris.InputNum({ "watched state (:changed logs to Event Log)", 1, 0, 1000 }, { number = watched })
            if watched:changed() then
                addLog(("watched state changed -> %s"):format(tostring(watched:get())))
            end

            Iris.Text({ "WeakState(25): value resets to 25 whenever its widget is discarded (try ForceRefresh below)" })
            Iris.SliderNum({ "WeakState number", 1, 0, 100 }, { number = Iris.WeakState(25) })

            Iris.SeparatorText({ "PushConfig / PopConfig" })
            Iris.PushConfig({ TextColor = Color3.fromRGB(255, 120, 120) })
                Iris.Text({ "text inside PushConfig (TextColor override)" })
                Iris.PushConfig({ ItemWidth = UDim.new(0, 160) })
                    Iris.SliderNum({ "narrow slider (ItemWidth 160)", 1, 0, 100 }, { number = Iris.State(75) })
                Iris.PopConfig()
            Iris.PopConfig()
            Iris.Text({ "normal text after PopConfig" })

            Iris.SeparatorText({ "IDs" })
            Iris.PushId("example_pushed_id")
                Iris.Text({ "widget inside PushId / PopId (shared id prefix)" })
            Iris.PopId()

            Iris.SeparatorText({ "SetNextWidgetID" })
            Iris.SetNextWidgetID("kirsh_example_shared_window")
            Iris.Window({ "Shared-ID Window" }, {
                size = Iris.State(Vector2.new(360, 180)),
                [Iris.Args.Window.NoCollapse] = true,
            })
                Iris.Text({ "This window is called TWICE per frame under the same id..." })
            Iris.End()
            Iris.SetNextWidgetID("kirsh_example_shared_window")
            Iris.Window()
                Iris.Text({ "...so this text lands in the SAME window (click X to close both)." })
            Iris.End()

            Iris.SeparatorText({ "Window / focus control" })
            if Iris.Button({ "SetFocusedWindow(Event Log)" }).clicked() then
                Iris.SetFocusedWindow(logWindow)
                addLog("focused the Event Log window")
            end
            if Iris.Button({ "Reset Event Log position" }).clicked() then
                logWindow.state.position:set(Vector2.new(716, 8))
                logWindow.state.size:set(Vector2.new(300, 540))
                addLog("reset Event Log position/size")
            end

            Iris.SeparatorText({ "Global style" })
            if Iris.Button({ "Dark theme" }).clicked() then
                Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorDark)
                addLog("UpdateGlobalConfig(colorDark)")
            end
            if Iris.Button({ "Light theme" }).clicked() then
                Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorLight)
                addLog("UpdateGlobalConfig(colorLight)")
            end
            if Iris.Button({ "Default size" }).clicked() then
                Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeDefault)
                addLog("UpdateGlobalConfig(sizeDefault)")
            end
            if Iris.Button({ "Clear size" }).clicked() then
                Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeClear)
                addLog("UpdateGlobalConfig(sizeClear)")
            end

            Iris.SeparatorText({ "Library control" })
            Iris.Checkbox({ "Iris.Disabled (UI freeze - press P to unfreeze)" }, {
                isChecked = Iris.TableState(Iris, "Disabled"),
            })
            local showBuiltinexample = Iris.State(false)
            Iris.Checkbox({ "Show built-in Iris.ShowexampleWindow()" }, { isChecked = showBuiltinexample })
            if showBuiltinexample.value then
                Iris.ShowexampleWindow()
            end
        Iris.End()

        Iris.Tab({ "Danger" })
            Iris.PushConfig({ TextColor = Color3.fromRGB(255, 120, 120) })
                Iris.Text({ "These actions affect the whole Iris session." })
            Iris.PopConfig()
            if Iris.Button({ "ForceRefresh() - destroy & rebuild every widget (may lag)" }).clicked() then
                addLog("ForceRefresh called")
                Iris.ForceRefresh()
            end
            if Iris.Button({ "Shutdown() - kill Iris (cannot restart)" }).clicked() then
                shutdownRequested = true
            end
        Iris.End()

    Iris.End()

    Iris.SeparatorText({ "Iris.Append" })
    if customFrame == nil or customFrame.Parent == nil then
        buildCustomFrame()
    end
    Iris.Append(customFrame)
    Iris.Text({ "(the frame above is a normal Instance parented in with Iris.Append)" })

    Iris.End()

    if shutdownRequested then
        print("[kirshlib example] Iris.Shutdown() called - bye!")
        addLog("Shutdown")
        Iris.Shutdown()
    end
end)
