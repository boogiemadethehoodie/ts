local Drawing = {}
Drawing.__index = Drawing

-- Fonts enum mapping
Drawing.Fonts = {
    UI = 0,        -- Enum.Font.Arial
    System = 1,    -- Enum.Font.SourceSans
    Plex = 2,      -- Enum.Font.Gotham
    Monospace = 3, -- Enum.Font.RobotoMono
    Code = 4,      -- Enum.Font.Code
    Bold = 5       -- Enum.Font.GothamBold
}

-- Font mapping to Roblox fonts
local FontMap = {
    [0] = Enum.Font.Arial,
    [1] = Enum.Font.SourceSans,
    [2] = Enum.Font.Gotham,
    [3] = Enum.Font.RobotoMono,
    [4] = Enum.Font.Code,
    [5] = Enum.Font.GothamBold
}

-- Create container for all drawing objects
local DrawingContainer = Instance.new("ScreenGui")
DrawingContainer.Name = "DrawingContainer"
DrawingContainer.ResetOnSpawn = false
DrawingContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
DrawingContainer.IgnoreGuiInset = true
DrawingContainer.DisplayOrder = 999999999

-- Safely set parent of DrawingContainer
local success, _ = pcall(function()
    syn = syn or {}
    if syn.protect_gui then
        syn.protect_gui(DrawingContainer)
        DrawingContainer.Parent = game:GetService("CoreGui")
    else
        DrawingContainer.Parent = game:GetService("CoreGui")
    end
end)

if not success then
    -- Fallback if CoreGui access is not available
    DrawingContainer.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

-- Store all drawing objects for management
local DrawingObjects = {}

-- Core classes for different drawing types
local BaseClass = {}
BaseClass.__index = BaseClass

function BaseClass.new()
    local self = setmetatable({}, BaseClass)
    self.Instance = nil
    self.Properties = {
        Visible = false,
        ZIndex = 1,
        Transparency = 1,
        Color = Color3.fromRGB(255, 255, 255)
    }
    return self
end

function BaseClass:Remove()
    if self.Instance then
        self.Instance:Destroy()
        self.Instance = nil
    end
    for i, obj in pairs(DrawingObjects) do
        if obj == self then
            table.remove(DrawingObjects, i)
            break
        end
    end
end

function BaseClass:SetProperty(property, value)
    self.Properties[property] = value
    self:Update()
end

function BaseClass:GetProperty(property)
    return self.Properties[property]
end

function BaseClass:Update()
    -- Base update function, to be overridden
end

-- Line Class
local Line = setmetatable({}, {__index = BaseClass})
Line.__index = Line

function Line.new()
    local self = setmetatable(BaseClass.new(), Line)
    
    -- Create line instance
    self.Instance = Instance.new("Frame")
    self.Instance.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instance.BorderSizePixel = 0
    self.Instance.ZIndex = 1
    self.Instance.Parent = DrawingContainer
    
    -- Line-specific properties
    self.Properties.From = Vector2.new(0, 0)
    self.Properties.To = Vector2.new(0, 0)
    self.Properties.Thickness = 1
    
    table.insert(DrawingObjects, self)
    self:Update()
    
    return self
end

function Line:Update()
    if not self.Instance then return end
    
    -- Update basic properties
    self.Instance.Visible = self.Properties.Visible
    self.Instance.BackgroundColor3 = self.Properties.Color
    self.Instance.BackgroundTransparency = 1 - self.Properties.Transparency
    self.Instance.ZIndex = self.Properties.ZIndex
    
    -- Calculate the line dimensions and rotation
    local from = self.Properties.From
    local to = self.Properties.To
    local direction = (to - from)
    local distance = direction.Magnitude
    
    -- Calculate angle in degrees
    local angle = math.atan2(direction.Y, direction.X) * (180 / math.pi)
    
    -- Update line position, size and rotation
    self.Instance.Position = UDim2.new(0, from.X, 0, from.Y)
    self.Instance.Size = UDim2.new(0, distance, 0, self.Properties.Thickness)
    self.Instance.Rotation = angle
    
    -- Apply anchor point to rotate around start correctly
    self.Instance.AnchorPoint = Vector2.new(0, 0.5)
end

-- Square Class
local Square = setmetatable({}, {__index = BaseClass})
Square.__index = Square

function Square.new()
    local self = setmetatable(BaseClass.new(), Square)
    
    -- Create square instance
    self.Instance = Instance.new("Frame")
    self.Instance.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instance.BackgroundTransparency = 1
    self.Instance.BorderSizePixel = 0
    self.Instance.ZIndex = 1
    self.Instance.Parent = DrawingContainer
    
    -- Create stroke for outline
    self.Stroke = Instance.new("UIStroke")
    self.Stroke.Color = Color3.fromRGB(255, 255, 255)
    self.Stroke.Thickness = 1
    self.Stroke.Parent = self.Instance
    
    -- Square-specific properties
    self.Properties.Size = Vector2.new(100, 100)
    self.Properties.Position = Vector2.new(0, 0)
    self.Properties.Filled = false
    self.Properties.Thickness = 1
    
    table.insert(DrawingObjects, self)
    self:Update()
    
    return self
end

function Square:Update()
    if not self.Instance then return end
    
    -- Update basic properties
    self.Instance.Visible = self.Properties.Visible
    self.Instance.BackgroundColor3 = self.Properties.Color
    self.Instance.ZIndex = self.Properties.ZIndex
    
    -- Update position and size
    self.Instance.Position = UDim2.new(0, self.Properties.Position.X, 0, self.Properties.Position.Y)
    self.Instance.Size = UDim2.new(0, self.Properties.Size.X, 0, self.Properties.Size.Y)
    
    -- Update fill and stroke
    if self.Properties.Filled then
        self.Instance.BackgroundTransparency = 1 - self.Properties.Transparency
        self.Stroke.Transparency = 1
    else
        self.Instance.BackgroundTransparency = 1
        self.Stroke.Transparency = 1 - self.Properties.Transparency
        self.Stroke.Color = self.Properties.Color
        self.Stroke.Thickness = self.Properties.Thickness
    end
end

-- Circle Class
local Circle = setmetatable({}, {__index = BaseClass})
Circle.__index = Circle

function Circle.new()
    local self = setmetatable(BaseClass.new(), Circle)
    
    -- Create circle instance
    self.Instance = Instance.new("Frame")
    self.Instance.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instance.BackgroundTransparency = 1
    self.Instance.BorderSizePixel = 0
    self.Instance.ZIndex = 1
    self.Instance.Parent = DrawingContainer
    
    -- Add corner radius to make it a circle
    self.Corner = Instance.new("UICorner")
    self.Corner.CornerRadius = UDim.new(1, 0)
    self.Corner.Parent = self.Instance
    
    -- Create stroke for outline
    self.Stroke = Instance.new("UIStroke")
    self.Stroke.Color = Color3.fromRGB(255, 255, 255)
    self.Stroke.Thickness = 1
    self.Stroke.Parent = self.Instance
    
    -- Circle-specific properties
    self.Properties.Radius = 50
    self.Properties.Position = Vector2.new(0, 0)
    self.Properties.Filled = false
    self.Properties.Thickness = 1
    self.Properties.NumSides = 0  -- Not used in Roblox implementation but kept for compatibility
    
    table.insert(DrawingObjects, self)
    self:Update()
    
    return self
end

function Circle:Update()
    if not self.Instance then return end
    
    -- Update basic properties
    self.Instance.Visible = self.Properties.Visible
    self.Instance.BackgroundColor3 = self.Properties.Color
    self.Instance.ZIndex = self.Properties.ZIndex
    
    -- Update position and size based on radius
    local diameter = self.Properties.Radius * 2
    self.Instance.Position = UDim2.new(0, self.Properties.Position.X - self.Properties.Radius, 
                                        0, self.Properties.Position.Y - self.Properties.Radius)
    self.Instance.Size = UDim2.new(0, diameter, 0, diameter)
    
    -- Update fill and stroke
    if self.Properties.Filled then
        self.Instance.BackgroundTransparency = 1 - self.Properties.Transparency
        self.Stroke.Transparency = 1
    else
        self.Instance.BackgroundTransparency = 1
        self.Stroke.Transparency = 1 - self.Properties.Transparency
        self.Stroke.Color = self.Properties.Color
        self.Stroke.Thickness = self.Properties.Thickness
    end
end

-- Text Class
local Text = setmetatable({}, {__index = BaseClass})
Text.__index = Text

function Text.new()
    local self = setmetatable(BaseClass.new(), Text)
    
    -- Create text instance
    self.Instance = Instance.new("TextLabel")
    self.Instance.BackgroundTransparency = 1
    self.Instance.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.Instance.TextTransparency = 0
    self.Instance.ZIndex = 1
    self.Instance.RichText = true
    self.Instance.Parent = DrawingContainer
    
    -- Create stroke for outline
    self.Stroke = Instance.new("UIStroke")
    self.Stroke.Color = Color3.fromRGB(0, 0, 0)
    self.Stroke.Thickness = 1
    self.Stroke.Parent = self.Instance
    
    -- Text-specific properties
    self.Properties.Text = ""
    self.Properties.Size = 14
    self.Properties.Position = Vector2.new(0, 0)
    self.Properties.Center = false
    self.Properties.Outline = false
    self.Properties.OutlineColor = Color3.fromRGB(0, 0, 0)
    self.Properties.Font = 0  -- Default to first font
    
    table.insert(DrawingObjects, self)
    self:Update()
    
    return self
end

function Text:Update()
    if not self.Instance then return end
    
    -- Update basic properties
    self.Instance.Visible = self.Properties.Visible
    self.Instance.TextColor3 = self.Properties.Color
    self.Instance.TextTransparency = 1 - self.Properties.Transparency
    self.Instance.ZIndex = self.Properties.ZIndex
    
    -- Update text-specific properties
    self.Instance.Text = self.Properties.Text
    self.Instance.Font = FontMap[self.Properties.Font] or Enum.Font.Arial
    self.Instance.TextSize = self.Properties.Size
    self.Instance.Position = UDim2.new(0, self.Properties.Position.X, 0, self.Properties.Position.Y)
    
    -- Auto-size text
    local textBounds = game:GetService("TextService"):GetTextSize(
        self.Properties.Text,
        self.Properties.Size,
        self.Instance.Font,
        Vector2.new(2048, 2048)
    )
    self.Instance.Size = UDim2.new(0, textBounds.X, 0, textBounds.Y)
    
    -- Update alignment based on centering
    if self.Properties.Center then
        self.Instance.TextXAlignment = Enum.TextXAlignment.Center
        self.Instance.TextYAlignment = Enum.TextYAlignment.Center
        self.Instance.AnchorPoint = Vector2.new(0.5, 0.5)
    else
        self.Instance.TextXAlignment = Enum.TextXAlignment.Left
        self.Instance.TextYAlignment = Enum.TextYAlignment.Top
        self.Instance.AnchorPoint = Vector2.new(0, 0)
    end
    
    -- Update outline
    if self.Properties.Outline then
        self.Stroke.Transparency = 0
        self.Stroke.Color = self.Properties.OutlineColor
    else
        self.Stroke.Transparency = 1
    end
end

-- Image Class
local Image = setmetatable({}, {__index = BaseClass})
Image.__index = Image

function Image.new()
    local self = setmetatable(BaseClass.new(), Image)
    
    -- Create image instance
    self.Instance = Instance.new("ImageLabel")
    self.Instance.BackgroundTransparency = 1
    self.Instance.ZIndex = 1
    self.Instance.Parent = DrawingContainer
    
    -- Image-specific properties
    self.Properties.Data = ""
    self.Properties.Size = Vector2.new(100, 100)
    self.Properties.Position = Vector2.new(0, 0)
    self.Properties.Rounding = 0
    
    -- Create corner radius for rounding
    self.Corner = Instance.new("UICorner")
    self.Corner.Parent = self.Instance
    
    table.insert(DrawingObjects, self)
    self:Update()
    
    return self
end

function Image:Update()
    if not self.Instance then return end
    
    -- Update basic properties
    self.Instance.Visible = self.Properties.Visible
    self.Instance.ImageColor3 = self.Properties.Color
    self.Instance.ImageTransparency = 1 - self.Properties.Transparency
    self.Instance.ZIndex = self.Properties.ZIndex
    
    -- Update position and size
    self.Instance.Position = UDim2.new(0, self.Properties.Position.X, 0, self.Properties.Position.Y)
    self.Instance.Size = UDim2.new(0, self.Properties.Size.X, 0, self.Properties.Size.Y)
    
    -- Update image data - handle different types of image sources
    if self.Properties.Data and self.Properties.Data ~= "" then
        -- Check if it's a raw Data URL
        if self.Properties.Data:sub(1, 5) == "data:" then
            self.Instance.Image = self.Properties.Data
        -- Check if it's a Roblox asset ID
        elseif self.Properties.Data:match("^%d+$") then
            self.Instance.Image = "rbxassetid://" .. self.Properties.Data
        -- Check if it's already a proper Roblox asset URL
        elseif self.Properties.Data:match("^rbxassetid://") or 
               self.Properties.Data:match("^http") then
            self.Instance.Image = self.Properties.Data
        else
            -- Assume it's a URL
            self.Instance.Image = self.Properties.Data
        end
    else
        self.Instance.Image = ""
    end
    
    -- Update corner rounding
    if self.Properties.Rounding > 0 then
        self.Corner.CornerRadius = UDim.new(self.Properties.Rounding / 100, 0)
    else
        self.Corner.CornerRadius = UDim.new(0, 0)
    end
end

-- Triangle Class (implemented using ImageLabel with triangle image)
local Triangle = setmetatable({}, {__index = BaseClass})
Triangle.__index = Triangle

function Triangle.new()
    local self = setmetatable(BaseClass.new(), Triangle)
    
    -- Create triangle frame
    self.Instance = Instance.new("Frame")
    self.Instance.BackgroundTransparency = 1
    self.Instance.ZIndex = 1
    self.Instance.ClipsDescendants = false
    self.Instance.Parent = DrawingContainer
    
    -- Create inner frame for actual triangle
    self.InnerFrame = Instance.new("Frame")
    self.InnerFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.InnerFrame.BorderSizePixel = 0
    self.InnerFrame.Parent = self.Instance
    
    -- Triangle-specific properties
    self.Properties.PointA = Vector2.new(0, 0)
    self.Properties.PointB = Vector2.new(50, 100)
    self.Properties.PointC = Vector2.new(100, 0)
    self.Properties.Filled = true
    self.Properties.Thickness = 1
    
    -- Create UIGradients for clipping
    self.Gradient1 = Instance.new("UIGradient")
    self.Gradient1.Parent = self.InnerFrame
    
    self.Gradient2 = Instance.new("UIGradient")
    self.Gradient2.Parent = self.InnerFrame
    
    table.insert(DrawingObjects, self)
    self:Update()
    
    return self
end

function Triangle:Update()
    if not self.Instance then return end
    
    -- Update basic properties
    self.Instance.Visible = self.Properties.Visible
    self.InnerFrame.BackgroundColor3 = self.Properties.Color
    self.InnerFrame.BackgroundTransparency = 1 - self.Properties.Transparency
    self.Instance.ZIndex = self.Properties.ZIndex
    
    -- Calculate triangle bounds
    local minX = math.min(self.Properties.PointA.X, self.Properties.PointB.X, self.Properties.PointC.X)
    local minY = math.min(self.Properties.PointA.Y, self.Properties.PointB.Y, self.Properties.PointC.Y)
    local maxX = math.max(self.Properties.PointA.X, self.Properties.PointB.X, self.Properties.PointC.X)
    local maxY = math.max(self.Properties.PointA.Y, self.Properties.PointB.Y, self.Properties.PointC.Y)
    
    -- Position and size the frame
    self.Instance.Position = UDim2.new(0, minX, 0, minY)
    self.Instance.Size = UDim2.new(0, maxX - minX, 0, maxY - minY)
    
    -- Position inner frame
    self.InnerFrame.Size = UDim2.fromScale(1, 1)
    self.InnerFrame.Position = UDim2.fromScale(0, 0)
    
    -- Calculate normalized points for the clipping gradients
    local normalizedA = Vector2.new(
        (self.Properties.PointA.X - minX) / (maxX - minX),
        (self.Properties.PointA.Y - minY) / (maxY - minY)
    )
    local normalizedB = Vector2.new(
        (self.Properties.PointB.X - minX) / (maxX - minX),
        (self.Properties.PointB.Y - minY) / (maxY - minY)
    )
    local normalizedC = Vector2.new(
        (self.Properties.PointC.X - minX) / (maxX - minX),
        (self.Properties.PointC.Y - minY) / (maxY - minY)
    )
    
    -- Set up clipping gradients (simplified approach - not perfect for all triangles)
    -- This is a simple approximation, perfect triangles would need a custom shader
    self.Gradient1.Transparency = {0, 1}
    self.Gradient1.Offset = Vector2.new(0, 0)
    self.Gradient1.Rotation = math.deg(math.atan2(
        normalizedB.Y - normalizedA.Y,
        normalizedB.X - normalizedA.X
    ))
    
    self.Gradient2.Transparency = {0, 1}
    self.Gradient2.Offset = Vector2.new(0, 0)
    self.Gradient2.Rotation = math.deg(math.atan2(
        normalizedC.Y - normalizedA.Y,
        normalizedC.X - normalizedA.X
    ))
end

-- Quad Class
local Quad = setmetatable({}, {__index = BaseClass})
Quad.__index = Quad

function Quad.new()
    local self = setmetatable(BaseClass.new(), Quad)
    
    -- Create frame
    self.Instance = Instance.new("Frame")
    self.Instance.BackgroundTransparency = 1
    self.Instance.BorderSizePixel = 0
    self.Instance.ZIndex = 1
    self.Instance.Parent = DrawingContainer
    
    -- Create 4 triangles for the quad
    self.Triangles = {}
    for i = 1, 2 do
        local triangle = Instance.new("Frame")
        triangle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        triangle.BorderSizePixel = 0
        triangle.Parent = self.Instance
        
        -- Create clipping gradients
        local gradient = Instance.new("UIGradient")
        gradient.Parent = triangle
        
        self.Triangles[i] = {
            Frame = triangle,
            Gradient = gradient
        }
    end
    
    -- Quad-specific properties
    self.Properties.PointA = Vector2.new(0, 0)
    self.Properties.PointB = Vector2.new(100, 0)
    self.Properties.PointC = Vector2.new(100, 100)
    self.Properties.PointD = Vector2.new(0, 100)
    self.Properties.Filled = true
    self.Properties.Thickness = 1
    
    table.insert(DrawingObjects, self)
    self:Update()
    
    return self
end

function Quad:Update()
    if not self.Instance then return end
    
    -- Update basic properties
    self.Instance.Visible = self.Properties.Visible
    self.Instance.ZIndex = self.Properties.ZIndex
    
    -- Calculate quad bounds
    local minX = math.min(self.Properties.PointA.X, self.Properties.PointB.X, 
                          self.Properties.PointC.X, self.Properties.PointD.X)
    local minY = math.min(self.Properties.PointA.Y, self.Properties.PointB.Y, 
                          self.Properties.PointC.Y, self.Properties.PointD.Y)
    local maxX = math.max(self.Properties.PointA.X, self.Properties.PointB.X, 
                          self.Properties.PointC.X, self.Properties.PointD.X)
    local maxY = math.max(self.Properties.PointA.Y, self.Properties.PointB.Y, 
                          self.Properties.PointC.Y, self.Properties.PointD.Y)
    
    -- Position and size the frame
    self.Instance.Position = UDim2.new(0, minX, 0, minY)
    self.Instance.Size = UDim2.new(0, maxX - minX, 0, maxY - minY)
    
    -- Update the triangles (split quad into 2 triangles)
    -- Triangle 1: A, B, C
    local triangle1 = self.Triangles[1]
    triangle1.Frame.BackgroundColor3 = self.Properties.Color
    triangle1.Frame.BackgroundTransparency = 1 - self.Properties.Transparency
    triangle1.Frame.Size = UDim2.fromScale(1, 1)
    
    -- Triangle 2: A, C, D
    local triangle2 = self.Triangles[2]
    triangle2.Frame.BackgroundColor3 = self.Properties.Color
    triangle2.Frame.BackgroundTransparency = 1 - self.Properties.Transparency
    triangle2.Frame.Size = UDim2.fromScale(1, 1)
    
    -- This is a simplified implementation - for complex quads with precise shapes,
    -- we would need more sophisticated clipping or actual mesh rendering
end

-- Function Factory for creating different drawing types
local function CreateDrawingObject(className)
    local classMap = {
        Line = Line,
        Square = Square,
        Circle = Circle,
        Text = Text,
        Image = Image,
        Triangle = Triangle,
        Quad = Quad
    }
    
    local class = classMap[className]
    if not class then
        warn("Unknown drawing class: " .. className)
        return nil
    end
    
    return class.new()
end

-- Main interface function
function Drawing.new(className)
    local obj = CreateDrawingObject(className)
    if not obj then return nil end
    
    -- Create the public interface with property getters/setters
    local interface = {}
    
    -- Method to remove the drawing object
    interface.Remove = function()
        obj:Remove()
    end
    
    -- Alias for Remove
    interface.Destroy = interface.Remove
    
    -- Set up getters and setters for properties via metatable
    local mt = {
        __index = function(_, key)
            return obj:GetProperty(key)
        end,
        
        __newindex = function(_, key, value)
            obj:SetProperty(key, value)
        end
    }
    
    return setmetatable(interface, mt)
end

-- Utility function to clear all drawing objects
function Drawing.clear_drawings()
    for _, obj in pairs(DrawingObjects) do
        if obj.Instance then
            obj.Instance:Destroy()
        end
    end
    table.clear(DrawingObjects)
end

-- Return the Drawing module
return Drawing
