Scriptname ThePlayerScript extends ReferenceAlias  

event OnPlayerLoadGame()

    MMEToSkyrimNetScript m = Quest.GetQuest("MMEToSkyrimNetQuest") as MMEToSkyrimNetScript
    m.LoadGame()

endevent