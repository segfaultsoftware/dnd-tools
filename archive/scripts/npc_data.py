"""Original lookup data for the Sword Coast NPC generator.

The tables in this file were synthesized for this project.  See SOURCES.md for
the official rules references and community generators/tables that informed
the categories and approach.  Entries are not transcriptions of proprietary
random tables.
"""

from __future__ import annotations

from dataclasses import dataclass, field


CR_ORDER = ("0", "1/8", "1/4", "1/2", "1", "2", "3", "4", "5")
CR_XP = {
    "0": 10,
    "1/8": 25,
    "1/4": 50,
    "1/2": 100,
    "1": 200,
    "2": 450,
    "3": 700,
    "4": 1_100,
    "5": 1_800,
}
CR_WEIGHTS = {
    "0": 28,
    "1/8": 28,
    "1/4": 15,
    "1/2": 12,
    "1": 9,
    "2": 4.5,
    "3": 2,
    "4": 1,
    "5": 0.5,
}
CR_PROFILES = {
    "0": {"hit_dice": 1, "attacks": 1, "dice": 1, "extra": None},
    "1/8": {"hit_dice": 2, "attacks": 1, "dice": 1, "extra": None},
    "1/4": {"hit_dice": 3, "attacks": 1, "dice": 1, "extra": (1, 4)},
    "1/2": {"hit_dice": 4, "attacks": 2, "dice": 1, "extra": None},
    "1": {"hit_dice": 6, "attacks": 2, "dice": 1, "extra": (1, 4)},
    "2": {"hit_dice": 8, "attacks": 2, "dice": 1, "extra": (2, 4)},
    "3": {"hit_dice": 10, "attacks": 2, "dice": 2, "extra": None},
    "4": {"hit_dice": 11, "attacks": 2, "dice": 3, "extra": None},
    "5": {"hit_dice": 13, "attacks": 3, "dice": 2, "extra": None},
}


@dataclass(frozen=True)
class Species:
    name: str
    name_profiles: tuple[str, ...]
    age_range: tuple[int, int]
    mature_age: int
    old_age: int
    size: str = "Medium"
    darkvision: bool = False
    language: str | None = None


SPECIES = {
    "human": Species("Human", ("northlander", "heartlander", "southern"), (18, 82), 30, 60),
    "dwarf": Species("Dwarf", ("dwarven",), (35, 340), 70, 240, darkvision=True, language="Dwarvish"),
    "elf": Species("Elf", ("elven",), (55, 720), 120, 520, darkvision=True, language="Elvish"),
    "halfling": Species("Halfling", ("halfling",), (20, 160), 45, 115, size="Small", language="Halfling"),
    "gnome": Species("Gnome", ("gnomish",), (30, 430), 75, 310, size="Small", darkvision=True, language="Gnomish"),
    "half-elf": Species("Half-Elf", ("heartlander", "northlander", "elven"), (18, 180), 40, 130, darkvision=True, language="Elvish"),
    "orc": Species("Orc", ("orcish",), (16, 90), 30, 65, darkvision=True, language="Orc"),
    "half-orc": Species("Half-Orc", ("northlander", "heartlander", "orcish"), (17, 100), 35, 72, darkvision=True, language="Orc"),
    "tiefling": Species("Tiefling", ("heartlander", "infernal"), (18, 105), 35, 78, darkvision=True, language="Infernal"),
    "dragonborn": Species("Dragonborn", ("draconic",), (15, 95), 32, 70, language="Draconic"),
    "goliath": Species("Goliath", ("giantkin",), (18, 100), 35, 72, language="Giant"),
    "aasimar": Species("Aasimar", ("heartlander", "celestial"), (18, 160), 45, 115, darkvision=True, language="Celestial"),
    "goblin": Species("Goblin", ("goblin",), (15, 80), 28, 58, size="Small", darkvision=True, language="Goblin"),
}

SPECIES_WEIGHTS = {
    "human": 55,
    "dwarf": 10,
    "orc": 6,
    "half-orc": 5,
    "elf": 6,
    "halfling": 6,
    "gnome": 3,
    "half-elf": 3,
    "tiefling": 2,
    "dragonborn": 1.5,
    "goliath": 1,
    "aasimar": 0.5,
    "goblin": 1,
}


# These are original, setting-compatible pools rather than copied D&D name
# tables.  Combining a given name, stored surname, or constructed surname gives
# hundreds of thousands of plausible results.
NAME_POOLS = {
    "northlander": {
        "masculine": "Aldren Arvik Brandel Corren Dain Edrik Garran Halvar Jorek Kael Luth Merrek Orin Roder Sten Tavin Ulric Wulvar".split(),
        "feminine": "Alda Brynja Catrin Dagna Elska Freya Gerda Halla Inga Jora Kara Linna Marra Runa Sella Tova Yrsa".split(),
        "neutral": "Ash Brin Dalen Eir Fen Hollis Kest Linden Merrin Rowan Tal Vey".split(),
        "surnames": "Ashdown Blackmere Coldwater Duskwood Evenwood Frost Graymantle Hardwick Ironwood Kettlebrook Longwake Northcott Reed Stonebridge Thorne Underbough Vale Wainwright Wintermere".split(),
        "prefixes": "Ash Black Cold Dawn Deep Far Frost Gray High Iron North Oak Raven Red Stone Storm West Winter".split(),
        "suffixes": "brook field ford hall hand hearth hill keep mark mere ridge shore stead stone vale ward wood".split(),
    },
    "heartlander": {
        "masculine": "Alric Bennet Carden Darron Edric Ferren Garrick Harlan Iven Jarret Leoric Marlow Nellan Perrin Roric Tomas Varden Willet".split(),
        "feminine": "Adela Brinna Celene Daria Ellyn Fara Giselle Hettie Isolde Jessa Liora Mara Nerys Odelia Pella Sabine Tressa Willa".split(),
        "neutral": "Avery Clem Darcy Emery Jory Kit Loren Marden Robin Sable Teryn Wynn".split(),
        "surnames": "Alder Bell Bramblebrook Carrow Dene Fairbairn Gorse Hart Holloway Jansen Kells Lark Mercer Pike Reed Rowanby Tanner Vell Weller Yarrow".split(),
        "prefixes": "Alder Amber Bright Brook Fair Gold Green Hart Hazel Kings Lark Low Merry New Quick Rose Silver South Thorn".split(),
        "suffixes": "bank bell bury cross dale den field ford gate ham ley man mill mont well wick worth yard".split(),
    },
    "southern": {
        "masculine": "Amin Barak Cassan Davir Esan Farid Hatem Idran Jamil Kadir Lucan Masir Nadim Rafi Samir Tarik Varun Zahir".split(),
        "feminine": "Amina Basira Calia Dalia Esra Farah Hana Ilyra Jamila Kessa Lina Mina Nasra Rima Safiya Tala Yara Zahra".split(),
        "neutral": "Ari Dima Eren Ilya Kavi Maris Noor Rian Sami Tali Vasha Zia".split(),
        "surnames": "Aban Arcos Belan Corvi Damar Enzar Farouq Ghalin Hazar Ibarra Jassan Korran Lucero Miran Nassar Orani Raval Saran Tovan Veyra".split(),
        "prefixes": "Amber Azure Bright Cedar Dawn Ember Gold Ivory Moon Olive Red River Sand Star Sun White".split(),
        "suffixes": "bloom crest flame hand light moon river rose sand sky song star veil wind wing".split(),
    },
    "dwarven": {
        "masculine": "Ardin Berrik Dorram Fendrik Gorren Harn Kazrik Lodrin Marnik Norrum Odran Sarvek Torren Varram Yorrik".split(),
        "feminine": "Anbera Brunna Dorria Elda Fenni Gurren Helgra Kazra Loda Marni Norra Orda Sarda Torra Vella".split(),
        "neutral": "Ari Berr Dorr Fen Grem Kori Lod Nori Tald Varr".split(),
        "surnames": "Ashenforge Anvilward Barrelhand Coppervein Deepdelver Embermantle Flintguard Goldbraid Graniteborn Hammerfall Ironkeg Lodestone Redpick Slatefist Stonebrow Tinwhistle Trueanvil Underpeak".split(),
        "prefixes": "Amber Anvil Black Copper Deep Ember Flint Gold Granite Hammer Iron Red Silver Slate Stone True".split(),
        "suffixes": "axe beard brow delver fist forge hand heart helm keg mantle pick shield vein ward".split(),
    },
    "elven": {
        "masculine": "Aevrin Caeril Daelion Eryndor Faenor Galaris Haevan Ilvaren Laethor Merion Naelor Othir Quenavel Saerion Thaelor Vaeris".split(),
        "feminine": "Aelira Briniel Caevra Darethiel Elauna Faerisse Ilythra Laevyn Meraleth Nuala Orelia Quessara Saelith Tiralyn Vaelora Wyneth".split(),
        "neutral": "Aeri Cael Eiren Iri Leth Nael Quen Sael Talien Vael Wyn".split(),
        "surnames": "Briarglade Clearbrook Dewsong Evenbough Fernmere Greenharp Larksong Mistvale Moonbrook Nightwillow Oakwhisper Riverleaf Silversong Starbough Sunmeadow Thornshade Windmere".split(),
        "prefixes": "Briar Dawn Dew Even Fern Green Lark Mist Moon Night Oak River Silver Star Sun Thorn Wind".split(),
        "suffixes": "bough brook dance leaf light meadow mist song star vale walk whisper wind wing wood".split(),
    },
    "halfling": {
        "masculine": "Aldo Bramwell Carden Derry Ebbin Fennick Garlan Hob Jory Larkin Merrit Ollo Perren Tobble Wilby".split(),
        "feminine": "Adra Bessam Cally Dovina Elsie Fenna Hettan Jilla Ketta Lorry Mara Nella Posy Tressa Willa".split(),
        "neutral": "Bram Derry Joss Lark Merry Pip Robin Tansy Val Wren".split(),
        "surnames": "Applewick Brushgather Clovertop Greenbottle Hearthkin Highhill Kettlebrook Meadowfoot Merryweather Quickstep Reedfellow Tealeaf Thornpatch Underbough Warmwater".split(),
        "prefixes": "Apple Berry Brush Clover Green Hazel High Honey Meadow Quick Reed Rose Tea Thorn Warm".split(),
        "suffixes": "blossom bottle burrow foot gather hill kettle leaf patch step top water way whistle wick".split(),
    },
    "gnomish": {
        "masculine": "Bennik Boddle Cobbin Dimmick Fendel Gerran Hobble Jerrin Kippel Marnik Noddle Perren Rollo Tovin Werrick".split(),
        "feminine": "Bimma Brennik Corra Dovvi Ellawin Fippa Grenna Kessi Lillabet Morra Nibbi Olla Rinna Tessa Wobba".split(),
        "neutral": "Bix Coggle Dabb Fenwick Gim Nib Pock Quill Tink Wob".split(),
        "surnames": "Bellwhistle Clockbutton Cobbleturn Fizzlegear Gearwhim Glittergem Knobspinner Nacklepin Pockle Sprocketspin Timberturn Twistwhistle Wobblecork".split(),
        "prefixes": "Bright Clock Cobble Copper Fizzle Gear Glitter Nackle Pock Sprocket Tinker Twist Wobble".split(),
        "suffixes": "button cork gear gem knob spark spin spring tink top whistle wick".split(),
    },
    "orcish": {
        "masculine": "Argran Bruk Dorgath Ekkar Garuk Hargan Keth Lugor Murog Narg Othok Rukar Sharn Thokk Ugar Varg".split(),
        "feminine": "Arha Bagra Drenna Ekkra Gharra Hura Korga Mazha Nagra Orgha Rasha Shavra Torga Urga Vola".split(),
        "neutral": "Azh Brakka Drek Ghar Kesh Morra Ruk Shak Targ Vesh".split(),
        "surnames": "Ashscar Blacktusk BrokenSpear Emberhide Graywolf Ironjaw Longstride Mossback Redhand Riverwalker Stonefang Stormhide Thornfoot Wolfkin".split(),
        "prefixes": "Ash Black Ember Gray Iron Long Moss Red River Stone Storm Thorn Wolf".split(),
        "suffixes": "back fang foot hand hide jaw kin scar spear stride tusk walker".split(),
    },
    "infernal": {
        "masculine": "Avaros Barzel Caldris Demeon Evarix Istran Kaivor Lethras Malver Nerion Oryx Sevran Thaezir Varek".split(),
        "feminine": "Avarra Brisia Calyra Demeia Erixa Ilyss Kaevra Lethira Maelis Neris Oryssa Sevria Thesra Veyra".split(),
        "neutral": "Ash Cinder Creed Echo Ember Fable Haven Kindle Rune Sable Vesper".split(),
        "surnames": "Ashvein Brightbrand Cinderwake Duskryn Emberfall Farrow Flameveil Gloam Hollow Nightglass Redwake Sablethorn Shadowend Vesper Windscar".split(),
        "prefixes": "Ash Bright Cinder Dark Dusk Ember Flame Gloam Night Red Sable Shadow Vesper".split(),
        "suffixes": "brand fall glass heart mark thorn veil vein wake ward wind".split(),
    },
    "draconic": {
        "masculine": "Arvash Belkhor Darveth Gheran Haskor Kelvash Medrakar Nareth Orvann Praxar Rethik Shavorn Tazrek Vorann Zethar".split(),
        "feminine": "Arvara Belira Dareth Ghesra Hasira Kelvara Medrassa Nareen Orvara Praxia Rethara Shavira Tazra Vorissa Zethra".split(),
        "neutral": "Arix Dar Kesh Khor Nym Rax Sar Taz Vesh Zorr".split(),
        "surnames": "Ardranex Belmoraath Cindervrax Darethkesh Embervaal Fenrakor Ghorvannis Kelmorath Linxavarr Myrastan Norvaketh Ophrendrix Praxilor Shestavar Turnuroth Verthikaan".split(),
        "prefixes": "Arj Bel Dra Fen Kesh Lin Myr Nor Oph Prex Rhog Shes Tor Ver".split(),
        "suffixes": "adrix ardon astan atuur enthis ixius molik orim thurgiesh uth vex".split(),
    },
    "giantkin": {
        "masculine": "Arvak Borun Dathar Eigan Gorram Hekar Kothan Lurok Marvek Norrak Orun Pethar Toruk Uvar Vekran".split(),
        "feminine": "Arva Borra Datha Eiga Gorra Heka Kotha Lura Marva Norra Orra Petha Tora Uva Vekra".split(),
        "neutral": "Aru Gath Kala Kori Maka Nao Peth Talu Ura Vek".split(),
        "surnames": "Bear-Shelter Dawncaller Flintfinder Goat-Keeper Highclimber Horncarver Keen-Eye Lonehunter River-Crosser Skywatcher Stonebreaker Stormwalker Tallpine Threadweaver".split(),
        "prefixes": "Bear Dawn Flint Goat High Horn Keen Lone River Sky Stone Storm Tall".split(),
        "suffixes": "breaker caller carver climber crosser eye finder hunter keeper shelter walker watcher".split(),
    },
    "celestial": {
        "masculine": "Adriel Cassiel Elyon Gavriel Hadriel Iophiel Malachiel Nahariel Oriphiel Raziel Samyaza Uriel Zuriel".split(),
        "feminine": "Ariella Cassia Eliana Galiel Hadria Ilyra Liora Michaela Neriah Oriel Raziela Seraphine Uriela".split(),
        "neutral": "Aster Dawn Elian Halo Lux Mercy Nova Radiant Sol Vesper".split(),
        "surnames": "Brightwater Dawnmantle Evenstar Graceward Lightfall Mercyhand Moonveil Radiant Starling Sunward Trueheart Vale Ward Wing".split(),
        "prefixes": "Bright Dawn Even Grace Light Mercy Moon Radiant Star Sun True".split(),
        "suffixes": "fall hand heart mantle star vale veil ward water wing".split(),
    },
    "goblin": {
        "masculine": "Bik Brik Dakk Fizz Grit Krek Mogg Nib Ruk Skab Tikk Vrak Wizz Zik".split(),
        "feminine": "Bikka Dizza Frik Grena Kikka Mib Nakka Rikka Skriz Tikka Vezza Wikka Zarra".split(),
        "neutral": "Bop Crik Fip Kip Nix Pak Razz Snip Tock Zip".split(),
        "surnames": "Bentnail Bramblefoot Copperpot Crookedcap Ditchrunner Foxbite Mudlark Needlefingers Quickwick Ratchet Reednose Sootface Tinspoon Underlog".split(),
        "prefixes": "Bent Bramble Copper Crooked Ditch Fox Mud Needle Quick Reed Soot Tin".split(),
        "suffixes": "bite cap fingers foot lark nail nose pot runner spoon wick".split(),
    },
}


@dataclass(frozen=True)
class Location:
    name: str
    kind: str
    blurb: str
    category_bias: dict[str, float] = field(default_factory=dict)
    species_bias: dict[str, float] = field(default_factory=dict)
    faction_bias: dict[str, float] = field(default_factory=dict)


LOCATIONS = {
    "neverwinter": Location(
        "Neverwinter", "city", "the rebuilding Jewel of the North",
        {"craft": 1.7, "civic": 1.6, "trade": 1.4, "arcane": 1.4, "rural": 0.35},
        {"human": 0.9, "dwarf": 1.3, "half-elf": 1.3, "tiefling": 1.2},
        {"neverwinter-guard": 3.0, "lords-alliance": 2.0, "trade-guild": 1.7},
    ),
    "phandalin": Location(
        "Phandalin", "frontier town", "a mining and farming settlement beneath the Sword Mountains",
        {"rural": 1.5, "craft": 1.3, "trade": 1.2, "wilderness": 1.4},
        {"dwarf": 1.8, "gnome": 1.4, "halfling": 1.2},
        {"local-militia": 2.3, "miners-guild": 2.2},
    ),
    "leilon": Location(
        "Leilon", "small town", "a resettled waystop between Neverwinter and Waterdeep",
        {"rural": 1.3, "transport": 1.6, "craft": 1.3, "civic": 1.2},
        {"human": 1.1, "halfling": 1.2},
        {"lords-alliance": 1.5, "local-militia": 2.0},
    ),
    "port-llast": Location(
        "Port Llast", "coastal town", "a stubborn harbor settlement north of Neverwinter",
        {"maritime": 3.0, "trade": 1.3, "craft": 1.2, "rural": 0.6},
        {"human": 1.1, "half-orc": 1.2},
        {"local-militia": 1.8, "smugglers-ring": 1.5},
    ),
    "helms-hold": Location(
        "Helm's Hold", "fortified town", "a walled refuge and pilgrimage town near Neverwinter",
        {"religious": 2.8, "civic": 1.6, "service": 1.3, "military": 1.4},
        {"human": 1.1, "aasimar": 1.8},
        {"order-gauntlet": 2.7, "temple": 2.2, "local-militia": 1.5},
    ),
    "triboar": Location(
        "Triboar", "market town", "a caravan crossroads on the edge of the Dessarin Valley",
        {"trade": 1.8, "transport": 2.0, "rural": 1.2, "service": 1.3},
        {"human": 1.1, "halfling": 1.3},
        {"lords-alliance": 1.5, "trade-guild": 2.1, "zhentarim": 1.4},
    ),
    "triboar-trail": Location(
        "Triboar Trail", "wilderness road", "a rough east-west road through forest and foothills",
        {"transport": 2.2, "wilderness": 2.2, "rural": 0.8, "criminal": 1.6},
        {"goblin": 2.2, "orc": 1.5, "half-orc": 1.3},
        {"emerald-enclave": 1.7, "zhentarim": 1.4, "smugglers-ring": 1.5},
    ),
    "high-road": Location(
        "the High Road", "coastal road", "the long trade road along the Sword Coast",
        {"transport": 2.4, "trade": 1.5, "wilderness": 1.3, "criminal": 1.3},
        {"human": 1.1, "halfling": 1.2},
        {"lords-alliance": 1.4, "zhentarim": 1.3, "harpers": 1.2},
    ),
    "neverwinter-wood": Location(
        "Neverwinter Wood", "deep forest", "an old and magically touched forest",
        {"wilderness": 4.0, "rural": 0.6, "craft": 0.5, "arcane": 1.5},
        {"elf": 3.0, "half-elf": 1.8, "gnome": 1.5, "human": 0.55},
        {"emerald-enclave": 3.5, "harpers": 1.4},
    ),
    "sword-mountains": Location(
        "the Sword Mountains", "mountain wilderness", "rocky peaks and mining country south of Neverwinter",
        {"wilderness": 2.6, "rural": 0.7, "craft": 1.3, "military": 1.2},
        {"dwarf": 3.0, "goliath": 2.5, "orc": 1.6, "gnome": 1.4},
        {"miners-guild": 2.4, "emerald-enclave": 1.4},
    ),
    "mere-of-dead-men": Location(
        "the Mere of Dead Men", "marsh wilderness", "a haunted marshland along the High Road",
        {"wilderness": 3.6, "transport": 1.3, "criminal": 1.5, "rural": 0.3},
        {"human": 0.8, "half-orc": 1.5, "goblin": 1.5},
        {"emerald-enclave": 2.0, "smugglers-ring": 1.8},
    ),
    "kryptgarden": Location(
        "Kryptgarden Forest", "forest wilderness", "a shadowed forest east of the Sword Mountains",
        {"wilderness": 3.8, "rural": 0.5, "arcane": 1.3},
        {"elf": 2.2, "half-elf": 1.5, "gnome": 1.4},
        {"emerald-enclave": 2.8, "harpers": 1.3},
    ),
    "luskan": Location(
        "Luskan", "city", "the hard-edged City of Sails north of Neverwinter",
        {"maritime": 2.5, "trade": 1.4, "criminal": 2.0, "arcane": 1.7, "rural": 0.25},
        {"human": 1.1, "half-orc": 1.4, "tiefling": 1.3},
        {"arcane-brotherhood": 3.0, "smugglers-ring": 2.0, "zhentarim": 1.2},
    ),
    "mirabar": Location(
        "Mirabar", "mining city", "a wealthy northern city of mines and stonework",
        {"craft": 2.2, "trade": 1.5, "military": 1.2, "rural": 0.3},
        {"dwarf": 3.2, "gnome": 1.3},
        {"miners-guild": 3.0, "lords-alliance": 1.8, "trade-guild": 1.7},
    ),
    "longsaddle": Location(
        "Longsaddle", "village", "a pastoral settlement on the Long Road",
        {"rural": 2.0, "wilderness": 1.3, "service": 1.2, "arcane": 1.1},
        {"human": 1.1, "halfling": 1.5},
        {"local-militia": 1.7, "harpers": 1.2},
    ),
    "yartar": Location(
        "Yartar", "river town", "a fortified trade town on the River Surbrin",
        {"trade": 1.7, "transport": 1.8, "maritime": 1.5, "criminal": 1.2},
        {"human": 1.1, "halfling": 1.2},
        {"lords-alliance": 1.6, "zhentarim": 1.3, "trade-guild": 1.7},
    ),
    "waterdeep": Location(
        "Waterdeep", "metropolis", "the City of Splendors far down the High Road",
        {"trade": 1.7, "craft": 1.5, "civic": 1.6, "service": 1.5, "arcane": 1.6, "rural": 0.15},
        {"human": 0.85, "all": 1.25},
        {"lords-alliance": 2.0, "harpers": 1.7, "trade-guild": 2.0, "zhentarim": 1.2},
    ),
    "daggerford": Location(
        "Daggerford", "town", "a walled market town guarding a crossing of the Delimbiyr",
        {"rural": 1.4, "trade": 1.3, "military": 1.4, "transport": 1.3},
        {"human": 1.1, "halfling": 1.2},
        {"lords-alliance": 1.7, "local-militia": 2.0},
    ),
    "baldurs-gate": Location(
        "Baldur's Gate", "metropolis", "the crowded mercantile city on the lower Sword Coast",
        {"trade": 1.8, "maritime": 1.7, "criminal": 1.8, "civic": 1.5, "rural": 0.1},
        {"human": 0.9, "tiefling": 1.5, "dragonborn": 1.4},
        {"flaming-fist": 2.5, "trade-guild": 1.8, "zhentarim": 1.3, "smugglers-ring": 1.6},
    ),
}

LOCATION_WEIGHTS = {
    "neverwinter": 20,
    "phandalin": 12,
    "leilon": 8,
    "port-llast": 6,
    "helms-hold": 6,
    "triboar": 6,
    "triboar-trail": 8,
    "high-road": 8,
    "neverwinter-wood": 7,
    "sword-mountains": 5,
    "mere-of-dead-men": 3,
    "kryptgarden": 3,
    "luskan": 3,
    "mirabar": 1.5,
    "longsaddle": 1.5,
    "yartar": 1.5,
    "waterdeep": 1,
    "daggerford": 0.5,
    "baldurs-gate": 0.5,
}


@dataclass(frozen=True)
class Occupation:
    name: str
    category: str
    archetypes: tuple[str, ...]
    tool_or_wares: str
    weight: float = 1.0


def _slug(text: str) -> str:
    return text.lower().replace("'", "").replace(" ", "-")


_OCCUPATION_ROWS = [
    # Rural and food production
    ("Apiarist", "rural", ("civilian", "scout"), "smoker, veil, and two jars of honey", 0.7),
    ("Apple grower", "rural", ("civilian",), "pruning knife and a sack of sound apples", 1.0),
    ("Cattle herder", "rural", ("civilian", "scout"), "herding crook and salt lick", 1.2),
    ("Dairy farmer", "rural", ("civilian",), "small churn and wrapped cheese", 1.0),
    ("Farmhand", "rural", ("civilian",), "sickle and work gloves", 2.2),
    ("Field farmer", "rural", ("civilian",), "hoe, seed pouch, and whetstone", 2.5),
    ("Fisher", "rural", ("civilian", "scout"), "fishing tackle and gutting knife", 1.7),
    ("Goatherd", "rural", ("civilian", "scout"), "crook and a pouch of coarse salt", 1.0),
    ("Hunter", "rural", ("scout",), "snare wire and skinning knife", 1.0),
    ("Miller", "rural", ("civilian",), "flour scoop and mill keys", 0.8),
    ("Orchard keeper", "rural", ("civilian",), "pruning hook and grafting twine", 0.8),
    ("Shepherd", "rural", ("civilian", "scout"), "crook and shepherd's whistle", 1.2),
    ("Trapper", "rural", ("scout",), "three small traps and hide scraper", 0.7),
    ("Woodcutter", "rural", ("civilian", "warrior"), "wood axe, wedges, and cord", 1.4),
    # Crafts
    ("Armorer", "craft", ("civilian", "guard"), "smith's tools and armor rivets", 0.5),
    ("Baker", "craft", ("civilian",), "baker's peel and a paper twist of yeast", 1.4),
    ("Basketmaker", "craft", ("civilian",), "reed knife and bundled osiers", 0.8),
    ("Blacksmith", "craft", ("civilian", "warrior"), "smith's tools and iron stock", 1.2),
    ("Bowyer", "craft", ("civilian", "scout"), "woodcarver's tools and bowstaves", 0.5),
    ("Brewer", "craft", ("civilian",), "brewer's supplies and a hop sample", 0.9),
    ("Carpenter", "craft", ("civilian",), "carpenter's tools and chalk line", 1.3),
    ("Cartwright", "craft", ("civilian",), "carpenter's tools and wheel gauge", 0.7),
    ("Chandler", "craft", ("civilian",), "candle molds, wick, and tallow", 0.7),
    ("Cobbler", "craft", ("civilian",), "cobbler's tools and spare laces", 0.9),
    ("Cooper", "craft", ("civilian",), "cooper's adze and hoop iron", 0.8),
    ("Dyer", "craft", ("civilian",), "dyer's gloves and packets of pigment", 0.6),
    ("Fletcher", "craft", ("civilian", "scout"), "woodcarver's tools and goose feathers", 0.6),
    ("Glassworker", "craft", ("civilian",), "glassblower's tools and colored cullet", 0.3),
    ("Jeweler", "craft", ("civilian", "expert"), "jeweler's tools and a loupe", 0.35),
    ("Leatherworker", "craft", ("civilian",), "leatherworker's tools and waxed cord", 0.9),
    ("Locksmith", "craft", ("expert",), "tinker's tools and key blanks", 0.35),
    ("Mason", "craft", ("civilian",), "mason's tools and plumb bob", 1.0),
    ("Potter", "craft", ("civilian",), "potter's tools and wrapped clay", 0.8),
    ("Ropemaker", "craft", ("civilian",), "marlinspike and hemp cord", 0.7),
    ("Shipwright", "craft", ("civilian", "expert"), "carpenter's tools and caulking oakum", 0.6),
    ("Tailor", "craft", ("civilian",), "weaver's tools and measuring cord", 1.0),
    ("Tanner", "craft", ("civilian",), "scraping knife and bark liquor", 0.7),
    ("Tinker", "craft", ("civilian", "expert"), "tinker's tools and wire", 0.8),
    ("Weaver", "craft", ("civilian",), "weaver's tools and a spindle", 1.0),
    ("Woodcarver", "craft", ("civilian",), "woodcarver's tools and unfinished figurine", 0.8),
    # Service and domestic work
    ("Bathhouse attendant", "service", ("civilian",), "soap, towels, and locker keys", 0.5),
    ("Cook", "service", ("civilian",), "cook's utensils and spice roll", 1.3),
    ("Groom", "service", ("civilian", "scout"), "brush, hoof pick, and oats", 0.8),
    ("Healer", "service", ("expert", "devotee"), "healer's kit and clean bandages", 0.6),
    ("Innkeeper", "service", ("civilian", "expert"), "ring of room keys and account slate", 0.9),
    ("Launderer", "service", ("civilian",), "lye soap and clothes pegs", 0.9),
    ("Messenger", "service", ("scout", "expert"), "message case and sealing wax", 0.8),
    ("Midwife", "service", ("expert",), "healer's kit and swaddling cloth", 0.5),
    ("Musician", "service", ("expert",), "musical instrument and spare strings", 0.8),
    ("Ostler", "service", ("civilian",), "stable keys and currycomb", 0.8),
    ("Ratcatcher", "service", ("scout",), "small traps, sack, and thick gloves", 0.7),
    ("Server", "service", ("civilian",), "apron, serving cloth, and bottle opener", 1.1),
    ("Street sweeper", "service", ("civilian",), "stiff broom and rubbish hook", 0.7),
    ("Tavern keeper", "service", ("civilian", "expert"), "tap key and chalkboard tally", 1.0),
    ("Undertaker", "service", ("civilian", "devotee"), "measuring cord and scented salts", 0.35),
    # Trade
    ("Cloth merchant", "trade", ("expert", "leader"), "fabric samples and merchant's scale", 0.7),
    ("Drover", "trade", ("civilian", "scout"), "drover's staff and bill of sale", 0.8),
    ("General merchant", "trade", ("expert", "leader"), "merchant's scale and order book", 1.2),
    ("Grain factor", "trade", ("expert",), "grain samples and contracts", 0.5),
    ("Herbalist", "trade", ("expert", "devotee"), "herbalism kit and dried herbs", 0.8),
    ("Market hawker", "trade", ("civilian", "expert"), "tray of small wares and coin apron", 1.0),
    ("Mineral assessor", "trade", ("expert",), "magnifying lens, scale, and sample hammer", 0.3),
    ("Moneychanger", "trade", ("expert",), "merchant's scale and lockbox key", 0.35),
    ("Peddler", "trade", ("civilian", "expert"), "pack of needles, ribbons, and tinware", 1.1),
    ("Salt merchant", "trade", ("expert", "leader"), "salt samples and trade warrants", 0.4),
    ("Timber factor", "trade", ("expert", "leader"), "calipers and timber tallies", 0.5),
    # Transport and road work
    ("Barge hand", "transport", ("civilian", "warrior"), "boat hook and tarred gloves", 0.8),
    ("Caravan guard", "transport", ("guard", "warrior"), "route map and signal whistle", 1.0),
    ("Caravan master", "transport", ("leader", "expert"), "route book and cargo seals", 0.5),
    ("Carter", "transport", ("civilian",), "wagon tools and feed sack", 1.2),
    ("Courier", "transport", ("scout",), "waterproof dispatch case", 0.7),
    ("Ferrier", "transport", ("civilian",), "toll tokens and coil of rope", 0.4),
    ("Guide", "transport", ("scout",), "local map and weather cloak", 0.8),
    ("Teamster", "transport", ("civilian",), "whip, spare harness buckle, and feed", 1.0),
    ("Toll collector", "transport", ("guard", "expert"), "tally board and lockbox key", 0.5),
    # Maritime
    ("Dockhand", "maritime", ("civilian", "warrior"), "cargo hook and tarred rope", 1.3),
    ("Harbor pilot", "maritime", ("expert", "scout"), "coastal chart and signal flags", 0.45),
    ("Net maker", "maritime", ("civilian",), "netting needle and twine", 0.7),
    ("Sailmaker", "maritime", ("civilian",), "sailmaker's palm and waxed thread", 0.6),
    ("Sailor", "maritime", ("civilian", "warrior", "scout"), "belaying pin and coil of line", 1.5),
    ("Ship's purser", "maritime", ("expert", "leader"), "cargo ledger and seal", 0.35),
    ("Smuggler", "maritime", ("outlaw", "scout"), "false-bottom pouch and coded manifest", 0.35),
    # Civic and learned
    ("Bailiff", "civic", ("guard", "leader"), "writs and badge of office", 0.5),
    ("Clerk", "civic", ("expert",), "ink, quills, and document case", 0.9),
    ("Herald", "civic", ("expert", "leader"), "heraldic notes and polished tabard", 0.35),
    ("Interpreter", "civic", ("expert",), "phrasebook and writing kit", 0.3),
    ("Lamplighter", "civic", ("civilian",), "lighting pole, oil, and tinderbox", 0.5),
    ("Magistrate", "civic", ("leader", "expert"), "seal of office and case notes", 0.25),
    ("Scribe", "civic", ("expert",), "calligrapher's supplies and parchment", 0.8),
    ("Surveyor", "civic", ("expert", "scout"), "surveyor's chain and charcoal map", 0.4),
    ("Teacher", "civic", ("expert",), "chalk, slate, and lesson notes", 0.6),
    ("Town crier", "civic", ("expert",), "handbell and notice roll", 0.4),
    # Military and dangerous work
    ("Bounty hunter", "military", ("scout", "warrior"), "wanted notices and manacles", 0.35),
    ("Gate guard", "military", ("guard",), "signal whistle and gate token", 1.2),
    ("Mercenary", "military", ("warrior", "guard"), "contract chit and weapon oil", 0.8),
    ("Militia member", "military", ("guard", "civilian"), "militia badge and signal whistle", 1.0),
    ("Retired soldier", "military", ("warrior", "civilian"), "old service badge and whetstone", 0.8),
    ("Road warden", "military", ("guard", "scout"), "warrant, manacles, and whistle", 0.55),
    ("Scout", "military", ("scout",), "map case and signal horn", 0.6),
    ("Soldier", "military", ("warrior", "guard"), "unit token and mess kit", 1.0),
    ("Watch officer", "military", ("leader", "guard"), "badge of rank and duty roster", 0.45),
    # Wilderness
    ("Charcoal burner", "wilderness", ("civilian", "scout"), "charcoal sack and fire rake", 0.8),
    ("Forager", "wilderness", ("scout",), "gathering basket and field knife", 1.0),
    ("Forester", "wilderness", ("scout", "guard"), "marking axe and boundary map", 0.8),
    ("Hermit", "wilderness", ("civilian", "devotee"), "herb bundle and patched blanket", 0.5),
    ("Prospector", "wilderness", ("scout", "expert"), "rock hammer and sample sack", 0.8),
    ("Ranger", "wilderness", ("scout", "warrior"), "trail rations and map scraps", 0.35),
    ("Resin gatherer", "wilderness", ("civilian", "scout"), "scraper and stoppered resin pots", 0.6),
    ("Wilderness warden", "wilderness", ("scout", "leader"), "boundary tokens and field journal", 0.4),
    # Religious
    ("Acolyte", "religious", ("devotee",), "holy symbol and prayer book", 1.1),
    ("Grave tender", "religious", ("civilian", "devotee"), "spade, incense, and prayer cord", 0.7),
    ("Itinerant preacher", "religious", ("devotee", "expert"), "holy symbol and worn sermons", 0.45),
    ("Priest", "religious", ("devotee", "leader"), "holy symbol and vestments", 0.65),
    ("Shrine keeper", "religious", ("devotee", "civilian"), "holy symbol, lamp oil, and offering key", 0.8),
    ("Temple healer", "religious", ("devotee", "expert"), "holy symbol and healer's kit", 0.45),
    # Arcane and unusual learned trades
    ("Alchemist", "arcane", ("arcanist", "expert"), "alchemist's supplies and ingredient vials", 0.6),
    ("Astrologer", "arcane", ("arcanist", "expert"), "star charts and brass dividers", 0.35),
    ("Hedge mage", "arcane", ("arcanist",), "wand, chalk, and spell notes", 0.7),
    ("Magic tutor", "arcane", ("arcanist", "expert"), "wand and lesson folio", 0.35),
    ("Potion brewer", "arcane", ("arcanist", "expert"), "alchemist's supplies and stoppered flasks", 0.4),
    ("Rune carver", "arcane", ("arcanist", "expert"), "mason's tools and rubbing paper", 0.35),
    ("Sage", "arcane", ("arcanist", "expert"), "reference folio and writing kit", 0.45),
    # Crime and marginal work
    ("Bandit", "criminal", ("outlaw",), "face scarf and stolen purse", 0.9),
    ("Burglar", "criminal", ("outlaw", "expert"), "thieves' tools and dark lantern", 0.55),
    ("Fence", "criminal", ("expert", "outlaw"), "coded price list and appraisal lens", 0.4),
    ("Poacher", "criminal", ("scout", "outlaw"), "snare wire and unmarked hides", 0.7),
    ("Roadside robber", "criminal", ("outlaw",), "road mask and cut purse", 0.6),
    ("Spy", "criminal", ("expert", "outlaw"), "disguise kit and cipher strip", 0.25),
    ("Thief", "criminal", ("outlaw",), "thieves' tools and chalk marks", 0.7),
]

OCCUPATIONS = {
    _slug(name): Occupation(name, category, archetypes, tool_or_wares, weight)
    for name, category, archetypes, tool_or_wares, weight in _OCCUPATION_ROWS
}

CATEGORY_WEIGHTS = {
    "rural": 27,
    "craft": 19,
    "service": 13,
    "trade": 9,
    "transport": 8,
    "maritime": 5,
    "civic": 5,
    "military": 5,
    "wilderness": 5,
    "religious": 2.5,
    "arcane": 0.7,
    "criminal": 0.8,
}


FACTIONS = {
    "none": ("Unaffiliated", "answers chiefly to family, neighbors, and whoever holds local authority"),
    "local-militia": ("Local militia", "serves when the settlement bell or horn calls"),
    "trade-guild": ("A local trade guild", "protects the interests and standards of a working trade"),
    "miners-guild": ("A miners' fellowship", "shares claims, warnings, and mutual aid among miners"),
    "temple": ("A local temple", "helps maintain a shrine and supports its charitable work"),
    "neverwinter-guard": ("Neverwinter Guard", "serves the city's watch or outlying patrols"),
    "flaming-fist": ("Flaming Fist", "serves the mercenary authority associated with Baldur's Gate"),
    "lords-alliance": ("Lords' Alliance", "quietly advances the security of allied northern settlements"),
    "harpers": ("Harpers", "passes information to those resisting tyranny and dangerous concentrations of power"),
    "emerald-enclave": ("Emerald Enclave", "works to preserve balance between settlement and wilderness"),
    "order-gauntlet": ("Order of the Gauntlet", "confronts threats judged too dangerous to leave unchecked"),
    "zhentarim": ("Zhentarim", "trades favors and services through the Black Network"),
    "arcane-brotherhood": ("Arcane Brotherhood", "supports or serves Luskan's ambitious wizardly institution"),
    "smugglers-ring": ("A smugglers' ring", "moves goods and messages around tolls and official scrutiny"),
}

FACTION_WEIGHTS = {
    "none": 80,
    "local-militia": 4.5,
    "trade-guild": 3.5,
    "miners-guild": 1.0,
    "temple": 2.5,
    "neverwinter-guard": 1.5,
    "flaming-fist": 0.15,
    "lords-alliance": 1.5,
    "harpers": 0.8,
    "emerald-enclave": 1.2,
    "order-gauntlet": 0.8,
    "zhentarim": 1.0,
    "arcane-brotherhood": 0.35,
    "smugglers-ring": 1.2,
}

FAITHS = {
    "none": ("No single patron", "observes the common rites of the North as circumstances demand"),
    "chauntea": ("Chauntea", "agriculture, growth, and the patient work of cultivation"),
    "tymora": ("Tymora", "good fortune, bold choices, and travelers' luck"),
    "lathander": ("Lathander", "renewal, hope, and beginnings"),
    "selune": ("Selûne", "the moon, navigation, and those who wander by night"),
    "torm": ("Torm", "duty, loyalty, and courage"),
    "tyr": ("Tyr", "justice and honorable judgment"),
    "helm": ("Helm", "vigilance, guardianship, and protection"),
    "ilmater": ("Ilmater", "endurance, compassion, and relief of suffering"),
    "tempus": ("Tempus", "battle, courage, and the fortunes of war"),
    "mielikki": ("Mielikki", "forests, rangers, and the wild places"),
    "silvanus": ("Silvanus", "untamed nature and natural balance"),
    "gond": ("Gond", "craft, invention, and practical ingenuity"),
    "waukeen": ("Waukeen", "trade, wealth, and fair opportunity"),
    "oghma": ("Oghma", "knowledge, learning, and ideas"),
    "mystra": ("Mystra", "magic and the responsible use of the Weave"),
    "sune": ("Sune", "beauty, love, and art"),
    "kelemvor": ("Kelemvor", "the dead, rightful passage, and honest remembrance"),
    "umberlee": ("Umberlee", "the sea's danger and the price of safe passage"),
    "moradin": ("Moradin", "dwarven creation, family, and the forge"),
    "corellon": ("Corellon", "elven art, magic, and self-expression"),
    "yondalla": ("Yondalla", "halfling community, home, and protection"),
    "gruumsh": ("Gruumsh", "orcish strength, survival, and conquest"),
}

FAITH_WEIGHTS = {
    "none": 24,
    "chauntea": 12,
    "tymora": 9,
    "lathander": 7,
    "selune": 7,
    "torm": 5,
    "tyr": 4,
    "helm": 4,
    "ilmater": 4,
    "tempus": 4,
    "mielikki": 3,
    "silvanus": 2,
    "gond": 3,
    "waukeen": 3,
    "oghma": 2,
    "mystra": 2,
    "sune": 2,
    "kelemvor": 2,
    "umberlee": 1,
    "moradin": 1,
    "corellon": 1,
    "yondalla": 1,
    "gruumsh": 0.5,
}

FAITH_CATEGORY_BIAS = {
    "rural": {"chauntea": 3, "lathander": 1.5, "mielikki": 1.3},
    "craft": {"gond": 3, "moradin": 1.5},
    "trade": {"waukeen": 3, "tymora": 1.5},
    "transport": {"tymora": 2, "selune": 1.6},
    "maritime": {"umberlee": 5, "selune": 2, "tymora": 1.3},
    "civic": {"tyr": 2.5, "torm": 1.6, "oghma": 1.5},
    "military": {"tempus": 3, "helm": 2, "torm": 2, "tyr": 1.5},
    "wilderness": {"mielikki": 3, "silvanus": 3, "selune": 1.4},
    "religious": {"none": 0.2},
    "arcane": {"mystra": 5, "oghma": 2},
    "criminal": {"tymora": 1.7, "none": 1.6},
}

ALIGNMENTS = {
    "lawful-good": "Lawful Good",
    "neutral-good": "Neutral Good",
    "chaotic-good": "Chaotic Good",
    "lawful-neutral": "Lawful Neutral",
    "neutral": "Neutral",
    "chaotic-neutral": "Chaotic Neutral",
    "lawful-evil": "Lawful Evil",
    "neutral-evil": "Neutral Evil",
    "chaotic-evil": "Chaotic Evil",
}
ALIGNMENT_WEIGHTS = {
    "lawful-good": 8,
    "neutral-good": 19,
    "chaotic-good": 8,
    "lawful-neutral": 15,
    "neutral": 32,
    "chaotic-neutral": 12,
    "lawful-evil": 2,
    "neutral-evil": 2.5,
    "chaotic-evil": 1.5,
}


ARCHETYPES = {
    "civilian": {
        "name": "Civilian",
        "scores": (10, 10, 10, 10, 10, 10),
        "primary": "str",
        "saves": (),
        "skills": (),
        "expertise": (),
        "armor": "none",
        "melee": ("Club", 4, "Bludgeoning", "str"),
        "ranged": None,
        "initiative": False,
    },
    "expert": {
        "name": "Skilled Expert",
        "scores": (10, 13, 11, 14, 12, 13),
        "primary": "int",
        "saves": ("int",),
        "skills": ("Insight", "Investigation", "Persuasion"),
        "expertise": ("Investigation",),
        "armor": "leather",
        "melee": ("Dagger", 4, "Piercing", "dex"),
        "ranged": ("Dagger", 4, "Piercing", "dex", "20/60 ft."),
        "initiative": False,
    },
    "guard": {
        "name": "Guard",
        "scores": (13, 12, 12, 10, 11, 10),
        "primary": "str",
        "saves": ("str",),
        "skills": ("Athletics", "Perception"),
        "expertise": (),
        "armor": "chain-shirt-shield",
        "melee": ("Spear", 6, "Piercing", "str"),
        "ranged": ("Spear", 6, "Piercing", "str", "20/60 ft."),
        "initiative": False,
    },
    "scout": {
        "name": "Scout",
        "scores": (11, 14, 12, 11, 13, 11),
        "primary": "dex",
        "saves": ("dex",),
        "skills": ("Nature", "Perception", "Stealth", "Survival"),
        "expertise": ("Stealth",),
        "armor": "leather",
        "melee": ("Shortsword", 6, "Piercing", "dex"),
        "ranged": ("Longbow", 8, "Piercing", "dex", "150/600 ft."),
        "initiative": True,
    },
    "outlaw": {
        "name": "Outlaw",
        "scores": (11, 14, 12, 11, 10, 12),
        "primary": "dex",
        "saves": ("dex",),
        "skills": ("Deception", "Sleight of Hand", "Stealth"),
        "expertise": ("Stealth",),
        "armor": "leather",
        "melee": ("Scimitar", 6, "Slashing", "dex"),
        "ranged": ("Light Crossbow", 8, "Piercing", "dex", "80/320 ft."),
        "initiative": True,
    },
    "warrior": {
        "name": "Warrior",
        "scores": (15, 12, 14, 9, 11, 10),
        "primary": "str",
        "saves": ("con",),
        "skills": ("Athletics", "Perception"),
        "expertise": (),
        "armor": "hide",
        "melee": ("Greataxe", 12, "Slashing", "str"),
        "ranged": ("Javelin", 6, "Piercing", "str", "30/120 ft."),
        "initiative": False,
    },
    "leader": {
        "name": "Leader",
        "scores": (14, 12, 13, 12, 13, 15),
        "primary": "cha",
        "saves": ("wis", "cha"),
        "skills": ("Insight", "Perception", "Persuasion"),
        "expertise": ("Persuasion",),
        "armor": "breastplate",
        "melee": ("Longsword", 8, "Slashing", "str"),
        "ranged": ("Heavy Crossbow", 10, "Piercing", "dex", "100/400 ft."),
        "initiative": True,
    },
    "devotee": {
        "name": "Devotee",
        "scores": (12, 10, 12, 11, 14, 12),
        "primary": "wis",
        "saves": ("wis",),
        "skills": ("Medicine", "Religion"),
        "expertise": ("Medicine",),
        "armor": "chain-shirt",
        "melee": ("Mace", 6, "Bludgeoning", "str"),
        "ranged": ("Radiant Flame", 6, "Radiant", "wis", "60 ft."),
        "initiative": False,
    },
    "arcanist": {
        "name": "Arcanist",
        "scores": (9, 13, 11, 15, 12, 11),
        "primary": "int",
        "saves": ("int", "wis"),
        "skills": ("Arcana", "History", "Investigation"),
        "expertise": ("Arcana",),
        "armor": "mage-armor",
        "melee": ("Arcane Burst", 8, "Force", "int"),
        "ranged": ("Arcane Burst", 8, "Force", "int", "120 ft."),
        "initiative": False,
    },
}


PRONOUNS = {
    "she-her": ("she", "her", "her", "hers", "herself"),
    "he-him": ("he", "him", "his", "his", "himself"),
    "they-them": ("they", "them", "their", "theirs", "themself"),
}

GENDERS = ("woman", "man", "nonbinary")

PERSONALITY_AXES = {
    "warmth": ("warm and attentive", "reserved but considerate", "brusque and difficult to read"),
    "discipline": ("methodical about small duties", "practical and adaptable", "habitually improvisational"),
    "confidence": ("quietly self-assured", "careful before committing", "quick to yield ground in public"),
    "curiosity": ("eager to hear unfamiliar ideas", "interested chiefly in useful knowledge", "suspicious of novelty"),
    "trust": ("inclined to give strangers a fair chance", "slow to trust but loyal thereafter", "always looking for the hidden price"),
    "humor": ("dryly funny at unexpected moments", "fond of gentle teasing", "almost painfully literal"),
}

IDEALS = [
    "A promise is a debt that should be paid.",
    "A community survives when everyone carries part of the burden.",
    "Good work should outlast the person who made it.",
    "Mercy is most valuable when it is inconvenient.",
    "Freedom means accepting the consequences of one's choices.",
    "Knowledge should be preserved and passed on.",
    "No law is worth more than the people it is meant to protect.",
    "Tradition deserves respect, but not blind obedience.",
    "The wilderness is not empty land; it has claims of its own.",
    "Fair trade makes better neighbors than charity offered with strings.",
    "Courage is doing the necessary thing while afraid.",
    "Skill is a form of honesty: the work shows what words conceal.",
    "Every traveler is entitled to a fire, water, and one warning.",
    "Power should be answerable to those who live beneath it.",
    "The dead are owed truth, and the living are owed a chance to mend.",
]

BONDS = [
    "supports a sibling whose livelihood recently failed",
    "keeps a promise made to a dying traveling companion",
    "is fiercely protective of a small roadside shrine",
    "sends part of every tenday's earnings to family elsewhere",
    "owes their start in life to a patient former master",
    "will not abandon the neighbors who sheltered them during a hard winter",
    "is saving to recover a family holding lost to debt",
    "cares for an aging draft animal that once saved their life",
    "guards a collection of letters from someone who never returned",
    "considers their work crew a second family",
    "feels responsible for a younger apprentice with more courage than sense",
    "maintains an old friendship across a bitter political divide",
    "is devoted to the memory of a village destroyed years ago",
    "has adopted an orphaned child in all but name",
    "owes a life-debt to a stranger whose whereabouts are unknown",
]

FLAWS = [
    "assumes silence will make an awkward problem disappear",
    "cannot resist correcting someone in public",
    "takes reasonable caution as a personal insult",
    "promises help before checking whether it is possible",
    "keeps grudges long after forgetting their cause",
    "becomes evasive whenever money is discussed",
    "mistakes stubbornness for reliability",
    "believes competence in one trade makes them an authority on everything",
    "downplays danger until others stop listening",
    "is unable to leave a mystery alone",
    "lies badly when trying to spare someone's feelings",
    "expects betrayal from officials and wealthy patrons",
    "has a weakness for wagers framed as tests of skill",
    "works past exhaustion and grows resentful when unthanked",
    "confuses being needed with being valued",
]

MANNERISMS = [
    "counts quietly on their fingers before answering",
    "turns a worn ring whenever thinking",
    "checks the nearest exit on entering a room",
    "uses trade metaphors even outside work",
    "keeps their hands occupied with a scrap of cord",
    "pauses to choose exact words, then speaks quickly",
    "nods once before disagreeing",
    "wipes clean any cup before using it",
    "touches two fingers to their brow in greeting",
    "lowers their voice rather than raising it when angry",
    "remembers people's boots more readily than their faces",
    "straightens crooked objects without noticing",
    "answers a difficult question with a different, easier truth",
    "looks toward the weather whenever conversation stalls",
    "keeps meticulous track of favors owed in both directions",
    "hums a four-note work song under stress",
    "repeats the last few words of an important instruction",
    "offers food before discussing business",
]

VOICES = [
    "a low northern drawl with careful consonants",
    "a quick, practical cadence that leaves little empty space",
    "a soft voice roughened by smoke and cold mornings",
    "a carrying market voice that becomes gentle in private",
    "a clipped coastal accent with sailor's turns of phrase",
    "a measured, bookish delivery interrupted by plainspoken asides",
    "a warm, husky voice prone to unfinished sentences",
    "a formal tone learned from dealing with officials",
    "a breathy voice that gains strength when discussing work",
    "a resonant voice used sparingly",
    "a cheerful lilt that disappears when money is mentioned",
    "a gravelly whisper caused by an old throat injury",
]

BUILDS = ["lean", "rangy", "broad-shouldered", "compact", "sturdy", "soft-built", "long-limbed", "wiry", "heavyset", "slight"]
FACES = ["square-jawed", "round-faced", "sharp-featured", "weather-lined", "open-faced", "hawk-nosed", "heavy-browed", "fine-boned", "freckled", "sun-creased"]
HAIR = ["cropped black", "wavy brown", "straight auburn", "close-shorn gray", "long dark", "curly chestnut", "braided fair", "thick silver", "shaved", "wind-tangled sandy"]
EYES = ["brown", "gray", "green", "hazel", "blue", "amber", "dark", "pale gray", "blue-green", "copper-brown"]
MARKS = [
    "a pale scar across one knuckle", "a nose broken long ago", "ink stains along two fingers",
    "a missing left earlobe", "a small burn on the wrist", "calluses appropriate to long practice",
    "a faded blue tattoo behind one ear", "a chipped front tooth", "one eyebrow split by a scar",
    "a persistent squint in bright light", "a patch of prematurely white hair", "carefully mended spectacles",
]
CLOTHING = [
    "well-mended wool in practical earth tones", "a waxed traveling cloak over layered work clothes",
    "clean but faded linen beneath a patched vest", "sturdy homespun with bright woven trim",
    "weather-darkened leathers over a wool shirt", "a serviceable coat with too many inner pockets",
    "plain clothes kept unusually neat", "mixed secondhand garments altered to fit",
    "heavy northern wool with a colored sash", "a hooded cloak smelling faintly of woodsmoke",
]

UPBRINGINGS = [
    "on an isolated farm where every pair of hands mattered",
    "among crowded kin in a noisy trade quarter",
    "in a roadside inn that heard news before officials did",
    "in a household that moved with the seasonal work",
    "near a shrine whose keeper taught letters to local children",
    "in a caravan family accustomed to long roads and short goodbyes",
    "in a fishing hamlet where storms set the calendar",
    "under a demanding craft master with exacting standards",
    "in a garrison settlement where alarms were common",
    "among prospectors and smallholders on disputed land",
    "in a rebuilding neighborhood shaped by mutual favors",
    "at the edge of a forest treated with equal respect and suspicion",
]

TURNING_POINTS = [
    "a failed harvest forced the household to seek another living",
    "an older relative arranged an apprenticeship",
    "a passing master noticed an aptitude no one else valued",
    "a workplace accident left a position unexpectedly vacant",
    "military service provided training but no desire to remain enlisted",
    "a debt had to be paid quickly and honestly",
    "a winter journey proved they were good at keeping others alive",
    "a feud closed one trade to them and opened another",
    "refugees arriving after a local disaster needed practical help",
    "a lucky sale supplied the tools for a better life",
    "a mentor vanished, leaving unfinished obligations behind",
    "they discovered that competence earned more freedom than charm",
]

LIFE_EVENTS = [
    "survived a caravan attack by hiding wounded strangers beneath a wagon",
    "spent a season helping rebuild homes after a violent storm",
    "was falsely accused of theft and cleared only after a costly delay",
    "found an abandoned child on the road and delivered them safely to kin",
    "lost nearly everything in a fire that may not have been accidental",
    "served as the only reliable witness to a local official's misconduct",
    "was trapped for three days by floodwater with an unlikely companion",
    "earned local gratitude during an outbreak of fever",
    "helped negotiate an end to a bitter dispute over grazing and water",
    "carried an urgent warning through dangerous country",
    "made a profitable discovery and shared more of it than expected",
    "returned from a journey to find home changed beyond recognition",
    "was once rescued by people they had been taught to distrust",
    "took blame for an apprentice's mistake and still bears the cost",
    "spent a year away from the Sword Coast and rarely explains why",
]

GOALS = [
    "secure a safe future for their household",
    "learn what happened to a missing traveler",
    "earn enough to open a modest place of their own",
    "clear an old debt without accepting a dangerous favor",
    "prove a disputed claim to land or inheritance",
    "protect a local route from a threat officials dismiss",
    "repair their standing with someone they wronged",
    "find a trustworthy successor before age or injury ends their work",
    "preserve a useful local tradition that is fading",
    "turn a fragile truce into a lasting peace",
    "identify who has been tampering with local supplies",
    "make one journey they have postponed for years",
]

OBSTACLES = [
    "a creditor with influence beyond the size of the debt",
    "an oath that forbids the easiest solution",
    "a rival who is unpleasant but not actually wrong",
    "dependents who cannot safely be left behind",
    "evidence that would implicate an innocent person",
    "a lack of coin and a refusal to steal it",
    "a local official who mistakes questions for disloyalty",
    "an old injury that worsens in cold weather",
    "the fear that success will expose a private failure",
    "two communities making incompatible demands",
    "a useful ally who cannot be trusted with the whole truth",
    "their own habit of waiting for certainty",
]

SECRETS = [
    "quietly sends money to a relative publicly believed dead",
    "knows a nearby ruin has been entered recently and has told no one",
    "once forged a travel permit for someone fleeing an abusive patron",
    "recognizes the seal on a letter everyone else thinks is meaningless",
    "owes a modest favor to a smuggler who has not yet collected",
    "has been skimming tiny sums to replace money stolen by a former partner",
    "saw a respected local figure meeting armed strangers after midnight",
    "uses a different surname from the one recorded at their birthplace",
    "keeps a map copied from a dying traveler's journal",
    "was responsible for an accident attributed to bad weather",
    "can identify a supposedly unknown body by an old scar",
    "occasionally passes harmless-looking messages for someone they know only by a sign",
    "has hidden a dangerous heirloom rather than destroy or surrender it",
    "lied about the last words of a dead friend to comfort the family",
    "is considering leaving without telling those who depend on them",
]

RUMORS = [
    "They once crossed Neverwinter Wood alone in winter.",
    "They have a standing arrangement with a local bandit chief.",
    "A minor noble owes them a surprisingly large favor.",
    "They can tell when someone is lying by watching their hands.",
    "They found something valuable and cursed in the hills.",
    "Their family name was changed after an old scandal.",
    "They know a safe trail that appears on no map.",
    "They refused a lucrative position in Neverwinter without explanation.",
    "They once worked for a faction agent under another name.",
    "Their ordinary-looking keepsake is worth more than their home.",
    "They have never lost a wager they chose themselves.",
    "They can speak with someone—or something—beneath the town.",
]

KEEPSAKES = [
    "a child's charcoal drawing folded into oilskin",
    "a smooth green stone drilled for a cord",
    "a dented brass button from an old uniform",
    "a recipe written in two different hands",
    "a tiny carved fox with one missing ear",
    "a foreign copper coin worn nearly blank",
    "a blue ribbon preserved in a wooden tube",
    "a cracked lens wrapped in soft cloth",
    "a letter that has been opened and resealed many times",
    "a narrow iron key whose lock is unknown",
    "a pressed sprig of mountain heather",
    "a child's wooden spinning top",
    "a bone gaming piece marked with a star",
    "a thumbnail portrait painted on a river shell",
    "a small packet of soil from a former home",
    "a whistle that produces no audible sound",
    "three beads from a broken prayer strand",
    "a careful sketch of a place that no longer exists",
]

GENERAL_ITEMS = [
    "tinderbox", "50 feet of hempen rope", "waterskin", "two days of trail rations",
    "whetstone", "small sewing kit", "hooded lantern and flask of oil", "chalk (5 pieces)",
    "bar of plain soap", "wooden mess kit", "blanket", "small steel mirror", "flint and steel",
    "twine (20 feet)", "three wax candles", "folding eating knife", "weathered local map",
    "packet of salt", "empty stoppered vial", "six iron spikes",
]

COMMON_MAGIC_ITEMS = [
    "Potion of Healing",
    "Spell Scroll (cantrip)",
]

UNCOMMON_MAGIC_ITEMS = [
    "Bag of Holding",
    "Boots of Elvenkind",
    "Cloak of Elvenkind",
    "Immovable Rod",
    "Sending Stones (one stone; its mate is elsewhere)",
]

MINOR_WONDERS = [
    "a palm-sized stone that stays pleasantly warm but sheds no heat",
    "a copper needle that always points toward the last garment it mended",
    "a clay bead that smells faintly of rain before a storm",
    "a tin cup that keeps clean water cool for an hour",
    "a wooden token that darkens whenever fresh bread is nearby",
    "a quill that never splits but otherwise writes normally",
]

SKILL_ABILITIES = {
    "Acrobatics": "dex", "Animal Handling": "wis", "Arcana": "int", "Athletics": "str",
    "Deception": "cha", "History": "int", "Insight": "wis", "Intimidation": "cha",
    "Investigation": "int", "Medicine": "wis", "Nature": "int", "Perception": "wis",
    "Performance": "cha", "Persuasion": "cha", "Religion": "int", "Sleight of Hand": "dex",
    "Stealth": "dex", "Survival": "wis",
}

ABILITY_NAMES = {
    "str": "Strength", "dex": "Dexterity", "con": "Constitution",
    "int": "Intelligence", "wis": "Wisdom", "cha": "Charisma",
}

