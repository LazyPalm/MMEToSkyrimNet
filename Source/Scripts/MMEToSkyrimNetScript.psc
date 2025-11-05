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

endfunction

bool function Milk_IsEligible(Actor akOriginator, string contextJson, string paramsJson) global

    bool result = false

    ;scan for nearby milk maids
    MilkQUEST mq = Quest.GetQuest("MME_MilkQUEST") as MilkQUEST
    Actor[] theActors = MiscUtil.ScanCellActors(Game.GetPlayer(), 1000.0, none)
    int idx = 0
    while idx < theActors.Length
        Actor a = theActors[idx]
        if a.IsInFaction(mq.MilkMaidFaction)
            idx = 500 ;break the loop
            result = true
        endif
        idx += 1
    endwhile

    return result

endfunction

function Milk_Execute(Actor akOriginator, string contextJson, string paramsJson) global

    Actor akTarget = SkyrimNetApi.GetJsonActor(paramsJson, "target", none) 

    if akTarget == none
        debug.Notification("No milking actor was sent by Milk Action")
        return
    endif

    MilkQUEST mq = Quest.GetQuest("MME_MilkQUEST") as MilkQUEST
    mq.MilkTarget.Cast(akOriginator, akTarget)

    SkyrimNetApi.DirectNarration(akTarget.GetDisplayName() + " is being milked by " + akOriginator.GetDisplayName())

endfunction

Faction property MMEToSkyrimNetCurrentMilkFaction auto
Faction property MMEToSkyrimNetLactacidFaction auto
Faction property MMEToSkyrimNetMaxMilkFaction auto