---@type DoorlockConfig
---@diagnostic disable-next-line: missing-fields
Config = {}

---Trigger a notification on the client when the door state is successfully updated.
Config.Notify = true

---Create a persistent notification while in-range of a door, prompting to lock/unlock.
Config.DrawTextUI = false

---Allow the specified ace principal to use 'command.doorlock'.
Config.CommandPrincipal = 'group.admin'

---Allow players with the 'command.doorlock' principal to use any door.
Config.PlayerAceAuthorised = false

---The default skill check difficulty when lockpicking a door.
Config.LockDifficulty = { 'easy', 'easy', 'medium' }

---Allow lockpicks to be used to lock an unlocked door.
Config.CanPickUnlockedDoors = false

---An array of items that function as lockpicks.
Config.LockpickItems = {
    'lockpick'
}

---Play sounds using game audio (sound natives) instead of through NUI.
Config.NativeAudio = false
