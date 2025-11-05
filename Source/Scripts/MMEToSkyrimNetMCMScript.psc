Scriptname MMEToSkyrimNetMCMScript extends SKI_ConfigBase

int[] toggleNpcOn
int[] toggleNpcOff

Actor thePlayer

Actor[] theActors
Form[] milkers

int toggleEnableMilkAction
int toggleEnableFeedLactacidAction

event OnConfigOpen()

    Pages = new string[2]

    Pages[0] = "Settings"
    Pages[1] = "Milkers"

    if toggleNpcOn.Length != 24
        toggleNpcOn = new int[24]
        toggleNpcOff = new int[24]
    endif

    thePlayer = Game.GetPlayer()

endevent

event OnPageReset(string page)

    SetCursorFillMode(LEFT_TO_RIGHT)
    
    SetCursorPosition(0)

    If (page == "")  
        DisplayWelcome()
    elseif page == "Settings"
        DisplaySettings()
    elseif page == "Milkers"
        DisplayMilkers()
    endif

endevent

function DisplayWelcome()
    AddTextOption("Mod Version", "0.1")
endfunction

function DisplaySettings()

    AddHeaderOption("Action Settings")
    AddHeaderOption("")

    toggleEnableMilkAction = AddToggleOption("Enable Milk Action", StorageUtil.GetIntValue(thePlayer, "mmesky_use_action_milk", 1))
    toggleEnableFeedLactacidAction = AddToggleOption("Enable Feed Lactacid Action", StorageUtil.GetIntValue(thePlayer, "mmesky_use_action_lactacid", 1))

endfunction

function DisplayMilkers()

    AddHeaderOption("Add Nearby NPC As Milker")
    AddHeaderOption("")

    theActors = MiscUtil.ScanCellActors(Game.GetPlayer(), 2000.0, none)
    int idx = 0
    int count = 0
    while idx < theActors.Length
        Actor a = theActors[idx]
        if a != thePlayer
            count += 1
            toggleNpcOn[idx] = AddTextOption(a.GetDisplayName(), "")
        endif
        idx += 1
    endwhile

    ;debug.MessageBox(theActors.Length)

    if count > 0
        if count % 2 > 0
            AddTextOption("", "")
        endif
    endif

    AddHeaderOption("Valid Milkers")
    AddHeaderOption("")

    milkers = StorageUtil.FormListToArray(thePlayer, "mmetosky_milkers")
    idx = 0
    while idx < milkers.Length
        Actor a = milkers[idx] as Actor
        toggleNpcOff[idx] = AddTextOption(a.GetDisplayName(), "")
        idx += 1
    endwhile

endfunction

event OnOptionSelect(int option)

    bool forceRefresh = false

    if option == toggleEnableMilkAction
        int currentValue = StorageUtil.GetIntValue(thePlayer, "mmesky_use_action_milk", 1)
        int newValue = 1
        if currentValue == 1
            newValue = 0
        endif
        StorageUtil.SetIntValue(thePlayer, "mmesky_use_action_milk", newValue)
        SetToggleOptionValue(option, newValue)
    endif

    if option == toggleEnableFeedLactacidAction
        int currentValue = StorageUtil.GetIntValue(thePlayer, "mmesky_use_action_lactacid", 1)
        int newValue = 1
        if currentValue == 1
            newValue = 0
        endif
        StorageUtil.SetIntValue(thePlayer, "mmesky_use_action_lactacid", newValue)
        SetToggleOptionValue(option, newValue)
    endif

    int idx = 0
    while idx < toggleNpcOff.Length
        if option == toggleNpcOff[idx]
            StorageUtil.FormListRemove(thePlayer, "mmetosky_milkers", milkers[idx])
            forceRefresh = true
        endif
        idx += 1
    endwhile

    idx = 0
    while idx < toggleNpcOn.Length
        if option == toggleNpcOn[idx]
            if !StorageUtil.FormListHas(thePlayer, "mmetosky_milkers", theActors[idx])
                StorageUtil.FormListAdd(thePlayer, "mmetosky_milkers", theActors[idx])
            endif
            forceRefresh = true
        endif
        idx += 1
    endwhile

    if forceRefresh
        ForcePageReset()
    endif

endevent