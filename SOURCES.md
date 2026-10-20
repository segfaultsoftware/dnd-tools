# Research and source notes

Accessed October 8, 2026.

The generator's lookup entries and prose were written for this project. Community sources were used to compare category coverage, weighting strategies, generator architecture, and the kinds of details game masters find useful; their tables were not copied wholesale. Proprietary D&D book tables were not transcribed.

## Official and open rules sources

- [System Reference Document 5.2.1](https://www.dndbeyond.com/srd) is the primary mechanical source. Its monster rules define the 2024 stat-block fields, Hit Dice by size, CR/XP, proficiency bonus, Gear, actions, reactions, and related terminology. Its open humanoid stat blocks supplied calibration examples.
- [SRD 5.2 PDF under CC BY 4.0](https://media.dndbeyond.com/compendium-images/srd/5.2/SRD_CC_v5.2.pdf) was consulted for the Commoner, Bandit, Berserker, Cultist, Guard, Guard Captain, Knight, Mage, Noble, Pirate, Priest, Scout, and Warrior examples.
- [2024 Basic Rules: How to Use a Monster](https://www.dndbeyond.com/sources/dnd/br-2024/how-to-use-a-monster) documents the meaning of the current stat-block entries and warns that combat-oriented magic items can affect CR.
- [2024 Basic Rules: Rules Glossary](https://www.dndbeyond.com/sources/dnd/br-2024/rules-glossary) supplies the current definitions of Challenge Rating, conditions, actions, and other rules terms.
- [2024 Free Rules overview](https://www.dndbeyond.com/posts/1804-start-playing-today-with-the-2024-d-d-free-rules) distinguishes the Free Rules from SRD 5.2 and summarizes their scope.
- [Official tour of Forgotten Realms locations](https://www.dndbeyond.com/posts/1485-take-a-tour-of-these-popular-locations-in-the) informed the broad, rebuilding-era portrayal of Neverwinter and the surrounding Sword Coast.
- [The Five Factions](https://www.dndbeyond.com/sources/dnd/basic-rules-2014/appendix-c-the-five-factions) was used for high-level faction roles. Affiliation is intentionally uncommon in the generator.
- [Gods of the Multiverse](https://www.dndbeyond.com/sources/dnd/basic-rules-2014/appendix-b-gods-of-the-multiverse) was used to check Forgotten Realms deity names and portfolios.
- [Running the first chapter of *Vecna: Eve of Ruin*](https://www.dndbeyond.com/posts/1731-running-the-1st-chapter-of-vecna-eve-of-ruin) supplied an official recent depiction of Neverwinter as cosmopolitan and as the film's major Sword Coast city.

## Setting and demographic cross-checks

These are secondary references, used as orientation rather than as authoritative current canon.

- [Forgotten Realms Wiki: Sword Coast North](https://forgottenrealms.fandom.com/wiki/Sword_Coast_North) helped identify settlements, exports, historic demographic estimates, and the region's rough boundaries.
- [Forgotten Realms Wiki: Northwest Faerûn](https://forgottenrealms.fandom.com/wiki/Northwest_Faer%C3%BBn) helped select wilderness regions and roads around Neverwinter.
- [Forgotten Realms Wiki: Neverwinter](https://forgottenrealms.fandom.com/wiki/Neverwinter) was used to cross-check names, geography, and late-fifteenth-century context.
- [Realms Helps: The North](https://www.realmshelps.net/faerun/north.shtml) was used to cross-check characteristic exports and regional organizations.

The species percentages in `npc_data.py` are an original, deliberately approximate campaign model—not a claim about a particular canonical year. Location profiles apply small multipliers rather than hard demographic rules.

## Community generators and random-table design

- [FyefoxxM/npc-generator](https://github.com/FyefoxxM/npc-generator) (MIT) demonstrates a useful separation among names, traits, occupations, secrets, and hooks, as well as deterministic generation and trait-conflict concerns.
- [Random-Tables/utility-npc-fantasy](https://github.com/Random-Tables/utility-npc-fantasy) (MIT) separates youth, past roles, life events, hobbies, and occupations into composable history elements.
- [NonFlavia/Fantasy_NPC_generator](https://github.com/NonFlavia/Fantasy_NPC_generator) (MIT-0) provides another open implementation to compare role and class categorization.
- [NPC Generate](https://www.npcgenerate.com/) demonstrates per-field locking, role-driven story hooks, and a stat-block-oriented output model.
- [Ashengold NPC & Tavern Generator](https://ashengold.gg/tools/npc-generator/) emphasizes a compact combination of job, mannerism, want, and hidden information.
- [Oracle RPG NPC Generator](https://oracle-rpg.com/2021/10/the-npc-generator/) uses separate personality and motivation passes for quick improvisational NPCs.
- [Dndspeak: 100 NPC Personality Traits](https://www.dndspeak.com/2022/01/23/100-npc-personality-traits/) helped assess the breadth and table usefulness of physical habits, beliefs, aspirations, and social behaviors.
- [MultiLoop: NPC Motivations](https://multiloop.app/tools/random-tables/npcs/motivations) highlights the useful distinction between visible needs and hidden motivations.
- [Borough Bound: d100 NPCs](https://blog.boroughbound.com/d100-npcs-to-populate-your-tabletop-city/) was used to compare urban role coverage and the balance between ordinary and adventure-facing people.
- [Praxxian Fantasy City Generator](https://praxxian.github.io/RPG-City-Generator/) informed the idea that settlement type should modify population and occupation weights.
- [RPGnet discussion of fantasy NPC occupations](https://forum.rpg.net/index.php?threads/fantasy-npc-occupations.919421/) was used as a cross-check for overlooked practical trades.
- [d20 Game Master's historic professions index](https://d20.pub/resources/459-historic-professions-jobs-and-trades-for-fantasy-rpg-settings/) was used to check the breadth of agriculture, craft, transport, civic, and service work.
- [Julia H. West's fantasy/medieval occupation list](https://www.juliahwest.com/prompts/fantasy_job_list.html) supplied another independent occupation-coverage check.
- [Wikipedia: List of obsolete occupations](https://en.wikipedia.org/wiki/List_of_obsolete_occupations) helped verify that less familiar trade names describe real work rather than invented jargon.
- [r/d100: memorable NPC behaviors](https://www.reddit.com/r/d100/comments/i1853a/d100_memorable_npc_behaviors/) reinforced separating stable personality from a visible table mannerism.
- [r/d100: NPC motivations](https://www.reddit.com/r/d100/comments/bxbfnm/lets_build_d100_npc_motivations/) was used to compare the range from immediate material needs to long-term ideals.
- [r/d100: simple NPC quirks](https://www.reddit.com/r/d100/comments/j9pxsc/d100_somewhat_simple_npc_quirks/) was used to check that quirks remain playable rather than overwhelming the character.
- [r/d100: unusual carried items](https://www.reddit.com/r/d100/comments/1s37ixp/oc_d100_unusual_items_npcs_carry/) reinforced using one personal object as an implied story rather than filling every pocket with plot devices.
- [r/d100: attitudes toward adventurers](https://www.reddit.com/r/d100/comments/j0zqq6/d50_attitudes_civilians_might_have_towards/) helped check that ordinary NPCs need not automatically admire or oppose adventurers.

## Licensing

Required SRD attribution:

> This work includes material from the System Reference Document 5.2 ("SRD 5.2") by Wizards of the Coast LLC, available at https://www.dndbeyond.com/srd. The SRD 5.2 is licensed under the Creative Commons Attribution 4.0 International License, available at https://creativecommons.org/licenses/by/4.0/legalcode.

That attribution is also appended to every generated Markdown document so copied campaign-wiki entries remain self-contained.

