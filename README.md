# VChat

VChat lets supported NPCs react to player voice chat and other sounds.

## Features

- Voice chat detection with volume-based range
- Wall and underwater muffling
- Prop collision, door, footstep, gunshot, and explosion detection
- Text chat and flashlight toggle detection
- ActMod emote support
- Media Player support
- Configurable detection ranges, NPC support, and debug output

Most optional sound detections are disabled by default.

## Supported NPC Bases

- Default Source Engine NPCs
- DrGBase NextBots
- VJBase SNPCs

Some NPCs may not investigate sounds correctly because of how their AI or movement is set up.

## Settings

Open the settings from:

`Q Menu → Utilities → VChat → VChat Settings`

The menu includes voice detection, detection ranges, NPC base support, sound features, volume scaling, wall and underwater muffling, and debug mode.

## NavMesh

Some NPCs need a valid NavMesh to move toward a sound. On maps without one, an NPC may detect the sound but fail to reach its source.

## Contributing

Contributions are welcome. Useful contributions include bug fixes, compatibility updates, testing, and small features. Contributors to the original VChat project will receive credit.

You can also make your own version of VChat. If you make a useful fix or improvement, please share it with the original project so it can be considered for inclusion.

## For Developers

VChat has an API for adding custom NPC reactions, changing sound ranges, and responding to NPC reactions. Add your code in a separate addon; you do not need to edit VChat's main file.

### Custom NPC Sound Behaviors

Set a behavior for an NPC class in `VChat.SoundBehaviors`:

```lua
VChat.SoundBehaviors["my_custom_npc"] = function(npc, source, soundType, soundPos)
    npc:SetLastPosition(soundPos)
    npc:SetSchedule(SCHED_FORCED_GO_RUN)
end
```

Return `false` from the function to report that the behavior did not handle the sound.

### NPC Blacklist

Prevent an NPC class from reacting:

```lua
VChat.AddBlacklist("my_npc_class")
```

Allow it to react again:

```lua
VChat.RemoveBlacklist("my_npc_class")
```

### Player Immunity

VChat can skip players listed in `VChat.PlayerImmunity`:

```lua
VChat.PlayerImmunity[ply:SteamID64()] = true
```

Remove the entry to restore detection for that player:

```lua
VChat.PlayerImmunity[ply:SteamID64()] = nil
```

VChat also has settings and checks for admin immunity, `FL_NOTARGET`, and muted players.

### Custom Sound Range

Add a function to `VChat.SoundFeatures.Custom` to adjust the range calculated for each listener. Return the range that VChat should use next:

```lua
VChat.SoundFeatures.Custom["my_addon"] = function(
    range,
    sourcePos,
    listenerPos,
    sourceEnt,
    volume
)
    return range * 0.5
end
```

This example halves the range.

### NPC Reaction Hooks

Use `VChat_PreNPCReact` to stop one NPC from reacting. Returning `false` prevents that NPC's reaction:

```lua
hook.Add("VChat_PreNPCReact", "MyAddon_PreventReaction", function(
    npc,
    source,
    soundType,
    soundPos,
    range
)
    if npc:GetClass() == "my_npc_class" then
        return false
    end
end)
```

Use `VChat_OnNPCReact` to find out when VChat finishes checking a sound:

```lua
hook.Add("VChat_OnNPCReact", "MyAddon_NPCReact", function(
    sourcePos,
    range,
    sourceEnt,
    soundType,
    volume,
    reactedCount
)
    print(reactedCount .. " NPCs reacted to " .. soundType)
end)
```

### NPC Cooldowns

Set a reaction cooldown in seconds for an NPC class:

```lua
VChat.NPCReactCooldowns["my_npc_class"] = 5
```

VChat also tracks per-NPC, per-source cooldowns for supported integrations.

### Trigger a Custom Sound

Call `VChat.ReactAllNPCs` to make supported NPCs check a sound source:

```lua
VChat.ReactAllNPCs(
    ent:GetPos(),
    1500,
    ent,
    "custom alarm",
    1,
    false
)
```

The arguments are the sound position, base range, source entity, sound name, volume, and whether this is voice chat.

### Sound History

VChat keeps recent sound records by player SteamID64. Read a player's history with:

```lua
local history = VChat.SoundHistory[ply:SteamID64()]
```

### Other Addon Support

The API can be used to add support for custom NPCs, NextBots, SNPC frameworks, weapons, entities, gamemodes, and sound sources.

## Repository Structure

```text
VChat/
├── lua/
│   └── autorun/
│       └── vchat.lua
└── README.md
```

## Forking

You may fork and modify VChat. Keep the original credits, follow the license, and do not claim the original project as entirely your own.

## Credits

- **A-m-a2021** — Creator of VChat
- **V0ID** — Development help

## License

VChat is licensed under the **VChat Custom Usage License**. It may be used, modified, and redistributed for free for non-commercial purposes. Full reuploads must include meaningful changes and credit **A-m-a2021 and V0ID - VChat**.
