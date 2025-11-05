Scriptname MMEToSkyrimNetScript extends Quest  

event OnInit()

    if self.IsRunning()
        LoadGame()
    endif

endevent

function LoadGame()

    if !Game.IsPluginInstalled("MilkModNEW.esp")
        debug.MessageBox("MilkModNEW.esp was not found")
        return
    endif

    RegisterForActions()

    UnregisterForUpdate()
    RegisterForUpdate(10.0)

endfunction

event OnUpdate()

    MilkQUEST mq = Quest.GetQuest("MME_MilkQUEST") as MilkQUEST

    Actor[] theActors = MiscUtil.ScanCellActors(Game.GetPlayer(), 1000.0, none)
    int idx = 0
    while idx < theActors.Length
        Actor a = theActors[idx]
        if a.IsInFaction(mq.MilkMaidFaction)
            a.SetFactionRank(MMEToSkyrimNetCurrentMilkFaction, MME_Storage.getMilkCurrent(a) as int)
            a.SetFactionRank(MMEToSkyrimNetMaxMilkFaction, MME_Storage.getMilkMaximum(a) as int)
            a.SetFactionRank(MMEToSkyrimNetLactacidFaction, MME_Storage.getLactacidCurrent(a) as int)
        endif
        idx += 1
    endwhile

    RegisterForUpdate(120.0)

endevent

function RegisterForActions()

    SkyrimNetApi.RegisterAction("Milk", "Use this to milk a nearby milkmaid.", \
                                    "MMEToSkyrimNetScript", "Milk_IsEligible", \
                                    "MMEToSkyrimNetScript", "Milk_Execute", \
                                    "", "PAPYRUS", \
                                    1, "{\"target\":\"Actor\"}", "", "")   

    SkyrimNetApi.RegisterAction("FeedLactacid", "Use this to feed more Lactacid to a nearby milkmaid. This will make them produce milk.", \
                                    "MMEToSkyrimNetScript", "FeedLactacid_IsEligible", \
                                    "MMEToSkyrimNetScript", "FeedLactacid_Execute", \
                                    "", "PAPYRUS", \
                                    1, "{\"target\":\"Actor\"}", "", "")                                   

endfunction

bool function FeedLactacid_IsEligible(Actor akOriginator, string contextJson, string paramsJson) global

    if StorageUtil.GetIntValue(Game.GetPlayer(), "mmesky_use_action_lactacid", 1) == 0
        MiscUtil.PrintConsole("MMEToSkyrimNetScript - milk action disabled")
        return false
    endif

    if !StorageUtil.FormListHas(Game.GetPlayer(), "mmetosky_milkers", akOriginator)
        MiscUtil.PrintConsole("MMEToSkyrimNetScript - not in valid milkers list")
        return false
    endif

    return true

endfunction

bool function Milk_IsEligible(Actor akOriginator, string contextJson, string paramsJson) global

    if StorageUtil.GetIntValue(Game.GetPlayer(), "mmesky_use_action_milk", 1) == 0
        MiscUtil.PrintConsole("MMEToSkyrimNetScript - milk action disabled")
        return false
    endif

    if !StorageUtil.FormListHas(Game.GetPlayer(), "mmetosky_milkers", akOriginator)
        MiscUtil.PrintConsole("MMEToSkyrimNetScript - not in valid milkers list")
        return false
    endif

    ; ;scan for nearby milk maids
    ; MilkQUEST mq = Quest.GetQuest("MME_MilkQUEST") as MilkQUEST
    ; Actor[] theActors = MiscUtil.ScanCellActors(Game.GetPlayer(), 1000.0, none)
    ; int idx = 0
    ; while idx < theActors.Length
    ;     Actor a = theActors[idx]
    ;     if a.IsInFaction(mq.MilkMaidFaction)
    ;         idx = 500 ;break the loop
    ;         result = true
    ;     endif
    ;     idx += 1
    ; endwhile

    return true

endfunction

function FeedLactacid_Execute(Actor akOriginator, string contextJson, string paramsJson) global

    Actor akTarget = SkyrimNetApi.GetJsonActor(paramsJson, "target", none) 

    if akTarget == none
        MiscUtil.PrintConsole("No milking actor was sent by Milk Action")
        return
    endif

    MilkQUEST mq = Quest.GetQuest("MME_MilkQUEST") as MilkQUEST
    if !akTarget.IsInFaction(mq.MilkMaidFaction)
        MiscUtil.PrintConsole("Targeted actor is not a milk maid")
        return
    endif

    if MME_Storage.getLactacidCurrent(akTarget) >= 5.0
        ;don't add too much - mcm setting?
        MiscUtil.PrintConsole("Targeted actor has enough Lactacid")
        return
    endif

    int qty = Utility.RandomInt(1, 5)
    int i = 0
    while i < qty
        akTarget.EquipItem(mq.MME_Util_Potions.GetAt(0), true, true)
        Utility.Wait(0.1)
        i += 1
    endwhile

    SkyrimNetApi.DirectNarration(akOriginator.GetDisplayName() + " feeds " + akTarget.GetDisplayName() + qty + " bottles of Lactacid")

endfunction

function Milk_Execute(Actor akOriginator, string contextJson, string paramsJson) global

    Actor akTarget = SkyrimNetApi.GetJsonActor(paramsJson, "target", none) 

    if akTarget == none
        MiscUtil.PrintConsole("No milking actor was sent by Milk Action")
        return
    endif

    MilkQUEST mq = Quest.GetQuest("MME_MilkQUEST") as MilkQUEST
    if !akTarget.IsInFaction(mq.MilkMaidFaction)
        MiscUtil.PrintConsole("Targeted actor is not a milk maid")
        return
    endif

    mq.MilkTarget.Cast(akOriginator, akTarget)

    SkyrimNetApi.DirectNarration(akTarget.GetDisplayName() + " is being milked by " + akOriginator.GetDisplayName())

endfunction

Faction property MMEToSkyrimNetCurrentMilkFaction auto
Faction property MMEToSkyrimNetLactacidFaction auto
Faction property MMEToSkyrimNetMaxMilkFaction auto