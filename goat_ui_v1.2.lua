-- Tim, August 16, 17, 18, 23, 24 2021
local library = {version = "1.2.9", gui = nil, toggled = true, togglekey = Enum.KeyCode.Backquote, callback = nil, theme = "dark"}

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local UserInputService = game:GetService("UserInputService")



--https://devforum.roblox.com/t/simple-module-for-creating-draggable-gui-elements/230678

local UDim2_new = UDim2.new
local DraggableObject 		= {}
DraggableObject.__index 	= DraggableObject

-- Sets up a new draggable object
function DraggableObject.new(Object)
	local self 			= {}
	self.Object			= Object
	self.DragStarted	= nil
	self.DragEnded		= nil
	self.Dragged		= nil
	self.Dragging		= false
	
	setmetatable(self, DraggableObject)
	
	return self
end

-- Enables dragging
function DraggableObject:Enable()
	local object			= self.Object
	local dragInput			= nil
	local dragStart			= nil
	local startPos			= nil
	local preparingToDrag	= false
	
	-- Updates the element
	local function update(input)
		local delta 		= input.Position - dragStart
		local newPosition	= UDim2_new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		object.Position 	= newPosition
	
		return newPosition
	end
	
	self.InputBegan = object.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			preparingToDrag = true
			
			local connection 
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End and (self.Dragging or preparingToDrag) then
					self.Dragging = false
					connection:Disconnect()
					
					if self.DragEnded and not preparingToDrag then
						self.DragEnded()
					end
					
					preparingToDrag = false
				end
			end)
		end
	end)
	
	self.InputChanged = object.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	self.InputChanged2 = UserInputService.InputChanged:Connect(function(input)
		if object.Parent == nil then
			self:Disable()
			return
		end
		
		if preparingToDrag then
			preparingToDrag = false
			
			if self.DragStarted then
				self.DragStarted()
			end
			
			self.Dragging	= true
			dragStart 		= input.Position
			startPos 		= object.Position
		end
		
		if input == dragInput and self.Dragging then
			local newPosition = update(input)
			
			if self.Dragged then
				self.Dragged(newPosition)
			end
		end
	end)
end

-- Disables dragging
function DraggableObject:Disable()
	self.InputBegan:Disconnect()
	self.InputChanged:Disconnect()
	self.InputChanged2:Disconnect()
	
	if self.Dragging then
		self.Dragging = false
		
		if self.DragEnded then
			self.DragEnded()
		end
	end
end

local function MakeSlider(Slider, Bar, NumberTitle, Name, Min, Max, Value, CallbackFunction)
	local Active = false

	local AP = Slider.AbsolutePosition
	local AS = Slider.AbsoluteSize

	NumberTitle.Text = tostring(Value)
	Bar.Size = UDim2.new(0, Value / (Max-Min) * AS.X, 1, 0)

	Slider.MouseButton1Down:Connect(function()
		Active = true
		AP = Slider.AbsolutePosition
		AS = Slider.AbsoluteSize

		Bar.Size = UDim2.new(0, (Mouse.X - AP.X), 1, 0)

		local Num = Min + Bar.Size.X.Offset / AS.X * (Max-Min)
		NumberTitle.Text = tostring(math.floor(Num))
		library.SetCallback(Name, math.floor(Num))
		CallbackFunction()
	end)

	Mouse.Move:Connect(function()
		AP = Slider.AbsolutePosition
		AS = Slider.AbsoluteSize
		if Active then
			if Mouse.X >= AP.X then -- infront
				Bar.Size = UDim2.new(0, (Mouse.X - AP.X), 1, 0)
				if Mouse.X >= (AP.X + AS.X) then -- past the infront
					Bar.Size = UDim2.new(0, AS.X, 1, 0)
				end
			else -- behind
				Bar.Size = UDim2.new(0, 0, 1, 0)
			end
			local Num = Min + Bar.Size.X.Offset / AS.X * (Max-Min)
			NumberTitle.Text = tostring(math.floor(Num))
			library.SetCallback(Name, math.floor(Num))
			CallbackFunction()
		end
	end)

	UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Active = false
		end
	end)
end

------------------------------------------------
-- Tim, August 16, 17, 18 2021

--local library = {gui = nil, toggled = true, togglekey = Enum.KeyCode.Backquote, callback = nil, theme = "dark"}

library.Kill = function()
	library.gui:Destroy()
end

library.Theme = {
	dark = {
		["Topbar"] = Color3.fromRGB(37, 37, 37),
		["DropShadow"] = Color3.fromRGB(24, 24, 24),
		["Background"] = Color3.fromRGB(51, 51, 51),
		["PrimaryText"] = Color3.fromRGB(255, 255, 255),
		["Button"] = Color3.fromRGB(34, 34, 34),
	},
	light = {
		["Topbar"] = Color3.fromRGB(255, 255, 255),
		["DropShadow"] = Color3.fromRGB(155, 155, 155),
		["Background"] = Color3.fromRGB(244, 244, 244),
		["PrimaryText"] = Color3.fromRGB(33, 33, 33),
		["Button"] = Color3.fromRGB(198, 198, 198),
	},
}

library.Notify = function(Info)
	game:GetService("StarterGui"):SetCore("SendNotification",{Title="goat ui",Text=Info})
end

library.AddCallback = function(Name, Value)
	if library.callback == nil then
		library.callback = Instance.new("Folder")
	end

	library.callback:SetAttribute(Name, Value)
end

library.GetCallback = function(Name)
	if library.callback == nil then
		library.callback = Instance.new("Folder")
	end

	return library.callback:GetAttribute(Name)
end

library.SetCallback = function(Name, Value)
	if library.callback == nil then
		library.callback = Instance.new("Folder")
	end

	if library.callback:GetAttribute(Name) ~= nil then
		library.callback:SetAttribute(Name, Value)
	else
		library.Notify(Name, "does not exist (nil)")
	end
	return Value
end

library.CreateWindow = function(Name)
	local s,e = pcall(function()
		local a=Instance.new"ScreenGui"
		a.Name="GoatUI"
		a.DisplayOrder=69696969
		local b=Instance.new"Frame"
		b.Name="BG"
		b.Selectable=true
		b.AnchorPoint=Vector2.new(0,1)
		b.Size=UDim2.new(0,663,0,289)
		b.ClipsDescendants=true
		b.Position=UDim2.new(0,960,0,347)
		b.BackgroundColor3=library.Theme[library.theme].Background
		b.Parent=a
		local c=Instance.new"UICorner"
		c.CornerRadius=UDim.new(0,12)
		c.Parent=b
		local d=Instance.new"Frame"
		d.Name="Topbar"
		d.ZIndex=2
		d.Size=UDim2.new(1,0,0,25)
		d.BackgroundColor3=library.Theme[library.theme].Topbar
		d.Parent=b
		local e=Instance.new"UICorner"
		e.CornerRadius=UDim.new(0,12)
		e.Parent=d
		local f=Instance.new"Frame"
		f.Name="NoBorder"
		f.AnchorPoint=Vector2.new(0,1)
		f.ZIndex=2
		f.Size=UDim2.new(1,0,0.5,0)
		f.Position=UDim2.new(0,0,1,0)
		f.BorderSizePixel=0
		f.BackgroundColor3=library.Theme[library.theme].Topbar
		f.Parent=d
		local g=Instance.new"Frame"
		g.Name="Divider"
		g.Size=UDim2.new(1,0,0,5)
		g.BorderColor3=Color3.fromRGB(27,42,53)
		g.Position=UDim2.new(0,0,1,0)
		g.BorderSizePixel=0
		g.BackgroundColor3=library.Theme[library.theme].DropShadow
		g.Parent=d
		local h=Instance.new"ImageLabel"
		h.Name="ShadowGradient"
		h.Visible=false
		h.Size=UDim2.new(1,0,0,10)
		h.Rotation=180
		h.BackgroundTransparency=1
		h.Position=UDim2.new(0,0,1,0)
		h.BackgroundColor3=Color3.fromRGB(255,255,255)
		h.ImageColor3=Color3.fromRGB(152,161,170)
		h.Image="rbxassetid://277037182"
		h.Parent=d
		local i=Instance.new"TextLabel"
		i.Name="Title"
		i.AnchorPoint=Vector2.new(0.5,0)
		i.ZIndex=2
		i.Size=UDim2.new(1,0,1,0)
		i.BackgroundTransparency=1
		i.Position=UDim2.new(0.5,0,0,0)
		i.BackgroundColor3=Color3.fromRGB(255,255,255)
		i.FontSize=7
		i.TextStrokeTransparency=0.9
		i.TextSize=21
		i.TextColor3=library.Theme[library.theme].PrimaryText
		i.Text=Name
		i.TextWrap=true
		i.Font=26
		i.TextWrapped=true
		i.TextStrokeColor3=library.Theme[library.theme].PrimaryText
		i.Parent=d
		local j=Instance.new"ImageButton"
		j.Name="Close"
		j.AnchorPoint=Vector2.new(0,0.5)
		j.ZIndex=4
		j.Size=UDim2.new(0,14,0,14)
		j.BackgroundTransparency=1
		j.Position=UDim2.new(0,5,0.5,0)
		j.BackgroundColor3=Color3.fromRGB(255,255,255)
		j.ImageColor3=Color3.fromRGB(240,71,71)
		j.Image="rbxassetid://660373145"
		j.Parent=d
		local k=Instance.new"ImageButton"
		k.Name="Minimize"
		k.AnchorPoint=Vector2.new(0,0.5)
		k.ZIndex=4
		k.Size=UDim2.new(0,14,0,14)
		k.BackgroundTransparency=1
		k.Position=UDim2.new(0,24,0.5,0)
		k.BackgroundColor3=Color3.fromRGB(255,255,255)
		k.ImageColor3=Color3.fromRGB(250,166,26)
		k.Image="rbxassetid://660373145"
		k.Parent=d
		local l=Instance.new"Frame"
		l.Name="Subsection"
		l.Size=UDim2.new(1,0,0,30)
		l.BackgroundTransparency=1
		l.Position=UDim2.new(0,0,0,30)
		l.BorderSizePixel=0
		l.BackgroundColor3=Color3.fromRGB(255,255,255)
		l.Parent=b
		local m=Instance.new"UIListLayout"
		m.FillDirection=0
		m.Padding=UDim.new(0,4)
		m.Parent=l
		local n=Instance.new"Frame"
		n.Name="Shadow"
		n.ZIndex=-5
		n.Size=UDim2.new(1,0,1,8)
		n.BackgroundColor3=library.Theme[library.theme].DropShadow
		n.Parent=b
		local o=Instance.new"UICorner"
		o.CornerRadius=UDim.new(0,12)
		o.Parent=n
		local p=Instance.new"Frame"
		p.Name="Pages"
		p.AnchorPoint=Vector2.new(0.5,0)
		p.Size=UDim2.new(1,-30,1,-70)
		p.BackgroundTransparency=1
		p.Position=UDim2.new(0.5,0,0,70)
		p.BorderSizePixel=0
		p.BackgroundColor3=Color3.fromRGB(255,255,255)
		p.Parent=b

		library.gui = a
		a.Parent = game.Players.LocalPlayer.PlayerGui
		n.Visible = false

		j.MouseButton1Up:Connect(function()
			library.ToggleWindow()
		end)

		local Minimized = false
		k.MouseButton1Up:Connect(function()
			Minimized = not Minimized
			if not Minimized then
				b:TweenSize(UDim2.new(0,663,0,289),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.3,true)
			else
				b:TweenSize(UDim2.new(0,240,0,30),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.3,true)
				b:TweenPosition(UDim2.new(0,0,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.3,true)
			end
		end)

		local Drag = DraggableObject.new(b)
		Drag:Enable()
	end)
	if not s then warn(e) end

	return library.gui
end

library.AddSectionPage = function(Name)
	local s,e = pcall(function()
		local a=Instance.new"Frame"
		a.Name=Name
		a.Size=UDim2.new(1,0,1,0)
		a.BackgroundTransparency=1
		a.BorderSizePixel=0
		a.BackgroundColor3=Color3.fromRGB(255,255,255)
		local b=Instance.new"UIListLayout"
		b.SortOrder=2
		b.Padding=UDim.new(0,5)
		b.Parent=a

		a.Parent = library.gui.BG.Pages
	end)
	if not s then warn(e) end
end

library.OpenPage = function(Name)
	local s,e = pcall(function()
		for i,v in pairs(library.gui.BG.Pages:GetChildren()) do
			if v.Name == Name then
				v.Visible = true
			else
				v.Visible = false
			end
		end
	end)
	if not s then warn(e) end
end

library.AddSectionTab = function(Name)
	local s,e = pcall(function()
		local a=Instance.new"Frame"
		a.Name="Section"
		a.Size=UDim2.new(0.5,-2,0,30)
		a.BackgroundTransparency=1
		a.BorderSizePixel=0
		a.BackgroundColor3=Color3.fromRGB(255,255,255)
		local b=Instance.new"Frame"
		b.Name="ButtonFrame"
		b.ZIndex=2
		b.Size=UDim2.new(1,0,1,-5)
		b.BorderSizePixel=0
		b.BackgroundColor3=library.Theme[library.theme].Button
		b.Parent=a
		local c=Instance.new"UICorner"
		c.CornerRadius=UDim.new(0,6)
		c.Parent=b
		local d=Instance.new"TextButton"
		d.Name="Button"
		d.ZIndex=3
		d.Size=UDim2.new(1,0,1,0)
		d.BackgroundTransparency=1
		d.BackgroundColor3=library.Theme[library.theme].Button
		d.FontSize=7
		d.TextStrokeTransparency=0.9
		d.TextSize=21
		d.TextColor3=library.Theme[library.theme].PrimaryText
		d.Text=Name
		d.Font=26
		d.Parent=b
		local e=Instance.new"Frame"
		e.Name="NoBorder"
		e.ZIndex=2
		e.Size=UDim2.new(1,0,0.5,0)
		e.BorderSizePixel=0
		e.BackgroundColor3=library.Theme[library.theme].Button
		e.Parent=b
		local f=Instance.new"Frame"
		f.Name="Shadow"
		f.Size=UDim2.new(1,0,0.5,0)
		f.Position=UDim2.new(0,0,0.5,0)
		f.BackgroundColor3=library.Theme[library.theme].DropShadow
		f.Parent=a
		local g=Instance.new"UICorner"
		g.CornerRadius=UDim.new(0,6)
		g.Parent=f
		local h=Instance.new"Frame"
		h.Name="ExtraButton"
		h.Size=UDim2.new(1,0,0.5,0)
		h.BorderSizePixel=0
		h.BackgroundColor3=library.Theme[library.theme].Button
		h.Parent=a

		a.Parent = library.gui.BG.Subsection
		library.AddSectionPage(Name)
		library.OpenPage(Name)

		local Tabs = #library.gui.BG.Subsection:GetChildren() - 1
		a.Size = UDim2.new(1 / Tabs,-2,0,30)

		for i,v in pairs(library.gui.BG.Subsection:GetChildren()) do
			Tabs = #library.gui.BG.Subsection:GetChildren() - 1
			if v:IsA("Frame") then
				v.Size = UDim2.new(1 / Tabs,-2,0,30)
			end
		end

		d.MouseButton1Down:Connect(function()
			spawn(function()
				b:TweenPosition(UDim2.new(0,0,0,5),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.1,true)
			end)
		end)

		d.MouseButton1Up:Connect(function()
			library.OpenPage(Name)
			spawn(function()
				b:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.1,true)
			end)
		end)
	end)
	if not s then warn(e) end
end

library.ToggleWindow = function()
	library.gui.Enabled = not library.gui.Enabled
	if library.gui.Enabled then
		local origin = library.gui.BG.Position
		library.gui.BG.Position = library.gui.BG.Position + UDim2.new(0,0,0,10)
		wait()
		library.gui.BG:TweenPosition(origin,Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.15,true)
	end
end

library.AddToggle = function(Page, Name, Value, CallbackFunction)
	local a=Instance.new"Frame"
	a.Name="Toggle"
	a.Size=UDim2.new(0,250,0,30)
	a.BackgroundTransparency=1
	a.BorderSizePixel=0
	a.BackgroundColor3=Color3.fromRGB(255,255,255)
	local b=Instance.new"TextLabel"
	b.Name="Title"
	b.AnchorPoint=Vector2.new(0.5,0)
	b.ZIndex=2
	b.Size=UDim2.new(1,0,1,0)
	b.BackgroundTransparency=1
	b.Position=UDim2.new(0.5,0,0,0)
	b.BackgroundColor3=Color3.fromRGB(255,255,255)
	b.FontSize=7
	b.TextStrokeTransparency=0.9
	b.TextSize=21
	b.TextColor3=library.Theme[library.theme].PrimaryText
	b.Text=Name
	b.TextWrap=true
	b.Font=20
	b.TextWrapped=true
	b.TextXAlignment=0
	b.Parent=a
	local c=Instance.new"Frame"
	c.Name="ButtonFrame"
	c.AnchorPoint=Vector2.new(1,0.5)
	c.Size=UDim2.new(0,30,0,30)
	c.Position=UDim2.new(1,0,0.5,0)
	c.BorderSizePixel=0
	c.BackgroundColor3=Color3.fromRGB(34,34,34)
	c.Parent=a
	local d=Instance.new"ImageButton"
	d.Name="ButtonIcon"
	d.AnchorPoint=Vector2.new(0.5,0.5)
	d.Size=UDim2.new(1,-6,1,-6)
	d.Position=UDim2.new(0.5,0,0.5,0)
	d.BackgroundColor3=Color3.fromRGB(62,62,62)
	d.AutoButtonColor=false
	d.Image="rbxassetid://6972569034"
	d.Parent=c
	local e=Instance.new"UICorner"
	e.Parent=d
	local f=Instance.new"UICorner"
	f.CornerRadius=UDim.new(0,10)
	f.Parent=c

	library.AddCallback(Name, Value)
	local Boolean = library.GetCallback(Name)
	d.ImageTransparency = (Boolean and 0 or 1)

	d.MouseButton1Down:Connect(function()
		Boolean = library.GetCallback(Name)
		Boolean = library.SetCallback(Name, not Boolean)
		d.ImageTransparency = (Boolean and 0 or 1)
		CallbackFunction()
	end)

	a.Parent = library.gui.BG.Pages[Page]
end

library.AddButton = function(Page, Text, CallbackFunction)
	local a=Instance.new"Frame"
	a.Name="Button"
	a.Size=UDim2.new(0,250,0,35)
	a.BackgroundTransparency=1
	a.BorderSizePixel=0
	a.BackgroundColor3=Color3.fromRGB(255,255,255)
	local b=Instance.new"Frame"
	b.Name="ButtonFrame"
	b.ZIndex=2
	b.Size=UDim2.new(1,0,1,-5)
	b.BorderSizePixel=0
	b.BackgroundColor3=library.Theme[library.theme].Button
	b.Parent=a
	local c=Instance.new"UICorner"
	c.CornerRadius=UDim.new(0,6)
	c.Parent=b
	local d=Instance.new"TextButton"
	d.Name="Button"
	d.ZIndex=3
	d.Size=UDim2.new(1,0,1,0)
	d.BackgroundTransparency=1
	d.BackgroundColor3=library.Theme[library.theme].Button
	d.FontSize=7
	d.TextStrokeTransparency=0.9
	d.TextSize=19
	d.TextColor3=library.Theme[library.theme].PrimaryText
	d.Text=Text
	d.Font=20
	d.Parent=b
	local e=Instance.new"Frame"
	e.Name="Shadow"
	e.Size=UDim2.new(1,0,0.5,0)
	e.BackgroundTransparency=0
	e.Position=UDim2.new(0,0,0.5,0)
	e.BackgroundColor3=library.Theme[library.theme].DropShadow
	e.Parent=a
	local f=Instance.new"UICorner"
	f.CornerRadius=UDim.new(0,6)
	f.Parent=e

	d.MouseButton1Down:Connect(function()
		spawn(function()
			b:TweenPosition(UDim2.new(0,0,0,5),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.1,true)
		end)
	end)

	d.MouseButton1Up:Connect(function()
		CallbackFunction()
		spawn(function()
			b:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.1,true)
		end)
	end)

	a.Parent = library.gui.BG.Pages[Page]
end

library.AddInfo = function(Page, Title, Info)
	local a=Instance.new"Frame"
	a.Name="Info"
	a.Size=UDim2.new(0,250,0,30)
	a.BackgroundTransparency=1
	a.BorderSizePixel=0
	a.BackgroundColor3=Color3.fromRGB(255,255,255)
	local b=Instance.new"TextLabel"
	b.Name="Title"
	b.AnchorPoint=Vector2.new(0.5,0)
	b.ZIndex=2
	b.Size=UDim2.new(1,0,1,0)
	b.BackgroundTransparency=1
	b.Position=UDim2.new(0.5,0,0,0)
	b.BackgroundColor3=Color3.fromRGB(255,255,255)
	b.FontSize=7
	b.TextStrokeTransparency=0.9
	b.TextSize=21
	b.TextColor3=library.Theme[library.theme].PrimaryText
	b.Text=Title .. ":"
	b.TextWrap=true
	b.Font=20
	b.TextWrapped=true
	b.TextXAlignment=0
	b.Parent=a
	local c=Instance.new"TextLabel"
	c.Name="Title2"
	c.AnchorPoint=Vector2.new(0.5,0)
	c.ZIndex=2
	c.Size=UDim2.new(1,0,1,0)
	c.BackgroundTransparency=1
	c.Position=UDim2.new(0.5,0,0,0)
	c.BackgroundColor3=Color3.fromRGB(255,255,255)
	c.FontSize=7
	c.TextStrokeTransparency=0.9
	c.TextSize=19
	c.TextColor3=library.Theme[library.theme].PrimaryText
	c.Text=Info
	c.TextWrap=true
	c.Font=20
	c.TextWrapped=true
	c.TextXAlignment=1
	c.Parent=a

	a.Parent = library.gui.BG.Pages[Page]
end

library.AddSlider = function(Page, Title, Name, Min, Max, Value, CallbackFunction)
	local a=Instance.new"Frame"
	a.Name="Slider"
	a.Size=UDim2.new(0,250,0,40)
	a.BackgroundTransparency=1
	a.BorderSizePixel=0
	a.BackgroundColor3=Color3.fromRGB(255,255,255)
	local b=Instance.new"TextButton"
	b.Name="SliderBtn"
	b.ZIndex=3
	b.Size=UDim2.new(0,250,0,20)
	b.Position=UDim2.new(0,0,0,20)
	b.BorderSizePixel=0
	b.BackgroundColor3=Color3.fromRGB(25,25,25)
	b.AutoButtonColor=false
	b.FontSize=7
	b.TextStrokeTransparency=0.9
	b.TextSize=19
	b.TextColor3=Color3.fromRGB(255,255,255)
	b.Text=""
	b.Font=20
	b.Parent=a
	local c=Instance.new"Frame"
	c.Name="Bar"
	c.ZIndex=3
	c.Size=UDim2.new(0,125,1,0)
	c.ClipsDescendants=true
	c.BorderSizePixel=0
	c.BackgroundColor3=Color3.fromRGB(0,196,255)
	c.Parent=b
	local d=Instance.new"UICorner"
	d.CornerRadius=UDim.new(0,12)
	d.Parent=c
	local e=Instance.new"TextLabel"
	e.Name="Title"
	e.ZIndex=4
	e.Size=UDim2.new(1,0,1,0)
	e.BackgroundTransparency=1
	e.BackgroundColor3=Color3.fromRGB(255,255,255)
	e.FontSize=5
	e.TextSize=14
	e.TextColor3=Color3.fromRGB(255,255,255)
	e.Text=tostring(Min)
	e.TextWrap=true
	e.Font=3
	e.TextWrapped=true
	e.TextScaled=true
	e.Parent=b
	local f=Instance.new"UICorner"
	f.CornerRadius=UDim.new(0,12)
	f.Parent=b
	local g=Instance.new"TextLabel"
	g.Name="Title"
	g.AnchorPoint=Vector2.new(0.5,0)
	g.ZIndex=2
	g.Size=UDim2.new(1,0,0,20)
	g.BackgroundTransparency=1
	g.Position=UDim2.new(0.5,0,0,0)
	g.BackgroundColor3=Color3.fromRGB(255,255,255)
	g.FontSize=6
	g.TextStrokeTransparency=0.9
	g.TextSize=15
	g.TextColor3=Color3.fromRGB(255,255,255)
	g.Text=Title
	g.TextWrap=true
	g.Font=20
	g.TextWrapped=true
	g.TextXAlignment=0
	g.Parent=a
	
	a.Parent = library.gui.BG.Pages[Page]
	library.AddCallback(Name, Value)
	MakeSlider(b, c, e, Name, Min, Max, Value, CallbackFunction)
end

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == library.togglekey then
			library.ToggleWindow()
		end
	end
end)

return library
