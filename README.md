# VChat

VChat is a Garry's Mod addon that allows supported NPCs to react to voice chat and other sounds

## Features

* Voice chat detection
* Volume-based detection range
* Wall muffling
* Underwater muffling
* Prop collision detection
* Door sound detection
* Footstep detection
* Gunshot detection
* Explosion detection
* Text chat detection
* Flashlight toggle sound detection
* ActMod emote support
* Media Player support

> Most optional sound features are disabled by default.

## Supported NPC Bases

VChat currently supports:

* Default Source Engine NPCs
* DrGBase NextBots
* VJBase SNPCs

Some NPCs may not react correctly depending on how their AI or movement systems are coded.

## Settings

All VChat settings can be found here:

`Q Menu → Utilities → VChat → VChat Settings`

You can configure:

* Voice detection
* Detection ranges
* NPC support
* Sound features
* Volume scaling
* Wall muffling
* Underwater muffling
* Debug mode

## NavMesh

NPCs may require a valid NavMesh to properly pathfind toward detected sounds.

Maps without a NavMesh may cause NPC movement or investigation behavior to not work correctly.

## For Developers

VChat includes an API that allows other developers to add compatibility for custom NPCs, addons, and sound-based systems.

Developers can extend VChat without modifying its main code.

### Custom NPC Sound Behaviors

Developers can create custom reactions for specific NPC classes.

Custom behaviors can:

* Make NPCs investigate a location
* Start custom AI behavior
* Change NPC schedules
* Trigger custom functions
* Ignore specific sounds

Example:

```lua
VChat.SoundBehaviors["my_custom_npc"] = function(npc, source, soundType, soundPos)
    npc:SetLastPosition(soundPos)
    npc:SetSchedule(SCHED_FORCED_GO_RUN)
end
```

### NPC Blacklists

Specific NPC classes can be prevented from reacting to VChat.

```lua
VChat.AddBlacklist("my_npc_class")
```

To remove an NPC from the blacklist:

```lua
VChat.RemoveBlacklist("my_npc_class")
```

This is useful for incompatible NPCs, custom AI, or NPCs that should ignore VChat completely.

### Player Immunity

Players can be made immune to VChat detection.

VChat automatically supports:

* Admin immunity
* `FL_NOTARGET` immunity
* Custom player immunity systems
* Muted players

Developers can add their own player to the immunity table:

```lua
VChat.PlayerImmunity[ply:SteamID64()] = true
```

To remove immunity:

```lua
VChat.PlayerImmunity[ply:SteamID64()] = nil
```

### Custom Sound Processing

Developers can modify how VChat calculates detection range.

Custom sound processing can affect:

* Detection range
* Voice volume scaling
* Wall muffling
* Underwater muffling
* Custom sound effects

Example:

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

This example reduces the final detection range by 50%.

### NPC Reaction Hooks

VChat provides hooks that allow other addons to interact with NPC reactions.

#### Prevent an NPC from reacting

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

Returning `false` prevents that NPC from reacting.

#### Detect NPC reactions

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

### Custom Cooldowns

VChat supports cooldowns to prevent NPC reaction spam.

Developers can set a cooldown for a specific NPC class:

```lua
VChat.NPCReactCooldowns["my_npc_class"] = 5
```

This prevents that NPC class from reacting again for 5 seconds.

VChat also supports per-NPC and per-source cooldowns.

### Creating Custom Sound Events

Developers can manually make nearby NPCs react to a custom sound:

```lua
VChat.ReactAllNPCs(
    soundPos,
    1000,
    sourceEnt,
    "custom sound",
    1,
    false
)
```

Example:

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

This makes supported NPCs within range react to the custom sound.

### Sound History

VChat records recent detected sounds from players.

This can be useful for custom systems that want to inspect a player's recent sound activity:

```lua
local history = VChat.SoundHistory[ply:SteamID64()]
```

### Custom Addon Support

Developers can use VChat to add support for:

* Custom NPC bases
* Custom NextBots
* SNPC frameworks
* Weapons
* Gamemodes
* Entities
* Custom sound sources

VChat is designed to be extended and can be used as a foundation for custom NPC hearing and sound reaction systems

## Repository Structure

```text
VChat/
├── lua/
│   └── autorun/
│       └── vchat.lua
├── README.md
├── LICENSE
└── .gitignore
```

## Forking

Anyone is free to fork and modify VChat.

If you use modify or include VChat code in another project please keep the original credits

Please do not falsely claim the original VChat project as entirely your own

## Credits

**A-m-a2021**
Creator of VChat

**V0ID**
Helped develop VChat

## License

VChat is licensed under the **VChat Custom Usage License**.

You may use, modify, and redistribute VChat for free and non-commercial purposes.

Full reuploads must contain meaningful changes, and redistributed versions must clearly credit:

**A-m-a2021 and V0ID - VChat**

See the `LICENSE` file for the complete license terms
