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

VChat includes systems that can be extended for custom addons and NPCs.

Developers can add:

* Custom NPC sound behaviors
* NPC blacklists
* Player immunity
* Custom sound processing
* NPC reaction hooks
* Custom cooldown behavior

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

VChat is licensed under the **MIT License**.
