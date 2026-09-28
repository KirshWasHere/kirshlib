local kirshlib = {
    Theme = {
        Background = Color3.fromRGB(14, 14, 14), 
        BackgroundImage = "rbxassetid://116049729009634",
        BackgroundImageTransparency = 0.2, 
        TopBar = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(255, 45, 85), 
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(150, 150, 150),
        Border = Color3.fromRGB(35, 35, 35)
    },
    NotifyEnabled = true,
    Accents = {}
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "kirshlib"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

local NotifyContainer = Instance.new("Frame")
NotifyContainer.Name = "Notifications"
NotifyContainer.Size = UDim2.new(0, 260, 1, -20)
NotifyContainer.Position = UDim2.new(1, -270, 0, 10)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.Parent = ScreenGui

local NotifyLayout = Instance.new("UIListLayout")
NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifyLayout.Padding = UDim.new(0, 8)
NotifyLayout.Parent = NotifyContainer

function kirshlib:repaint(color)
    kirshlib.Theme.Accent = color
    for _, item in pairs(kirshlib.Accents) do
        if typeof(item) == "Instance" and item.Parent then
            if item:IsA("UIStroke") then
                item.Color = color
            else
                item.BackgroundColor3 = color
            end
        elseif type(item) == "table" and item.Object and item.Object.Parent then
            if item.Active and item.Active() then
                if item.Text then
                    item.Object.TextColor3 = color
                else
                    item.Object.BackgroundColor3 = color
                end
            else
                if item.Text then
                    item.Object.TextColor3 = kirshlib.Theme.TextDim
                else
                    item.Object.BackgroundColor3 = kirshlib.Theme.Background
                end
            end
        end
    end
end

local function drag(topbar, window)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function scale(grip, window)
    local scaling, scaleStart, startSize
    grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            scaling = true
            scaleStart = input.Position
            startSize = window.AbsoluteSize
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    scaling = false
                end
            end)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            scaling = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if scaling and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local deltaX = input.Position.X - scaleStart.X
            local deltaY = input.Position.Y - scaleStart.Y
            local newWidth = math.max(340, startSize.X + deltaX)
            local newHeight = math.max(180, startSize.Y + deltaY)
            window.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
end

function kirshlib:notify(title, desc, duration)
    if not kirshlib.NotifyEnabled then
        return
    end

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 52)
    card.BackgroundColor3 = kirshlib.Theme.TopBar
    card.BorderSizePixel = 0
    card.BackgroundTransparency = 1
    card.Parent = NotifyContainer

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 4)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = kirshlib.Theme.Border
    cardStroke.Transparency = 1
    cardStroke.Parent = card

    local cardAccent = Instance.new("Frame")
    cardAccent.Size = UDim2.new(0, 3, 1, 0)
    cardAccent.BackgroundColor3 = kirshlib.Theme.Accent
    cardAccent.BorderSizePixel = 0
    cardAccent.BackgroundTransparency = 1
    cardAccent.Parent = card
    table.insert(kirshlib.Accents, cardAccent)

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent = cardAccent

    local head = Instance.new("TextLabel")
    head.Size = UDim2.new(1, -16, 0, 20)
    head.Position = UDim2.new(0, 12, 0, 6)
    head.BackgroundTransparency = 1
    head.Text = title or "Notification"
    head.TextColor3 = kirshlib.Theme.Text
    head.Font = Enum.Font.GothamBold
    head.TextSize = 13
    head.TextXAlignment = Enum.TextXAlignment.Left
    head.TextTransparency = 1
    head.Parent = card

    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1, -16, 0, 18)
    body.Position = UDim2.new(0, 12, 0, 26)
    body.BackgroundTransparency = 1
    body.Text = desc or ""
    body.TextColor3 = kirshlib.Theme.TextDim
    body.Font = Enum.Font.Gotham
    body.TextSize = 12
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextTransparency = 1
    body.Parent = card

    TweenService:Create(card, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    TweenService:Create(cardStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
    TweenService:Create(cardAccent, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    TweenService:Create(head, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
    TweenService:Create(body, TweenInfo.new(0.2), {TextTransparency = 0}):Play()

    local function remove()
        if card and card.Parent then
            card:Destroy()
        end
    end

    local function dismiss()
        if card and card.Parent then
            local tween = TweenService:Create(card, TweenInfo.new(0.2), {BackgroundTransparency = 1})
            TweenService:Create(cardStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
            TweenService:Create(cardAccent, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(head, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            TweenService:Create(body, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            tween:Play()
            tween.Completed:Connect(remove)
        end
    end

    task.delay(duration or 3, dismiss)
end

function kirshlib:window(config)
    local title = config.Title or "Kirsh Inf Yield"
    local size = config.Size or UDim2.new(0, 400, 0, 260)
    local bgImage = kirshlib.Theme.BackgroundImage

    local Window = {
        Tabs = {},
        CurrentTab = nil
    }

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = size
    MainFrame.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    MainFrame.BackgroundColor3 = kirshlib.Theme.Background
    MainFrame.BackgroundTransparency = bgImage and 0.1 or 0
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    if bgImage then
        local BackgroundImage = Instance.new("ImageLabel")
        BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
        BackgroundImage.BackgroundTransparency = 1
        local bgId = tostring(string.match(tostring(bgImage), "%d+"))
        local finalImage = "rbxassetid://" .. bgId
        pcall(function()
            local objs = game:GetObjects(finalImage)
            if objs[1] and objs[1]:IsA("Decal") then
                finalImage = objs[1].Texture
            end
        end)
        BackgroundImage.Image = finalImage
        BackgroundImage.ScaleType = Enum.ScaleType.Crop
        BackgroundImage.ImageTransparency = kirshlib.Theme.BackgroundImageTransparency or 0.2
        BackgroundImage.ZIndex = 0
        BackgroundImage.Parent = MainFrame
        local BgCorner = Instance.new("UICorner")
        BgCorner.CornerRadius = UDim.new(0, 6)
        BgCorner.Parent = BackgroundImage
    end

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = kirshlib.Theme.Border
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    local MainGrip = Instance.new("Frame")
    MainGrip.Name = "Resize"
    MainGrip.Size = UDim2.new(0, 16, 0, 16)
    MainGrip.Position = UDim2.new(1, -16, 1, -16)
    MainGrip.BackgroundTransparency = 1
    MainGrip.ZIndex = 25
    MainGrip.Parent = MainFrame

    local MainGripBar1 = Instance.new("Frame")
    MainGripBar1.Size = UDim2.new(0, 9, 0, 1)
    MainGripBar1.Position = UDim2.new(1, -11, 1, -4)
    MainGripBar1.Rotation = -45
    MainGripBar1.BackgroundColor3 = kirshlib.Theme.Border
    MainGripBar1.BorderSizePixel = 0
    MainGripBar1.ZIndex = 26
    MainGripBar1.Parent = MainGrip

    local MainGripBar2 = Instance.new("Frame")
    MainGripBar2.Size = UDim2.new(0, 5, 0, 1)
    MainGripBar2.Position = UDim2.new(1, -7, 1, -3)
    MainGripBar2.Rotation = -45
    MainGripBar2.BackgroundColor3 = kirshlib.Theme.Border
    MainGripBar2.BorderSizePixel = 0
    MainGripBar2.ZIndex = 26
    MainGripBar2.Parent = MainGrip

    local MainGripBtn = Instance.new("TextButton")
    MainGripBtn.Size = UDim2.new(1, 0, 1, 0)
    MainGripBtn.BackgroundTransparency = 1
    MainGripBtn.Text = ""
    MainGripBtn.ZIndex = 27
    MainGripBtn.Parent = MainGrip

    scale(MainGripBtn, MainFrame)

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundColor3 = kirshlib.Theme.TopBar
    TopBar.BackgroundTransparency = bgImage and 0.1 or 0
    TopBar.BorderSizePixel = 0
    TopBar.ClipsDescendants = true
    TopBar.ZIndex = 10
    TopBar.Parent = MainFrame

    local TopBarAccent = Instance.new("Frame")
    TopBarAccent.Name = "TopBarAccent"
    TopBarAccent.Size = UDim2.new(1, 0, 0, 2)
    TopBarAccent.BackgroundColor3 = kirshlib.Theme.Accent
    TopBarAccent.BorderSizePixel = 0
    TopBarAccent.ZIndex = 15
    TopBarAccent.Parent = TopBar
    table.insert(kirshlib.Accents, TopBarAccent)

    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 6)
    TopBarCorner.Parent = TopBar

    local TopBarFix = Instance.new("Frame")
    TopBarFix.Size = UDim2.new(1, 0, 0, 6)
    TopBarFix.Position = UDim2.new(0, 0, 1, -6)
    TopBarFix.BackgroundColor3 = kirshlib.Theme.TopBar
    TopBarFix.BackgroundTransparency = bgImage and 0.1 or 0
    TopBarFix.BorderSizePixel = 0
    TopBarFix.ZIndex = 10
    TopBarFix.Parent = TopBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -290, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = kirshlib.Theme.Text
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 12
    TitleLabel.Parent = TopBar

    local SettingsButton = Instance.new("TextButton")
    SettingsButton.Name = "SettingsButton"
    SettingsButton.Size = UDim2.new(0, 60, 0, 22)
    SettingsButton.Position = UDim2.new(1, -210, 0, 6)
    SettingsButton.BackgroundColor3 = kirshlib.Theme.Background
    SettingsButton.Text = "Settings"
    SettingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SettingsButton.Font = Enum.Font.Gotham
    SettingsButton.TextSize = 12
    SettingsButton.ZIndex = 12
    SettingsButton.Parent = TopBar

    local SettingsBtnCorner = Instance.new("UICorner")
    SettingsBtnCorner.CornerRadius = UDim.new(0, 4)
    SettingsBtnCorner.Parent = SettingsButton

    local SettingsBtnStroke = Instance.new("UIStroke")
    SettingsBtnStroke.Color = kirshlib.Theme.Border
    SettingsBtnStroke.Parent = SettingsButton

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0, 136, 0, 22)
    SearchBox.Position = UDim2.new(1, -144, 0, 6)
    SearchBox.BackgroundColor3 = kirshlib.Theme.Background
    SearchBox.PlaceholderText = "Search"
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 12
    SearchBox.ZIndex = 12
    SearchBox.Parent = TopBar

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 4)
    SearchCorner.Parent = SearchBox

    local SearchStroke = Instance.new("UIStroke")
    SearchStroke.Color = kirshlib.Theme.Border
    SearchStroke.Parent = SearchBox

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local searchText = string.lower(SearchBox.Text)
        local firstMatchTab = nil
        for _, tab in pairs(Window.Tabs) do
            local hasMatch = false
            for _, item in pairs(tab.Content:GetChildren()) do
                if item:IsA("Frame") then
                    local itemText = item:GetAttribute("SearchText")
                    if itemText then
                        if searchText == "" or string.find(itemText, searchText) then
                            item.Visible = true
                            hasMatch = true
                        else
                            item.Visible = false
                        end
                    end
                end
            end
            if searchText ~= "" then
                if hasMatch then
                    tab.Button.TextColor3 = kirshlib.Theme.Accent
                    if not firstMatchTab then firstMatchTab = tab end
                else
                    tab.Button.TextColor3 = kirshlib.Theme.Border
                end
            else
                if Window.CurrentTab == tab then
                    tab.Button.TextColor3 = kirshlib.Theme.Text
                else
                    tab.Button.TextColor3 = kirshlib.Theme.TextDim
                end
            end
        end
        if searchText ~= "" and firstMatchTab and Window.CurrentTab ~= firstMatchTab then
            Window:choose(firstMatchTab)
        end
    end)

    drag(TopBar, MainFrame)

    local MidAccent = Instance.new("Frame")
    MidAccent.Name = "MidAccent"
    MidAccent.Size = UDim2.new(1, 0, 0, 1)
    MidAccent.Position = UDim2.new(0, 0, 0, 35)
    MidAccent.BackgroundColor3 = kirshlib.Theme.Accent
    MidAccent.BorderSizePixel = 0
    MidAccent.ZIndex = 15
    MidAccent.Parent = MainFrame
    table.insert(kirshlib.Accents, MidAccent)

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 120, 1, -36)
    TabContainer.Position = UDim2.new(0, 0, 0, 36)
    TabContainer.BackgroundColor3 = kirshlib.Theme.TopBar
    TabContainer.BackgroundTransparency = bgImage and 0.3 or 0.5
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    TabContainer.ClipsDescendants = true
    TabContainer.ZIndex = 1
    TabContainer.Parent = MainFrame

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 2)
    TabListLayout.Parent = TabContainer

    local function resize()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 16)
    end
    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)

    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 8)
    TabPadding.PaddingLeft = UDim.new(0, 8)
    TabPadding.PaddingRight = UDim.new(0, 8)
    TabPadding.Parent = TabContainer

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -120, 1, -36)
    ContentContainer.Position = UDim2.new(0, 120, 0, 36)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ClipsDescendants = true
    ContentContainer.ZIndex = 1
    ContentContainer.Parent = MainFrame

    local SettingsFrame = Instance.new("Frame")
    SettingsFrame.Name = "SettingsMenu"
    SettingsFrame.Size = size
    SettingsFrame.Position = MainFrame.Position
    SettingsFrame.BackgroundColor3 = kirshlib.Theme.Background
    SettingsFrame.BackgroundTransparency = bgImage and 0.1 or 0
    SettingsFrame.BorderSizePixel = 0
    SettingsFrame.ClipsDescendants = true
    SettingsFrame.Visible = false
    SettingsFrame.Parent = ScreenGui

    local SettingsCorner = Instance.new("UICorner")
    SettingsCorner.CornerRadius = UDim.new(0, 6)
    SettingsCorner.Parent = SettingsFrame

    local SettingsStroke = Instance.new("UIStroke")
    SettingsStroke.Color = kirshlib.Theme.Border
    SettingsStroke.Thickness = 1
    SettingsStroke.Parent = SettingsFrame

    local SettingsGrip = Instance.new("Frame")
    SettingsGrip.Name = "Resize"
    SettingsGrip.Size = UDim2.new(0, 16, 0, 16)
    SettingsGrip.Position = UDim2.new(1, -16, 1, -16)
    SettingsGrip.BackgroundTransparency = 1
    SettingsGrip.ZIndex = 25
    SettingsGrip.Parent = SettingsFrame

    local SettingsGripBar1 = Instance.new("Frame")
    SettingsGripBar1.Size = UDim2.new(0, 9, 0, 1)
    SettingsGripBar1.Position = UDim2.new(1, -11, 1, -4)
    SettingsGripBar1.Rotation = -45
    SettingsGripBar1.BackgroundColor3 = kirshlib.Theme.Border
    SettingsGripBar1.BorderSizePixel = 0
    SettingsGripBar1.ZIndex = 26
    SettingsGripBar1.Parent = SettingsGrip

    local SettingsGripBar2 = Instance.new("Frame")
    SettingsGripBar2.Size = UDim2.new(0, 5, 0, 1)
    SettingsGripBar2.Position = UDim2.new(1, -7, 1, -3)
    SettingsGripBar2.Rotation = -45
    SettingsGripBar2.BackgroundColor3 = kirshlib.Theme.Border
    SettingsGripBar2.BorderSizePixel = 0
    SettingsGripBar2.ZIndex = 26
    SettingsGripBar2.Parent = SettingsGrip

    local SettingsGripBtn = Instance.new("TextButton")
    SettingsGripBtn.Size = UDim2.new(1, 0, 1, 0)
    SettingsGripBtn.BackgroundTransparency = 1
    SettingsGripBtn.Text = ""
    SettingsGripBtn.ZIndex = 27
    SettingsGripBtn.Parent = SettingsGrip

    scale(SettingsGripBtn, SettingsFrame)

    local SettingsTopBar = Instance.new("Frame")
    SettingsTopBar.Name = "SettingsTopBar"
    SettingsTopBar.Size = UDim2.new(1, 0, 0, 35)
    SettingsTopBar.BackgroundColor3 = kirshlib.Theme.TopBar
    SettingsTopBar.BackgroundTransparency = bgImage and 0.1 or 0
    SettingsTopBar.BorderSizePixel = 0
    SettingsTopBar.ClipsDescendants = true
    SettingsTopBar.ZIndex = 10
    SettingsTopBar.Parent = SettingsFrame

    local SettingsTopBarAccent = Instance.new("Frame")
    SettingsTopBarAccent.Name = "SettingsTopBarAccent"
    SettingsTopBarAccent.Size = UDim2.new(1, 0, 0, 2)
    SettingsTopBarAccent.BackgroundColor3 = kirshlib.Theme.Accent
    SettingsTopBarAccent.BorderSizePixel = 0
    SettingsTopBarAccent.ZIndex = 15
    SettingsTopBarAccent.Parent = SettingsTopBar
    table.insert(kirshlib.Accents, SettingsTopBarAccent)

    local SettingsTopBarCorner = Instance.new("UICorner")
    SettingsTopBarCorner.CornerRadius = UDim.new(0, 6)
    SettingsTopBarCorner.Parent = SettingsTopBar

    local SettingsTopBarFix = Instance.new("Frame")
    SettingsTopBarFix.Size = UDim2.new(1, 0, 0, 6)
    SettingsTopBarFix.Position = UDim2.new(0, 0, 1, -6)
    SettingsTopBarFix.BackgroundColor3 = kirshlib.Theme.TopBar
    SettingsTopBarFix.BackgroundTransparency = bgImage and 0.1 or 0
    SettingsTopBarFix.BorderSizePixel = 0
    SettingsTopBarFix.ZIndex = 10
    SettingsTopBarFix.Parent = SettingsTopBar

    local SettingsTitle = Instance.new("TextLabel")
    SettingsTitle.Size = UDim2.new(1, -70, 1, 0)
    SettingsTitle.Position = UDim2.new(0, 15, 0, 0)
    SettingsTitle.BackgroundTransparency = 1
    SettingsTitle.Text = "Settings"
    SettingsTitle.TextColor3 = kirshlib.Theme.Text
    SettingsTitle.TextSize = 14
    SettingsTitle.Font = Enum.Font.GothamBold
    SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
    SettingsTitle.ZIndex = 12
    SettingsTitle.Parent = SettingsTopBar

    local BackButton = Instance.new("TextButton")
    BackButton.Name = "Back"
    BackButton.Size = UDim2.new(0, 50, 0, 22)
    BackButton.Position = UDim2.new(1, -60, 0, 6)
    BackButton.BackgroundColor3 = kirshlib.Theme.Background
    BackButton.Text = "Back"
    BackButton.TextColor3 = kirshlib.Theme.Text
    BackButton.Font = Enum.Font.Gotham
    BackButton.TextSize = 12
    BackButton.ZIndex = 12
    BackButton.Parent = SettingsTopBar

    local BackCorner = Instance.new("UICorner")
    BackCorner.CornerRadius = UDim.new(0, 4)
    BackCorner.Parent = BackButton

    local BackStroke = Instance.new("UIStroke")
    BackStroke.Color = kirshlib.Theme.Border
    BackStroke.Parent = BackButton

    local function reveal()
        SettingsFrame.Size = MainFrame.Size
        SettingsFrame.Position = MainFrame.Position
        MainFrame.Visible = false
        SettingsFrame.Visible = true
    end
    SettingsButton.MouseButton1Click:Connect(reveal)

    local function revert()
        MainFrame.Size = SettingsFrame.Size
        MainFrame.Position = SettingsFrame.Position
        SettingsFrame.Visible = false
        MainFrame.Visible = true
    end
    BackButton.MouseButton1Click:Connect(revert)

    drag(SettingsTopBar, SettingsFrame)

    local SettingsMidAccent = Instance.new("Frame")
    SettingsMidAccent.Name = "SettingsMidAccent"
    SettingsMidAccent.Size = UDim2.new(1, 0, 0, 1)
    SettingsMidAccent.Position = UDim2.new(0, 0, 0, 35)
    SettingsMidAccent.BackgroundColor3 = kirshlib.Theme.Accent
    SettingsMidAccent.BorderSizePixel = 0
    SettingsMidAccent.ZIndex = 15
    SettingsMidAccent.Parent = SettingsFrame
    table.insert(kirshlib.Accents, SettingsMidAccent)

    local SettingsContent = Instance.new("ScrollingFrame")
    SettingsContent.Name = "SettingsContent"
    SettingsContent.Size = UDim2.new(1, 0, 1, -36)
    SettingsContent.Position = UDim2.new(0, 0, 0, 36)
    SettingsContent.BackgroundTransparency = 1
    SettingsContent.BorderSizePixel = 0
    SettingsContent.ScrollBarThickness = 2
    SettingsContent.ClipsDescendants = true
    SettingsContent.ZIndex = 1
    SettingsContent.Parent = SettingsFrame

    local SettingsLayout = Instance.new("UIListLayout")
    SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SettingsLayout.Padding = UDim.new(0, 8)
    SettingsLayout.Parent = SettingsContent

    local SettingsPadding = Instance.new("UIPadding")
    SettingsPadding.PaddingTop = UDim.new(0, 10)
    SettingsPadding.PaddingLeft = UDim.new(0, 12)
    SettingsPadding.PaddingRight = UDim.new(0, 12)
    SettingsPadding.PaddingBottom = UDim.new(0, 10)
    SettingsPadding.Parent = SettingsContent

    local function expand()
        SettingsContent.CanvasSize = UDim2.new(0, 0, 0, SettingsLayout.AbsoluteContentSize.Y + 20)
    end
    SettingsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(expand)

    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Size = UDim2.new(1, 0, 0, 32)
    NotifyFrame.BackgroundColor3 = kirshlib.Theme.TopBar
    NotifyFrame.Parent = SettingsContent

    local NotifyCorner = Instance.new("UICorner")
    NotifyCorner.CornerRadius = UDim.new(0, 4)
    NotifyCorner.Parent = NotifyFrame

    local NotifyStroke = Instance.new("UIStroke")
    NotifyStroke.Color = kirshlib.Theme.Border
    NotifyStroke.Parent = NotifyFrame

    local NotifyLabel = Instance.new("TextLabel")
    NotifyLabel.Size = UDim2.new(1, -50, 1, 0)
    NotifyLabel.Position = UDim2.new(0, 10, 0, 0)
    NotifyLabel.BackgroundTransparency = 1
    NotifyLabel.Text = "Notifications"
    NotifyLabel.TextColor3 = kirshlib.Theme.Text
    NotifyLabel.Font = Enum.Font.GothamSemibold
    NotifyLabel.TextSize = 13
    NotifyLabel.TextXAlignment = Enum.TextXAlignment.Left
    NotifyLabel.Parent = NotifyFrame

    local NotifyCheck = Instance.new("Frame")
    NotifyCheck.Size = UDim2.new(0, 16, 0, 16)
    NotifyCheck.Position = UDim2.new(1, -26, 0.5, -8)
    NotifyCheck.BackgroundColor3 = kirshlib.Theme.Accent
    NotifyCheck.Parent = NotifyFrame
    table.insert(kirshlib.Accents, { Object = NotifyCheck, Active = function() return kirshlib.NotifyEnabled end })

    local NotifyCheckCorner = Instance.new("UICorner")
    NotifyCheckCorner.CornerRadius = UDim.new(0, 4)
    NotifyCheckCorner.Parent = NotifyCheck

    local NotifyBtn = Instance.new("TextButton")
    NotifyBtn.Size = UDim2.new(1, 0, 1, 0)
    NotifyBtn.BackgroundTransparency = 1
    NotifyBtn.Text = ""
    NotifyBtn.Parent = NotifyFrame

    local function silence()
        kirshlib.NotifyEnabled = not kirshlib.NotifyEnabled
        TweenService:Create(NotifyCheck, TweenInfo.new(0.2), {
            BackgroundColor3 = kirshlib.NotifyEnabled and kirshlib.Theme.Accent or kirshlib.Theme.Background
        }):Play()
    end
    NotifyBtn.MouseButton1Click:Connect(silence)

    local initialColor = kirshlib.Theme.Accent
    local hue, sat, val = Color3.toHSV(initialColor)

    local Picker = Instance.new("Frame")
    Picker.Size = UDim2.new(1, 0, 0, 110)
    Picker.BackgroundColor3 = kirshlib.Theme.TopBar
    Picker.Parent = SettingsContent

    local PickerCorner = Instance.new("UICorner")
    PickerCorner.CornerRadius = UDim.new(0, 6)
    PickerCorner.Parent = Picker

    local PickerStroke = Instance.new("UIStroke")
    PickerStroke.Color = kirshlib.Theme.Border
    PickerStroke.Parent = Picker

    local wheelAsset = "rbxassetid://1003599924"
    pcall(function()
        local objs = game:GetObjects(wheelAsset)
        if objs[1] and objs[1]:IsA("Decal") then
            wheelAsset = objs[1].Texture
        end
    end)

    local Wheel = Instance.new("ImageLabel")
    Wheel.Size = UDim2.new(0, 88, 0, 88)
    Wheel.Position = UDim2.new(0, 10, 0, 11)
    Wheel.BackgroundTransparency = 1
    Wheel.Image = wheelAsset
    Wheel.Parent = Picker

    local WheelCorner = Instance.new("UICorner")
    WheelCorner.CornerRadius = UDim.new(1, 0)
    WheelCorner.Parent = Wheel

    local Cursor = Instance.new("Frame")
    Cursor.Size = UDim2.new(0, 12, 0, 12)
    Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
    Cursor.BackgroundTransparency = 1
    Cursor.Parent = Wheel

    local CursorCorner = Instance.new("UICorner")
    CursorCorner.CornerRadius = UDim.new(1, 0)
    CursorCorner.Parent = Cursor

    local CursorStroke = Instance.new("UIStroke")
    CursorStroke.Color = Color3.new(0, 0, 0)
    CursorStroke.Thickness = 2
    CursorStroke.Parent = Cursor

    local InnerDot = Instance.new("Frame")
    InnerDot.Size = UDim2.new(0, 4, 0, 4)
    InnerDot.AnchorPoint = Vector2.new(0.5, 0.5)
    InnerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    InnerDot.BackgroundColor3 = Color3.new(1, 1, 1)
    InnerDot.BorderSizePixel = 0
    InnerDot.Parent = Cursor

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = InnerDot

    local WheelButton = Instance.new("TextButton")
    WheelButton.Size = UDim2.new(1, 0, 1, 0)
    WheelButton.BackgroundTransparency = 1
    WheelButton.Text = ""
    WheelButton.Parent = Wheel

    local Controls = Instance.new("Frame")
    Controls.Size = UDim2.new(1, -118, 0, 92)
    Controls.Position = UDim2.new(0, 108, 0, 9)
    Controls.BackgroundTransparency = 1
    Controls.Parent = Picker

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 18)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundTransparency = 1
    Header.Parent = Controls

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(1, -30, 1, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = "Accent Color"
    HeaderTitle.TextColor3 = kirshlib.Theme.Text
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextSize = 12
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header

    local Swatch = Instance.new("Frame")
    Swatch.Size = UDim2.new(0, 24, 0, 16)
    Swatch.Position = UDim2.new(1, -24, 0, 1)
    Swatch.BackgroundColor3 = initialColor
    Swatch.Parent = Header

    local SwatchCorner = Instance.new("UICorner")
    SwatchCorner.CornerRadius = UDim.new(0, 4)
    SwatchCorner.Parent = Swatch

    local SwatchStroke = Instance.new("UIStroke")
    SwatchStroke.Color = kirshlib.Theme.Border
    SwatchStroke.Parent = Swatch

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, 0, 0, 10)
    Track.Position = UDim2.new(0, 0, 0, 22)
    Track.BackgroundColor3 = Color3.new(1, 1, 1)
    Track.Parent = Controls

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 5)
    TrackCorner.Parent = Track

    local TrackStroke = Instance.new("UIStroke")
    TrackStroke.Color = kirshlib.Theme.Border
    TrackStroke.Parent = Track

    local TrackGrad = Instance.new("UIGradient")
    TrackGrad.Color = ColorSequence.new(Color3.fromHSV(hue, sat, 1), Color3.new(0, 0, 0))
    TrackGrad.Parent = Track

    local Thumb = Instance.new("Frame")
    Thumb.Size = UDim2.new(0, 14, 0, 14)
    Thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    Thumb.Position = UDim2.new(1 - val, 0, 0.5, 0)
    Thumb.BackgroundColor3 = Color3.new(1, 1, 1)
    Thumb.Parent = Track

    local ThumbCorner = Instance.new("UICorner")
    ThumbCorner.CornerRadius = UDim.new(0, 7)
    ThumbCorner.Parent = Thumb

    local ThumbStroke = Instance.new("UIStroke")
    ThumbStroke.Color = Color3.fromRGB(60, 60, 60)
    ThumbStroke.Thickness = 1.5
    ThumbStroke.Parent = Thumb

    local TrackButton = Instance.new("TextButton")
    TrackButton.Size = UDim2.new(1, 0, 1, 0)
    TrackButton.BackgroundTransparency = 1
    TrackButton.Text = ""
    TrackButton.Parent = Track

    local ValuesRow = Instance.new("Frame")
    ValuesRow.Size = UDim2.new(1, 0, 0, 18)
    ValuesRow.Position = UDim2.new(0, 0, 0, 38)
    ValuesRow.BackgroundTransparency = 1
    ValuesRow.Parent = Controls

    local HexBox = Instance.new("TextBox")
    HexBox.Size = UDim2.new(0.48, 0, 1, 0)
    HexBox.Position = UDim2.new(0, 0, 0, 0)
    HexBox.BackgroundColor3 = kirshlib.Theme.Background
    HexBox.Text = ""
    HexBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    HexBox.PlaceholderColor3 = kirshlib.Theme.TextDim
    HexBox.PlaceholderText = "Hex"
    HexBox.Font = Enum.Font.GothamSemibold
    HexBox.TextSize = 11
    HexBox.Parent = ValuesRow

    local HexCorner = Instance.new("UICorner")
    HexCorner.CornerRadius = UDim.new(0, 4)
    HexCorner.Parent = HexBox

    local HexStroke = Instance.new("UIStroke")
    HexStroke.Color = kirshlib.Theme.Border
    HexStroke.Parent = HexBox

    local RgbBox = Instance.new("TextBox")
    RgbBox.Size = UDim2.new(0.48, 0, 1, 0)
    RgbBox.Position = UDim2.new(0.52, 0, 0, 0)
    RgbBox.BackgroundColor3 = kirshlib.Theme.Background
    RgbBox.Text = ""
    RgbBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    RgbBox.PlaceholderColor3 = kirshlib.Theme.TextDim
    RgbBox.PlaceholderText = "RGB"
    RgbBox.Font = Enum.Font.Gotham
    RgbBox.TextSize = 11
    RgbBox.ClearTextOnFocus = false
    RgbBox.Parent = ValuesRow

    local RgbCorner = Instance.new("UICorner")
    RgbCorner.CornerRadius = UDim.new(0, 4)
    RgbCorner.Parent = RgbBox

    local RgbStroke = Instance.new("UIStroke")
    RgbStroke.Color = kirshlib.Theme.Border
    RgbStroke.Parent = RgbBox

    local PaletteRow = Instance.new("Frame")
    PaletteRow.Size = UDim2.new(1, 0, 0, 16)
    PaletteRow.Position = UDim2.new(0, 0, 0, 62)
    PaletteRow.BackgroundTransparency = 1
    PaletteRow.Parent = Controls

    local PaletteLayout = Instance.new("UIListLayout")
    PaletteLayout.FillDirection = Enum.FillDirection.Horizontal
    PaletteLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    PaletteLayout.Padding = UDim.new(0, 4)
    PaletteLayout.Parent = PaletteRow

    local function sync()
        local chosen = Color3.fromHSV(hue, sat, val)
        local radius = 44
        local cx, cy = 44, 44
        local theta = ((1 - hue) * 2 * math.pi) % (2 * math.pi)
        local posX = cx + sat * radius * math.cos(theta)
        local posY = cy + sat * radius * math.sin(theta)
        Cursor.Position = UDim2.new(0, posX, 0, posY)
        TrackGrad.Color = ColorSequence.new(Color3.fromHSV(hue, sat, 1), Color3.new(0, 0, 0))
        Thumb.Position = UDim2.new(math.clamp(1 - val, 0, 1), 0, 0.5, 0)
        local r = math.floor(chosen.R * 255)
        local g = math.floor(chosen.G * 255)
        local b = math.floor(chosen.B * 255)
        HexBox.Text = string.format("%02X%02X%02X", r, g, b)
        RgbBox.Text = string.format("%d %d %d", r, g, b)
        Swatch.BackgroundColor3 = chosen
        kirshlib:repaint(chosen)
    end

    local wheelActive = false
    local function wheel(inp)
        local relX = inp.Position.X - Wheel.AbsolutePosition.X
        local relY = inp.Position.Y - Wheel.AbsolutePosition.Y
        local dx = relX - 44
        local dy = relY - 44
        local dist = math.sqrt(dx * dx + dy * dy)
        sat = math.clamp(dist / 44, 0, 1)
        local theta = math.atan2(dy, dx)
        if theta < 0 then theta = theta + 2 * math.pi end
        hue = (1 - (theta / (2 * math.pi))) % 1
        sync()
    end

    WheelButton.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            wheelActive = true
            wheel(inp)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            wheelActive = false
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if wheelActive and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            wheel(inp)
        end
    end)

    local sliderActive = false
    local function slider(inp)
        local percent = math.clamp((inp.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        val = 1 - percent
        sync()
    end

    TrackButton.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            sliderActive = true
            slider(inp)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            sliderActive = false
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if sliderActive and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            slider(inp)
        end
    end)

    HexBox.FocusLost:Connect(function()
        local text = string.gsub(HexBox.Text, "[^0-9A-Fa-f]", "")
        if #text == 6 then
            local r = tonumber(string.sub(text, 1, 2), 16)
            local g = tonumber(string.sub(text, 3, 4), 16)
            local b = tonumber(string.sub(text, 5, 6), 16)
            if r and g and b then
                local h, s, v = Color3.toHSV(Color3.fromRGB(r, g, b))
                hue = h
                sat = s
                val = v
                sync()
            end
        else
            sync()
        end
    end)

    local function swatch(col)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 14, 0, 14)
        btn.BackgroundColor3 = col
        btn.Text = ""
        btn.Parent = PaletteRow
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 3)
        corner.Parent = btn
        local stroke = Instance.new("UIStroke")
        stroke.Color = kirshlib.Theme.Border
        stroke.Parent = btn
        local function apply()
            local h, s, v = Color3.toHSV(col)
            hue = h
            sat = s
            val = v
            sync()
        end
        btn.MouseButton1Click:Connect(apply)
    end

    swatch(Color3.fromRGB(255, 45, 85))
    swatch(Color3.fromRGB(255, 59, 48))
    swatch(Color3.fromRGB(255, 149, 0))
    swatch(Color3.fromRGB(255, 204, 0))
    swatch(Color3.fromRGB(52, 199, 89))
    swatch(Color3.fromRGB(0, 199, 190))
    swatch(Color3.fromRGB(0, 122, 255))
    swatch(Color3.fromRGB(88, 86, 214))
    swatch(Color3.fromRGB(175, 82, 222))
    swatch(Color3.fromRGB(240, 240, 240))

    sync()

    function Window:tab(tabName)
        local Tab = {}
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 28)
        TabButton.BackgroundColor3 = kirshlib.Theme.Accent
        TabButton.BackgroundTransparency = 1
        TabButton.Text = tabName
        TabButton.TextColor3 = kirshlib.Theme.TextDim
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.TextSize = 13
        TabButton.Parent = TabContainer
        table.insert(kirshlib.Accents, TabButton)

        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 4)
        TabButtonCorner.Parent = TabButton

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 2
        TabContent.ClipsDescendants = true
        TabContent.Visible = false
        TabContent.ZIndex = 1
        TabContent.Parent = ContentContainer

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 6)
        ContentLayout.Parent = TabContent

        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingTop = UDim.new(0, 10)
        ContentPadding.PaddingLeft = UDim.new(0, 10)
        ContentPadding.PaddingRight = UDim.new(0, 10)
        ContentPadding.PaddingBottom = UDim.new(0, 10)
        ContentPadding.Parent = TabContent

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
        end)

        TabButton.MouseButton1Click:Connect(function()
            Window:choose(Tab)
        end)

        function Tab:label(text, color)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Size = UDim2.new(1, 0, 0, 0)
            LabelFrame.AutomaticSize = Enum.AutomaticSize.Y
            LabelFrame.BackgroundTransparency = 1
            LabelFrame:SetAttribute("SearchText", string.lower(text))
            LabelFrame.Parent = TabContent

            local LabelPadding = Instance.new("UIPadding")
            LabelPadding.PaddingTop = UDim.new(0, 4)
            LabelPadding.PaddingBottom = UDim.new(0, 4)
            LabelPadding.PaddingLeft = UDim.new(0, 8)
            LabelPadding.PaddingRight = UDim.new(0, 8)
            LabelPadding.Parent = LabelFrame

            local LabelText = Instance.new("TextLabel")
            LabelText.Size = UDim2.new(1, 0, 0, 0)
            LabelText.AutomaticSize = Enum.AutomaticSize.Y
            LabelText.BackgroundTransparency = 1
            LabelText.Text = text
            LabelText.TextColor3 = color or kirshlib.Theme.Text
            LabelText.Font = Enum.Font.Gotham
            LabelText.TextSize = 13
            LabelText.TextWrapped = true
            LabelText.TextXAlignment = Enum.TextXAlignment.Left
            LabelText.Parent = LabelFrame

            local Item = {}
            function Item:set(newText)
                LabelText.Text = newText
                LabelFrame:SetAttribute("SearchText", string.lower(newText))
            end
            return Item
        end
        Tab.text = Tab.label

        function Tab:button(text, callback)
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Size = UDim2.new(1, 0, 0, 32)
            ButtonFrame.BackgroundColor3 = kirshlib.Theme.TopBar
            ButtonFrame:SetAttribute("SearchText", string.lower(text))
            ButtonFrame.Parent = TabContent

            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 4)
            ButtonCorner.Parent = ButtonFrame

            local ButtonStroke = Instance.new("UIStroke")
            ButtonStroke.Color = kirshlib.Theme.Border
            ButtonStroke.Parent = ButtonFrame

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.BackgroundTransparency = 1
            Button.Text = text
            Button.TextColor3 = kirshlib.Theme.Text
            Button.Font = Enum.Font.GothamSemibold
            Button.TextSize = 13
            Button.Parent = ButtonFrame

            local function restore()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = kirshlib.Theme.TopBar}):Play()
            end

            local function press()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = kirshlib.Theme.Accent}):Play()
                task.delay(0.1, restore)
                kirshlib:notify(text, "Button Pressed", 2)
                if callback then callback() end
            end
            Button.MouseButton1Click:Connect(press)
        end

        function Tab:toggle(text, default, callback)
            local state = default or false
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 32)
            ToggleFrame.BackgroundColor3 = kirshlib.Theme.TopBar
            ToggleFrame:SetAttribute("SearchText", string.lower(text))
            ToggleFrame.Parent = TabContent

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 4)
            ToggleCorner.Parent = ToggleFrame

            local ToggleStroke = Instance.new("UIStroke")
            ToggleStroke.Color = kirshlib.Theme.Border
            ToggleStroke.Parent = ToggleFrame

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Size = UDim2.new(1, -90, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = text
            ToggleLabel.TextColor3 = kirshlib.Theme.Text
            ToggleLabel.Font = Enum.Font.GothamSemibold
            ToggleLabel.TextSize = 13
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame

            local bindKey = nil
            local KeyButton = Instance.new("TextButton")
            KeyButton.Size = UDim2.new(0, 40, 0, 16)
            KeyButton.Position = UDim2.new(1, -74, 0.5, -8)
            KeyButton.BackgroundColor3 = kirshlib.Theme.Background
            KeyButton.Text = "Bind"
            KeyButton.TextColor3 = kirshlib.Theme.TextDim
            KeyButton.Font = Enum.Font.Gotham
            KeyButton.TextSize = 11
            KeyButton.ZIndex = 2
            KeyButton.Parent = ToggleFrame

            local KeyCorner = Instance.new("UICorner")
            KeyCorner.CornerRadius = UDim.new(0, 4)
            KeyCorner.Parent = KeyButton

            local KeyStroke = Instance.new("UIStroke")
            KeyStroke.Color = kirshlib.Theme.Border
            KeyStroke.Parent = KeyButton

            local ToggleCheck = Instance.new("Frame")
            ToggleCheck.Size = UDim2.new(0, 16, 0, 16)
            ToggleCheck.Position = UDim2.new(1, -26, 0.5, -8)
            ToggleCheck.BackgroundColor3 = state and kirshlib.Theme.Accent or kirshlib.Theme.Background
            ToggleCheck.Parent = ToggleFrame
            table.insert(kirshlib.Accents, { Object = ToggleCheck, Active = function() return state end })

            local CheckCorner = Instance.new("UICorner")
            CheckCorner.CornerRadius = UDim.new(0, 4)
            CheckCorner.Parent = ToggleCheck

            local CheckStroke = Instance.new("UIStroke")
            CheckStroke.Color = kirshlib.Theme.Border
            CheckStroke.Parent = ToggleCheck

            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(1, 0, 1, 0)
            ToggleButton.BackgroundTransparency = 1
            ToggleButton.Text = ""
            ToggleButton.ZIndex = 1
            ToggleButton.Parent = ToggleFrame

            local function trigger()
                state = not state
                TweenService:Create(ToggleCheck, TweenInfo.new(0.2), {
                    BackgroundColor3 = state and kirshlib.Theme.Accent or kirshlib.Theme.Background
                }):Play()
                local status = state and "Enabled" or "Disabled"
                kirshlib:notify(text, status, 2)
                if callback then callback(state) end
            end
            ToggleButton.MouseButton1Click:Connect(trigger)

            local listening = false
            KeyButton.MouseButton1Click:Connect(function()
                listening = true
                KeyButton.Text = "Press"
                KeyButton.TextColor3 = kirshlib.Theme.Accent
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Escape then
                        bindKey = nil
                        KeyButton.Text = "Bind"
                        KeyButton.TextColor3 = kirshlib.Theme.TextDim
                    else
                        bindKey = input.KeyCode
                        KeyButton.Text = bindKey.Name
                        KeyButton.TextColor3 = kirshlib.Theme.Text
                    end
                    listening = false
                elseif not gameProcessed and bindKey and input.KeyCode == bindKey and not listening then
                    trigger()
                end
            end)
            if callback then callback(state) end
        end

        function Tab:slider(text, min, max, default, callback)
            local value = default or min
            local start = value
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 48)
            SliderFrame.BackgroundColor3 = kirshlib.Theme.TopBar
            SliderFrame:SetAttribute("SearchText", string.lower(text))
            SliderFrame.Parent = TabContent

            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 4)
            SliderCorner.Parent = SliderFrame

            local SliderStroke = Instance.new("UIStroke")
            SliderStroke.Color = kirshlib.Theme.Border
            SliderStroke.Parent = SliderFrame

            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Size = UDim2.new(1, -20, 0, 20)
            SliderLabel.Position = UDim2.new(0, 10, 0, 5)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = text
            SliderLabel.TextColor3 = kirshlib.Theme.Text
            SliderLabel.Font = Enum.Font.GothamSemibold
            SliderLabel.TextSize = 13
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(1, -20, 0, 20)
            ValueLabel.Position = UDim2.new(0, 10, 0, 5)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(value)
            ValueLabel.TextColor3 = kirshlib.Theme.TextDim
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextSize = 13
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame

            local BarArea = Instance.new("Frame")
            BarArea.Size = UDim2.new(1, -20, 0, 10)
            BarArea.Position = UDim2.new(0, 10, 0, 30)
            BarArea.BackgroundColor3 = kirshlib.Theme.Background
            BarArea.Parent = SliderFrame

            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(0, 4)
            BarCorner.Parent = BarArea

            local BarStroke = Instance.new("UIStroke")
            BarStroke.Color = kirshlib.Theme.Border
            BarStroke.Parent = BarArea

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(math.clamp((value - min) / (max - min), 0, 1), 0, 1, 0)
            Fill.BackgroundColor3 = kirshlib.Theme.Accent
            Fill.Parent = BarArea
            table.insert(kirshlib.Accents, Fill)

            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(0, 4)
            FillCorner.Parent = Fill

            local DragButton = Instance.new("TextButton")
            DragButton.Size = UDim2.new(1, 0, 1, 0)
            DragButton.BackgroundTransparency = 1
            DragButton.Text = ""
            DragButton.Parent = BarArea

            local dragging = false
            local function adjust(input)
                local percent = math.clamp((input.Position.X - BarArea.AbsolutePosition.X) / BarArea.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * percent)
                TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
                ValueLabel.Text = tostring(value)
                if callback then callback(value) end
            end

            local function grab(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    start = value
                    adjust(input)
                end
            end
            DragButton.InputBegan:Connect(grab)

            local function release(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if dragging and value ~= start then
                        kirshlib:notify(text, "Changed from " .. tostring(start) .. " to " .. tostring(value), 2)
                        start = value
                    end
                    dragging = false
                end
            end
            UserInputService.InputEnded:Connect(release)

            local function slide(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    adjust(input)
                end
            end
            UserInputService.InputChanged:Connect(slide)
        end

        function Tab:input(text, placeholder, callback)
            local TextboxFrame = Instance.new("Frame")
            TextboxFrame.Size = UDim2.new(1, 0, 0, 32)
            TextboxFrame.BackgroundColor3 = kirshlib.Theme.TopBar
            TextboxFrame:SetAttribute("SearchText", string.lower(text))
            TextboxFrame.Parent = TabContent

            local TextboxCorner = Instance.new("UICorner")
            TextboxCorner.CornerRadius = UDim.new(0, 4)
            TextboxCorner.Parent = TextboxFrame

            local TextboxStroke = Instance.new("UIStroke")
            TextboxStroke.Color = kirshlib.Theme.Border
            TextboxStroke.Parent = TextboxFrame

            local TextboxLabel = Instance.new("TextLabel")
            TextboxLabel.Size = UDim2.new(0.5, -10, 1, 0)
            TextboxLabel.Position = UDim2.new(0, 10, 0, 0)
            TextboxLabel.BackgroundTransparency = 1
            TextboxLabel.Text = text
            TextboxLabel.TextColor3 = kirshlib.Theme.Text
            TextboxLabel.Font = Enum.Font.GothamSemibold
            TextboxLabel.TextSize = 13
            TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextboxLabel.Parent = TextboxFrame

            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(0.5, -10, 1, -12)
            TextBox.Position = UDim2.new(0.5, 0, 0, 6)
            TextBox.BackgroundColor3 = kirshlib.Theme.Background
            TextBox.PlaceholderText = placeholder or ""
            TextBox.Text = ""
            TextBox.TextColor3 = kirshlib.Theme.Text
            TextBox.PlaceholderColor3 = kirshlib.Theme.TextDim
            TextBox.Font = Enum.Font.Gotham
            TextBox.TextSize = 12
            TextBox.Parent = TextboxFrame

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 4)
            BoxCorner.Parent = TextBox

            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Color = kirshlib.Theme.Border
            BoxStroke.Parent = TextBox

            TextBox.FocusLost:Connect(function()
                if callback then callback(TextBox.Text) end
            end)
        end

        function Tab:bind(text, default, callback)
            local key = default
            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Size = UDim2.new(1, 0, 0, 32)
            KeybindFrame.BackgroundColor3 = kirshlib.Theme.TopBar
            KeybindFrame:SetAttribute("SearchText", string.lower(text))
            KeybindFrame.Parent = TabContent

            local KeybindCorner = Instance.new("UICorner")
            KeybindCorner.CornerRadius = UDim.new(0, 4)
            KeybindCorner.Parent = KeybindFrame

            local KeybindStroke = Instance.new("UIStroke")
            KeybindStroke.Color = kirshlib.Theme.Border
            KeybindStroke.Parent = KeybindFrame

            local KeybindLabel = Instance.new("TextLabel")
            KeybindLabel.Size = UDim2.new(0.5, -10, 1, 0)
            KeybindLabel.Position = UDim2.new(0, 10, 0, 0)
            KeybindLabel.BackgroundTransparency = 1
            KeybindLabel.Text = text
            KeybindLabel.TextColor3 = kirshlib.Theme.Text
            KeybindLabel.Font = Enum.Font.GothamSemibold
            KeybindLabel.TextSize = 13
            KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeybindLabel.Parent = KeybindFrame

            local KeyButton = Instance.new("TextButton")
            KeyButton.Size = UDim2.new(0.5, -10, 1, -12)
            KeyButton.Position = UDim2.new(0.5, 0, 0, 6)
            KeyButton.BackgroundColor3 = kirshlib.Theme.Background
            KeyButton.Text = key and key.Name or "None"
            KeyButton.TextColor3 = kirshlib.Theme.Text
            KeyButton.Font = Enum.Font.Gotham
            KeyButton.TextSize = 12
            KeyButton.Parent = KeybindFrame

            local KeyCorner = Instance.new("UICorner")
            KeyCorner.CornerRadius = UDim.new(0, 4)
            KeyCorner.Parent = KeyButton

            local KeyStroke = Instance.new("UIStroke")
            KeyStroke.Color = kirshlib.Theme.Border
            KeyStroke.Parent = KeyButton

            local listening = false
            KeyButton.MouseButton1Click:Connect(function()
                listening = true
                KeyButton.Text = "Press"
                KeyButton.TextColor3 = kirshlib.Theme.Accent
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    key = input.KeyCode
                    KeyButton.Text = key.Name
                    KeyButton.TextColor3 = kirshlib.Theme.Text
                    listening = false
                elseif not gameProcessed and input.KeyCode == key and not listening then
                    if callback then callback(key) end
                end
            end)
        end

        function Tab:dropdown(text, list, default, callback)
            local selected = default or (list and list[1]) or "None"
            local open = false
            local items = list or {}

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 32)
            Frame.BackgroundColor3 = kirshlib.Theme.TopBar
            Frame.ClipsDescendants = true
            Frame.Parent = TabContent

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 4)
            Corner.Parent = Frame

            local Stroke = Instance.new("UIStroke")
            Stroke.Color = kirshlib.Theme.Border
            Stroke.Parent = Frame

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.4, 0, 0, 32)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = kirshlib.Theme.Text
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local MainButton = Instance.new("TextButton")
            MainButton.Size = UDim2.new(0.55, -10, 0, 22)
            MainButton.Position = UDim2.new(0.45, 0, 0, 5)
            MainButton.BackgroundColor3 = kirshlib.Theme.Background
            MainButton.Text = tostring(selected)
            MainButton.TextColor3 = kirshlib.Theme.Text
            MainButton.Font = Enum.Font.Gotham
            MainButton.TextSize = 12
            MainButton.Parent = Frame

            local MainCorner = Instance.new("UICorner")
            MainCorner.CornerRadius = UDim.new(0, 4)
            MainCorner.Parent = MainButton

            local MainStroke = Instance.new("UIStroke")
            MainStroke.Color = kirshlib.Theme.Border
            MainStroke.Parent = MainButton

            local Scroll = Instance.new("ScrollingFrame")
            Scroll.Size = UDim2.new(1, -20, 0, 100)
            Scroll.Position = UDim2.new(0, 10, 0, 34)
            Scroll.BackgroundColor3 = kirshlib.Theme.Background
            Scroll.BorderSizePixel = 0
            Scroll.ScrollBarThickness = 2
            Scroll.Visible = false
            Scroll.Parent = Frame

            local ScrollCorner = Instance.new("UICorner")
            ScrollCorner.CornerRadius = UDim.new(0, 4)
            ScrollCorner.Parent = Scroll

            local ScrollLayout = Instance.new("UIListLayout")
            ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ScrollLayout.Padding = UDim.new(0, 2)
            ScrollLayout.Parent = Scroll

            local function build()
                for _, child in ipairs(Scroll:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end

                for _, name in ipairs(items) do
                    local OptionBtn = Instance.new("TextButton")
                    OptionBtn.Size = UDim2.new(1, 0, 0, 22)
                    OptionBtn.BackgroundColor3 = kirshlib.Theme.TopBar
                    OptionBtn.BackgroundTransparency = 0.5
                    OptionBtn.Text = tostring(name)
                    OptionBtn.TextColor3 = (name == selected) and kirshlib.Theme.Accent or kirshlib.Theme.Text
                    OptionBtn.Font = Enum.Font.Gotham
                    OptionBtn.TextSize = 12
                    OptionBtn.Parent = Scroll

                    local OptionCorner = Instance.new("UICorner")
                    OptionCorner.CornerRadius = UDim.new(0, 3)
                    OptionCorner.Parent = OptionBtn

                    OptionBtn.MouseButton1Click:Connect(function()
                        selected = name
                        MainButton.Text = tostring(name)
                        open = false
                        Scroll.Visible = false
                        TweenService:Create(Frame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 32) }):Play()
                        build()
                        if callback then
                            callback(selected)
                        end
                    end)
                end

                local count = #items
                local height = math.clamp(count * 24, 24, 120)
                Scroll.Size = UDim2.new(1, -20, 0, height)
                Scroll.CanvasSize = UDim2.new(0, 0, 0, count * 24)
            end

            build()

            MainButton.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    build()
                    local count = #items
                    local height = math.clamp(count * 24, 24, 120)
                    Scroll.Visible = true
                    TweenService:Create(Frame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 40 + height) }):Play()
                else
                    Scroll.Visible = false
                    TweenService:Create(Frame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 32) }):Play()
                end
            end)

            local Handler = {}
            function Handler:refresh(newItems)
                items = newItems or {}
                build()
            end
            function Handler:set(val)
                selected = val
                MainButton.Text = tostring(val)
                build()
                if callback then
                    callback(selected)
                end
            end

            return Handler
        end

        Tab.Button = TabButton
        Tab.Content = TabContent

        table.insert(Window.Tabs, Tab)
        TabButton.Visible = true
        if #Window.Tabs == 1 then
            Window:choose(Tab)
        end

        return Tab
    end

    function Window:choose(tab)
        if Window.CurrentTab then
            Window.CurrentTab.Button.BackgroundTransparency = 1
            if SearchBox.Text == "" then
                Window.CurrentTab.Button.TextColor3 = kirshlib.Theme.TextDim
            end
            Window.CurrentTab.Content.Visible = false
        end
        Window.CurrentTab = tab
        tab.Button.BackgroundTransparency = 0.8
        if SearchBox.Text ~= "" then
            tab.Button.TextColor3 = kirshlib.Theme.Accent
        else
            tab.Button.TextColor3 = kirshlib.Theme.Text
        end
        tab.Content.Visible = true
    end

    return Window
end

return kirshlib
