-----------------------------------------------------------------------------------------------
-- Client Lua Script for TaviTooltips
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Apollo"
require "GameLib"
require "FriendshipLib"
require "ChallengesLib"
require "PlayerPathLib"
require "Unit"
require "Item"

local TaviTooltips = {}
local knDataWindowPadding = 5
local kItemTooltipWindowWidth = 350
local kstrTab = "    "
local kUIBody = "ff39b5d4"
local kUITeal = "ff53aa7f"
local kUIRed = "Reddish" -- "ffab472f" Sat +50
local kUIGreen = "ff42da00" -- "ff55ab2f" Sat +50
local kUIYellow = kUIBody
local kUICyan = "UI_TextHoloBodyCyan"
local kUILowDurability = "yellow"
local kUIHugeFontSize = "CRB_HeaderSmall"

local karSimpleDispositionUnitTypes =
{
	["Simple"]			= true,
	["Chest"]			= true,
	["Door"]			= true,
	["Collectible"]		= true,
	["Platform"]		= true,
	["Mailbox"]			= true,
	["BindPoint"]		= true,
}

local karNPCDispositionUnitTypes =
{
	["NonPlayer"]			= true,
	["Destructible"]		= true,
	["Vehicle"]				= true,
	["Corpse"]				= true,
	["Mount"]				= true,
	["Taxi"]				= true,
	["DestructibleDoor"]	= true,
	["Turret"]				= true,
	["Pet"]					= true,
	["Esper Pet"]			= true,
	["Scanner"]				= true,
	["StructuredPlug"]		= true,
	["Lockbox"]				= true,
}

local karClassToString =
{
	[GameLib.CodeEnumClass.Warrior]       	= Apollo.GetString("ClassWarrior"),
	[GameLib.CodeEnumClass.Engineer]      	= Apollo.GetString("ClassEngineer"),
	[GameLib.CodeEnumClass.Esper]         	= Apollo.GetString("ClassESPER"),
	[GameLib.CodeEnumClass.Medic]         	= Apollo.GetString("ClassMedic"),
	[GameLib.CodeEnumClass.Stalker]       	= Apollo.GetString("ClassStalker"),
	[GameLib.CodeEnumClass.Spellslinger]    = Apollo.GetString("ClassSpellslinger"),
}

local ktClassToIcon =
{
	[GameLib.CodeEnumClass.Medic]       	= "Icon_Windows_UI_CRB_Medic",
	[GameLib.CodeEnumClass.Esper]       	= "Icon_Windows_UI_CRB_Esper",
	[GameLib.CodeEnumClass.Warrior]     	= "Icon_Windows_UI_CRB_Warrior",
	[GameLib.CodeEnumClass.Stalker]     	= "Icon_Windows_UI_CRB_Stalker",
	[GameLib.CodeEnumClass.Engineer]    	= "Icon_Windows_UI_CRB_Engineer",
	[GameLib.CodeEnumClass.Spellslinger]  	= "Icon_Windows_UI_CRB_Spellslinger",
}

local ktPathToString =
{
	[PlayerPathLib.PlayerPathType_Soldier]    = Apollo.GetString("PlayerPathSoldier"),
	[PlayerPathLib.PlayerPathType_Settler]    = Apollo.GetString("PlayerPathSettler"),
	[PlayerPathLib.PlayerPathType_Scientist]  = Apollo.GetString("PlayerPathExplorer"),
	[PlayerPathLib.PlayerPathType_Explorer]   = Apollo.GetString("PlayerPathScientist"),
}

local ktPathToIcon =
{
	[PlayerPathLib.PlayerPathType_Soldier]    = "Icon_Windows_UI_CRB_Soldier",
	[PlayerPathLib.PlayerPathType_Settler]    = "Icon_Windows_UI_CRB_Colonist",
	[PlayerPathLib.PlayerPathType_Scientist]  = "Icon_Windows_UI_CRB_Scientist",
	[PlayerPathLib.PlayerPathType_Explorer]   = "Icon_Windows_UI_CRB_Explorer",
}

local karFactionToString =
{
	[Unit.CodeEnumFaction.ExilesPlayer]     = Apollo.GetString("CRB_Exile"),
	[Unit.CodeEnumFaction.DominionPlayer]   = Apollo.GetString("CRB_Dominion"),
}

local karDispositionColors =
{
	[Unit.CodeEnumDisposition.Neutral]  = ApolloColor.new("DispositionNeutral"),
	[Unit.CodeEnumDisposition.Hostile]  = ApolloColor.new("DispositionHostile"),
	[Unit.CodeEnumDisposition.Friendly] = ApolloColor.new("DispositionFriendly"),
}

local karDispositionColorStrings =
{
	[Unit.CodeEnumDisposition.Neutral]  = "DispositionNeutral",
	[Unit.CodeEnumDisposition.Hostile]  = "DispositionHostile",
	[Unit.CodeEnumDisposition.Friendly] = "DispositionFriendly",
}

local karDispositionFrameSprites =
{
	[Unit.CodeEnumDisposition.Neutral]  = "sprTooltip_SquareFrame_UnitYellow",
	[Unit.CodeEnumDisposition.Hostile]  = "sprTooltip_SquareFrame_UnitRed",
	[Unit.CodeEnumDisposition.Friendly] = "sprTooltip_SquareFrame_UnitGreen",
}

local karRaceToString =
{
	[GameLib.CodeEnumRace.Human] 	= Apollo.GetString("RaceHuman"),
	[GameLib.CodeEnumRace.Granok] 	= Apollo.GetString("RaceGranok"),
	[GameLib.CodeEnumRace.Aurin] 	= Apollo.GetString("RaceAurin"),
	[GameLib.CodeEnumRace.Draken] 	= Apollo.GetString("RaceDraken"),
	[GameLib.CodeEnumRace.Mechari] 	= Apollo.GetString("RaceMechari"),
	[GameLib.CodeEnumRace.Chua] 	= Apollo.GetString("RaceChua"),
	[GameLib.CodeEnumRace.Mordesh] 	= Apollo.GetString("CRB_Mordesh"),
}

local eConDiferentials = {
	nConTrivial = -4,
	nConInferior = -3,
	nConMinor = -2,
	nConEase = -1,
	nConAverage = 0,
	nConModerate = 1,
	nConTough = 2,
	nConHard = 3,
	nConSuperior = 4,
	nConMaxLevel = 5,
}

local ktRankDescriptions =
{
	[Unit.CodeEnumRank.Fodder] 		= 	Apollo.GetString("TargetFrame_Fodder"),
	[Unit.CodeEnumRank.Minion] 		= 	Apollo.GetString("TargetFrame_Minion"),
	[Unit.CodeEnumRank.Standard]	= 	Apollo.GetString("TargetFrame_Grunt"),
	[Unit.CodeEnumRank.Champion] 	=	Apollo.GetString("TargetFrame_Challenger"),
	[Unit.CodeEnumRank.Superior] 	=  	Apollo.GetString("TargetFrame_Superior"),
	[Unit.CodeEnumRank.Elite] 		= 	Apollo.GetString("TargetFrame_Prime"),
}

local ktRewardToIcon =
{
	[Unit.CodeEnumRewardInfoType.Quest] 			= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_ActiveQuest",
	[Unit.CodeEnumRewardInfoType.Challenge] 		= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_Challenge",
	[Unit.CodeEnumRewardInfoType.Explorer] 		= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_PathExp",
	[Unit.CodeEnumRewardInfoType.Scientist] 		= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_PathSci",
	[Unit.CodeEnumRewardInfoType.Soldier] 		= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_PathSol",
	[Unit.CodeEnumRewardInfoType.Settler] 		= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_PathSet",
	[Unit.CodeEnumRewardInfoType.PublicEvent] 	= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_PublicEvent",
	[Unit.CodeEnumRewardInfoType.Rival] 			= "ClientSprites:Icon_Windows_UI_CRB_Rival",
	[Unit.CodeEnumRewardInfoType.Friend] 			= "ClientSprites:Icon_Windows_UI_CRB_Friend",
	[Unit.CodeEnumRewardInfoType.ScientistSpell]	= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_PathSciSpell",
	[Unit.CodeEnumRewardInfoType.Contract]			= "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_Contract"
}

local ktRewardToString =
{
	[Unit.CodeEnumRewardInfoType.Quest] 			= Apollo.GetString("Tooltips_Quest"),
	[Unit.CodeEnumRewardInfoType.Challenge] 		= Apollo.GetString("Tooltips_Challenge"),
	[Unit.CodeEnumRewardInfoType.Explorer] 		= Apollo.GetString("ZoneMap_ExplorerMission"),
	[Unit.CodeEnumRewardInfoType.Scientist] 		= Apollo.GetString("ZoneMap_ScientistMission"),
	[Unit.CodeEnumRewardInfoType.Soldier] 		= Apollo.GetString("ZoneMap_SoldierMission"),
	[Unit.CodeEnumRewardInfoType.Settler] 		= Apollo.GetString("ZoneMap_SettlerMission"),
	[Unit.CodeEnumRewardInfoType.PublicEvent] 	= Apollo.GetString("ZoneMap_PublicEvent"),
	[Unit.CodeEnumRewardInfoType.Rival] 			= Apollo.GetString("Tooltips_Rival"),
	[Unit.CodeEnumRewardInfoType.Friend] 			= Apollo.GetString("Tooltips_Friend"),
	[Unit.CodeEnumRewardInfoType.ScientistSpell]	= Apollo.GetString("PlayerPathScientist"),
	[Unit.CodeEnumRewardInfoType.Contract]			= Apollo.GetString("Tooltips_Contract")
}

local karSigilTypeToIcon =
{
	[Item.CodeEnumRuneType.Air]		= { strUsed = "IconSprites:Icon_RuneSocket_Icon_Windows_UI_RuneSocket_Air_Used",	strEmpty = "IconSprites:Icon_RuneSocket_Icon_Windows_UI_RuneSocket_Air_Empty" },
	[Item.CodeEnumRuneType.Fire]	= { strUsed = "IconSprites:Icon_RuneSocket_Icon_Windows_UI_RuneSocket_Fire_Used",	strEmpty = "IconSprites:Icon_RuneSocket_Icon_Windows_UI_RuneSocket_Fire_Empty" },
	[Item.CodeEnumRuneType.Water]	= { strUsed = "IconSprites:Icon_RuneSocket_Icon_Windows_UI_RuneSocket_Water_Used",	strEmpty = "IconSprites:Icon_RuneSocket_Icon_Windows_UI_RuneSocket_Water_Empty" },
	[Item.CodeEnumRuneType.Earth]	= { strUsed = "IconSprites:Icon_RuneSocket_Icon_Windows_UI_RuneSocket_Earth_Used",	strEmpty = "IconSprites:Icon_RuneSocket_Icon_Windows_UI_RuneSocket_Earth_Empty" },
	[Item.CodeEnumRuneType.Logic]	= { strUsed = "IconSprites:Icon_RuneSocket_Icon_Windows_UI_RuneSocket_Logic_Used",	strEmpty = "IconSprites:Icon_RuneSocket_Icon_Windows_UI_RuneSocket_Logic_Empty" },
	[Item.CodeEnumRuneType.Life]	= { strUsed = "IconSprites:Icon_RuneSocket_Icon_Windows_UI_RuneSocket_Life_Used",	strEmpty = "IconSprites:Icon_RuneSocket_Icon_Windows_UI_RuneSocket_Life_Empty" },
	[Item.CodeEnumRuneType.Fusion]	= { strUsed = "IconSprites:Icon_RuneSocket_Icon_Windows_UI_RuneSocket_Fusion_Used",	strEmpty = "IconSprites:Icon_RuneSocket_Icon_Windows_UI_RuneSocket_Fusion_Empty" },
}

local karSigilTypeToString =
{
	[Item.CodeEnumRuneType.Air] 				= Apollo.GetString("CRB_Air"),
	[Item.CodeEnumRuneType.Water] 				= Apollo.GetString("CRB_Water"),
	[Item.CodeEnumRuneType.Earth] 				= Apollo.GetString("CRB_Earth"),
	[Item.CodeEnumRuneType.Fire] 				= Apollo.GetString("CRB_Fire"),
	[Item.CodeEnumRuneType.Logic] 				= Apollo.GetString("CRB_Logic"),
	[Item.CodeEnumRuneType.Life] 				= Apollo.GetString("CRB_Life"),
	[Item.CodeEnumRuneType.Fusion] 				= Apollo.GetString("CRB_Fusion"),
}

-- TODO REFACTOR, we can combine all these item quality tables into one
local karEvalColors =
{
	[Item.CodeEnumItemQuality.Inferior] 		= "ItemQuality_Inferior",
	[Item.CodeEnumItemQuality.Average] 			= "ItemQuality_Average",
	[Item.CodeEnumItemQuality.Good] 			= "ItemQuality_Good",
	[Item.CodeEnumItemQuality.Excellent] 		= "ItemQuality_Excellent",
	[Item.CodeEnumItemQuality.Superb] 			= "ItemQuality_Superb",
	[Item.CodeEnumItemQuality.Legendary] 		= "ItemQuality_Legendary",
	[Item.CodeEnumItemQuality.Artifact]		 	= "ItemQuality_Artifact",
}

local karEvalSprites =
{
	[Item.CodeEnumItemQuality.Inferior] 		= "sprTT_HeaderDarkGrey",
	[Item.CodeEnumItemQuality.Average] 			= "sprTT_HeaderWhite",
	[Item.CodeEnumItemQuality.Good] 			= "sprTT_HeaderGreen",
	[Item.CodeEnumItemQuality.Excellent] 		= "sprTT_HeaderBlue",
	[Item.CodeEnumItemQuality.Superb] 			= "sprTT_HeaderPurple",
	[Item.CodeEnumItemQuality.Legendary] 		= "sprTT_HeaderOrange",
	[Item.CodeEnumItemQuality.Artifact]		 	= "sprTT_HeaderLightPurple",
}

local karEvalInsetSprites =
{
	[Item.CodeEnumItemQuality.Inferior] 		= "sprTT_HeaderInsetDarkGrey",
	[Item.CodeEnumItemQuality.Average] 			= "sprTT_HeaderInsetWhite",
	[Item.CodeEnumItemQuality.Good] 			= "sprTT_HeaderInsetGreen",
	[Item.CodeEnumItemQuality.Excellent] 		= "sprTT_HeaderInsetBlue",
	[Item.CodeEnumItemQuality.Superb] 			= "sprTT_HeaderInsetPurple",
	[Item.CodeEnumItemQuality.Legendary] 		= "sprTT_HeaderOrange",
	[Item.CodeEnumItemQuality.Artifact]		 	= "sprTT_HeaderInsetLightPurple"
}

local karEvalStrings =
{
	[Item.CodeEnumItemQuality.Inferior] 		= Apollo.GetString("CRB_Inferior"),
	[Item.CodeEnumItemQuality.Average] 			= Apollo.GetString("CRB_Average"),
	[Item.CodeEnumItemQuality.Good] 			= Apollo.GetString("CRB_Good"),
	[Item.CodeEnumItemQuality.Excellent] 		= Apollo.GetString("CRB_Excellent"),
	[Item.CodeEnumItemQuality.Superb] 			= Apollo.GetString("CRB_Superb"),
	[Item.CodeEnumItemQuality.Legendary] 		= Apollo.GetString("CRB_Legendary"),
	[Item.CodeEnumItemQuality.Artifact]		 	= Apollo.GetString("CRB_Artifact")
}

local karItemQualityToHeaderBG =
{
	[Item.CodeEnumItemQuality.Inferior] 		= "CRB_Tooltips:sprTooltip_Header_Silver",
	[Item.CodeEnumItemQuality.Average] 			= "CRB_Tooltips:sprTooltip_Header_White",
	[Item.CodeEnumItemQuality.Good] 			= "CRB_Tooltips:sprTooltip_Header_Green",
	[Item.CodeEnumItemQuality.Excellent] 		= "CRB_Tooltips:sprTooltip_Header_Blue",
	[Item.CodeEnumItemQuality.Superb] 			= "CRB_Tooltips:sprTooltip_Header_Purple",
	[Item.CodeEnumItemQuality.Legendary] 		= "CRB_Tooltips:sprTooltip_Header_Orange",
	[Item.CodeEnumItemQuality.Artifact]		 	= "CRB_Tooltips:sprTooltip_Header_Pink",
}

local karItemQualityToHeaderBar =
{
	[Item.CodeEnumItemQuality.Inferior] 		= "CRB_Tooltips:sprTooltip_RarityBar_Silver",
	[Item.CodeEnumItemQuality.Average] 			= "CRB_Tooltips:sprTooltip_RarityBar_White",
	[Item.CodeEnumItemQuality.Good] 			= "CRB_Tooltips:sprTooltip_RarityBar_Green",
	[Item.CodeEnumItemQuality.Excellent] 		= "CRB_Tooltips:sprTooltip_RarityBar_Blue",
	[Item.CodeEnumItemQuality.Superb] 			= "CRB_Tooltips:sprTooltip_RarityBar_Purple",
	[Item.CodeEnumItemQuality.Legendary] 		= "CRB_Tooltips:sprTooltip_RarityBar_Orange",
	[Item.CodeEnumItemQuality.Artifact]		 	= "CRB_Tooltips:sprTooltip_RarityBar_Pink",
}

local karItemQualityToBorderFrameBG =
{
	[Item.CodeEnumItemQuality.Inferior] 		= "CRB_Tooltips:sprTooltip_SquareFrame_Silver",
	[Item.CodeEnumItemQuality.Average] 			= "CRB_Tooltips:sprTooltip_SquareFrame_White",
	[Item.CodeEnumItemQuality.Good] 			= "CRB_Tooltips:sprTooltip_SquareFrame_Green",
	[Item.CodeEnumItemQuality.Excellent] 		= "CRB_Tooltips:sprTooltip_SquareFrame_Blue",
	[Item.CodeEnumItemQuality.Superb] 			= "CRB_Tooltips:sprTooltip_SquareFrame_Purple",
	[Item.CodeEnumItemQuality.Legendary] 		= "CRB_Tooltips:sprTooltip_SquareFrame_Orange",
	[Item.CodeEnumItemQuality.Artifact]		 	= "CRB_Tooltips:sprTooltip_SquareFrame_Pink",
}

local ktRankToString = {
	[Unit.CodeEnumRank.Elite] = {strLocText = Apollo.GetString("TargetFrame_Prime")},
	[Unit.CodeEnumRank.Superior] = {strLocText = Apollo.GetString("Tooltips_Superior")},
	[Unit.CodeEnumRank.Champion] = {strLocText = Apollo.GetString("CreatureRankTitle_Champion")},
	[Unit.CodeEnumRank.Standard] = {strLocText = Apollo.GetString("CreatureElitenessTitle_Standard")},
	[Unit.CodeEnumRank.Minion] = {strLocText = Apollo.GetString("CreatureRankTitle_Minion")},
	[Unit.CodeEnumRank.Fodder] = {strLocText = Apollo.GetString("TargetFrame_Fodder")},
}

local ktRiskToIcon = {
	[Unit.CreatureRisk.Minor] = {strWnd = "CreatureRisk_Low"},
	[Unit.CreatureRisk.Average] = {strWnd = "CreatureRisk_Medium"},
	[Unit.CreatureRisk.Major] = {strWnd = "CreatureRisk_High"},
}

local strleftbrace		= string.format("<T TextColor=\"%s\">%s</T>", kUIBody, "[")			
local strrightbrace		= string.format("<T TextColor=\"%s\">%s</T>", kUIBody, "]")
local strplussign		= string.format("<T TextColor=\"%s\">%s</T>", kUIBody, "+")
local strequalsign		= string.format("<T TextColor=\"%s\">%s</T>", kUIBody, "=")

local kcrGroupTextColor					= ApolloColor.new("BlizzardBlue")
local kcrFlaggedFriendlyTextColor 		= karDispositionColors[Unit.CodeEnumDisposition.Friendly]
local kcrDefaultUnflaggedAllyTextColor 	= karDispositionColors[Unit.CodeEnumDisposition.Friendly]
local kcrAggressiveEnemyTextColor 		= karDispositionColors[Unit.CodeEnumDisposition.Neutral]
local kcrNeutralEnemyTextColor 			= ApolloColor.new("DispositionNeutral")


local tDefaultSettings = {
	MergeRunes		= false,
	GearColor		= kUIBody,
	RuneColor		= "Green",
	TotalColor		= "Cyan",
}
local MergeRunes = "MergeRunes"
local GearColor = "GearColor"
local RuneColor = "RuneColor"
local TotalColor = "TotalColor"
local bisDefaulting = false

local tSettings

local tVitals = {}

local knWndHeightBuffer
local knWndHeightPadding_Spell = 24

function TaviTooltips:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	o.timerGeneral = nil
	o.tTimedWindows = {}

	o.tRealmNamePendingCallbacks = {}

	return o
end

function TaviTooltips:Init()
	Apollo.RegisterAddon(self)
end

function TaviTooltips:OnRestore(eLevel, tData)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Account then return end
	if tData then
		tSettings = tData
	end
end

function TaviTooltips:OnSave(eLevel)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Account then return end
	local tData = TableUtil:Copy(tSettings)	
	return tData
end

function TaviTooltips:OnLoad()
    self.xmlDoc = XmlDoc.CreateFromFile("TooltipsForms.xml")
    self.xmlDoc:RegisterCallback("OnDocumentReady", self)
end

function TaviTooltips:OnOptionChanged( wndHandler, wndControl, strText )
	local option = wndHandler:GetName()
	if option == nil then return end
	
	wndHandler:SetTextColor(strText)
	tSettings[option] = wndHandler:GetText()

end

function TaviTooltips:OnCheckbox( wndHandler, wndControl, eMouseButton )
	local option = wndHandler:GetName()
	if option == nil then return end
	
	tSettings[option] = wndHandler:IsChecked()

end

function TaviTooltips:OnSlashCommand()
	self.wndSettings:FindChild("MergeRunes"):SetCheck(tSettings.MergeRunes)
	self.wndSettings:FindChild("GearColor"):SetText(tSettings.GearColor)
	self.wndSettings:FindChild("GearColor"):SetTextColor(tSettings.GearColor)
	self.wndSettings:FindChild("RuneColor"):SetText(tSettings.RuneColor)
	self.wndSettings:FindChild("RuneColor"):SetTextColor(tSettings.RuneColor)
	self.wndSettings:FindChild("TotalColor"):SetText(tSettings.TotalColor)
	self.wndSettings:FindChild("TotalColor"):SetTextColor(tSettings.TotalColor)
	
	if bisDefaulting then
		bisDefaulting = false
		return
	end
	if not self.wndSettings:IsShown() then
		self.wndSettings:Show(true)
	else
		self.wndSettings:Show(false)
	end
end	


function TaviTooltips:OnDocumentReady()
    if self.xmlDoc == nil then
        return
    end

	if tSettings == nil then
		tSettings = tDefaultSettings
	end
	
	self.SavedStats = {}
	tVitals = Unit.GetVitalTable()


	Apollo.RegisterEventHandler("PlayerChanged", "OnUpdateVitals", self)
	Apollo.RegisterEventHandler("MatchEntered", "OnUpdateVitals", self)
	--Apollo.RegisterEventHandler("MouseOverUnitChanged", "OnMouseOverUnitChanged", self)
	Apollo.RegisterEventHandler("PlayerRealmName", "OnPlayerRealmName", self)
	Apollo.RegisterSlashCommand("tavitooltips", "OnSlashCommand", self)
	Apollo.RegisterSlashCommand("TaviTooltips", "OnSlashCommand", self)
	Apollo.RegisterSlashCommand("ttt", "OnSlashCommand", self)
	
	self.wndSettings = Apollo.LoadForm(self.xmlDoc, "SettingsForm", nil, self)

	local wndTooltip = Apollo.LoadForm(self.xmlDoc, "ItemTooltip_Base", nil, self)
	local wndTooltipItem = wndTooltip:FindChild("Items")

	knWndHeightBuffer = wndTooltip:GetHeight() - wndTooltipItem:GetHeight()

	wndTooltip:Destroy()
	wndTooltipItem:Destroy()

	self.timerGeneral = ApolloTimer.Create(1.0, true, "OnTimer", self)
	self.timerGeneral:Stop()

	self:CreateCallNames()

	self.wndContainer = Apollo.LoadForm("TooltipsForms.xml", "WorldTooltipContainer", nil, self)
	GameLib.SetWorldTooltipContainer(self.wndContainer)
end


--GeminiHook things ... I don't know if half of this was even necessary, but at least it's not replacing Carbine's ToolTips, so compatability should be okay for dependancies

TaviTooltipsHook = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:NewAddon("TaviTooltipsHook", false, {}, "Gemini:Hook-1.0")

function TaviTooltipsHook:OnEnable()
  --self:RawHook(Apollo.GetAddon("ToolTips"),"OnGenerateWorldObjectTooltip")
  self:RawHook(Apollo.GetAddon("ToolTips"),"OnMouseOverUnitChanged")
  self:RawHook(Apollo.GetAddon("ToolTips"),"CreateCallNames")
  self:RawHook(Apollo.GetAddon("ToolTips"),"OnUpdateVitals")
 -- self:RawHook(Apollo.GetAddon("ToolTips"),"UnitTooltipGen")
  self:RawHook(Apollo.GetAddon("ToolTips"),"AddTimedWindow")
  self:RawHook(Apollo.GetAddon("ToolTips"),"OnTimer")
  self:RawHook(Apollo.GetAddon("ToolTips"),"OnPlayerRealmName")
end

function TaviTooltipsHook:OnGenerateWorldObjectTooltip( wndHandler, wndControl, eToolTipType, unit, strPropName )
	--self.hooks[Apollo.GetAddon("ToolTips")].OnGenerateWorldObjectTooltip( wndHandler, wndControl, eToolTipType, unit, strPropName )
	TaviTooltips:OnGenerateWorldObjectTooltip( wndHandler, wndControl, eToolTipType, unit, strPropName )
end
function TaviTooltipsHook:OnMouseOverUnitChanged(unit)
	--self.hooks[Apollo.GetAddon("ToolTips")].OnMouseOverUnitChanged(unit)
	TaviTooltips:OnMouseOverUnitChanged(unit)
end
function TaviTooltipsHook:CreateCallNames()
	self.hooks[Apollo.GetAddon("ToolTips")].CreateCallNames()
	TaviTooltips:CreateCallNames()
end
function TaviTooltipsHook:OnUpdateVitals()
	self.hooks[Apollo.GetAddon("ToolTips")].OnUpdateVitals()
	--TaviTooltips:OnUpdateVitals()
end
function TaviTooltipsHook:UnitTooltipGen(wndContainer, unitSource, strProp)
	--if strProp ~= "" then
		--self.hooks[Apollo.GetAddon("ToolTips")].UnitTooltipGen(wndContainer, unitSource, strProp)
	--else
		--TaviTooltips:UnitTooltipGen(wndContainer, unitSource, strProp)
	--end
end
function TaviTooltipsHook:AddTimedWindow(nStartValue, nStepValue, nStopValue, strDisplayFormat, wndTimed)
	self.hooks[Apollo.GetAddon("ToolTips")].AddTimedWindow(nStartValue, nStepValue, nStopValue, strDisplayFormat, wndTimed)
	--TaviTooltips:AddTimedWindow(nStartValue, nStepValue, nStopValue, strDisplayFormat, wndTimed)
end
function TaviTooltipsHook:OnTimer()
	self.hooks[Apollo.GetAddon("ToolTips")].OnTimer()
	--TaviTooltips:OnTimer()
end
function TaviTooltipsHook:OnPlayerRealmName(unit, strRealmName)
	self.hooks[Apollo.GetAddon("ToolTips")].OnPlayerRealmName(unit, strRealmName)
	--TaviTooltips:OnPlayerRealmName(unit, strRealmName)
end



function TaviTooltips:OnPlayerRealmName(unit, strRealmName)
	local tCallback = self.tRealmNamePendingCallbacks[unit:GetId()]
	if tCallback == nil then
		return
	end

	tCallback(strRealmName)

	self.tRealmNamePendingCallbacks[unit:GetId()] = nil
end

function TaviTooltips:OnTimer()
	for idx, tTimedWindow in pairs(self.tTimedWindows) do
		tTimedWindow.nValue = tTimedWindow.nValue - tTimedWindow.nStepValue
		if tTimedWindow.nStepValue > 0 then
			tTimedWindow.nValue = math.max(tTimedWindow.nValue, tTimedWindow.nStopValue)
		else
			tTimedWindow.nValue = math.min(tTimedWindow.nValue, tTimedWindow.nStopValue)
		end

		local bValidWindow = tTimedWindow.wndTimed ~= nil and tTimedWindow.wndTimed:IsValid()
		if bValidWindow then
			tTimedWindow.wndTimed:SetText(String_GetWeaselString(tTimedWindow.strDisplayFormat, tTimedWindow.nValue))
		end

		if not bValidWindow or tTimedWindow.nValue == tTimedWindow.nStopValue then
			table.remove(self.tTimedWindows, idx)
		end

		if #self.tTimedWindows == 0 then
			self.timerGeneral:Stop()
		end
	end
end

function TaviTooltips:AddTimedWindow(nStartValue, nStepValue, nStopValue, strDisplayFormat, wndTimed)
	if #self.tTimedWindows == 0 then
		self.timerGeneral:Start()
	end

	self.tTimedWindows[#self.tTimedWindows + 1] =
	{
		["nValue"] = nStartValue,
		["nStepValue"] = nStepValue,
		["nStopValue"] = nStopValue,
		["strDisplayFormat"] = strDisplayFormat,
		["wndTimed"] = wndTimed
	}
end

function TaviTooltips:GearCompareHelper(strProp, nvalue)
	if self.SavedStats[strProp] ~= nil then
		local returnvalue = nvalue - self.SavedStats[strProp]
		return returnvalue
	else
		self.SavedStats[strProp] = nvalue
		return false
	end
end
	
function TaviTooltips:ClearSave()
	self.SavedStats = {}
end


--Carbine's main tooltip mega-function


function TaviTooltips:UnitTooltipGen(wndContainer, unitSource, strProp)
	TaviTooltips.SavedStats = {}
	local wndTooltipForm = nil
	local bSkipFormatting = false -- used to identify when we switch to item tooltips (aka pinata loot)
	local bNoDisposition = false -- used to replace dispostion assets when they're not needed
	local bHideFormSecondary = true

	if not unitSource and strProp == "" then -- invalid
		wndContainer:SetTooltipForm(nil)
		wndContainer:SetTooltipFormSecondary(nil)
		return
	elseif strProp ~= "" then -- prop tooltip
		if not self.wndPropTooltip or not self.wndPropTooltip:IsValid() then
			self.wndPropTooltip = wndContainer:LoadTooltipForm("ui\\Tooltips\\TooltipsForms.xml", "PropTooltip_Base", self)
		end
		self.wndPropTooltip:FindChild("NameString"):SetText(strProp)

		local tMouse = Apollo.GetMouse()
		Apollo.SetNavTextAnchor(tMouse.x + 10, true, tMouse.y + 10, false)

		wndContainer:SetTooltipForm(self.wndPropTooltip)
		wndContainer:SetTooltipFormSecondary(nil)
		return
	end

	-- Unit Tooltips
	local tDisplay = Apollo.GetDisplaySize()
	if tDisplay and tDisplay.nHeight then
		Apollo.SetNavTextAnchor(10, true, tDisplay.nHeight - 332, false)
	end

	if not self.wndUnitTooltip or not self.wndUnitTooltip:IsValid() then
		self.wndUnitTooltip = wndContainer:LoadTooltipForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Base", self)
	end

	local wndTopDataBlock 			= self.wndUnitTooltip:FindChild("TopDataBlock")
	local wndMiddleDataBlock 		= self.wndUnitTooltip:FindChild("MiddleDataBlock") -- THIS GETS USED FOR A LOT!!
	local wndTargetClassBlock 		= self.wndUnitTooltip:FindChild("TargetClassBlock")
	local wndBottomDataBlock 		= self.wndUnitTooltip:FindChild("BottomDataBlock")
	local wndTopRight				= wndTopDataBlock:FindChild("RightSide")
	local wndMiddleDataBlockContent = wndMiddleDataBlock:FindChild("MiddleDataBlockContent")
	local wndTargetClassBlockContent = wndTargetClassBlock:FindChild("TargetClassBlockContent")
	local wndPathIcon 				= wndTopRight:FindChild("PathIcon")
	local wndClassIcon 				= wndTopRight:FindChild("ClassIcon")
	local wndClassBack 				= wndTopRight:FindChild("ClassBack")
	local wndPathBack 				= wndTopRight:FindChild("PathBack")
	local wndBreakdownString 		= wndBottomDataBlock:FindChild("BreakdownString")
	local wndUpsellIcon				= wndBreakdownString:FindChild("UpsellIcon")
	local wndRank					= wndTargetClassBlock:FindChild("Rank")
	local wndDispositionFrame 		= self.wndUnitTooltip:FindChild("DispositionArtFrame")
	local wndNameLevelString 		= wndTopDataBlock:FindChild("NameLevelString")
	local wndAffiliationString 		= self.wndUnitTooltip:FindChild("AffiliationString")

	local wndGroupBack 			= wndTopRight:FindChild("GroupBack")
	local wndGroupIcon 			= wndTopRight:FindChild("GroupIcon")

	wndGroupIcon:Show(false)
	wndGroupBack:Show(false)

	local unitPlayer = GameLib.GetPlayerUnit()
	local eDisposition = unitSource:GetDispositionTo(unitPlayer)

	local fullWndLeft, fullWndTop, fullWndRight, fullWndBottom = self.wndUnitTooltip:GetAnchorOffsets()
	local topBlockLeft, topBlockTop, topBlockRight, topBlockBottom = self.wndUnitTooltip:FindChild("TopDataBlock"):GetAnchorOffsets()

	-- Basics
	local bShownLevel = true
	wndDispositionFrame:SetSprite(karDispositionFrameSprites[eDisposition] or "")

	-- Unit to player affiliation
	local strAffiliationName = unitSource:GetAffiliationName() or ""
	wndAffiliationString:SetTextRaw(strAffiliationName)
	wndAffiliationString:Show(strAffiliationName ~= "")
	wndAffiliationString:SetTextColor(karDispositionColors[eDisposition])

	-- Reward info
	wndMiddleDataBlockContent:DestroyChildren()
	for idx, tRewardInfo in pairs(unitSource:GetRewardInfo() or {}) do
		local eRewardType = tRewardInfo.eType
		local bCanAddReward = true

		-- Only show active challenge rewards
		if eRewardType == Unit.CodeEnumRewardInfoType.Challenge then
			bCanAddReward = false
			for index, clgCurr in pairs(ChallengesLib.GetActiveChallengeList()) do
				if tRewardInfo.idChallenge == clgCurr:GetId() and clgCurr:IsActivated() and not clgCurr:IsInCooldown() then
					bCanAddReward = true
					break
				end
			end
		end

		if bCanAddReward and ktRewardToIcon[eRewardType] and ktRewardToString[eRewardType] then
			if eRewardType == Unit.CodeEnumRewardInfoType.PublicEvent then
				tRewardInfo.strTitle = tRewardInfo.peoObjective:GetEvent():GetName() or ""
			elseif eRewardType == Unit.CodeEnumRewardInfoType.Soldier or eRewardType == Unit.CodeEnumRewardInfoType.Explorer or eRewardType == Unit.CodeEnumRewardInfoType.Settler then
				tRewardInfo.strTitle = tRewardInfo.pmMission and tRewardInfo.pmMission:GetName() or ""
			elseif eRewardType == Unit.CodeEnumRewardInfoType.Scientist then
				if tRewardInfo.pmMission then
					if tRewardInfo.pmMission:GetMissionState() >= PathMission.PathMissionState_Unlocked then
						tRewardInfo.strTitle = tRewardInfo.pmMission:GetName()
					else
						tRewardInfo.strTitle = Apollo.GetString("TargetFrame_UnknownReward")
					end
				end
			end

			if tRewardInfo.strTitle and tRewardInfo.strTitle ~= "" then
				local wndReward = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Reward", wndMiddleDataBlockContent, self)
				wndReward:FindChild("Icon"):SetSprite(ktRewardToIcon[eRewardType])
				wndReward:FindChild("Label"):SetText(String_GetWeaselString(Apollo.GetString("Tooltip_TitleReward"), tRewardInfo.strTitle, ktRewardToString[eRewardType]))

				-- Adjust height to fit text
				wndReward:FindChild("Label"):SetHeightToContentHeight()
				if wndReward:FindChild("Label"):GetHeight() > wndReward:GetHeight() then
					local rewardWndLeft, rewardWndTop, rewardWndRight, rewardWndBottom = wndReward:GetAnchorOffsets()
					wndReward:SetAnchorOffsets(rewardWndLeft, rewardWndTop, rewardWndRight, wndReward:FindChild("Label"):GetHeight() + 3) -- +3 for decenders
				end
			end
		end
	end

	local bShowUpsellIcon = false
	local strUnitType = unitSource:GetType()
	if strUnitType == "Player" then

		-- Player
		local tSourceStats = unitSource:GetBasicStats()
		local ePathType = unitSource:GetPlayerPathType()
		local eClassType = unitSource:GetClassId()
		local bIsPvpFlagged = unitSource:IsPvpFlagged()

		wndPathIcon:SetSprite(ktPathToIcon[ePathType])
		wndClassIcon:SetSprite(ktClassToIcon[eClassType])

		-- Player specific affiliation override
		local strPlayerAffiliationName = unitSource:GetGuildName()
		if strPlayerAffiliationName then
			wndAffiliationString:SetTextRaw(String_GetWeaselString(Apollo.GetString("Nameplates_GuildDisplay"), strPlayerAffiliationName))
			wndAffiliationString:Show(true)
		end

		-- Player specific disposition color override
		local crColorToUse = karDispositionColors[eDisposition]
		if eDisposition == Unit.CodeEnumDisposition.Friendly then
			if unitSource:IsPvpFlagged() then
				crColorToUse = kcrFlaggedFriendlyTextColor
			elseif unitSource:IsInYourGroup() then
				crColorToUse = kcrGroupTextColor
			else
				crColorToUse = kcrDefaultUnflaggedAllyTextColor
			end
		else
			local bIsUnitFlagged = unitSource:IsPvpFlagged()
			local bAmIFlagged = GameLib.IsPvpFlagged()
			if not bAmIFlagged and not bIsUnitFlagged then
				crColorToUse = kcrNeutralEnemyTextColor
			elseif bAmIFlagged ~= bIsUnitFlagged then
				crColorToUse = kcrAggressiveEnemyTextColor
			end
		end
		wndNameLevelString:SetTextColor(crColorToUse)
		wndAffiliationString:SetTextColor(crColorToUse)

		-- Determine if Exile Human or Cassian
		local strRaceString = ""
		local nRaceID = unitSource:GetRaceId()
		local nFactionID = unitSource:GetFaction()
		if nRaceID == GameLib.CodeEnumRace.Human then
			if nFactionID == Unit.CodeEnumFaction.ExilesPlayer then
				strRaceString = Apollo.GetString("CRB_ExileHuman")
			elseif nFactionID == Unit.CodeEnumFaction.DominionPlayer then
				strRaceString = Apollo.GetString("CRB_Cassian")
			end
		else
			strRaceString = karRaceToString[nRaceID]
		end

		local strBreakdown = String_GetWeaselString(Apollo.GetString("Tooltip_CharacterDescription"), tSourceStats.nLevel, strRaceString)
		if tSourceStats.nEffectiveLevel ~= 0 and unitSource:IsMentoring() then -- GOTCHA: Intentionally we don't care about IsRallied()
			strBreakdown = String_GetWeaselString(Apollo.GetString("Tooltips_MentoringAppend"), strBreakdown, tSourceStats.nEffectiveLevel)
		end
		if bIsPvpFlagged then
			strBreakdown = String_GetWeaselString(Apollo.GetString("Tooltips_PvpFlagged"), strBreakdown)
		end
		wndBreakdownString:SetText(strBreakdown)

		-- Friend or Rival
		if unitSource:IsFriend() then
			local wndReward = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Reward", wndMiddleDataBlockContent, self)
			wndReward:FindChild("Icon"):SetSprite(ktRewardToIcon[Unit.CodeEnumRewardInfoType.Friend])
			wndReward:FindChild("Label"):SetText(ktRewardToString[Unit.CodeEnumRewardInfoType.Friend])
			wndMiddleDataBlockContent:Show(true)
		end

		if unitSource:IsRival() then
			local wndReward = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Reward", wndMiddleDataBlockContent, self)
			wndReward:FindChild("Icon"):SetSprite(ktRewardToIcon[Unit.CodeEnumRewardInfoType.Rival])
			wndReward:FindChild("Label"):SetText(ktRewardToString[Unit.CodeEnumRewardInfoType.Rival])
			wndMiddleDataBlockContent:Show(true)
		end

		local wndInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
		wndInfo:FindChild("Label"):SetText(Apollo.GetString("Tooltips_RealmUnknown"))
		self.tRealmNamePendingCallbacks[unitSource:GetId()] = function(strRealmName)
			if wndInfo:IsValid() then
				wndInfo:FindChild("Label"):SetText(String_GetWeaselString(Apollo.GetString("Tooltips_RealmFrom"), strRealmName))
			end
		end
		unitSource:RequestRealmName()

		wndMiddleDataBlockContent:Show(true)

		wndBottomDataBlock:Show(true)
		wndPathIcon:Show(true)
		wndClassIcon:Show(true)
		wndTargetClassBlock:Show(false)
		wndBreakdownString:Show(true)

	elseif karNPCDispositionUnitTypes[strUnitType] then
		bShowUpsellIcon = unitSource:IsInstanceLockbox();
		if bShowUpsellIcon then -- If this is an Last Chance chest, display description for opening requirements
			wndBreakdownString:SetText(String_GetWeaselString(Apollo.GetString("InstanceLockbox_RequiresKey")))
		else -- else display rank
			wndBreakdownString:SetText(ktRankDescriptions[unitSource:GetRank()] or "")
		end

		-- Settler improvement
		if unitSource:IsSettlerImprovement() then
			if unitSource:IsSettlerReward() then
				local strSettlerRewardName = String_GetWeaselString(Apollo.GetString("Tooltips_SettlerReward"), unitSource:GetSettlerRewardName(), Apollo.GetString("CRB_Settler_Reward"))
				local wndInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
				wndInfo:FindChild("Label"):SetText(strSettlerRewardName)
			else
				local tSettlerImprovementInfo = unitSource:GetSettlerImprovementInfo()

				for idx, strOwnerName in pairs(tSettlerImprovementInfo.arOwnerNames) do
					local wndInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
					wndInfo:FindChild("Label"):SetText(Apollo.GetString("Tooltips_GetSettlerDepot")..strOwnerName)
				end

				if not tSettlerImprovementInfo.bIsInfiniteDuration then
					local strSettlerTimeRemaining = String_GetWeaselString(Apollo.GetString("CRB_Remaining_Time_Format"), tSettlerImprovementInfo.nRemainingTime)
					local wndInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
					wndInfo:FindChild("Label"):SetText(strSettlerTimeRemaining)
					self:AddTimedWindow(tSettlerImprovementInfo.nRemainingTime, 1, 0, Apollo.GetString("CRB_Remaining_Time_Format"), wndInfo:FindChild("Label"))
				end

				for idx, tTier in pairs(tSettlerImprovementInfo.arTiers) do
					local wndInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
					wndInfo:FindChild("Label"):SetText(String_GetWeaselString(Apollo.GetString("Tooltips_SettlerTier"), tTier.nTier, tTier.strName))
				end
			end
		end

		-- Friendly Warplot structure
		if unitSource:IsFriendlyWarplotStructure() then
			local strCurrentTier = String_GetWeaselString(Apollo.GetString("CRB_WarplotPlugTier"), unitSource:GetCurrentWarplotTier())
			local wndCurrentTier = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
			wndCurrentTier:FindChild("Label"):SetText(strCurrentTier)
			if unitSource:CanUpgradeWarplotStructure() then
				local strCurrentCost = String_GetWeaselString(Apollo.GetString("CRB_WarplotPlugUpgradeCost"), unitSource:GetCurrentWarplotUpgradeCost())
				local wndCurrentCost = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
				wndCurrentCost:FindChild("Label"):SetText(strCurrentCost)
			end
		end

		wndBottomDataBlock:Show(true)
		wndPathIcon:Show(false)
		wndClassIcon:Show(false)
		wndTargetClassBlock:Show(eDisposition == Unit.CodeEnumDisposition.Hostile or eDisposition == Unit.CodeEnumDisposition.Neutral)
		wndBreakdownString:Show(unitSource:ShouldShowNamePlate())

	elseif karSimpleDispositionUnitTypes[strUnitType] then

		-- Simple
		bNoDisposition = true

		wndBottomDataBlock:Show(false)
		wndPathIcon:Show(false)
		wndClassIcon:Show(false)
		wndTargetClassBlock:Show(false)
		wndBreakdownString:Show(false)

	elseif strUnitType == "InstancePortal" then
		-- Instance Portal
		bNoDisposition = true

		local tLevelRange = unitSource:GetInstancePortalLevelRange()
		if tLevelRange and tLevelRange.nMinLevel and tLevelRange.nMaxLevel then
			local strInstancePortalLevelRange = ""
			if tLevelRange.nMinLevel == tLevelRange.nMaxLevel then
				strInstancePortalLevelRange = String_GetWeaselString(Apollo.GetString("InstancePortal_RequiredLevel"), tLevelRange.nMaxLevel)
			else
				strInstancePortalLevelRange = String_GetWeaselString(Apollo.GetString("InstancePortal_LevelRange"), tLevelRange.nMinLevel, tLevelRange.nMaxLevel)
			end
			local wndInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
			wndInfo:FindChild("Label"):SetText(strInstancePortalLevelRange)
		end

		local nPortalCompletionTime = unitSource:GetInstancePortalCompletionTime()
		if nPortalCompletionTime then
			local strInstanceCompletionTime = String_GetWeaselString(Apollo.GetString("InstancePortal_ExpectedCompletionTime"), nPortalCompletionTime)
			local wndInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
			wndInfo:FindChild("Label"):SetText(strInstanceCompletionTime)
		end

		local nPortalRemainingTime = unitSource:GetInstancePortalRemainingTime()
		if nPortalRemainingTime and nPortalRemainingTime > 0 then
			local strInstancePortalRemainingTime = String_GetWeaselString(Apollo.GetString("CRB_Remaining_Time_Format"), nPortalRemainingTime)
			local wndInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Info", wndMiddleDataBlockContent, self)
			wndInfo:FindChild("Label"):SetText(strInstancePortalRemainingTime)

			self:AddTimedWindow(nPortalRemainingTime, 1, 0, Apollo.GetString("CRB_Remaining_Time_Format"), wndInfo:FindChild("Label"))
		end

		wndBottomDataBlock:Show(false)
		wndPathIcon:Show(false)
		wndClassIcon:Show(false)
		bShownLevel = false
		wndTargetClassBlock:Show(false)
		wndBreakdownString:Show(false)

	elseif strUnitType == "Harvest" then
		-- Harvestable
		bNoDisposition = true

		local strHarvestRequiredTradeskillName = unitSource:GetHarvestRequiredTradeskillName()

		if strHarvestRequiredTradeskillName and strHarvestRequiredTradeskillName ~= "" then
			wndBreakdownString:SetText(String_GetWeaselString(Apollo.GetString("CRB_Requires_Tradeskill_Tier"), strHarvestRequiredTradeskillName, unitSource:GetHarvestRequiredTradeskillTier() or 1))

			wndBottomDataBlock:Show(true)
			bShownLevel = false
			wndBreakdownString:Show(true)
		else
			wndBottomDataBlock:Show(false)
			bShownLevel = true
			wndBreakdownString:Show(false)
		end

		wndPathIcon:Show(false)
		wndClassIcon:Show(false)
		wndTargetClassBlock:Show(false)

	elseif strUnitType == "PinataLoot" then
		local tLoot = unitSource:GetLoot()
		if tLoot then
			bNoDisposition = true

			if tLoot.eLootItemType == Unit.CodeEnumLootItemType.StaticItem then
				bHideFormSecondary = false
				local itemEquipped = tLoot.itemLoot:GetEquippedItemForItemType()
				local tTooltipData = {bPrimary = true, itemCompare = itemEquipped, itemModData = tLoot.itemModData, tGlyphData = tLoot.itemSigilData}

				-- Overwrite everything and show itemLoot tooltip instead
				wndTooltipForm = Tooltip.GetItemTooltipForm(self, wndContainer, tLoot.itemLoot, tTooltipData)
				bSkipFormatting = true
			elseif tLoot.eLootItemType == Unit.CodeEnumLootItemType.Cash then
				local wndCash = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Cash", wndMiddleDataBlockContent, self)
				wndCash:FindChild("CashWindow"):SetAmount(tLoot.monCurrency, true)

			elseif tLoot.eLootItemType == Unit.CodeEnumLootItemType.VirtualItem then
				local wndLoot = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_PinataLoot", wndMiddleDataBlockContent, self)
				local wndLootLeft, wndLootTop, wndLootRight, wndLootBottom = wndLoot:GetAnchorOffsets()

				wndLoot:FindChild("TextWindow"):SetText(tLoot.tVirtualItem.strFlavor)
				wndLoot:FindChild("TextWindow"):SetHeightToContentHeight()
				wndLoot:SetAnchorOffsets( wndLootLeft, wndLootTop, wndLootRight, math.max(wndLootBottom, wndLoot:FindChild("TextWindow"):GetHeight()))

			elseif tLoot.eLootItemType == Unit.CodeEnumLootItemType.AdventureSpell then
				local wndLoot = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_PinataLoot", wndMiddleDataBlockContent, self)
				local wndLootLeft, wndLootTop, wndLootRight, wndLootBottom = wndLoot:GetAnchorOffsets()

				wndLoot:FindChild("TextWindow"):SetText(tLoot.tAbility.strDescription)
				wndLoot:FindChild("TextWindow"):SetHeightToContentHeight()
				wndLoot:SetAnchorOffsets( wndLootLeft, wndLootTop, wndLootRight, math.max(wndLootBottom, wndLoot:FindChild("TextWindow"):GetHeight()))
			elseif tLoot.eLootItemType == Unit.CodeEnumLootItemType.AccountItem then
				if tLoot.tAccountItem.item then
					bHideFormSecondary = false
					local itemEquipped = tLoot.tAccountItem.item:GetEquippedItemForItemType()
					local tTooltipData = {bPrimary = true, itemCompare = itemEquipped, itemModData = tLoot.itemModData, tGlyphData = tLoot.itemSigilData}

					-- Overwrite everything and show item tooltip instead
					wndTooltipForm = Tooltip.GetItemTooltipForm(self, wndContainer, tLoot.tAccountItem.item, tTooltipData)
					bSkipFormatting = true
				elseif tLoot.tAccountItem.entitlement then
					local wndLoot = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_PinataLoot", wndMiddleDataBlockContent, self)
					local wndLootLeft, wndLootTop, wndLootRight, wndLootBottom = wndLoot:GetAnchorOffsets()

					wndLoot:FindChild("TextWindow"):SetText(tLoot.tAccountItem.entitlement.description)
					wndLoot:FindChild("TextWindow"):SetHeightToContentHeight()
					wndLoot:SetAnchorOffsets( wndLootLeft, wndLootTop, wndLootRight, math.max(wndLootBottom, wndLoot:FindChild("TextWindow"):GetHeight()))
				elseif tLoot.tAccountItem.monCurrency then
					local wndCash = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "UnitTooltip_Cash", wndMiddleDataBlockContent, self)
					wndCash:FindChild("CashWindow"):SetAmount(tLoot.tAccountItem.monCurrency, true)
				end
			end
		end

		wndBottomDataBlock:Show(false)
		wndPathIcon:Show(false)
		wndClassIcon:Show(false)
		bShownLevel = false
		wndTargetClassBlock:Show(false)
		wndBreakdownString:Show(false)

	else -- error state, do name only
		bNoDisposition = true

		wndBottomDataBlock:Show(false)
		wndPathIcon:Show(false)
		wndClassIcon:Show(false)
		wndTargetClassBlock:Show(false)
		wndBreakdownString:Show(false)
	end
	wndUpsellIcon:Show(bShowUpsellIcon);

	if wndTargetClassBlock:IsShown() then
		local nGroupValue = unitSource:GetGroupValue()
		if nGroupValue and nGroupValue > 1 then --If this creature requires more then the player character to kill.
			wndGroupIcon:Show(true)
			wndGroupIcon:SetText(nGroupValue)
		end

		wndBreakdownString:Show(false)

		for idx, wndIcon in pairs(wndTargetClassBlockContent:GetChildren() or {}) do
			wndIcon:SetBGColor(ApolloColor.new("UI_AlphaPercent25"))
		end

		local tRankInfo = ktRankToString[unitSource:GetRank()]
		local nCreatureRisk = unitSource:GetCreatureRisk()
		if nCreatureRisk and tRankInfo then
			wndTargetClassBlockContent:FindChild(ktRiskToIcon[nCreatureRisk].strWnd):SetBGColor(ApolloColor.new("UI_AlphaPercent100"))
			wndRank:SetText(tRankInfo.strLocText)
		end
	end

	local strColor = karDispositionColorStrings[eDisposition]
	local strNameLevel = ""
	local nUnitLevel = unitSource:GetLevel()
	if bShownLevel and  nUnitLevel then
		strNameLevel = string.format("<P Font=\"CRB_HeaderSmall\" TextColor=\"%s\">%s</P><P Font=\"CRB_Header10\" TextColor=\"%s\">%s</P>", strColor, unitSource:GetName(), strColor, String_GetWeaselString(Apollo.GetString("Tradeskills_Level"), nUnitLevel))
	else
		strNameLevel = string.format("<P Font=\"CRB_HeaderSmall\" TextColor=\"%s\">%s</P>", strColor, unitSource:GetName())
	end

	wndNameLevelString:SetText(strNameLevel)
	-- formatting and resizing --
	if not bSkipFormatting then
		if bNoDisposition then
			wndNameLevelString:SetTextColor(ApolloColor.new("UI_TextHoloBodyHighlight"))
			wndDispositionFrame:SetSprite("sprTooltip_SquareFrame_UnitTeal")
		end

		wndClassBack:Show(wndClassIcon:IsShown())
		wndPathBack:Show(wndPathIcon:IsShown())
		wndGroupBack:Show(wndGroupIcon:IsShown())

		-- Right anchor of name
		local nNameLeft, nNameTop, nNameRight, nNameBottom = wndNameLevelString:GetAnchorOffsets()
		if wndPathIcon:IsShown() then
			local nPathLeft, nPathTop, nPathRight,nPathBottom = wndPathBack:GetAnchorOffsets()
			wndNameLevelString:SetAnchorOffsets(nNameLeft, nNameTop, nPathLeft - wndPathIcon:GetWidth(), nNameBottom)
		elseif wndClassIcon:IsShown() then
			local nClassLeft, nClassTop, nClassRight, nClassBottom = wndClassBack:GetAnchorOffsets()
			wndNameLevelString:SetAnchorOffsets(nNameLeft, nNameTop, nClass - wndClassBack:GetWidth(), nNameBottom)
		elseif wndGroupIcon:IsShown() then
			local nGroupLeft, nGroupTop, nGroupRight, nGroupBottom = wndGroupIcon:GetAnchorOffsets()
			wndNameLevelString:SetAnchorOffsets(nNameLeft, nNameTop, nGroupLeft - wndGroupIcon:GetWidth(), nNameBottom)
		end

		-- Vertical Height
		local nHeight = wndTopDataBlock:GetHeight()
		
		local nNameWidth, nNameHeight = wndNameLevelString:SetHeightToContentHeight()
		local nOrigNameLeft, nOrigNameTop, nOrigNameRight, nOrigNameBottom = wndNameLevelString:GetOriginalLocation():GetOffsets()
		local nOrigHeight = nOrigNameBottom - nOrigNameTop
		nNameHeight = math.max(nNameHeight, nOrigHeight)
		local nTopDataBlockLeft, nTopDataBlockTop, nTopDataBlockRight, nTopDataBlockBottom = wndTopDataBlock:GetAnchorOffsets()
		wndTopDataBlock:SetAnchorOffsets(nTopDataBlockLeft, nTopDataBlockTop, nTopDataBlockRight, nTopDataBlockTop + math.max(nOrigHeight, nNameTop + nNameHeight))
		
		local nTopDataBlockDiff = nNameHeight - nOrigHeight

		local nAffiliationHeight = 0

		if wndAffiliationString:IsShown() then
			local nLeft, nTop, nRight, nBottom = wndAffiliationString:GetAnchorOffsets()
			nAffiliationHeight = wndAffiliationString:GetHeight()
			local nAffiliationBottom = nHeight + nAffiliationHeight
			wndAffiliationString:SetAnchorOffsets(nLeft, nHeight, nRight, nAffiliationBottom)

			local nLeft, nTop, nRight, nBottom = wndMiddleDataBlock:GetAnchorOffsets()
			wndMiddleDataBlock:SetAnchorOffsets(nLeft, nAffiliationBottom, nRight, nAffiliationBottom + wndMiddleDataBlock:GetHeight())

			nHeight = nHeight + wndAffiliationString:GetHeight()
		else
			local nLeft, nTop, nRight, nBottom = wndMiddleDataBlock:GetAnchorOffsets()
			wndMiddleDataBlock:SetAnchorOffsets(nLeft, nHeight, nRight, nBottom)

			local nTargHeight = wndTargetClassBlock:GetHeight()
			nLeft, nTop, nRight, nBottom = wndTargetClassBlock:GetAnchorOffsets()
			wndTargetClassBlock:SetAnchorOffsets(nLeft, nNameBottom, nRight, nNameBottom + nTargHeight)
		end

		local nBlockHeight = 0

		-- Size middle block
		local bShowMiddleBlock = #wndMiddleDataBlockContent:GetChildren() > 0
		wndMiddleDataBlock:Show(bShowMiddleBlock)
		if bShowMiddleBlock then
			local nInnerHeight = wndMiddleDataBlockContent:ArrangeChildrenVert(Window.CodeEnumArrangeOrigin.LeftOrTop)
			nBlockHeight = nInnerHeight + knDataWindowPadding
			nHeight = nHeight + nBlockHeight * 2

			local nLeft, nTop, nRight, nBottom = wndMiddleDataBlockContent:GetAnchorOffsets()
			wndMiddleDataBlockContent:SetAnchorOffsets(nLeft, nTop, nRight, nTop + nInnerHeight)

			local nLeft, nTop, nRight, nBottom = wndMiddleDataBlock:GetAnchorOffsets()
			wndMiddleDataBlock:SetAnchorOffsets(nLeft, nTop, nRight, nTop + nBlockHeight)
		end

		-- Size Tooltip
		if wndTargetClassBlock:IsShown() then
			local nLeft, nTop, nRight, nBottom = wndTargetClassBlock:GetOriginalLocation():GetOffsets()
			nTop = nTop + nBlockHeight + nAffiliationHeight
			nBottom = nBottom + nBlockHeight + nAffiliationHeight
			wndTargetClassBlock:SetAnchorOffsets(nLeft, nTop + nTopDataBlockDiff, nRight, nBottom + nTopDataBlockDiff)
			nHeight = nHeight + wndTargetClassBlock:GetHeight()
		end

		if wndRank:IsShown() then
			nHeight = nHeight + wndRank:GetHeight()
		end

		if wndBreakdownString:IsShown() then
			local nLeft, nTop, nRight, nBottom = wndBottomDataBlock:GetOriginalLocation():GetOffsets()
			local nBreakdownStrWidth, nBreakdownStrHeight = wndBreakdownString:SetHeightToContentHeight()
			nHeight = nHeight + nBreakdownStrHeight
			wndBottomDataBlock:SetAnchorOffsets(nLeft, nBottom - nBreakdownStrHeight, nRight, nBottom)
		end

		self.wndUnitTooltip:SetAnchorOffsets(fullWndLeft, fullWndTop, fullWndRight, fullWndTop + nHeight)
	end

	if not wndTooltipForm then
		wndTooltipForm = self.wndUnitTooltip
	end

	self.unitTooltip = unitSource

	wndContainer:SetTooltipForm(wndTooltipForm)
	if bHideFormSecondary then
		wndContainer:SetTooltipFormSecondary(nil)
	end
end

------------------
-- Item Tooltip --
------------------

-- #############################
local tTotalStats = {}
local tRuneStats = {}
local function ItemTooltipHeaderHelper(wndParent, tItemInfo, itemSource, wndTooltip, tFlags)
	local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "ItemTooltip_Header", wndParent)
	local wndItemTooltip_HeaderBG = wnd:FindChild("ItemTooltip_HeaderBG")
	wndItemTooltip_HeaderBG:SetSprite(karItemQualityToHeaderBG[tItemInfo.eQuality])
	wndItemTooltip_HeaderBG:Show(not tFlags.bInvisibleFrame)
	wnd:FindChild("ItemTooltip_HeaderBar"):SetSprite(karItemQualityToHeaderBar[tItemInfo.eQuality])

	if tItemInfo.tProfRequirement and not tItemInfo.tProfRequirement.bRequirementMet then
		wnd:FindChild("ItemTooltip_Header_Types"):SetTextColor(kUIRed)
	else
		wnd:FindChild("ItemTooltip_Header_Types"):SetTextColor(karEvalColors[tItemInfo.eQuality])
	end

	local eRuneType = tItemInfo.tRuneInfo and tItemInfo.tRuneInfo.eType or 0
	local strName = eRuneType > 0 and string.format("%s (%s)", itemSource:GetItemTypeName(), String_GetWeaselString(Apollo.GetString("Tooltips_RuneSlot"), karSigilTypeToString[eRuneType])) or itemSource:GetItemTypeName()
	wnd:FindChild("ItemTooltip_Header_Types"):SetText(strName)
	wnd:FindChild("ItemTooltip_Header_Name"):SetAML("<P Font=\"CRB_HeaderSmall\" TextColor=\""..karEvalColors[tItemInfo.eQuality].."\">"..tItemInfo.strName.."</P>")

	local nWidth, nHeight = wnd:FindChild("ItemTooltip_Header_Name"):SetHeightToContentHeight()
	local nLeft, nTop, nRight, nBottom = wnd:GetAnchorOffsets()
	wnd:SetAnchorOffsets(nLeft, nTop, nRight, nTop + math.max(20, nHeight) + 63)
end

-- #############################

local function ItemTooltipBasicStatsHelperWindowBuilder(wndParent, strColor, strString)
	local wndCurItemBasicStats = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "ItemBasicStatsLine", wndParent)
	wndCurItemBasicStats:SetAML("<P Font=\"CRB_InterfaceSmall\" Align=\"Left\" TextColor=\"" .. strColor.. "\">" .. strString .. "</P>")
	wndCurItemBasicStats:SetHeightToContentHeight()
	return wndCurItemBasicStats
end

-- #############################

local function ItemTooltipBasicStatsHelper(wndParent, tItemInfo, itemSource)

	local bNeedLeftColumn = tItemInfo.nItemLevel or
	                        tItemInfo.tLevelRequirement or
							tItemInfo.arAllowedSlots or
	                        (tItemInfo.tStack and tItemInfo.tStack.nMaxCount ~= 1) or
	                        (tItemInfo.bPvpGear or tItemInfo.bPvpOnlyRune or tItemInfo.bPveOnlyRune) or
	                        (tItemInfo.nInstalledMinimumItemLevel or tItemInfo.nPowerCoreMaximumLevel or tItemInfo.nCraftedMultiplier) or
							tItemInfo.tBind.bSoulbound or tItemInfo.tBind.bOnEquip or tItemInfo.tBind.bOnPickup or itemSource:IsSalvagedLootSoulbound() or tItemInfo.tUnique
	
	if not bNeedLeftColumn then
		return
	end
	
	local wndBox = nil
	
	wndBox = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "ItemTooltip_BasicStatsBox", wndParent)
	
	local wndLeftColumn = nil
	
	--// LEFT COLUMN //--
	if bNeedLeftColumn then
		
		wndLeftColumn = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "ItemBasicStatsLine", wndBox)
		
		-- Item Level
		local nItemLevel = tItemInfo.nItemLevel
		if nItemLevel and nItemLevel > 0 then
			ItemTooltipBasicStatsHelperWindowBuilder(wndLeftColumn, kUIBody, String_GetWeaselString(Apollo.GetString("Tooltips_ItemLevel"), nItemLevel ))
		end
		
		-- Binding Messages
		local strBind = ""
		if tItemInfo.tBind and tItemInfo.tBind.bSoulbound then
			strBind = Apollo.GetString("CRB_Soulbound")
		elseif tItemInfo.tBind and tItemInfo.tBind.bOnPickup then
			strBind = Apollo.GetString("CRB_Bind_on_pickup")
		elseif itemSource:IsSalvagedLootSoulbound() then
			strBind = Apollo.GetString("CRB_Bind_on_pickup")
		elseif tItemInfo.tBind and tItemInfo.tBind.bOnEquip then
			strBind = Apollo.GetString("CRB_Bind_on_equip")
		end
		
		if strBind ~= "" then
			ItemTooltipBasicStatsHelperWindowBuilder(wndLeftColumn, kUIBody, strBind )
		end
		
		-- Unique
		if tItemInfo.tUnique then
			local strUniqueStr = ""
			if tItemInfo.tUnique.bUnique and tItemInfo.tUnique.nCount and tItemInfo.tUnique.nCount > 1 then
				strUniqueStr = String_GetWeaselString(Apollo.GetString("Tooltips_UniqueCount"), tItemInfo.tUnique.nCount)
			elseif tItemInfo.tUnique.bUnique then
				strUniqueStr = Apollo.GetString("CRB_Unique")
			elseif tItemInfo.tUnique.bEquipped then
				strUniqueStr = Apollo.GetString("Tooltips_UniqueEquipped")
			end
			
			if strUniqueStr ~= "" then
				ItemTooltipBasicStatsHelperWindowBuilder(wndLeftColumn, kUIBody, strUniqueStr )
			end
		end
		
		-- Level req (if important)
		local nPlayerLevel = GameLib.GetPlayerLevel()
		if tItemInfo.tLevelRequirement and tItemInfo.tBind and tItemInfo.tBind.bSoulbound and nPlayerLevel and nPlayerLevel > tItemInfo.tLevelRequirement.nLevelRequired then
			-- Omit intentionally
		elseif tItemInfo.tLevelRequirement then
			local strColor = tItemInfo.tLevelRequirement.bRequirementMet and kUIBody or kUIRed
			ItemTooltipBasicStatsHelperWindowBuilder(wndLeftColumn, strColor, String_GetWeaselString(Apollo.GetString("Tooltips_ReqLevel"), tItemInfo.tLevelRequirement.nLevelRequired))
		end
		
		-- PvP
		strPvp = ""
		if tItemInfo.bPvpGear then
			strPvp = String_GetWeaselString(Apollo.GetString("ItemTooltip_ItemTypePvP"))
		elseif tItemInfo.bPvpOnlyRune then
			strPvp = String_GetWeaselString(Apollo.GetString("ItemTooltip_ItemTypeReqPvP"))
		elseif tItemInfo.bPveOnlyRune then
			strPvp = String_GetWeaselString(Apollo.GetString("ItemTooltip_ItemTypeReqPvE"))
		end
		
		if strPvp ~= "" then
			ItemTooltipBasicStatsHelperWindowBuilder(wndLeftColumn, kUIBody, strPvp)
		end
	
		-- Stack Count
		if tItemInfo.tStack and tItemInfo.tStack.nMaxCount ~= 1 then
			local strStackCount = ""
			if tItemInfo.tStack.nCount then
				strStackCount = String_GetWeaselString(Apollo.GetString("Tooltips_StackCountLimited"), tItemInfo.tStack.nCount, tItemInfo.tStack.nMaxCount)
			else
				strStackCount = String_GetWeaselString(Apollo.GetString("Tooltips_StackCount"), tItemInfo.tStack.nMaxCount)
			end
			if strStackCount ~= "" then
				ItemTooltipBasicStatsHelperWindowBuilder(wndLeftColumn, kUIBody, strStackCount)
			end
		end
		
		-- Rune is unique per item, since it is part of a set
		if tItemInfo.tRuneSet then
			ItemTooltipBasicStatsHelperWindowBuilder(wndLeftColumn, kUIBody, Apollo.GetString("ItemTooltip_UniquePerItem"))
		end
		
		-- Item Slot
		if tItemInfo.arAllowedSlots then
			for idx, tAllowedSlot in pairs(tItemInfo.arAllowedSlots) do
				if tAllowedSlot.strName and tAllowedSlot.strName ~= "" then
					ItemTooltipBasicStatsHelperWindowBuilder(wndLeftColumn, kUIBody, String_GetWeaselString(Apollo.GetString("ItemTooltip_ItemRequiredSlot"), tAllowedSlot.strName))
				end
			end
		end
		
		-- Power Core and Crafting
		local strPowerCoreCraft = ""
		if tItemInfo.nInstalledMinimumItemLevel ~= nil and tItemInfo.nInstalledMinimumItemLevel > 1 then
			strPowerCoreCraft = String_GetWeaselString(Apollo.GetString("Tooltips_InstalledMinimumItemLevel"), tItemInfo.nInstalledMinimumItemLevel)
		end
	
		if tItemInfo.nPowerCoreMaximumLevel then
			strPowerCoreCraft = String_GetWeaselString(Apollo.GetString("Tooltips_PowerCoreMaximumLevel"), tItemInfo.nPowerCoreMaximumLevel)
		end
	
		if tItemInfo.nCraftedMultiplier then
			if tItemInfo.nCraftedMultiplier > 1 then
				local value = ((tItemInfo.nCraftedMultiplier * 100) - 100)
				strPowerCoreCraft = String_GetWeaselString(Apollo.GetString("Tooltips_CraftedMultiplierOver"), value )
			elseif tItemInfo.nCraftedMultiplier > 0 and tItemInfo.nCraftedMultiplier < 1 then
				local value = (100 - (tItemInfo.nCraftedMultiplier * 100))
				strPowerCoreCraft = String_GetWeaselString(Apollo.GetString("Tooltips_CraftedMultiplierUnder"), value )
			end
		end
		
		if strPowerCoreCraft ~= "" then
			ItemTooltipBasicStatsHelperWindowBuilder(wndLeftColumn, kUIBody, strPowerCoreCraft )
		end
	end
	
	--// FORMATTING //--
	
	local numHeightLeft = wndLeftColumn:ArrangeChildrenVert(Window.CodeEnumArrangeOrigin.Middle)

	local nLeft, nTop, nRight, nBottom
	
	nLeft, nTop, nRight, nBottom = wndLeftColumn:GetAnchorOffsets()
	wndLeftColumn:SetAnchorOffsets(nLeft, nTop, nRight, nTop + numHeightLeft)
			
	nLeft, nTop, nRight, nBottom = wndBox:GetAnchorOffsets()
	wndBox:SetAnchorOffsets(nLeft, nTop, nRight, nTop + numHeightLeft )

end

-- #############################

local function ItemTooltipClassReqHelper(wndParent, tItemInfo)
	if tItemInfo.tClassRequirement then
		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
		local strClasses = Apollo.GetString("Tooltips_ClassList")
		local strColor = tItemInfo.tClassRequirement.bRequirementMet and kUIGreen or kUIRed
		local strClassList = ""
		for idx, tCur in pairs (tItemInfo.tClassRequirement.arClasses) do
			if idx > 1 then
				strClassList = String_GetWeaselString(Apollo.GetString("Tooltips_ClassListItem"), strClassList, karClassToString[tItemInfo.tClassRequirement.arClasses[idx]])
			else
				strClassList = karClassToString[tItemInfo.tClassRequirement.arClasses[idx]]
			end
		end

		strClasses = String_GetWeaselString(strClasses, strClassList)

		wnd:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</P>", strColor, strClasses))
		wnd:SetHeightToContentHeight()
	end
end

-- #############################

local function ItemTooltipFactionReqHelper(wndParent, tItemInfo)
	if tItemInfo.tFactionRequirement then
		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
		local strFaction = String_GetWeaselString(Apollo.GetString("Tooltips_Faction"), tItemInfo.tFactionRequirement.strFactionName)
		local strColor = tItemInfo.tFactionRequirement.bRequirementMet and kUIGreen or kUIRed

		wnd:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</P>", strColor, strFaction))
		wnd:SetHeightToContentHeight()
	end
end

-- #############################

local function ItemTooltipSpellReqHelper(wndParent, tItemInfo)
	if tItemInfo.arSpells then
		for idx, tCur in pairs(tItemInfo.arSpells) do
			if tCur.strFailure then
				local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)

				wnd:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</P>", kUIRed, tCur.strFailure))
				wnd:SetHeightToContentHeight()
			end
		end
	end
end

-- #############################

local function ItemTooltipSpecialReqHelper(wndParent, tItemInfo)
	if tItemInfo.strSpecialFailures then
		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)

		wnd:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</P>", kUIRed, tItemInfo.strSpecialFailures))
		wnd:SetHeightToContentHeight()
	end
end

-- #############################

local function ItemTooltipAdditiveHelper(wndParent, tItemInfo)
	-- Additive Coordinate Effects
	if tItemInfo.tAdditive then
		local strCoordChange = String_GetWeaselString(Apollo.GetString("Tooltips_CoordChange"),tItemInfo.tAdditive.nVectorX, tItemInfo.tAdditive.nVectorY)
		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
		wnd:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</P>", kUIBody, strCoordChange))
		wnd:SetHeightToContentHeight()
	end
end

-- #############################

local function ItemTooltipSchematicHelper(wndParent, tItemInfo)
	-- Tradeskill Schematic Details
	if tItemInfo.arTradeskillReqs then
		for nIdx,tTradeskillReqs in pairs(tItemInfo.arTradeskillReqs) do
			if tTradeskillReqs then
				local strTradeskillDetails = String_GetWeaselString(Apollo.GetString("CRB_Requires_Tradeskill_Tier"), tTradeskillReqs.strName, tTradeskillReqs.eTier)
				local strColor = kUIRed

				if tTradeskillReqs.bIsKnown then
					strTradeskillDetails = Apollo.GetString("CRB_Schematic_Already_Known")
				elseif tTradeskillReqs.bCanLearn then
					strColor = kUIGreen
				end

				local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
				wnd:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</P>", strColor, strTradeskillDetails))
				wnd:SetHeightToContentHeight()
			end
		end
	end
end

-- #############################

local function ItemTooltipSeparatorDiagonalHelper(wndParent)
	if #wndParent:GetChildren() > 1 then -- Separator is skipped if it's the very first element
		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SeparatorDiagonal", wndParent)
	end
end

-- #############################

local function ItemTooltipSeparatorSmallLineHelper(wndParent)
	if #wndParent:GetChildren() > 1 then -- Separator is skipped if it's the very first element
		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SeparatorSmallLine", wndParent)
	end
end

-- #############################

local function ItemTooltipInnatePropHelper(wndParent, tSortedInnatePropList, bUseDiff) -- E.G. Assault Power, Support Power, Armor, Shield
	if tSortedInnatePropList and #tSortedInnatePropList > 0 then
		ItemTooltipSeparatorDiagonalHelper(wndParent) -- Diagonal separator is skipped if it's the very first element
	end

	for idx, tCur in pairs (tSortedInnatePropList) do
		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)

		local strLine = ""
		local nVal = tCur.nValue or 0
		local strProperty = Item.GetPropertyName(tCur.eProperty)

		if not tCur.nDiff or not bUseDiff then
			local strWeaselString = tCur.bPercentage and "Tooltips_StatEvenFloatPercent" or tCur.bSeconds and "Tooltips_StatEvenFloatSec" or "Tooltips_StatEven"
			strLine = String_GetWeaselString(Apollo.GetString( strWeaselString ), nVal, strProperty)
		end

		if strLine == "" then -- Implied that tCur.nDiff is not 0 and bUseDiff is true
			local nDiffRound = strRound(tCur.nDiff)
			if nVal == 0 and tCur.nDiff < 0 then -- stat is present on other item and we are 0 - all red
				local strWeaselString = tCur.bPercentage and "Tooltips_StatDiffNewFloatPercent" or tCur.bSeconds and "Tooltips_StatDiffNewFloatSec" or "Tooltips_StatDiffNew"
				strLine = string.format("<T TextColor=\"%s\">%s</T>", kUIRed, String_GetWeaselString(Apollo.GetString( strWeaselString ), nVal, strProperty, nDiffRound))
			elseif nVal ~= 0 then
				if tCur.nDiff == nVal then -- stat not present on other item, we are all green
					local strWeaselString = tCur.bPercentage and "Tooltips_StatLostFloatPercent" or tCur.bSeconds and "Tooltips_StatLostFloatSec" or "Tooltips_StatLost"
					strLine = string.format("<T TextColor=\"%s\">%s</T>", kUIGreen, String_GetWeaselString(Apollo.GetString( strWeaselString ), nVal, strProperty, nDiffRound))
				elseif tCur.nDiff > 0 then -- stat present on other item, but we are higher. Diff is green
					local strWeaselString = tCur.bPercentage and "Tooltips_StatUpFloatPercent" or tCur.bSeconds and "Tooltips_StatUpFloatSec" or "Tooltips_StatUpFloat"
					local color = tCur.bInverseCompare and kUIRed or kUIGreen
					local strDiff = string.format("<T TextColor=\"%s\">%s</T>", color , String_GetWeaselString(Apollo.GetString( strWeaselString ), nDiffRound))
					strWeaselString= tCur.bPercentage and "Tooltips_StatDiffFloatPercent" or tCur.bSeconds and "Tooltips_StatDiffFloatSec" or "Tooltips_StatDiff"
					strLine = String_GetWeaselString(Apollo.GetString( strWeaselString ), nVal, strProperty, strDiff)
				elseif tCur.nDiff < 0 then -- we are lower than other item : diff is red
					local strWeaselString = tCur.bPercentage and "Tooltips_StatDownFloatPercent" or tCur.bSeconds and "Tooltips_StatDownFloatSec" or "Tooltips_StatDownFloat"
					local color = tCur.bInverseCompare and kUIGreen or kUIRed
					local strDiff = string.format("<T TextColor=\"%s\">%s</T>", color, String_GetWeaselString(Apollo.GetString( strWeaselString ), nDiffRound))
					strWeaselString= tCur.bPercentage and "Tooltips_StatDiffFloatPercent" or tCur.bSeconds and "Tooltips_StatDiffFloatSec" or "Tooltips_StatDiff"
					strLine = String_GetWeaselString(Apollo.GetString( strWeaselString ), nVal, strProperty, strDiff)

				elseif tCur.nDiff == 0 then -- we match other item, so no color change
					local strWeaselString= tCur.bPercentage and "Tooltips_StatEvenFloatPercent" or tCur.bSeconds and "Tooltips_StatEvenFloatSec" or "Tooltips_StatEven"
					strLine = String_GetWeaselString(Apollo.GetString( strWeaselString ), nVal, strProperty)
				end
			end
		end

		wnd:SetAML(string.format("<T Font=\"%s\" TextColor=\"%s\">%s</T>", kUIHugeFontSize, kUITeal, strLine))
		wnd:SetHeightToContentHeight()
	end
end

-- #############################
local tTotalStats = {}
local tRuneStats = {}

local function ItemTooltipBudgetPropHelper(wndParent, tblSortedBudgetPropList, bUseDiff, tItemInfo) -- E.G. Moxie, Grit, Brutality
	for idx, tCur in pairs(tblSortedBudgetPropList) do
		local wndBudgetFirst = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
		local wndBudgetOverlay = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndBudgetFirst)
		
		local strLine = ""
		local nVal = tCur.nValue or 0
		local strProperty = Item.GetPropertyName(tCur.eProperty)
		if not tCur.nDiff or not bUseDiff then
			local strWeaselString = tCur.bPercentage and "Tooltips_StatEvenFloatPercent" or tCur.bSeconds and "Tooltips_StatEvenFloatSec" or "Tooltips_StatEven"
			strLine = String_GetWeaselString(Apollo.GetString( strWeaselString ), nVal, strProperty)
		end
		local statdiff = 0
		if strLine == "" then -- Implied that tCur.nDiff is not 0 and bUseDiff is true
			local nDiffRound = strRound(tCur.nDiff)
			statdiff = nDiffRound
			if nVal == 0 and tCur.nDiff < 0 then -- stat is present on other item and we are 0 - all red
				local strWeaselString = tCur.bPercentage and "Tooltips_StatDiffNewFloatPercent" or tCur.bSeconds and "Tooltips_StatDiffNewFloatSec" or "Tooltips_StatDiffNew"
				strLine = string.format("<T TextColor=\"%s\">%s</T>", kUIRed, String_GetWeaselString(Apollo.GetString( strWeaselString ), nVal, strProperty, nDiffRound))
			elseif nVal ~= 0 then
				if tCur.nDiff == nVal then -- stat not present on other item, we are all green
					local strWeaselString = tCur.bPercentage and "Tooltips_StatLostFloatPercent" or tCur.bSeconds and "Tooltips_StatLostFloatSec" or "Tooltips_StatLost"
					strLine = string.format("<T TextColor=\"%s\">%s</T>", kUIGreen, String_GetWeaselString(Apollo.GetString( strWeaselString ), nVal, strProperty, nDiffRound))
				elseif tCur.nDiff > 0 then -- stat present on other item, but we are higher. Diff is green
					local strWeaselString = tCur.bPercentage and "Tooltips_StatUpFloatPercent" or tCur.bSeconds and "Tooltips_StatUpFloatSec" or "Tooltips_StatUpFloat"
					local color = tCur.bInverseCompare and kUIRed or kUIGreen
					local strDiff = string.format("<T TextColor=\"%s\">%s</T>", color , String_GetWeaselString(Apollo.GetString( strWeaselString ), nDiffRound))
					strWeaselString= tCur.bPercentage and "Tooltips_StatDiffFloatPercent" or tCur.bSeconds and "Tooltips_StatDiffFloatSec" or "Tooltips_StatDiff"
					strLine = String_GetWeaselString(Apollo.GetString( strWeaselString ), nVal, strProperty, strDiff)
				elseif tCur.nDiff < 0 then -- we are lower than other item : diff is red
					local strWeaselString = tCur.bPercentage and "Tooltips_StatDownFloatPercent" or tCur.bSeconds and "Tooltips_StatDownFloatSec" or "Tooltips_StatDownFloat"
					local color = tCur.bInverseCompare and kUIGreen or kUIRed
					local strDiff = string.format("<T TextColor=\"%s\">%s</T>", color, String_GetWeaselString(Apollo.GetString( strWeaselString ), nDiffRound))
					strWeaselString= tCur.bPercentage and "Tooltips_StatDiffFloatPercent" or tCur.bSeconds and "Tooltips_StatDiffFloatSec" or "Tooltips_StatDiff"
					strLine = String_GetWeaselString(Apollo.GetString( strWeaselString ), nVal, strProperty, strDiff)

				elseif tCur.nDiff == 0 then -- we match other item, so no color change
					local strWeaselString= tCur.bPercentage and "Tooltips_StatEvenFloatPercent" or tCur.bSeconds and "Tooltips_StatEvenFloatSec" or "Tooltips_StatEven"
					strLine = String_GetWeaselString(Apollo.GetString( strWeaselString ), nVal, strProperty)
				end
			end
		end
	
		
		wndBudgetFirst:SetAML(string.format("<T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</T>", kUIBody, strLine))
		wndBudgetFirst:SetHeightToContentHeight()

		wndBudgetOverlay:SetAML(string.format("<T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</T>", kUIBody, "Meow"))
		wndBudgetOverlay:SetHeightToContentHeight()
		
		local l, t, r, b  = wndBudgetFirst:GetAnchorOffsets()
		wndBudgetOverlay:SetAnchorOffsets(l , t, r + 20 , b)
		
		
		tTotalStats[strProperty] = {
			window = wndBudgetFirst,
			overlay = wndBudgetOverlay,
			value = nVal,
			property = strProperty,
			diff = statdiff,
			equiped = equipedvalue
		}

	end

end

-- #############################

local function ItemTooltipEmptySocketsHelper(wndParent, tItemInfo, itemSource)
	local bMadeHeader = false
	local tRunes = tItemInfo.tRunes -- GOTCHA: This is provided data
	if not tRunes then
		tRunes = itemSource:GetRuneSlots() -- GOTCHA: This default data
	end

	if tRunes and tRunes.nMinimum and tRunes.nMaximum and tRunes.nMaximum ~= 0 then
		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
		if tRunes.nMinimum == tRunes.nMaximum then
			local tActor =
			{
				["count"] = tRunes.nMinimum,
				["name"] = Apollo.GetString("Tooltips_RuneSlotPlural")
			}
			local strStaticAmount = String_GetWeaselString(Apollo.GetString("Tooltips_RuneSlotsStatic"), tActor)
			wnd:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</P>", kUIBody, strStaticAmount))
		else
			local tActor =
			{
				["count"] = tRunes.nMinimum,
				["name"] = Apollo.GetString("Tooltips_RuneSlotPlural")
			}
			local strRangedAmount = String_GetWeaselString(Apollo.GetString("Tooltips_RuneSlotsRange"), tActor, tRunes.nMaximum)
			wnd:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</P>", kUIBody, strRangedAmount))
		end
		wnd:SetHeightToContentHeight()
	end
end

-- #############################

local function ItemTooltipChargeHelper(wndParent, tItemInfo)
	-- Charge Count
	if tItemInfo.tCharge and tItemInfo.tCharge.nMaxCount ~= 1 then
		ItemTooltipSeparatorDiagonalHelper(wndParent)

		-- If no data for the nCount was populated we have none
		if tItemInfo.tCharge.nCount == nil then
			tItemInfo.tCharge.nCount = 0
		end

		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
		local strChargeCount = String_GetWeaselString(Apollo.GetString("Tooltips_ChargeCount"), tItemInfo.tCharge.nCount, tItemInfo.tCharge.nMaxCount)
		wnd:SetAML(string.format("<T Font=\"%s\" TextColor=\"%s\">%s</T>", kUIHugeFontSize, kUITeal, strChargeCount))
		wnd:SetHeightToContentHeight()
	end
end

-- #############################

local function ItemTooltipSpellEffectHelper(wndParent, tItemInfo)
	-- Spell Effects
	if tItemInfo.arSpells then
		for idx, tCur in pairs(tItemInfo.arSpells) do
			local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
			local strResult = ""
			if tCur.bActivate then
				strResult = String_GetWeaselString(Apollo.GetString("Tooltips_OnUse"), tCur.strName)
			elseif tCur.bOnEquip then
				strResult = String_GetWeaselString(Apollo.GetString("Tooltips_OnSpecial"), tCur.strName)
			elseif tCur.bProc then
				strResult = String_GetWeaselString(Apollo.GetString("Tooltips_OnSpecial"), tCur.strName)
			end

			if strResult ~= "" then
				local strItemSpellEffect = strResult
				if tCur.strFlavor ~= "" then
					strItemSpellEffect = String_GetWeaselString(Apollo.GetString("Tooltips_ItemSpellEffect"), strResult, tCur.strFlavor)
				end
				wnd:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</P>", kUIBody, strItemSpellEffect))
				wnd:SetHeightToContentHeight()
			end
		end
	end

	if tItemInfo.eFamily == Item.CodeEnumItem2Family.Rune and tItemInfo.arSpells and #tItemInfo.arSpells > 0 then
		ItemTooltipSeparatorSmallLineHelper(wndParent)
		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
		wnd:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</P>", kUITeal, Apollo.GetString("ItemTooltip_SpecialUniquePerItem")))
		local nWidth, nHeight = wnd:SetHeightToContentHeight()
		local nLeft, nTop, nRight, nBottom = wnd:GetAnchorOffsets()
		wnd:SetAnchorOffsets(nLeft, nTop, nRight, nTop + nHeight)
	end
	
end

-- #############################
local function ItemTooltipImbuementHelper(wndParent, tItemInfo)
	if not tItemInfo.arImbuements then
		return
	end

	ItemTooltipSeparatorDiagonalHelper(wndParent)

	local nTotalCount = 0
	local nCompletedCount = 0
	for idx, tCur in pairs(tItemInfo.arImbuements) do
		if tCur.bComplete then
			nCompletedCount = nCompletedCount + 1
		end
		nTotalCount = nTotalCount + 1
	end

	local wndFirst = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
	local strImbuementProgress = ""
	if nCompletedCount ~= nTotalCount then
		strImbuementProgress = String_GetWeaselString(Apollo.GetString("Tooltips_Imbuement"), nCompletedCount, nTotalCount)
	else
		strImbuementProgress = String_GetWeaselString(Apollo.GetString("Tooltips_Imbuement_Complete"), nCompletedCount, nTotalCount)
	end
	wndFirst:SetAML(string.format("<P Font=\"%s\" TextColor=\"%s\">%s</P>", kUIHugeFontSize, kUITeal, strImbuementProgress))
	wndFirst:SetHeightToContentHeight()

	for idx, tCur in pairs(tItemInfo.arImbuements) do
	
		 if tCur.bActive then
		
			if tCur.strObjective then
				local wndChallegeName = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
				wndChallegeName:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</P>", kUIBody, String_GetWeaselString(Apollo.GetString("Tooltips_Imbuement_Details"), tCur.strName, tCur.strObjective)))
				wndChallegeName:SetHeightToContentHeight()
			end
		
			local strImbumentInfo = ""
			
			if tCur.strSpecial then
				strImbumentInfo = String_GetWeaselString(Apollo.GetString("Tooltips_OnSpecial"), tCur.strSpecial)
			elseif tCur.eProperty and tCur.nValue then
				strImbumentInfo = String_GetWeaselString(Apollo.GetString("Tooltips_Imbuement_Reward"), tCur.nValue, Item.GetPropertyName(tCur.eProperty))
			elseif tCur.eNewQuality then
				strImbumentInfo = String_GetWeaselString(Apollo.GetString("Tooltips_Imbuement_ChangeQuality"), karEvalStrings[tCur.eNewQuality])
			elseif tCur.nAddedRuneSlots then
				strImbumentInfo = String_GetWeaselString(Apollo.GetString("Tooltips_Imbuement_AddsReward"), GetPluralizeActor(Apollo.GetString("Tooltips_Imbuement_RuneSlot"), tCur.nAddedRuneSlots))
			elseif tCur.nAddedLevels then
				strImbumentInfo = String_GetWeaselString(Apollo.GetString("Tooltips_Imbuement_AddsReward"), GetPluralizeActor(Apollo.GetString("Tooltips_Imbuement_ItemLevel"), tCur.nAddedLevels))
			else
				return
			end
			
			local wndProperty = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
			wndProperty:SetAML(string.format("<T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</T>", kUIBody, strImbumentInfo))
			wndProperty:SetHeightToContentHeight()
			
		end
		
	end
	
end

-- #############################

local function ItemTooltipQuestHelper(wndParent, tItemInfo)
	-- Quest
	if tItemInfo.nQuestMinLevel then
		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
		wnd:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</P>", kUIBody, String_GetWeaselString(Apollo.GetString("Tooltips_UseToStartQuest"), tItemInfo.nQuestMinLevel)))
		wnd:SetHeightToContentHeight()
	end
end

-- #############################

local function ItemTooltipSigilHelper(wndParent, tItemInfo, itemSource)
	tRuneStats = {}
	-- if the item is a rune
	if tItemInfo.tRuneSet then

		ItemTooltipSeparatorSmallLineHelper(wndParent)

		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
		wnd:SetAML(string.format("<P Font=\"CRB_InterfaceMedium\" TextColor=\"%s\">%s</P>", kUIGreen, String_GetWeaselString(Apollo.GetString("ItemTooltip_RuneSetText"), tItemInfo.tRuneSet.nPower, tItemInfo.tRuneSet.strName)))
		local nTextWidth, nTextHeight = wnd:SetHeightToContentHeight()
		local nLeft, nTop, nRight, nBottom = wnd:GetAnchorOffsets()
		wnd:SetAnchorOffsets(nLeft, nTop, nRight, nTop + nTextHeight + 3)

		wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
		wnd:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</P>", kUIBody , Apollo.GetString("ItemTooltip_RuneSetBonusText")))
		wnd:SetHeightToContentHeight()

		for idx, tCur in pairs(tItemInfo.tRuneSet.arBonuses) do

			wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)

			local strPower = ""
			local strValue = ""

			if tCur.strFlavor then

				strPower = string.format("<T TextColor=\"%s\">%s</T>", kUIBody , String_GetWeaselString(Apollo.GetString("ItemTooltip_RuneSpellPowerSummaryText"), tCur.nPower))
				strValue = string.format("<T TextColor=\"%s\">%s</T>", kUICyan , String_GetWeaselString(Apollo.GetString("ItemTooltip_RuneSetNameFlavor"), tCur.strName, tCur.strFlavor))

			else
				local nAdjusted_Value

				if tCur.nValue then
					nAdjusted_Value = tCur.nValue * 100 -- make a %
				else
					nAdjusted_Value = ((tCur.nScalar * 100) - 100) -- make a %
				end

				if nAdjusted_Value >= 0 then
					strValue = string.format("<T TextColor=\"%s\">%s</T>", kUICyan , String_GetWeaselString(Apollo.GetString("ItemTooltip_RuneSetPositivePower"), nAdjusted_Value, tCur.strName))
				else
					strValue = string.format("<T TextColor=\"%s\">%s</T>", kUICyan , String_GetWeaselString(Apollo.GetString("ItemTooltip_RuneSetNegativePower"), nAdjusted_Value, tCur.strName))
				end

				strPower = string.format("<T TextColor=\"%s\">%s</T>", kUIBody , String_GetWeaselString(Apollo.GetString("ItemTooltip_RuneSpellPowerSummaryText"), tCur.nPower))

			end

			wnd:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\">%s</P>", strPower .. strValue ))
			wnd:SetHeightToContentHeight()

		end

		wndParent:ArrangeChildrenVert(1)

	end

	-- IMPORTANT: Drawing runes on an item, not if mousing over a rune item
	local tRunes = tItemInfo.tRunes -- GOTCHA: This is provided data
	if not tRunes then
		tRunes = itemSource:GetRuneSlots() -- GOTCHA: This is default data
	end

	if not tRunes or not tRunes.arRuneSlots then
		return
	end

	-- Order is important, create the divider first
	for idx, tCur in pairs(tRunes.arRuneSlots) do
		if karSigilTypeToString[tCur.eElement] then
			ItemTooltipSeparatorSmallLineHelper(wndParent)
			break
		end
	end

	-- if item has socketed rune sets
	if tItemInfo.arSets then
		local strResult = ""
		for idxSets, tCurSets in pairs(tItemInfo.arSets) do
			strResult =  String_GetWeaselString(Apollo.GetString("ItemTooltip_RuneSetSummaryText"), tCurSets.strName, tCurSets.nPower, tCurSets.nMaxPower)
			local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "ItemTooltip_RuneSummary", wndParent)
			wnd:FindChild("ItemTooltip_RuneSummaryML"):SetAML(strResult)
			-- Resize
			local nTextWidth, nTextHeight = wnd:FindChild("ItemTooltip_RuneSummaryML"):SetHeightToContentHeight()
			local nLeft, nTop, nRight, nBottom = wnd:GetAnchorOffsets()
			wnd:SetAnchorOffsets(nLeft, nTop, nRight, nTop + nTextHeight + 23)
		end
	end

	local nHeight = 0
	local wndBox = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "ItemTooltip_RuneBox", wndParent)
	for idx, tCur in pairs(tRunes.arRuneSlots) do
		if karSigilTypeToString[tCur.eElement] then
			local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "ItemTooltip_Rune", wndBox)
			if nHeight == 0 then
				nHeight = wnd:GetHeight()
			end

			if tCur.itemRune then
				wnd:FindChild("ItemTooltip_RuneIcon"):SetSprite(karSigilTypeToIcon[tCur.eElement].strUsed or "")
				if tCur.arSpells then
					for idxSpells, tCurSpells in pairs(tCur.arSpells) do
						wnd:FindChild("ItemTooltip_RuneText"):SetText(tCurSpells.strName)
					end
				else
					for idxProperty, tCurProperty in pairs(tCur.arProperties) do
						if tCurProperty.nValue and tCurProperty.nValue > 0 then
							local prop = Item.GetPropertyName(tCurProperty.eProperty)
							tRuneStats[prop] = tRuneStats[prop] or 0 --TaviTooltip: Add up rune values manually, no idea if there's a better way to call this information
							tRuneStats[prop] = tRuneStats[prop] + tCurProperty.nValue
							wnd:FindChild("ItemTooltip_RuneText"):SetText(String_GetWeaselString(Apollo.GetString("Tooltips_RuneAttributeBonus"), strRound(tCurProperty.nValue), Item.GetPropertyName(tCurProperty.eProperty)))
						end
					end
				end
			else
				local strText = Apollo.GetString("Tooltips_RuneSlotOpen")
				wnd:FindChild("ItemTooltip_RuneIcon"):SetSprite(karSigilTypeToIcon[tCur.eElement].strEmpty or "")
				wnd:FindChild("ItemTooltip_RuneText"):SetText(String_GetWeaselString(strText, karSigilTypeToString[tCur.eElement]))
			end

			-- If it's the only item, use the full space
			if #tRunes.arRuneSlots == 1 then
				local nLeft, nTop, nRight, nBottom = wnd:GetAnchorOffsets()
				wnd:SetAnchorOffsets(nLeft, nTop, wndBox:GetWidth() / 2, nBottom)
			end
		end
	end
	
	wndBox:ArrangeChildrenTiles(Window.CodeEnumArrangeOrigin.LeftOrTop)
	local nNumChildren = #wndBox:GetChildren()
	local nLeft, nTop, nRight, nBottom = wndBox:GetAnchorOffsets()
	wndBox:SetAnchorOffsets(nLeft, nTop, nRight, nTop + (math.ceil(nNumChildren / 2) * nHeight))
end

-- #############################

local function ItemTooltipRuneHelper(wndParent, tItemInfo)
end

-- #############################

local function ItemTooltipFlavorHelper(wndParent, tItemInfo)
	local strResult = ""
	if tItemInfo.strFlavor and tItemInfo.strFlavor ~= " " and string.len(tItemInfo.strFlavor) > 0 then
		strResult = string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"UI_TextMetalBodyHighlight\">%s</P>", tItemInfo.strFlavor)
	end

	if tItemInfo.bDestroyOnLogout then
		strResult = string.format("%s<P Font=\"CRB_InterfaceSmall\" TextColor=\"UI_TextMetalBodyHighlight\">%s</P>", strResult, Apollo.GetString("Tooltip_DestroyedOnLogout"))
	end

	if tItemInfo.bDestroyOnZone then
		strResult = string.format("%s<P Font=\"CRB_InterfaceSmall\" TextColor=\"UI_TextMetalBodyHighlight\">%s</P>", strResult, Apollo.GetString("Tooltip_DestroyedOnZone"))
	end

	if tItemInfo.nExpiresInTimeSeconds ~= nil and tItemInfo.nExpiresInTimeSeconds > 0 then
		local nMinutes = math.floor(tItemInfo.nExpiresInTimeSeconds / 60)
		local nSeconds = math.floor(tItemInfo.nExpiresInTimeSeconds) % 60
		local strMinutesAndSeconds = String_GetWeaselString(Apollo.GetString("Tooltip_ExpiringTime"), nMinutes, nSeconds)
		strResult = string.format("%s<P Font=\"CRB_InterfaceSmall\" TextColor=\"UI_TextMetalBodyHighlight\">%s</P>", strResult, strMinutesAndSeconds)
	elseif (tItemInfo.nExpirationTimeSeconds and tItemInfo.nExpirationTimeSeconds or 0) > 0 then
		local strExpireTime = String_GetWeaselString(Apollo.GetString("Tooltip_ExpireTime"), math.floor(tItemInfo.nExpirationTimeSeconds / 60))
		strResult = string.format("%s<P Font=\"CRB_InterfaceSmall\" TextColor=\"UI_TextMetalBodyHighlight\">%s</P>", strResult, strExpireTime)
	end

	if tItemInfo.strMakersMark and string.len(tItemInfo.strMakersMark) > 0 and tItemInfo.strMakersMark ~= Apollo.GetString("CRB_Unknown") then
		local strCraftedBy = String_GetWeaselString(Apollo.GetString("Tooltips_CraftedBy"), tItemInfo.strMakersMark)
		strResult = string.format("%s<P Font=\"CRB_InterfaceSmall\" TextColor=\"UI_TextMetalBodyHighlight\">%s</P>", strResult, strCraftedBy)
	end

	if strResult == " " or string.len(strResult) == 0 then
		return
	end

	local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "ItemTooltip_Flavor", wndParent)
	wnd:FindChild("ItemTooltip_FlavorML"):SetAML(strResult)

	-- Resize
	local nTextWidth, nTextHeight = wnd:FindChild("ItemTooltip_FlavorML"):SetHeightToContentHeight()
	local nLeft, nTop, nRight, nBottom = wnd:GetAnchorOffsets()
	wnd:SetAnchorOffsets(nLeft, nTop, nRight, nTop + nTextHeight + 23)
end

-- #############################

local function ItemTooltipCostumeHelper(wndParent, tItemInfo)
	-- We only want to show the costume portion for weapon and armor tooltips.
	if (tItemInfo.eFamily == Item.CodeEnumItem2Family.Weapon or tItemInfo.eFamily == Item.CodeEnumItem2Family.Armor or tItemInfo.eFamily == Item.CodeEnumItem2Family.Apparel) and tItemInfo.bCanCostumeUnlock and not tItemInfo.bCostumeUnlocked then
		local wndCostumeInfo = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
		wndCostumeInfo:SetAML(string.format("<T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</T>", kUICyan, Apollo.GetString("Costumes_Unlockable")))
		wndCostumeInfo:SetHeightToContentHeight()
	end
end

-- #############################

local function ItemTooltipMonHelper(wndParent, tItemInfo, itemSource, tFlags) -- Sell, Buy, Buy Back, Repair
	if not tItemInfo.tCost or tFlags.bInvisibleFrame then -- bInvisibleFrame is mainly used for crafting
		return
	end

	-- Buy requirements, e.g. 2000 Reputation (Should be it's own method)
	if (tFlags.bBuying or tFlags.nPrereqVendorId) and (itemSource ~= tFlags.itemCompare) then
		local unitPlayer = GameLib.GetPlayerUnit()
		local tPrereqInfo = unitPlayer and unitPlayer:GetPrereqInfo(tFlags.nPrereqVendorId) or nil
		if tPrereqInfo and tPrereqInfo.strText then
			local wndPrereq = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndParent)
			wndPrereq:SetAML(string.format("<T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</T>", tPrereqInfo.bIsMet and kUICyan or kUIRed, String_GetWeaselString(tPrereqInfo.strText)))
			wndPrereq:SetHeightToContentHeight()
		end
	end

	-- Start the Money Helper Now. If we're drawing at least one thing do a wndBox
	local wndBox = nil
	local bCanRepair = tItemInfo.tCost.monRepair and tItemInfo.tCost.monRepair:GetAmount() ~= 0
	if tItemInfo.bSalvagable or tItemInfo.tDurability or tFlags.bBuying or tFlags.bBuyback or tItemInfo.tCost.arMonSell or bCanRepair or tItemInfo.bCantDelete then
		if not wndParent:FindChild("ItemTooltip_Flavor") then
			ItemTooltipSeparatorSmallLineHelper(wndParent) -- The art for Flavor already provides a natural separator if it exists
		end

		wndBox = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "ItemTooltip_SalvageAndMoney", wndParent)
	end

	-- Left Side
	-- Durability
	if tItemInfo.tDurability then
		local nMax = tItemInfo.tDurability.nMax
		local nCurrent = tItemInfo.tDurability.nCurrent
		local nCurrentPercentage = nCurrent and (nCurrent / nMax) or 1

		local strFinishedString = ""
		if nCurrentPercentage == 0 then
			strFinishedString  = string.format("<T TextColor=\"%s\">%s</T>", kUIRed, nCurrent)
			strFinishedString = String_GetWeaselString(Apollo.GetString("Tooltips_DurabilityLow"), strFinishedString, nMax)
		elseif nCurrentPercentage <= 0.25 then
			strFinishedString  = string.format("<T TextColor=\"%s\">%s</T>", kUILowDurability, nCurrent)
			strFinishedString = String_GetWeaselString(Apollo.GetString("Tooltips_DurabilityLow"), strFinishedString, nMax)
		elseif nCurrentPercentage == 1 then
			strFinishedString = String_GetWeaselString(Apollo.GetString("CRB_ProgressSimple"), nMax, nMax)
		else
			strFinishedString = String_GetWeaselString(Apollo.GetString("CRB_ProgressSimple"), nCurrent, nMax)
		end

		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndBox:FindChild("LeftSide"))
		wnd:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</P>", kUICyan, String_GetWeaselString(Apollo.GetString("Tooltips_Durability"), strFinishedString)))
		wnd:SetHeightToContentHeight()
	end

	-- Salvage
	if tItemInfo.bSalvagable and not tFlags.bBuying then
		local strSalvage = tItemInfo.bAutoSalvage and Apollo.GetString("Tooltips_RightClickSalvage") or Apollo.GetString("Tooltips_Salvageable")
		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndBox:FindChild("LeftSide"))
		wnd:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</P>", kUICyan, strSalvage))
		wnd:SetHeightToContentHeight()
	end
	
	-- Can Delete Item
	if tItemInfo.bCantDelete and tItemInfo.bCantDelete == true then
		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndBox:FindChild("LeftSide"))
		wnd:SetAML(string.format("<P Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</P>", kUICyan, Apollo.GetString("ItemTooltip_CanNotDelete")))
		wnd:SetHeightToContentHeight()
	end

	-- Right Side
	-- Buy
	local nStackCount = tItemInfo.tStack and (tItemInfo.tStack.nCount or tFlags.nStackCount) or 1
	if tFlags.bBuying and tItemInfo.tCost.arMonBuy then
		local wnd = nil
		local xml = XmlDoc.new()
		for idx, monPrice in pairs(tItemInfo.tCost.arMonBuy) do
			if monPrice:GetAmount() ~= 0 then

				if wnd == nil or not wnd:IsValid() then
					wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndBox:FindChild("RightSide"))

					local strSellCaption = Apollo.GetString("CRB_Buy_For")
					if nStackCount > 1 then
						monPrice = monPrice:Multiply(nStackCount)
						strSellCaption = String_GetWeaselString(Apollo.GetString("CRB_Buy_X_For"), nStackCount)
					end
					xml:AddLine(strSellCaption.."<T TextColor=\"0\">.</T>", kUICyan, "CRB_InterfaceSmall", "Right")
				end

				monPrice:AppendToTooltip(xml)
			end
		end

		if wnd ~= nil and wnd:IsValid() then
			wnd:SetDoc(xml)
			wnd:SetHeightToContentHeight()
		end
	end

	-- Buyback
	if not tFlags.bBuying and tFlags.bBuyback and tItemInfo.tCost.arMonSell then
		local wnd = nil
		local xml = XmlDoc.new()
		for idx, monPrice in pairs(tItemInfo.tCost.arMonSell) do
			if monPrice:GetAmount() ~= 0 then

				if wnd == nil or not wnd:IsValid() then
					wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndBox:FindChild("RightSide"))

					local strSellCaption = Apollo.GetString("CRB_Buy_For")
					if nStackCount > 1 then
						monPrice = monPrice:Multiply(nStackCount)
						strSellCaption = String_GetWeaselString(Apollo.GetString("CRB_Buy_X_For"), nStackCount)
					end
					xml:AddLine(strSellCaption.."<T TextColor=\"0\">.</T>", kUICyan, "CRB_InterfaceSmall", "Right")
				end

				monPrice:AppendToTooltip(xml)
			end
		end

		if wnd ~= nil and wnd:IsValid() then
			wnd:SetDoc(xml)
			wnd:SetHeightToContentHeight()
		end
	end

	-- Repair
	if bCanRepair then
		local monPrice = tItemInfo.tCost.monRepair
		local strSellCaption = Apollo.GetString("Tooltips_RepairFor") .. "<T TextColor=\"0\">.</T>"
		if nStackCount > 1 then
			monPrice = monPrice:Multiply(nStackCount)
		end

		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndBox:FindChild("RightSide"))
		xml = XmlDoc.new()
		xml:AddLine(strSellCaption, kUICyan, "CRB_InterfaceSmall", "Right")
		monPrice:AppendToTooltip(xml)
		wnd:SetDoc(xml)
		wnd:SetHeightToContentHeight()
	end

	-- Sell
	local bHasSellPrice = false
	if tItemInfo.tCost.arMonSell then
		for idx, tCur in pairs(tItemInfo.tCost.arMonSell) do
			local monPrice = tCur
			if monPrice:GetAmount() ~= 0 then
				bHasSellPrice = true
				local strSellCaption = Apollo.GetString("CRB_Sell_for_")
				if nStackCount > 1 then
					monPrice = monPrice:Multiply(nStackCount)
					strSellCaption = tFlags.bBuying and Apollo.GetString("CRB_Sell_for_") or String_GetWeaselString(Apollo.GetString("CRB_Sell_X_For_"), nStackCount) -- Not bSelling
				end

				local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndBox:FindChild("RightSide"))
				xml = XmlDoc.new()
				xml:AddLine(strSellCaption .. "<T TextColor=\"0\">.</T>", kUICyan, "CRB_InterfaceSmall", "Right")
				monPrice:AppendToTooltip(xml)
				wnd:SetDoc(xml)
				wnd:SetHeightToContentHeight()
			end
		end
	end

	if tItemInfo.tCost.bHasRestockingFee then
		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndBox:FindChild("RightSide"))
		xml = XmlDoc.new()
		xml:AddLine(Apollo.GetString("CRB_RestockFee"), kUICyan, "CRB_InterfaceSmall", "Right")
		wnd:SetDoc(xml)
		wnd:SetHeightToContentHeight()
	end

	if bHasSellPrice and tItemInfo.tCost.nRemainingReturnTimeSeconds then
		ItemTooltipSeparatorSmallLineHelper(wndParent) -- The art for Flavor already provides a natural separator if it exists

		local wndBox2 = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "ItemTooltip_SalvageAndMoney", wndParent)
		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndBox2:FindChild("LeftSide"))
		local nTimeMinutes = math.floor(tItemInfo.tCost.nRemainingReturnTimeSeconds) / 60
		local tTimeInfo = {["name"] = Apollo.GetString("CRB_Min"), ["count"] = nTimeMinutes}
		local strSellToVendorBase = tItemInfo.tCost.bHasRestockingFee and Apollo.GetString("CRB_SellToVendorWithFeeTime") or Apollo.GetString("CRB_SellToVendorTime")
		local strTimeRemaining = String_GetWeaselString(strSellToVendorBase, tTimeInfo)

		xml = XmlDoc.new()
		xml:AddLine(strTimeRemaining, kUICyan, "CRB_InterfaceSmall", "Center")
		wnd:SetDoc(xml)
		wnd:SetHeightToContentHeight()
	end

	if tItemInfo.nSoulboundTradeAllowedTimeSeconds  then
		ItemTooltipSeparatorSmallLineHelper(wndParent) -- The art for Flavor already provides a natural separator if it exists

		local wndBox2 = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "ItemTooltip_SalvageAndMoney", wndParent)
		local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SimpleRowSmallML", wndBox2:FindChild("LeftSide"))
		local nTimeMinutes = math.floor(tItemInfo.nSoulboundTradeAllowedTimeSeconds) / 60
		local tTimeInfo = {["name"] = Apollo.GetString("CRB_Min"), ["count"] = nTimeMinutes}
		local strTimeRemaining = String_GetWeaselString(Apollo.GetString("CRB_SoulboundTradingTime"), tTimeInfo)

		xml = XmlDoc.new()
		xml:AddLine(strTimeRemaining, kUICyan, "CRB_InterfaceSmall", "Center")
		wnd:SetDoc(xml)
		wnd:SetHeightToContentHeight()
	end

	-- Resize
	if wndBox and wndBox:IsValid() then
		local nHeightLeftSide = wndBox:FindChild("LeftSide"):ArrangeChildrenVert(Window.CodeEnumArrangeOrigin.LeftOrTop)
		local nHeightRightSide = wndBox:FindChild("RightSide"):ArrangeChildrenVert(Window.CodeEnumArrangeOrigin.LeftOrTop)
		local nLeft, nTop, nRight, nBottom = wndBox:GetAnchorOffsets()
		wndBox:SetAnchorOffsets(nLeft, nTop, nRight, nTop + math.max(nHeightLeftSide, nHeightRightSide) + 4)
	end
end

-- #############################

local function ItemTooltipAppendHelper(wndParent, strAppendText)
	local wnd = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "ItemTooltip_Flavor", wndParent)
	wnd:FindChild("ItemTooltip_FlavorML"):SetText(strAppendText)

	local nTextWidth, nTextHeight = wnd:FindChild("ItemTooltip_FlavorML"):SetHeightToContentHeight()

	local nLeft, nTop, nRight, nBottom = wnd:GetAnchorOffsets()
	wnd:SetAnchorOffsets(nLeft, nTop, nRight, nTop + nTextHeight + 30)
end

-- #############################

local function ItemTooltipPropSortHelper(tItemInfo)
	local tSorted = {}
	if not tItemInfo then
		return {}
	end

	local function fnSort(a,b)
		if a.nSortOrder and b.nSortOrder then
			return a.nSortOrder < b.nSortOrder
		elseif b.nSortOrder then
			return true
		else
			return false
		end
	end

	tSorted = tItemInfo
	table.sort(tSorted, fnSort)

	return tSorted
end

-- Item Tooltip Generate
-- Flags: bBuyBack, idVendorUnique, itemModData, tGlyphData, arGlyphIds, strMaker, itemCompare, bPermanent, bNotEquipped, tCompare, bInvisibleFrame, bShowSimple, strAppend
local function GenerateItemTooltipForm(luaCaller, wndParent, itemSource, tFlags, nCount)
	if not itemSource then
		return
	end

	wndParent:SetTooltipDoc(nil)
	wndParent:SetTooltipDocSecondary(nil)

	if tFlags.bBuyback then
		tFlags.idVendorUnique = nil
	end

	local tSource = { itemSource, tFlags.itemModData, tFlags.tGlyphData, tFlags.arGlyphIds, tFlags.strMaker, tFlags.idVendorUnique }
	local tItemInfo = tFlags.itemCompare and Item.GetDetailedInfo(tSource, tFlags.itemCompare) or Item.GetDetailedInfo(tSource)
	
	local wndTooltip = nil
	local wndTooltipComp = nil
	if tFlags.bPermanent then
		wndTooltip = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "ItemTooltip_Base", tFlags.wndParent, luaCaller)
		if tFlags.bNotEquipped then
			wndTooltip:FindChild("CurrentHeader"):Show(false)
		end
	else
		wndTooltip = wndParent:LoadTooltipForm("ui\\Tooltips\\TooltipsForms.xml", "ItemTooltip_Base", luaCaller)
		if tItemInfo.tCompare then
			wndTooltipComp = wndParent:LoadTooltipFormSecondary("ui\\Tooltips\\TooltipsForms.xml", "ItemTooltip_Base", luaCaller)
		end
		if tFlags.bNotEquipped == false then
			wndTooltip:FindChild("CurrentHeader"):Show(true)
		else
			wndTooltip:FindChild("CurrentHeader"):Show(false)
		end
	end

	local wndItems = wndTooltip:FindChild("Items")
	local wndItemsCompare = wndTooltipComp and wndTooltipComp:FindChild("Items") or nil
	local tPrimaryInnateSort = {}
	local tPrimaryBudgetBasedSort = {}
	local tCompareInnateSort = {}
	local tCompareBudgetBasedSort = {}
	
	TaviTooltips.SavedStats = {}

	-- After resizing, now draw
	local function CallAllHelpers(wndTooltip, wndItems, itemOne, itemTwo, tFlags, tPrimaryInate, tPrimaryBudget, bPropHelper)
		ItemTooltipHeaderHelper(wndItems, itemOne, itemTwo, wndTooltip, tFlags)
		--
		ItemTooltipBasicStatsHelper(wndItems, itemOne, itemTwo)
		ItemTooltipClassReqHelper(wndItems, itemOne)
		ItemTooltipFactionReqHelper(wndItems, itemOne)
		ItemTooltipSpellReqHelper(wndItems, itemOne)
		ItemTooltipSpecialReqHelper(wndItems, itemOne)
		ItemTooltipSchematicHelper(wndItems, itemOne)
		ItemTooltipAdditiveHelper(wndItems, itemOne)
		--
		ItemTooltipInnatePropHelper(wndItems, tPrimaryInate, bPropHelper)
		ItemTooltipBudgetPropHelper(wndItems, tPrimaryBudget, bPropHelper, itemOne)
		--
		ItemTooltipChargeHelper(wndItems, itemOne)
		ItemTooltipSpellEffectHelper(wndItems, itemOne)
		--
		ItemTooltipEmptySocketsHelper(wndItems, itemOne, itemTwo)
		--
		ItemTooltipImbuementHelper(wndItems, itemOne)
		ItemTooltipQuestHelper(wndItems, itemOne)
		--
		ItemTooltipSigilHelper(wndItems, itemOne, itemTwo)
		ItemTooltipRuneHelper(wndItems, itemOne)
		ItemTooltipFlavorHelper(wndItems, itemOne)
		--
		ItemTooltipMonHelper(wndItems, itemOne, itemTwo, tFlags)
		ItemTooltipCostumeHelper(wndItems, itemOne)
		
		--[[
		tTotalStats[strProperty] 			the table containing our saved numbers to compare with later
								.window		the original window that contains stat line, a new window for each line
								.value		the value of the stat
								.property	the stat's name
								.diff		Carbine's combined difference
		]]
		
		for prop, tpropinfo in pairs(tTotalStats) do
			local ntotal, nrunes, ngear, nequiped, ndiff, strprop, strtotal, strrunes, strgear, strdiff, strproperty, nvalue 
			
			strproperty = tpropinfo.property
			nvalue = tpropinfo.value
			
			if nvalue then
				ntotal = strRound(nvalue)
			else
				ntotal = 0
			end
			
			--Our saved count from the sigil helper function
			if tRuneStats[strproperty] then
				nrunes = strRound(tRuneStats[strproperty])
			else
				nrunes = 0
			end
			
			ngear = ntotal - nrunes --find the base stats on the gear, no idea if there's a better way to do this
			strgear = ""
			strrunes = ""
			strdiff = ""
			
			ndiff = TaviTooltips:GearCompareHelper(strproperty, ngear) -- Our helper function to remember the stats
			
			--Carbine keeps using floor instead of round, so results aren't exact, but close enough.
			if ndiff then
				if tSettings.MergeRunes then ndiff = tpropinfo.diff end
				if ndiff > 10 then
					strdiff = string.format("<T TextColor=\"%s\">(+%s) </T>", kUIGreen, ndiff)
				elseif ndiff < -10 then
					strdiff = string.format("<T TextColor=\"%s\">(%s) </T>", kUIRed, ndiff)
				else
					strdiff = ""
				end
			end
			
			--Formatting for setAML
			strprop = string.format("<T TextColor=\"%s\">%s: </T>", kUIBody, strproperty)
			strtotal = string.format("<T TextColor=\"%s\">%s</T>", tSettings.TotalColor, ntotal)
			strgear = string.format("<T TextColor=\"%s\">%s</T>", tSettings.GearColor, ngear)
			strrunes = string.format("<T TextColor=\"%s\">%s</T>", tSettings.RuneColor, nrunes)

			local strLineLeft = tostring("<P Align=\"Left\" Font=\"CRB_InterfaceSmall\">"..strprop..strdiff.."</P>")
			local strLineRight = tostring("<P Align=\"Right\" Font=\"CRB_InterfaceSmall\">"..strleftbrace..strgear..strplussign..strrunes..strrightbrace..strequalsign..strtotal.."</P>")
			
			--window is the original, which we modified, and overlay is the right-aligned bit
			tpropinfo.window:SetAML(strLineLeft)
			tpropinfo.window:SetHeightToContentHeight()
			tpropinfo.overlay:SetAML(strLineRight)
			tpropinfo.overlay:SetHeightToContentHeight()
		end
	end

	if tItemInfo.tPrimary and wndTooltip then
		wndTooltip:FindChild("ItemTooltip_BaseCanEquip"):Show(itemSource:IsEquippable() and not itemSource:CanEquip())
		wndTooltip:FindChild("ItemTooltip_BaseRarityFrame"):SetSprite(karItemQualityToBorderFrameBG[tItemInfo.tPrimary.eQuality] or "")
	end

	if tItemInfo.tCompare and wndTooltipComp then
		wndTooltipComp:FindChild("ItemTooltip_BaseCanEquip"):Show(tFlags.itemCompare:IsEquippable() and not tFlags.itemCompare:CanEquip())
		wndTooltipComp:FindChild("ItemTooltip_BaseRarityFrame"):SetSprite(karItemQualityToBorderFrameBG[tItemInfo.tCompare.eQuality] or "")
	end

	-- This is mainly used for crafting
	local nInvisibleFramePadding = 0
	if tFlags.bInvisibleFrame then
		nInvisibleFramePadding = 10
		wndTooltip:FindChild("ItemTooltipBG"):Show(false)
		wndTooltip:FindChild("ItemTooltip_BaseCanEquip"):Show(false)
		wndTooltip:FindChild("ItemTooltip_BaseRarityFrame"):Show(false)
		if wndTooltipComp then
			wndTooltipComp:FindChild("ItemTooltipBG"):Show(false)
			wndTooltipComp:FindChild("ItemTooltip_BaseCanEquip"):Show(false)
			wndTooltipComp:FindChild("ItemTooltip_BaseRarityFrame"):Show(false)
		end
	end

	if tFlags.bSimple then
		ItemTooltipHeaderHelper(wndItems, tItemInfo.tPrimary, itemSource, wndTooltip, tFlags)

		local nAppendBuffer = 0
		if tFlags.strAppend then
			ItemTooltipAppendHelper(wndItems, tFlags.strAppend)
			nAppendBuffer = 10
		end

		local nLeft, nTop, nRight, nItemsBottom = wndItems:GetAnchorOffsets()
		wndTooltip:Move(0, 0, kItemTooltipWindowWidth, wndItems:ArrangeChildrenVert(Window.CodeEnumArrangeOrigin.LeftOrTop) + nItemsBottom + knWndHeightBuffer + nAppendBuffer)
	else
		

		--Compare (Equipped)
		if tItemInfo.tCompare and wndTooltipComp and wndItemsCompare and wndTooltipComp:IsValid() and wndItemsCompare:IsValid() then
			if tItemInfo.tCompare.arInnateProperties then
				tCompareInnateSort = ItemTooltipPropSortHelper(tItemInfo.tCompare.arInnateProperties)
			end

			if tItemInfo.tCompare.arBudgetBasedProperties then
				tCompareBudgetBasedSort = ItemTooltipPropSortHelper(tItemInfo.tCompare.arBudgetBasedProperties)
			end
			
			TaviTooltips:ClearSave() --Reset so we don't accidently use old data from other items
			
			CallAllHelpers(wndTooltipComp, wndItemsCompare, tItemInfo.tCompare, tFlags.itemCompare, tFlags, tCompareInnateSort, tCompareBudgetBasedSort, false)
		end
		
		if tItemInfo.tPrimary and wndTooltip and wndTooltip:IsValid() and wndItems and wndItems:IsValid() then
			if tItemInfo.tPrimary.arInnateProperties then
				tPrimaryInnateSort = ItemTooltipPropSortHelper(tItemInfo.tPrimary.arInnateProperties)
			end
			if tItemInfo.tPrimary.arBudgetBasedProperties then
				tPrimaryBudgetBasedSort = ItemTooltipPropSortHelper(tItemInfo.tPrimary.arBudgetBasedProperties)
			end
			
			CallAllHelpers(wndTooltip, wndItems, tItemInfo.tPrimary, itemSource, tFlags, tPrimaryInnateSort, tPrimaryBudgetBasedSort, true)

			if tFlags.strAppend then
				ItemTooltipAppendHelper(wndItems, tFlags.strAppend)
			end
		end


		-- GOTCHA: There is only one draw pass, so XML must match kItemTooltipWindowWidth, otherwise text calculation may be wrong
		wndTooltip:Move(0, 0, kItemTooltipWindowWidth, wndItems:ArrangeChildrenVert(Window.CodeEnumArrangeOrigin.LeftOrTop) + nInvisibleFramePadding + knWndHeightBuffer)
		if tItemInfo.tCompare and wndTooltipComp and wndTooltipComp:IsValid() then
			wndTooltipComp:Move(0, 0, kItemTooltipWindowWidth, wndItemsCompare:ArrangeChildrenVert(Window.CodeEnumArrangeOrigin.LeftOrTop) + nInvisibleFramePadding + knWndHeightBuffer)
		end
	end

	return wndTooltip, wndTooltipComp
end

-------------------
-- Spell Tooltip --
-------------------

local function GenerateSpellTooltipForm(luaCaller, wndParent, splSource, tFlags)

	-- Initial Bad Data Checks
	if splSource == nil then
		return
	end

	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil then
		return
	end

	local wndTooltip
	if tFlags and tFlags.bPermanent then
		wndTooltip = Apollo.LoadForm("ui\\Tooltips\\TooltipsForms.xml", "SpellTooltip_Base", tFlags.wndParent, luaCaller)
	else
		wndTooltip = wndParent:LoadTooltipForm("ui\\Tooltips\\TooltipsForms.xml", "SpellTooltip_Base", luaCaller)
	end

	--TopDataBlock
	local wndTopDataBlock 				= wndTooltip:FindChild("TopDataBlock")
	local wndName 						= wndTopDataBlock:FindChild("NameString")
	local wndTier 						= wndTopDataBlock:FindChild("TierString")
	local wndCastInfo 					= wndTopDataBlock:FindChild("CastInfoString")
	local wndRange 						= wndTopDataBlock:FindChild("RangeString")
	local wndCost						= wndTopDataBlock:FindChild("CostString")
	local wndTargeting					= wndTopDataBlock:FindChild("TargetingString")
	local wndCooldown					= wndTopDataBlock:FindChild("CooldownString")
	local wndMobility					= wndTopDataBlock:FindChild("MobilityString")
	local wndCharges					= wndTopDataBlock:FindChild("ChargesString")
	local wndGeneralDescription 		= wndTooltip:FindChild("GeneralDescriptionString")
	local wndServiceTokenDescription 	= wndTooltip:FindChild("ServiceTokenDescriptionString")

    -- Name
	wndName:SetAML(string.format("<P Font=\"CRB_HeaderSmall\" TextColor=\"UI_TextHoloTitle\">%s</P>", splSource:GetName()))

	-- Tier
	local nTier = splSource:GetTier() - 1
	local strTier = nTier == 0 and Apollo.GetString("ToolTip_BaseLowercase") or String_GetWeaselString(Apollo.GetString("Tooltips_Tier"), nTier)
	wndTier:SetText(strTier)

    -- Cast Info
	local fCastTime
	local strCastInfo = splSource:GetCastInfoString()
	local eCastMethod = splSource:GetCastMethod()
	local tChannelData = splSource:GetChannelData()

	if strCastInfo and strCastInfo ~= "" then
		fCastTime = splSource:GetCastTimeOverride()
	else
		if eCastMethod == Spell.CodeEnumCastMethod.Channeled or eCastMethod == Spell.CodeEnumCastMethod.ChanneledField then
			fCastTime = tChannelData.fMaxTime
		elseif eCastMethod == Spell.CodeEnumCastMethod.PressHold or eCastMethod == Spell.CodeEnumCastMethod.ChargeRelease then
			fCastTime = splSource:GetThresholdTime()
		else
			fCastTime = splSource:GetCastTime()
		end

		if eCastMethod == Spell.CodeEnumCastMethod.Normal or eCastMethod == Spell.CodeEnumCastMethod.Multiphase or eCastMethod == Spell.CodeEnumCastMethod.Aura then
			if fCastTime == 0 then
				strCastInfo = Apollo.GetString("Tooltip_Instant")
			else
				strCastInfo = String_GetWeaselString(Apollo.GetString("Tooltip_CastTime"), tostring(strRound(fCastTime, 2)))
			end
		elseif eCastMethod == Spell.CodeEnumCastMethod.Channeled or eCastMethod == Spell.CodeEnumCastMethod.ChanneledField then
			strCastInfo = String_GetWeaselString(Apollo.GetString("Tooltip_ChannelTime"), tostring(strRound(fCastTime, 2)))
		elseif eCastMethod == Spell.CodeEnumCastMethod.PressHold then
			strCastInfo = String_GetWeaselString(Apollo.GetString("Tooltip_HoldTime"), tostring(strRound(fCastTime, 2)))
		elseif eCastMethod == Spell.CodeEnumCastMethod.ClientSideInteraction then
			strCastInfo = Apollo.GetString("Tooltip_CSI")
		elseif eCastMethod == Spell.CodeEnumCastMethod.RapidTap then
			if fCastTime == 0 then
				strCastInfo = Apollo.GetString("Tooltips_InstantMultiTap")
			else
				strCastInfo = String_GetWeaselString(Apollo.GetString("Tooltips_CastThenMultiTap"), tostring(strRound(fCastTime, 2)))
			end
		elseif eCastMethod == Spell.CodeEnumCastMethod.ChargeRelease then
			strCastInfo = String_GetWeaselString(Apollo.GetString("Tooltips_ChargeTime"), tostring(strRound(fCastTime, 2)))
		else
			strCastInfo = Apollo.GetString("Tooltips_UnknownCastMethod")
		end
	end

	wndCastInfo:SetText(strCastInfo)
	wndCastInfo:SetHeightToContentHeight()
	nLeft, nTop, nRight, nBottom = wndCastInfo:GetAnchorOffsets()
	if wndCastInfo:GetHeight() > 20 then
		wndCastInfo:SetAnchorOffsets(nLeft, nTop, nRight, nTop + 36)
	else
		wndCastInfo:SetAnchorOffsets(nLeft, nTop, nRight, nTop + 18)
	end

	-- Range

	local nMaxRange = splSource:GetMaximumRange()
	local nMinRange = splSource:GetMinimumRange()
	if nMaxRange == 0 then
		wndRange:SetText("")
		wndRange:SetAnchorOffsets(3, 0, -3, 0)
	elseif nMinRange == 0 then
		local strRangeMinMax = String_GetWeaselString(Apollo.GetString("Tooltips_SpellRangeStatic"), Apollo.GetString("CRB_Range_"), nMaxRange, Apollo.GetString("CRB_M_Meters_Symbol"))
		wndRange:SetText(strRangeMinMax)
	else
		local strRangeMinMax = String_GetWeaselString(Apollo.GetString("Tooltips_RangeVariable"), Apollo.GetString("CRB_Range_"), nMinRange, nMaxRange, Apollo.GetString("CRB_M_Meters_Symbol"))
	    wndRange:SetText(strRangeMinMax)
    end


	-- Cost

	local strCost = splSource:GetCostInfoString() -- always use the override string if available
	if not strCost or strCost == "" then
		local tResource = {}
		local tCosts = splSource:GetCasterInnateCosts()

		if not tCosts or #tCosts == 0 then
			tCosts = splSource:GetCasterInnateRequirements()
		end

		for idx = 1, #tCosts do
			if strCost ~= "" then
				strCost = strCost .. Apollo.GetString("Tooltips_And")
			end

			tResource = tVitals[tCosts[idx].eVital]
			if not tResource then
				tResource = {}
				tResource.strName = String_GetWeaselString(Apollo.GetString("Tooltips_UnknownVital"), tCosts[idx].eVital)
			end

			tResourceData =
			{
				["name"]	= tResource.strName,
				["count"]	= tCosts[idx].nValue,
			}
			strCost = String_GetWeaselString(Apollo.GetString("Tooltips_SpellCost"), strCost, tResourceData)

			if eCastMethod == Spell.CodeEnumCastMethod.Channeled then
				strCost = String_GetWeaselString(Apollo.GetString("Tooltips_ChanneledCost"), strCost)
			elseif eCastMethod == Spell.CodeEnumCastMethod.ChargeRelease then
				strCost = String_GetWeaselString(Apollo.GetString("Tooltips_Charges"), strCost)
			end
		end
	end

	if strCost == "" then
		wndCost:SetAnchorOffsets(3, 0, -3, 0)
	end

	wndCost:SetText(strCost)


	-- Targeting

	if splSource:IsFreeformTarget() then
		wndTargeting:SetText(Apollo.GetString("Tooltips_Freeform"))
	elseif splSource:IsSelfSpell() then
		wndTargeting:SetText(Apollo.GetString("Tooltips_Self"))
	else
		wndTargeting:SetText(Apollo.GetString("Tooltips_Targeted"))
	end


	-- Cooldown / Recharge

    local fCooldownTime = splSource:GetCooldownTime()
    local tCharges = splSource:GetAbilityCharges()

	if splSource:ShouldHideCooldownInTooltip() then
		wndCooldown:SetText("")
	else
		if fCooldownTime == 0 or tCharges then
			local nChargeCount = 0
			if tCharges then
				fCooldownTime = tCharges.fRechargeTime
				nChargeCount = tCharges.nRechargeCount
			end

			if fCooldownTime == 0 then
				wndCooldown:SetText(Apollo.GetString("Tooltips_NoCooldown"))
			elseif fCooldownTime < 60 then
				wndCooldown:SetText(String_GetWeaselString(Apollo.GetString("Tooltips_RechargePerSeconds"), nChargeCount, strRound(fCooldownTime, 0)))
			else
				wndCooldown:SetText(String_GetWeaselString(Apollo.GetString("Tooltips_RechargePerMin"), nChargeCount, strRound(fCooldownTime / 60, 1)))
			end
		elseif fCooldownTime < 60 then
			wndCooldown:SetText(String_GetWeaselString(Apollo.GetString("Tooltips_SecondsCooldown"), strRound(fCooldownTime, 0)))
		else
			wndCooldown:SetText(String_GetWeaselString(Apollo.GetString("Tooltips_MinCooldown"), strRound(fCooldownTime / 60, 1)))
		end
	end


	-- Mobility

	if (eCastMethod == Spell.CodeEnumCastMethod.Normal or eCastMethod == Spell.CodeEnumCastMethod.RapidTap or eCastMethod == Spell.CodeEnumCastMethod.Multiphase) and fCastTime == 0 then
		wndMobility:SetText("")
		wndMobility:SetAnchorOffsets(3, 0, -3, 0)
	else
		if splSource:IsMovingInterrupted() then
			wndMobility:SetText(Apollo.GetString("Tooltips_Stationary"))
		else
			wndMobility:SetText(Apollo.GetString("Tooltips_Mobile"))
		end
	end


	-- Charges

	if tCharges and tCharges.nChargesMax > 1 then
		tAbilityChargeData =
		{
			["name"] = Apollo.GetString("Tooltips_AbilityCharges"),
			["count"] = tCharges.nChargesMax,
		}
	    wndCharges:SetText(String_GetWeaselString(Apollo.GetString("Tooltips_Tokens"), tAbilityChargeData))
	else
		wndCharges:SetText("")
		wndCharges:SetAnchorOffsets(3, 0, -3, 0)
    end

	-- General Description

	wndGeneralDescription:SetText(splSource:GetFlavor())
	wndGeneralDescription:SetHeightToContentHeight()

	-- Service Tokens Description
	local nCost = 0
	local monCost = splSource:GetSpellServiceTokenCost()
	if monCost then
		nCost = monCost:GetAmount()
	end

	if nCost > 0 then
		wndServiceTokenDescription:SetText(String_GetWeaselString(Apollo.GetString("Tooltip_SpellServiceTokensCanBeCast"), nCost))
		wndServiceTokenDescription:SetHeightToContentHeight()
	end
	-- Bottom Block

	local wndBottomBlock = wndTooltip:FindChild("BottomDataBlock")
	local wndNextTierString = wndBottomBlock:FindChild("NextTierBonusString")
	local wndTier4String = wndBottomBlock:FindChild("Tier4BonusString")
	local wndTier8String = wndBottomBlock:FindChild("Tier8BonusString")
	local wndRequiredLevel	= wndTooltip:FindChild("RequiredLevelString")

	if tFlags and tFlags.bTiers then
		wndBottomBlock:Show(true)

		-- Tier Bonus Text

		local tTierSpells = AbilityBook.GetAbilityInfo(splSource:GetId(), 0, 0)

		if tTierSpells and tTierSpells.tTiers and tTierSpells.tTiers[1] and tTierSpells.tTiers[5] and tTierSpells.tTiers[8] then
			local nCurrentTier = tTierSpells.nCurrentTier

			wndNextTierString:SetText(tTierSpells.tTiers[1].splObject:GetLasBonusEachTierDesc())
			wndNextTierString:SetHeightToContentHeight()

			wndTier4String:SetText(tTierSpells.tTiers[5].splObject:GetLasTierDesc())
			wndTier4String:SetHeightToContentHeight()
			if nCurrentTier >= 5 then
				wndTier4String:SetTextColor("MuddyYellow")
			end

			wndTier8String:SetText(tTierSpells.tTiers[9].splObject:GetLasTierDesc())
			wndTier8String:SetHeightToContentHeight()
			if nCurrentTier >= 9 then
				wndTier8String:SetTextColor("MuddyYellow")
			end
		else
			wndBottomBlock:Show(false)
		end


		-- Required Level

		local nRequiredLevel = splSource:GetRequiredLevel()

		if nRequiredLevel and nRequiredLevel > unitPlayer:GetLevel() then
			wndRequiredLevel:SetText(String_GetWeaselString(Apollo.GetString("Tooltips_ReqLevel"), nRequiredLevel))
			wndRequiredLevel:SetSprite("CRB_Tooltips:sprTooltip_Header")
		else
			wndRequiredLevel:SetText("")
			wndRequiredLevel:SetSprite("")
			--wndTooltip:FindChild("RequiredLevelString"):SetAnchorOffsets(3, 0, -3, 0)
		end
	end

	-- Resize Tooltip
	local nMainLeft, nMainTop, nMainRight, nMainBottom = wndTooltip:GetAnchorOffsets()
	local nBlockLeft, nBlockTop, nBlockRight, nBlockBottom = wndTopDataBlock:GetAnchorOffsets()
	local nLineHeight = 18 -- Single line height
	local nCastInfoHeight = wndTopDataBlock:FindChild("CastInfoString"):GetHeight()

	-- Resize name
	local wndTierWidth = Apollo.GetTextWidth("CRB_HeaderSmall", strTier)
	local nNameLeft, nNameTop, nNameRight, nNameBottom = wndName:GetAnchorOffsets()
	wndName:SetAnchorOffsets(nNameLeft, nNameTop, -wndTierWidth - 10, nNameBottom)
	wndName:SetHeightToContentHeight()

	local nLeft = 0
	if wndCost:GetText() == "" then
		nLeft = nLeft + 1
	end
	if wndCharges:GetText() == "" then
		nLeft = nLeft + 1
	end

	local nRight = 0
	if wndRange:GetText() == "" then
		nRight = nRight + 1
	end
	if wndMobility:GetText() == "" then
		nRight = nRight + 1
	end
	if wndTargeting:GetText() == "" then
		nRight = nRight + 1
	end

	if nLeft == 0 then
		nMainBottom = nMainBottom - (nLineHeight) - 18 + nCastInfoHeight + wndName:GetHeight() -- 18 = original line height which we're removing in favor of nCastInfoHeight
		nBlockBottom = nBlockBottom - (nLineHeight) - 18 + nCastInfoHeight + wndName:GetHeight()
	elseif nLeft == 1 or nRight == 0 then
		nMainBottom = nMainBottom - (nLineHeight * 2) - 18 + nCastInfoHeight + wndName:GetHeight()
		nBlockBottom = nBlockBottom - (nLineHeight * 2) - 18 + nCastInfoHeight + wndName:GetHeight()
	elseif nLeft <= 3 or nRight <= 2 then
		nLineHeight = nLineHeight + 10
		nMainBottom = nMainBottom - (nLineHeight * 2) - 18 + nCastInfoHeight + wndName:GetHeight()
		nBlockBottom = nBlockBottom - (nLineHeight * 2) - 18 + nCastInfoHeight + wndName:GetHeight()
	end

	nMainBottom = nMainBottom + wndGeneralDescription:GetHeight() + wndServiceTokenDescription:GetHeight() + knWndHeightPadding_Spell
	if not wndBottomBlock:IsVisible() then
		nMainBottom = nMainBottom - wndBottomBlock:GetHeight()
	else
		nMainBottom = nMainBottom + wndNextTierString:GetHeight()
		nMainBottom = nMainBottom + wndTier4String:GetHeight()
		nMainBottom = nMainBottom + wndTier8String:GetHeight()

		--[[if wndTooltip:FindChild("RequiredLevelString"):GetText() == "" then
			nMainBottom = nMainBottom - nLineHeight
		end--]]
	end

	wndTooltip:SetAnchorOffsets(nMainLeft, nMainTop, nMainRight, nMainBottom)
	wndTopDataBlock:SetAnchorOffsets(nBlockLeft, nBlockTop, nBlockRight, nBlockBottom)

	return wndTooltip
end

------------------
-- Buff Tooltip --
------------------

local function GenerateBuffTooltipForm(luaCaller, wndParent, splSource, tFlags)
	-- Initial Bad Data Checks
	if splSource == nil then
		return
	end

	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil then
		return
	end

	local wndTooltip = wndParent:LoadTooltipForm("ui\\Tooltips\\TooltipsForms.xml", "BuffTooltip_Base", luaCaller)
	wndTooltip:FindChild("NameString"):SetText(splSource:GetName())

    -- Dispellable
	local eSpellClass = splSource:GetClass()
	if eSpellClass == Spell.CodeEnumSpellClass.BuffDispellable or eSpellClass == Spell.CodeEnumSpellClass.DebuffDispellable then
		wndTooltip:FindChild("DispellableString"):SetText(Apollo.GetString("Tooltips_Dispellable"))
	else
		wndTooltip:FindChild("DispellableString"):SetText("")
	end

	-- Calculate width
	local nNameLeft, nNameTop, nNameRight, nNameBottom = wndTooltip:FindChild("NameString"):GetAnchorOffsets()
	local nNameWidth = Apollo.GetTextWidth("CRB_InterfaceLarge", splSource:GetName())
	local nDispelWidth = Apollo.GetTextWidth("CRB_InterfaceMedium", wndTooltip:FindChild("DispellableString"):GetText())
	local nOffset = math.max(0, nNameWidth + nDispelWidth + (nNameLeft * 4) - wndTooltip:FindChild("NameString"):GetWidth())

	-- Resize Tooltip width
	wndTooltip:SetAnchorOffsets(0, 0, wndTooltip:GetWidth() + nOffset, wndTooltip:GetHeight())

	-- General Description
	wndTooltip:FindChild("GeneralDescriptionString"):SetText(wndParent:GetBuffTooltip())
	wndTooltip:FindChild("GeneralDescriptionString"):SetHeightToContentHeight()

	-- Resize tooltip height
	wndTooltip:SetAnchorOffsets(0, 0, wndTooltip:GetWidth(), wndTooltip:GetHeight() + wndTooltip:FindChild("GeneralDescriptionString"):GetHeight())

	return wndTooltip
end

------------------
-- Housing Buff Tooltip --
------------------

local function GenerateHousingBuffTooltipForm(luaCaller, wndParent, splSource, tFlags)
	-- Initial Bad Data Checks
	if splSource == nil then
		return
	end

	local unitPlayer = GameLib.GetPlayerUnit()
	if unitPlayer == nil then
		return
	end

	local wndTooltip = wndParent:LoadTooltipForm("ui\\Tooltips\\TooltipsForms.xml", "BuffTooltip_Base", luaCaller)
	wndTooltip:FindChild("TopDataBlock:NameString"):SetText(splSource:GetName())

	-- General Description
	wndTooltip:FindChild("GeneralDescriptionString"):SetText(splSource:GetFlavor())
	wndTooltip:FindChild("GeneralDescriptionString"):SetHeightToContentHeight()

	wndTooltip:FindChild("DispellableString"):SetText("")

	-- Resize Tooltip
	wndTooltip:SetAnchorOffsets(0, 0, wndTooltip:GetWidth(), wndTooltip:GetHeight() + wndTooltip:FindChild("GeneralDescriptionString"):GetHeight())

	return wndTooltip
end

local function GenerateSignatureTooltipForm(luaCaller, wndParent, strUnlock)
	if not wndParent or not strUnlock then
		return
	end

	local wndTooltip = wndParent:LoadTooltipForm("ui\\Tooltips\\TooltipsForms.xml", "SignatureTooltip", luaCaller)
	local strSignaturePlayerTitle = String_GetWeaselString(Apollo.GetString("Tooltips_SignatureUnlock"), strUnlock)
	wndTooltip:FindChild("Title"):SetAML(string.format('<T Font=\"CRB_HeaderHuge\" TextColor=\"UI_TextHoloTitle\" >%s</T>', strSignaturePlayerTitle))
	local nOrigHeight = wndTooltip:GetHeight()
	local nWidth, nHeight = wndTooltip:FindChild("Title"):SetHeightToContentHeight()
	nLeft, nTop, nRight, nBottom = wndTooltip:GetAnchorOffsets()
	wndTooltip:SetAnchorOffsets(nLeft, nTop, nRight, nTop + nHeight + nOrigHeight)
end


function TaviTooltips:OnUpdateVitals()
	tVitals = Unit.GetVitalTable()
end

function strRound(nSource, nDecimals)
    return tonumber(string.format("%." .. (nDecimals or 0) .. "f", nSource))
end

---------------------------------------------------------------------------------------------------
-- WorldTooltipContainer Functions
---------------------------------------------------------------------------------------------------

function TaviTooltips:CreateCallNames()
	Tooltip.GetItemTooltipForm 			= GenerateItemTooltipForm
	Tooltip.GetSpellTooltipForm 		= GenerateSpellTooltipForm
	Tooltip.GetBuffTooltipForm 			= GenerateBuffTooltipForm
	Tooltip.GetHousingBuffTooltipForm 	= GenerateHousingBuffTooltipForm
	Tooltip.GetSignatureTooltipForm 	= GenerateSignatureTooltipForm
end

function TaviTooltips:OnGenerateWorldObjectTooltip( wndHandler, wndControl, eToolTipType, unit, strPropName )
	if eToolTipType == Tooltip.TooltipGenerateType_UnitOrProp then
		self:UnitTooltipGen(GameLib.GetWorldTooltipContainer(), unit, strPropName)
	end
end

function TaviTooltips:OnMouseOverUnitChanged(unit)
	--self:UnitTooltipGen(GameLib.GetWorldTooltipContainer(), unit, "")
end


---------------------------------------------------------------------------------------------------
-- SettingsForm Functions
---------------------------------------------------------------------------------------------------

local ToolTipInstance = TaviTooltips:new()
ToolTipInstance:Init()



function TaviTooltips:OnCloseWindow( wndHandler, wndControl, eMouseButton )
	self.wndSettings:Show(false)
end


function TaviTooltips:OnDefaults( wndHandler, wndControl, eMouseButton )
	tSettings = tDefaultSettings
	bisDefaulting = true
	self:OnSlashCommand()
end

