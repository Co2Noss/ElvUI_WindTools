local W, F, E, L = unpack(select(2, ...))
local CH = W:NewModule("ClassHelper", "AceEvent-3.0", "AceHook-3.0")

local eventHandlers = {}
local cleuHandlers = {}
local initFunctions = {}
local profileUpdateFunctions = {}

function CH:EventHandler(event, ...)
    if not eventHandlers[event] then
        return
    end

    for _, func in pairs(eventHandlers[event]) do
        xpcall(func, F.Developer.ThrowError, self, event, ...)
    end
end

function CH:CLEUHandler()
    local params = {CombatLogGetCurrentEventInfo()}
    if params and params[2] and cleuHandlers[params[2]] then
        for _, func in pairs(cleuHandlers[params[2]]) do
            xpcall(func, F.Developer.ThrowError, self, params)
        end
    end
end

function CH:RegisterEvents()
    for event, _ in pairs(eventHandlers) do
        self:RegisterEvent(event, "EventHandler")
    end

    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "CLEUHandler")
end

function CH:UnregisterEvents()
    for event, _ in pairs(eventHandlers) do
        self:UnregisterEvent(event)
    end

    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function CH:RegeisterHelper(helper)
    if type(helper) == "string" then
        helper = self[helper]
        if not helper then
            self:Log("debug", "[RegeisterHelper] Invalid helper name: " .. helper)
            return
        end
    end

    for event, callback in pairs(helper.eventHandlers) do
        if not eventHandlers[event] then
            eventHandlers[event] = {}
        end

        eventHandlers[event][helper.name] = callback
        print(event, helper.name, callback)
    end

    for subevent, callback in pairs(helper.cleuHandlers) do
        if not cleuHandlers[subevent] then
            cleuHandlers[subevent] = {}
        end

        cleuHandlers[subevent][helper.name] = callback
    end

    if helper.init then
        initFunctions[helper.name] = helper.init
    end

    if helper.profileUpdate then
        profileUpdateFunctions[helper.name] = helper.profileUpdate
    end
end

function CH:Initialize()
    for _, func in pairs(initFunctions) do
        xpcall(func, F.Developer.ThrowError, self)
    end

    self:RegisterEvents()

    E:Delay(1, print, "ClassHelper initialized")
end

F.Developer.DelayInitialize(CH, 2)

function CH:ProfileUpdate()
    for _, func in pairs(profileUpdateFunctions) do
        xpcall(func, F.Developer.ThrowError, self)
    end
end

W:RegisterModule(CH:GetName())
