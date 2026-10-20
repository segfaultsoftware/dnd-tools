# Sword Coast NPC Generator

`scripts/create-npc` creates a grounded Forgotten Realms NPC as Markdown. Each NPC includes a reproducible seed, history, personality, goals, secrets, possessions, and a complete fifth-edition-compatible 2024-style monster stat block.

The default generator is centered on the wilderness, roads, villages, and small towns around Neverwinter, while also covering the broader Sword Coast and Western Heartlands. Ordinary people are common. Powerful combatants, faction agents, spellcasters, and magic items are deliberately rare.

## First-time setup

Install Python 3.11 or newer, then check that it is available:

```powershell
py --version
```

The generator uses only Python's standard library, so there are no packages to install.

## Generate an NPC

From the root of this project on Windows:

```powershell
py scripts/create-npc
```

On macOS or Linux, use `python3` in place of `py`:

```sh
python3 scripts/create-npc
```

The Markdown is printed in the terminal. The bottom of every result contains the random seed, which recreates that exact result:

```powershell
py scripts/create-npc --seed 1499
```

To write directly to a wiki-ready Markdown file:

```powershell
py scripts/create-npc --output my-npc.md
```

The script refuses to replace an existing file unless `--force` is supplied.

## Lock in details

Every lock-in is optional and can be combined with any other lock-in:

```powershell
py scripts/create-npc --location phandalin --occupation blacksmith
py scripts/create-npc --species dwarf --faith moradin --cr 3
py scripts/create-npc --faction harpers --archetype scout --min-cr 1 --max-cr 3
py scripts/create-npc --name "Mara Vell" --gender woman --pronouns she-her --age 42
```

Generate several distinct NPCs in one Markdown document:

```powershell
py scripts/create-npc --count 6 --location leilon --max-cr 1 --output leilon-townsfolk.md
```

Run the full help command to see every flag and every supported value, including all occupations, locations, faiths, factions, and mechanical archetypes:

```powershell
py scripts/create-npc --help
```

## What is randomized

- Sword Coast location and origin, with a Neverwinter-region bias
- species, age, gender, pronouns, and a culture-aware full name
- a weighted livelihood drawn from more than one hundred ordinary and unusual occupations
- appearance, voice, mannerism, personality, ideal, bond, and flaw
- upbringing, career turning point, formative event, present goal, obstacle, secret, and rumor
- faith and faction affiliation, with unaffiliated NPCs far more common than agents
- recoverable combat gear, work gear, practical belongings, cash, and a keepsake
- a rare chance of a minor wonder or actual magic item
- CR 0–5 monster-style statistics and features appropriate to the selected occupation and archetype

## Mechanical approach

The stat blocks use the 2024 monster presentation: AC, Initiative score, average HP plus Hit Dice, all six score/modifier/save values, skills, Gear, Senses, Languages, CR/XP/PB, and separated Traits, Actions, Bonus Actions, and Reactions.

The numbers are generated consistently:

- proficiency bonus is derived from CR;
- attack rolls, saving throw DCs, skills, saves, passive Perception, AC, Initiative, and HP are calculated from the displayed statistics;
- Hit Dice use the correct die size for the creature's displayed size;
- recoverable equipment is listed separately from supernatural or specialized actions;
- magic items are excluded from the stated CR unless their effects are already represented in the block.

CR profiles are calibrated against the open-licensed humanoid examples in SRD 5.2, including the Commoner, Guard, Scout, Bandit, Berserker, Priest, Knight, Warrior Veteran, and Guard Captain. Generated NPCs are original variations rather than claims of being official published creatures.

## Customize the tables

All lookup data lives in [`scripts/npc_data.py`](scripts/npc_data.py). The most useful sections to edit are:

- `LOCATION_WEIGHTS` — how often an unlocked location appears;
- `LOCATIONS` — per-location multipliers for occupations, species, and factions;
- `SPECIES_WEIGHTS`, `CATEGORY_WEIGHTS`, `FACTION_WEIGHTS`, and `FAITH_WEIGHTS` — global population assumptions;
- `OCCUPATIONS` and the narrative lists — the content pools;
- `CR_WEIGHTS` — how often each challenge rating occurs.

To add a campaign village, copy one `Location(...)` entry, give it a new slug, and add its global chance to `LOCATION_WEIGHTS`. If the village should use only global population assumptions, its three bias dictionaries can be empty.

## Tests

```powershell
py -m unittest discover -s tests -v
```

Research notes, licensing details, and the official/community sources used to design the original tables are in [`SOURCES.md`](SOURCES.md).

