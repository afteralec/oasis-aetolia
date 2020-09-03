module(..., package.seeall)

-------------------------------------------------------

--! @file
--! @brief Offensive module for Oasis Curing System for Aetolia.

--! @copyright Copyright 2014 Alec DuBois, all rights reserved.

--! http://oasis.interimreality.com/

--! Commented in standardized format Doxygen::Lua.

-------------------------------------------------------

--! todo: add function to change which hand you wield your weapon in and which you wield your shield in
--! todo: add table to register weapons by class, spec, and number
--! todo: create condition to force it only to allow certain afflictions under certain conditions - two-layer allowances
--! todo: create conditions to load alternate priorities into parse_affs() - matching hypnosis or anxieties
--! todo: create more robust calculations for limb damage and forcing multiple breaks in a combo
--! todo: ab.terramancy() - set up more conditions for "fracture" against critical bruising

local ab = {}			--! special conditions for parsing class abilities
local ac = {}			--! storage for special action functions
local cn = {}			--! special conditions for parsing affliction priorities
local rp = {}			--! special conditions for when to repeat afflictions
local k = {}			--! class offense namespace
local vn = {}			--! special conditions for venoms

--! todo: key this into settings module
--! settings by category
sets = {
	route = "affliction",
	stack = 2,
	breaks = 2,
	t_parry = false,
	stacks = {
		asthma = {
			"clumsiness",
			"hypochondria",
			"magic_impaired",
			"paralysis"
		},

		hellsight = {
			"clumsiness",
			"hypochondria",
			"magic_impaired",
			"paralysis"
		},

		slickness = {
			"asthma",
			"limp_veins",
			"clumsiness",
			"hypochondria",
			"magic_impaired",
			"paralysis"
		},

		thin_blood = {
			"haemophilia",
			"hypochondria",
			"clumsiness",
			"sunlight_allergy",
			"vomiting",
			"magic_impaired",
			"paresis",
			"paralysis",
			"asthma",
			"limp_veins"
		}
	},

	ascendril = {},
	cabalist = {},
	carnifex = {
		bardiche = { "41233", "both" },
		damage_hammer = { "195585", "both" },
		speed_hammer = { "195585", "both" },
		deathlore = {
			bloodburst = { act = 80 },
			soulchill = { act = 80 },
			soul_disease = { act = 80 },
			distortion = { act = 90 },
			glasslimb = { act = 75 },
			implant = { act = 75, ven_one = "aconite", ven_two = "slike" },
			wraith = { act = 90 }
		},
		poison_thresh = 5,
		warhounds = {
			["epilepsy"] = "184443",
			["frozen"] = "183343",
			["insulation"] = "183343",
			["loki"] = "181702",
			["ruptured_eardrum"] = "184443",
			["shivering"] = "183343",
			["stupidity"] = "183343"
		}
	},
	indorani = {
		dagger = "bonedagger"
	},
	luminary = {
		o_thresh = 5,
		sap_thresh = 55,

		weaps = {
			affliction = "buckler",
			arms = "kite",
			damage = "buckler",
			legs = "kite",
		}
	},
	monk = {},
	praenomen = {
		bb_thresh = 100,
		biles = {
			"effused_yellowbile",
			"effused_phlegm",
			"effused_blood"
		},
		chanted = {
			bloodmeld = false,
			eldritch = false,
			shiftsoul = false,
			thirst = false
		},
		frenzy = "overpower",
		hand = "one",
		link = "mindleech",
		minion = "brainboil",
		speed = "fast",

		weaps = {
			one = {
				fast = { "dirk", "right", "shield", "left" },
			}
		},

		whisper = "dwhisper"
	},
	sciomancer = {},
	sentinel = {
		opportunity = false
	},
	shaman = {},
	shapeshifter = {},
	syssin = {
		dbl_suggest = false,
		mark = "numbness",
		pall = 5,
		snap = "dstab",
		sealtimer = "2.5"
	},
	templar = {},
	teradrim = {},
	zealot = {},

	weaps = {
		carnifex = {
			affliction = { "170058", "both" },
			limb = { "warhammer", "both" }
		},
		templar = {
			affliction = { "spear", "left", "broadsword", "right" },
			bruising = { "185067", "left", "92883", "right" },
			damage = { "bastardsword", "both" },
			limb = { "mace", "left", "mace", "right" },
			rupture = { "warhammer", "both" },
		},

		std_one = "shortsword",
		small_blade = "broadsword",
		small_blunt = "mace",

		std_two = "bastardsword",
		large_blade = "bastardsword",
		large_blunt = "warhammer",

		wield = {

		},
	}
}

lib = {
	--! affliction and defense library
	addiction = { two = { sentinel = true } },
	aeon = { two = { indorani = true } },
	agoraphobia = { one = { praenomen = true }, two = { sentinel = true }, three = { sentinel = true }, nocombo = { sentinel = { crippled_throat = true, heartflutter = true, impatience = true } } },
	anorexia = { venom = "slike", one = { indorani = true, luminary = true }, three = { carnifex = true } },
	asleep = { venom = "delphinium", strip = "insomnia", stack = "instawake", two = { praenomen = true }, three = { carnifex = true, praenomen = true } },
	asthma = { undead = "limp_veins", venom = "kalmia", strip = "fitness", two = { luminary = true, praenomen = true }, three = { carnifex = true, luminary = true, praenomen = true } },
	berserking = { one = { luminary = true }, two = { indorani = true, luminary = true } },
	blaze = { venom = "blaze" },
	blindness = { def = true, venom = "oculus", one = { indorani = true }, two = { luminary = true, praenomen = true }, three = { carnifex = true, luminary = true, praenomen = true } },
	blood_fever = { one = { praenomen = true }, three = { praenomen = true } },
	blood_plague = { one = { praenomen = true }, three = { praenomen = true } },
	blurry_vision = { two = { sentinel = true } },
	camus = { venom = "camus", two = { syssin = true }, three = { syssin = true } },
	clarity = { def = true, to_aff = "dementia", one = { luminary = true }, three = { luminary = true } },
	claustrophobia = { two = { sentinel = true }, three = { sentinel = true }, nocombo = { sentinel = { crippled_throat = true, heartflutter = true, impatience = true } } },
	clumsiness = { venom = "xentio", two = { praenomen = true }, three = { carnifex = true, praenomen = true } },
	confusion = { one = { carnifex = true, praenomen = true }, two = { carnifex = true, indorani = true, luminary = true, sentinel = true }, three = { luminary = true }, tar = { sentinel = "head" } },
	conviction = { venom = "conviction" },
	cracked_ribs = { tar = "chest", two = { carnifex = true }, three = { carnifex = true } },
	crippled = { venom = "cripple", block = "crippled_body", fade = 30 },
	crippled_body = { venom = "cripple", fade = 30 },
	crippled_throat = { one = { sentinel = true } },
	crushed_chest = { tar = "chest", two = { carnifex = true }, three = { carnifex = true } },
	crushed_elbows = { tar = "elbows", two = { carnifex = true }, three = { carnifex = true } },
	crushed_kneecaps = { tar = "crushed_kneecaps", two = { carnifex = true }, three = { carnifex = true } },
	deafness = { def = true, venom = "prefarar", one = { luminary = true }, two = { luminary = true, praenomen = true }, three = { carnifex = true, praenomen = true }, ent = { indorani = true } },
	dementia = { strip = "clarity", one = { luminary = true, praenomen = true }, three = { luminary = true } },
	destroyed_throat = { two = { sentinel = true } },
	disfigurement = { venom = "monkshood", strip = "hierophant", one = { indorani = true }, two = { luminary = true, praenomen = true }, three = { carnifex = true, luminary = true, praenomen = true } },
	disrupted = { two = { luminary = true, praenomen = true, syssin = true }, three = { luminary = true, praenomen = true, syssin = true } },
	dizziness = { venom = "larkspur", two = { praenomen = true }, one = { indorani = true }, two = { luminary = true }, three = { carnifex = true, luminary = true, praenomen = true } },
	epilepsy = { one = { carnifex = true, praenomen = true }, two = { carnifex = true, indorani = true, sentinel = true } },
	fitness = { def = true, venom = "kalmia", two = { luminary = true, praenomen = true }, three = { carnifex = true, luminary = true, praenomen = true } },
	frozen = { one = { carnifex = true }, two = { carnifex = true }, ent = { carnifex = true } },
	haemophilia = { venom = "hepafarin", one = { indorani = true }, two = { praenomen = true }, three = { carnifex = true, praenomen = true } },
	hallucinations = { strip = "clarity", two = { luminary = true }, three = { luminary = true } },
	head_bruised = { venom = "trauma", tar = { templar = "head", teradrim = "head" } },
	head_bruised_critical = { venom = "trauma", tar = { templar = "head", teradrim = "head" } },
	head_bruised_moderate = { venom = "trauma", tar = { templar = "head", teradrim = "head" } },
	head_damaged = { three = { luminary = true }, tar = { luminary = "head", templar = "head", teradrim = "head" } },
	head_mangled = { three = { luminary = true }, tar = { luminary = "head", templar = "head", teradrim = "head" } },
	heartflutter = { one = { sentinel = true }, tar = { sentinel = "torso" } },
	hellsight = { nr = true, two = { luminary = true }, three = { luminary = true } },
	hierophant = { def = true, venom = "monkshood", one = { indorani = true }, two = { luminary = true }, three = { luminary = true } },
	hypochondria = { one = { luminary = true }, three = { luminary = true } },
	impatience = { one = { luminary = true, praenomen = true, sentinel = true }, two = { indorani = true, luminary = true }, tar = { sentinel = "head" } },
	indifference = { one = { praenomen = true, syssin = true }, two = { indorani = true, sentinel = true, syssin = true }, tar = { sentinel = "head" } },
	insomnia = { def = true, venom = "delphinium", one = { indorani = true }, two = { praenomen = true }, three = { praenomen = true } },
	instawake = { def = true, venom = "delphinium" },
	insulation = { def = true, one = { carnifex = true }, two = { carnifex = true } },
	justice = { two = { indorani = true } },
	left_arm_amputated = { tar = "left arm" },
	left_arm_broken = { venom = "epteth", one = { indorani = true }, two = { praenomen = true }, three = { carnifex = true, praenomen = true } },
	left_arm_bruised = { venom = "trauma", tar = { templar = "left arm", teradrim = "left arm" } },
	left_arm_bruised_critical = { venom = "trauma", tar = { templar = "left arm", teradrim = "left arm" } },
	left_arm_bruised_moderate = { venom = "trauma", tar = { templar = "left arm", teradrim = "left arm" } },
	left_arm_damaged = { venom = "trauma", three = { luminary = true }, tar = { luminary = "left arm", templar = "left arm", teradrim = "left arm" } },
	left_arm_mangled = { venom = "trauma", three = { luminary = true }, tar = { luminary = "left arm", templar = "left arm", teradrim = "left arm" } },
	left_leg_amputated = { tar = { carnifex = "left leg" } },
	left_leg_broken = { venom = "epseth", one = { indorani = true }, two = { praenomen = true }, three = { carnifex = true, praenomen = true } },
	left_leg_bruised = { venom = "trauma", tar = { templar = "left leg", teradrim = "left leg" } },
	left_leg_bruised_critical = { venom = "trauma", tar = { templar = "left leg", teradrim = "left leg" } },
	left_leg_bruised_moderate = { venom = "trauma", tar = { templar = "left leg", teradrim = "left leg" } },
	left_leg_damaged = { venom = "trauma", three = { luminary = true }, tar = { luminary = "left leg", templar = "left leg", teradrim = "left leg" } },
	left_leg_mangled = { venom = "trauma", three = { luminary = true }, tar = { luminary = "left leg", templar = "left leg", teradrim = "left leg" } },
	lethargy = { one = { luminary = true }, two = { indorani = true, sentinel = true }, three = { luminary = true } },
	limp_veins = { venom = "kalmia", strip = "fitness", two = { luminary = true, praenomen = true }, three = { carnifex = true, luminary = true, praenomen = true } },
	loki = { venom = "loki", one = { carnifex = true }, two = { carnifex = true }, ent = { carnifex = true } },
	loneliness = { one = { luminary = true, praenomen = true }, two = { sentinel = true }, three = { luminary = true, sentinel = true }, nocombo = { sentinel = { crippled_throat = true, heartflutter = true, impatience = true } } },
	lovers_effect = { two = { indorani = true } },
	magic_impaired = { venom = "colocasia", two = { praenomen = true }, three = { carnifex = true, praenomen = true } },
	masochism = { one = { luminary = true, praenomen = true }, three = { luminary = true } },
	mental_disruption = { venom = "disrupt", empower = true },
	pacifism = { two = { luminary = true }, three = { luminary = true } },
	paranoia = { one = { luminary = true, praenomen = true }, three = { luminary = true } },
	paresis = { venom = "curare", block = "paralysis", two = { luminary = true, praenomen = true }, three = { carnifex = true, luminary = true, praenomen = true } },
	peace = { venom = "ouabian", two = { luminary = true }, three = { carnifex = true, luminary = true } },
	physical_disruption = { venom = "disrupt", empower = true },
	recklessness = { venom = "eurypteria", one = { luminary = true }, three = { luminary = true } },
	right_arm_amputated = { tar = "right arm" },
	right_arm_broken = { venom = "epteth", one = { indorani = true }, two = { praenomen = true }, three = { carnifex = true, praenomen = true } },
	right_arm_bruised = { venom = "trauma", tar = { templar = "right arm", teradrim = "right arm" } },
	right_arm_bruised_critical = { venom = "trauma", tar = { templar = "right arm", teradrim = "right arm" } },
	right_arm_bruised_moderate = { venom = "trauma", tar = { templar = "right arm", teradrim = "right arm" } },
	right_arm_damaged = { venom = "trauma", three = { luminary = true }, tar = { luminary = "right arm", templar = "right arm", teradrim = "right arm" } },
	right_arm_mangled = { venom = "trauma", three = { luminary = true }, tar = { luminary = "right arm", templar = "right arm", teradrim = "right arm" } },
	right_leg_amputated = { tar = { carnifex = "right leg" } },
	right_leg_broken = { venom = "epseth", two = { praenomen = true }, three = { carnifex = true, praenomen = true } },
	right_leg_bruised = { venom = "trauma", tar = { templar = "right leg", teradrim = "right leg" } },
	right_leg_bruised_critical = { venom = "trauma", tar = { templar = "right leg", teradrim = "right leg" } },
	right_leg_bruised_moderate = { venom = "trauma", tar = { templar = "right leg", teradrim = "right leg" } },
	right_leg_damaged = { venom = "trauma", three = { luminary = true }, tar = { luminary = "right leg", templar = "right leg", teradrim = "right leg" } },
	right_leg_mangled = { venom = "trauma", three = { luminary = true }, tar = { luminary = "right leg", templar = "right leg", teradrim = "right leg" } },
	ruptured_eardrum = { one = { carnifex = true }, two = { carnifex = true }, ent = { carnifex = true } },
	seduction = { one = { praenomen = true } },
	selarnia = { venom = "selarnia", two = { praenomen = true }, three = { carnifex = true, praenomen = true } },
	self_pity = { one = { luminary = true }, two = { luminary = true } },
	sensitivity = { venom = "prefarar", strip = "deafness", one = { luminary = true }, two = { luminary = true, praenomen = true }, three = { carnifex = true, praenomen = true } },
	shivering = { strip = "insulation", stack = "frozen", one = { carnifex = true }, two = { carnifex = true }, ent = { carnifex = true } },
	slickness = { venom = "gecko", two = { luminary = true, praenomen = true }, three = { carnifex = true, luminary = true, praenomen = true } },
	stupidity = { venom = "aconite", one = { luminary = true }, two = { luminary = true }, ent = { carnifex = true } },
	sunlight_allergy = { venom = "darkshade", two = { praenomen = true }, three = { carnifex = true, praenomen = true } },
	superstition = { two = { indorani = true } },
	temptation = { one = { praenomen = true } },
	thin_blood = { venom = "scytherus", two = { syssin = true }, three = { syssin = true } },
	torso_bruised = { venom = "trauma", tar = { templar = "torso", teradrim = "torso" } },
	torso_bruised_critical = { venom = "trauma", tar = { templar = "torso", teradrim = "torso" } },
	torso_bruised_moderate = { venom = "trauma", tar = { templar = "torso", teradrim = "torso" } },
	torso_damaged = { venom = "trauma", three = { luminary = true }, tar = { luminary = "torso", templar = "torso", teradrim = "torso" } },
	torso_mangled = { venom = "trauma", three = { luminary = true }, tar =  { luminary = "torso", templar = "torso", teradrim = "torso" } },
	vertigo = { one = { luminary = true, praenomen = true }, two = { luminary = true, sentinel = true }, three = { sentinel = true }, nocombo = { sentinel = { crippled_throat = true, heartflutter = true, impatience = true } } },
	vomiting = { venom = "euphorbia", two = { praenomen = true }, three = { carnifex = true, praenomen = true } },
	voyria = { aff = "voyria", venom = "voyria", two = { praenomen = true }, three = { praenomen = true } },
	weariness = { venom = "vernalius", one = { indorani = true }, two = { luminary = true, praenomen = true }, three = { luminary = true, praenomen = true } },
	withering = { nr = true, two = { templar = true }, three = { templar = true } },
	writhe_transfix = { two = { luminary = true }, three = { luminary = true } },

	--! venoms tagged by effect
	["aconite"] = "stupidity",
	["colocasia"] = "magic_impaired",
	["curare"] = "paresis",
	["darkshade"] = "sunlight_allergy",
	["delphinium"] = "asleep",
	["euphorbia"] = "vomiting",
	["eurypteria"] = "recklessness",
	["epseth"] = "left_arm_broken",
	["epteth"] = "right_leg_broken",
	["gecko"] = "slickness",
	["hepafarin"] = "haemophilia",
	["kalmia"] = "asthma",
	["larkspur"] = "dizziness",
	["monkshood"] = "disfigurement",
	["ouabian"] = "peace",
	["oculus"] = "blindness",
	["prefarar"] = "sensitivity",
	["scytherus"] = "thin_blood",
	["slike"] = "anorexia",
	["vernalius"] = "weariness",
	["xentio"] = "clumsiness",

	--! todo: index these
	["soulchill"] = "chill",
	["soul_disease"] = "disease",
	["distortion"] = "distort",
	["glasslimb"] = "frailty",
	["implant"] = "implant",
	["wraith"] = "wraith",

	warhounds = {
		["ablaze"] = "hound firebreath",
		["epilepsy"] = "hound shock",
		["frozen"] = "hound tundralhowl",
		["insulation"] = "hound tundralhowl",
		["loki"] = "hound contagion",
		["ruptured_eardrum"] = "hound rupture",
		["shivering"] = "hound tundralhowl",
		["stupidity"] = "hound growl",
	},

	ent_bals = {
		carnifex = "warhounds",
		indorani = "chimera"
	}
}

prio = {
	ascendril = {},
	cabalist = {},
	carnifex = {
		affliction = {
			"crushed_chest",
			"cracked_ribs",
			"hierophant",
			"fitness",
			"voyria",
			"peace",
			"paresis",
			"clumsiness",
			"weariness",
			"asthma",
			"slickness",
			"anorexia",
			"disfigurement",
			"crushed_kneecaps",
			"left_leg_broken",
			"right_leg_broken",
			"right_arm_broken",
			"left_arm_broken",
			"crushed_elbows",
			"stupidity",
			"deafness",
			"sensitivity",
			"vomiting",
			"sunlight_allergy",
			"haemophilia",
			"blindness",
			"insulation",
			"shivering",
			"frozen",
			"ruptured_eardrum",
			"loki"
		},
		damage = {
			"crushed_chest",
			"cracked_ribs",
			"hierophant",
			"fitness",
			"voyria",
			"peace",
			"paresis",
			"deafness",
			"sensitivity",
			"clumsiness",
			"vomiting",
			"haemophilia",
			"sunlight_allergy",
			"weariness",
			"asthma",
			"slickness",
			"anorexia",
			"disfigurement",
			"crushed_kneecaps",
			"left_leg_broken",
			"right_leg_broken",
			"right_arm_broken",
			"left_arm_broken",
			"crushed_elbows",
			"stupidity",
			"blindness",
			"insulation",
			"shivering",
			"frozen",
			"ruptured_eardrum",
			"loki"
		},
		limb = {},
		deathlore = {
			affliction = {
				"wraith",
				"soul_disease",
				"implant",
				"soulchill",
				"distortion"
			},
			damage = {
				"wraith",
				"distortion",
				"glasslimb",
				"soulchill",
				"implant"
			},
			limb = {}
		}
	},
	indorani = {
		affliction = {
			"fitness",
			"hierophant",
			"impatience",
			"paresis",
			"clumsiness",
			"asthma",
			"aeon",
			"disfigurement",
			"slickness",
			"anorexia",
			"indifference",
			"left_leg_broken",
			"right_leg_broken",
			"left_arm_broken",
			"right_arm_broken",
			"weariness",
			"lethargy",
			"vomiting",
			"berserking",
			"deafness",
			"sensitivity",
			"epilepsy",
			"confusion",
			"stupidity",
			"recklessness",
			"superstition",
			"sunlight_allergy",
			"haemophilia",
			"lovers_effect",
			"justice"
		},
		damage = {
			"fitness",
			"hierophant",
			"impatience",
			"paresis",
			"clumsiness",
			"deafness",
			"sensitivity",
			"asthma",
			"aeon",
			"slickness",
			"anorexia",
			"indifference",
			"left_leg_broken",
			"right_leg_broken",
			"left_arm_broken",
			"right_arm_broken",
			"weariness",
			"lethargy",
			"vomiting",
			"berserking",
			"epilepsy",
			"confusion",
			"stupidity",
			"recklessness",
			"superstition",
			"sunlight_allergy",
			"haemophilia",
			"lovers_effect",
			"justice"
		},
	},
	luminary = {
		affliction = {
			"fitness",
			"clarity",
			"hellsight",
			"slickness",
			"anorexia",
			"asthma",
			"paresis",
			"weariness",
			"confusion",
			"disrupted",
			"blindness",
			"writhe_transfix",
			"lethargy",
			"hypochondria",
			"loneliness",
			"recklessness",
			"masochism",
			"dementia",
			"paranoia",
			"impatience",
			"berserking",
			"stupidity",
			"self_pity",
			"sensitivity",
			"vertigo"
		},
		lock = {
			"fitness",
			"clarity",
			"hellsight",
			"slickness",
			"anorexia",
			"asthma",
			"weariness",
			"paresis",
			"hypochondria",
			"blindness",
			"confusion",
			"disrupted",
			"writhe_transfix",
			"lethargy",
			"loneliness",
			"recklessness",
			"masochism",
			"dementia",
			"paranoia",
			"impatience",
			"berserking",
			"stupidity",
			"self_pity",
			"sensitivity",
			"vertigo"		
		},
		damage = {
			"fitness",
			"clarity",
			"hellsight",
			"slickness",
			"anorexia",
			"asthma",
			"paresis",
			"weariness",
			"confusion",
			"disrupted",
			"blindness",
			"writhe_transfix",
			"lethargy",
			"hypochondria",
			"recklessness",
			"masochism",
			"loneliness",
			"dementia",
			"paranoia",
			"sensitivity",
			"impatience",
			"berserking",
			"stupidity",
			"self_pity",
			"vertigo"
		},
		arms = {
			"left_arm_damaged",
			"right_arm_damaged",
			"head_damaged",
			"torso_damaged",
			"right_leg_damaged",
			"left_leg_damaged",
			"left_arm_mangled",
			"right_arm_mangled",
			"head_mangled",
			"torso_mangled",
			"right_leg_mangled",
			"left_leg_mangled",
			"impatience",
			"anorexia",
			"sensitivity"
		},
		legs = {
			"right_leg_damaged",
			"left_leg_damaged",
			"head_damaged",
			"torso_damaged",
			"left_arm_damaged",
			"right_arm_damaged",
			"right_leg_mangled",
			"left_leg_mangled",
			"head_mangled",
			"torso_mangled",
			"left_arm_mangled",
			"right_arm_mangled",
			"anorexia",
		},
	},
	monk = {},
	praenomen = {
		affliction = {
			"hierophant",
			"fitness",
			"voyria",
			"paresis",
			"loneliness",
			"clumsiness",
			"asthma",
			"slickness",
			"anorexia",
			"indifference",
			"disfigurement",
			"left_leg_broken",
			"right_leg_broken",
			"right_arm_broken",
			"left_arm_broken",
			"deafness",
			"sensitivity",
			"vomiting",
			"sunlight_allergy",
			"blindness",
			"temptation",
			"seduction",
			"clarity",
			"weariness",
			"epilepsy",
			"confusion",
			"stupidity",
			"recklessness",
			"masochism",
			"peace",
			"agoraphobia",
			"paranoia",
			"vertigo",
			"dementia"
			},
		damage = {
			"asthma",
			"slickness",
			"anorexia",
			"indifference",
			"hierophant",
			"fitness",
			"voyria",
			"paresis",
			"vomiting",
			"deafness",
			"loneliness",
			"sensitivity",
			"dizziness",
			"sunlight_allergy",
			"clumsiness",
			"disfigurement",
			"left_leg_broken",
			"right_leg_broken",
			"right_arm_broken",
			"left_arm_broken",
			"blindness",
			"temptation",
			"seduction",
			"clarity",
			"impatience",
			"weariness",
			"epilepsy",
			"masochism",
			"recklessness",
			"confusion",
			"stupidity",
			"peace",
			"agoraphobia",
			"paranoia",
			"vertigo",
			"dementia"
		},
		lock = {
			"hierophant",
			"fitness",
			"voyria",
			"paresis",
			"asthma",
			"slickness",
			"anorexia",
			"indifference",
			"deafness",
			"sensitivity",
			"vomiting",
			"sunlight_allergy",
			"clumsiness",
			"disfigurement",
			"left_leg_broken",
			"right_leg_broken",
			"right_arm_broken",
			"left_arm_broken",
			"blindness",
			"temptation",
			"seduction",
			"clarity",
			"impatience",
			"weariness",
			"epilepsy",
			"masochism",
			"recklessness",
			"loneliness",
			"confusion",
			"stupidity",
			"peace",
			"agoraphobia",
			"paranoia",
			"vertigo",
			"dementia"
	}
	},
	sciomancer = {},
	sentinel = {
		resins = {
			"loki",
			"loki",
			"blackout"
		},
		affliction = {
			"hierophant",
			"fitness",
			"peace",
			"paresis",
			"impatience",
			"loneliness",
			"clumsiness",
			"weariness",
			"destroyed_throat",
			"slickness",
			"asthma",
			"anorexia",
			"indifference",
			"confusion",
			"lethargy",
			"heartflutter",
			"disfigurement",
			"right_arm_broken",
			"left_arm_broken",
			"left_leg_broken",
			"right_leg_broken",
			"deafness",
			"sensitivity",
			"vomiting",
			"sunlight_allergy",
			"haemophilia"
		},
		hinder = {
			"hierophant",
			"fitness",
			"peace",
			"paresis",
			"lethargy",
			"heartflutter",
			"impatience",
			"loneliness",
			"clumsiness",
			"weariness",
			"destroyed_throat",
			"slickness",
			"asthma",
			"anorexia",
			"indifference",
			"confusion",
			"disfigurement",
			"right_arm_broken",
			"left_arm_broken",
			"left_leg_broken",
			"right_leg_broken",
			"deafness",
			"sensitivity",
			"vomiting",
			"sunlight_allergy",
			"haemophilia"
		},
		lock = {
			"hierophant",
			"fitness",
			"destroyed_throat",
			"slickness",
			"peace",
			"paresis",
			"impatience",
			"loneliness",
			"clumsiness",
			"weariness",
			"asthma",
			"anorexia",
			"indifference",
			"confusion",
			"lethargy",
			"heartflutter",
			"disfigurement",
			"right_arm_broken",
			"left_arm_broken",
			"left_leg_broken",
			"right_leg_broken",
			"deafness",
			"sensitivity",
			"vomiting",
			"sunlight_allergy",
			"haemophilia"
		}
	},
	shaman = {},
	shapeshifter = {},
	syssin = {
		suggest = {
			affliction = {
				"lethargy",
				"hypochondria",
				"impatience",
				"lethargy",
				"hypochondria",
				"impatience",
				"confusion",
				"indifference"
			},
			lock = {
				"lethargy",
				"hypochondria",
				"impatience",
				"lethargy",
				"hypochondria",
				"impatience",
				"confusion",
				"indifference"
			}
		},
		affliction = {
			"hierophant",
			"fitness",
			"insomnia",
			"asleep",
			"instawake",
			"voyria",
			"disrupted",
			"thin_blood",
			"camus",
			"blindness",
			"peace",
			"paresis",
			"clumsiness",
			"weariness",
			"stupidity",
			"asthma",
			"slickness",
			"anorexia",
			"disfigurement",
			"right_arm_broken",
			"left_arm_broken",
			"left_leg_broken",
			"right_leg_broken",
			"deafness",
			"sensitivity",
			"vomiting",
			"sunlight_allergy",
			"haemophilia"
		},

		affliction = {
			"hierophant",
			"fitness",
			"insomnia",
			"asleep",
			"instawake",
			"voyria",
			"disrupted",
			"thin_blood",
			"camus",
			"peace",
			"paresis",
			"anorexia",
			"stupidity",
			"asthma",
			"slickness",
			"clumsiness",
			"weariness",
			"disfigurement",
			"right_arm_broken",
			"left_arm_broken",
			"left_leg_broken",
			"right_leg_broken",
			"deafness",
			"sensitivity",
			"vomiting",
			"sunlight_allergy",
			"haemophilia"
		},
	},
	templar = {
		affliction = {
			"hierophant",
			"fitness",
			"conviction",
			"paresis",
			"clumsiness",
			"asthma",
			"slickness",
			"withering",
			"disfigurement",
			"left_arm_broken",
			"right_arm_broken",
			"left_leg_broken",
			"right_leg_broken",
			"mental_disruption",
			"anorexia",
			"weariness",
			"stupidity",
			"physical_disruption",
			"crippled",
			"crippled_body",
			"sunlight_allergy",
			"haemophilia",
			"deafness",
			"sensitivity",
			"vomiting",
			"blindness"
		},
		damage = {
			"hierophant",
			"fitness",
			"conviction",
			"paresis",
			"clumsiness",
			"asthma",
			"vomiting",		
			"deafness",
			"sensitivity",
			"sunlight_allergy",
			"haemophilia",
			"slickness",
			"withering",
			"disfigurement",
			"left_arm_broken",
			"right_arm_broken",
			"left_leg_broken",
			"right_leg_broken",
			"mental_disruption",
			"anorexia",
			"weariness",
			"stupidity",
			"physical_disruption",
			"crippled",
			"crippled_body",
			"blindness"
		},
		limb = {
			"left_arm_bruised",
			"torso_bruised",
			"left_arm_bruised_moderate",
			"right_arm_bruised",
			"torso_bruised_moderate",
			"right_arm_bruised_moderate",
			"right_leg_bruised",
			"left_leg_bruised",
			"head_bruised",
		},
		bruising = {
			"left_arm_bruised",
			"torso_bruised",
			"left_arm_bruised_moderate",
			"right_arm_bruised",
			"torso_bruised_moderate",
			"right_arm_bruised_moderate",
			"left_arm_bruised_critical",
			"torso_bruised_critical",
			"right_leg_bruised",
			"right_leg_bruised_moderate",
			"right_leg_bruised_critical",
			"left_leg_bruised",
			"left_leg_bruised_moderate",
			"left_leg_bruised_critical",
			"head_bruised",
			"head_bruised_moderate",
			"head_bruised_critical"
		}
	},
	teradrim = {
		affliction = {},
		arms = {
			"left_arm_damaged",
			"right_arm_damaged",
			"head_damaged",
			"torso_damaged",
			"right_leg_damaged",
			"left_leg_damaged",
			"left_arm_mangled",
			"right_arm_mangled",
			"head_mangled",
			"torso_mangled",
			"right_leg_mangled",
			"left_leg_mangled",
		},
		legs = {
			"right_leg_damaged",
			"left_leg_damaged",
			"head_damaged",
			"torso_damaged",
			"left_arm_damaged",
			"right_arm_damaged",
			"right_leg_mangled",
			"left_leg_mangled",
			"head_mangled",
			"torso_mangled",
			"left_arm_mangled",
			"right_arm_mangled",
		},
	},
	zealot = {},
}

allow = {
	agoraphobia = true,
	asthma = true,
	berserking = true,
	blindness = true,
	conviction = true,
	clarity = true,
	clumsiness = true,
	confusion = true,
	contemplate = true,
	crippled = true,
	crippled_body = true,
	deafness = true,
	dementia = true,
	destroyed_throat = true,
	distortion = true,
	epilepsy = true,
	fitness = true,
	fracture = true,
	haemophilia = true,
	head_bruised = true,
	head_bruised_moderate = true,
	head_bruised_critical = true,
	head_damaged = true,
	head_mangled = true,
	heartflutter = true,
	hellsight = true,
	hierophant = true,
	hypochondria = true,
	impatience = true,
	indifference = true,
	justice = true,
	left_arm_bruised = true,
	left_arm_bruised_moderate = true,
	left_arm_bruised_critical = true,
	left_arm_damaged = true,
	left_arm_mangled = true,
	left_leg_bruised = true,
	left_leg_bruised_moderate = true,
	left_leg_bruised_critical = true,
	left_leg_damaged = true,
	left_leg_mangled = true,
	lethargy = true,
	loki = true,
	loneliness = true,
	lovers_effect = true,
	magic_impaired = true,
	mark = true,
	masochism = true,
	mental_disruption = true,
	overwhelm = true,
	paranoia = true,
	paresis = true,
	physical_disruption = true,
	recklessness = true,
	right_arm_bruised = true,
	right_arm_bruised_moderate = true,
	right_arm_bruised_critical = true,
	right_arm_damaged = true,
	right_arm_mangled = true,
	right_leg_bruised = true,
	right_leg_bruised_moderate = true,
	right_leg_bruised_critical = true,
	right_leg_damaged = true,
	right_leg_mangled = true,
	ruptured_eardrum = true,
	seduction = true,
	self_pity = true,
	sensitivity = true,
	shadow = true,
	shred = true,
	shriveled_chest = true,
	slickness = true,
	soul_disease = true,
	soul_poison = true,
	spiritwrack = true,
	sunlight_allergy = true,
	superstition = true,
	temptation = true,
	torso_bruised = true,
	torso_bruised_moderate = true,
	torso_bruised_critical = true,
	torso_damaged = true,
	torso_mangled = true,
	vertigo = true,
	vomiting = true
}

follow = {}
switch = {}
match = {
	ascendril = {},
	cabalist = {},
	carnifex = {},
	indorani = {},
	luminary = {},
	monk = {},
	praenomen = {
		prio = {},
		allow = {},
		body_odor = {},
		commitment_fear = {},
		hubris = {},
		sadness = {},
		self_pity = {}
	},
	sentinel = {},
	shaman = {},
	shapeshifter = {},
	syssin = {
		prio = {
			"hypochondria",
			"thin_blood",
			"mental_fatigue",
			"lethargy",
			"impatience"
		},
		allow = {},
		hypochondria = {},
		impatience = {},
		lethargy = {},
		mental_fatique = {},
		thin_blood = {}
	},
	templar = {},
	teradrim = {},
	zealot = {}
}

function engage(class, route)
	if not engaged then return end

	--! todo: build stopwatches for these
	tmp.t_sync = tmp.t_sync or 2.5
	local t_timers = {
		["herb"] = 1.9,
		["pipe"] = 1.6,
		["salve"] = 1.1,
		["focus"] = 10,	--! todo
		["tree"] = 10,	--! todo
		["renew"] = 10,	--! todo
		["rage"] = 10,	--! todo
		["fitness"] = 20,
		["shrug"] = 20,
		["shed"] = 20,
		["scour"] = 20,
		["sync"] = tmp.t_sync,
		["active"] = 20	--! todo
	}

	for _, timer in pairs(t_timers) do
		t_timer = "t_" .. timer
		if stopwatch[t_timer] then
			timers[t_timer] = t_timers[timer] - getStopWatchTime(stopwatch[t_timer])
		else
			timers[t_timer] = nil
		end
	end

	parse_affs(class, route)
	k[class](route)
end

--! todo: time target rebounding for things you can push through rebounding and razes
function parse_affs(class, route)
	combo = {}
	local tar = tmp.target:title()

	local raze = {
		carnifex = true
	}

	local t = cdb.chars[tar]
	local parse = table.shallowcopy(prio[class][route])

	local match = match[class]
	if match and match.prio then
		for _, aff in ipairs(match.prio) do
			if t.affs[aff] and match.allow[aff] then
				parse = match[aff]
				break
			end
		end
	end

	local ent_bal = lib.ent_bals and lib.ent_bals[class] or nil
	local next_ent_aff
	for i, v in ipairs(parse) do
		if lib[aff] and lib[aff].ent and lib[aff].ent[class] then
			next_ent_aff = v
			break
		end
	end

	for k, v in pairs(follow) do
		table.iremove(parse, k)
		for pos, aff in ipairs(parse) do
			if aff == follow[v][1] then
				local pos = pos + follow[v][2]
				table.insert(parse, pos, k)
			end
		end
	end

	for k, v in pairs(switch) do
		table.ireplace(parse, k, v)
	end

	--! pick a first affliction to be only loaded as a venom
	for _, aff in ipairs(parse) do
		if ((allow[aff]
			and ((cn[aff]
				and cn[aff]())
				or not cn[aff]))
			or (cn[aff]
				and cn[aff](true)))
			and not (o.bals.ent_bal
			and aff == next_ent_aff)
			and ((((not t.affs[aff]
				and not (lib[aff].undead
					and t.affs[lib[aff].undead]))
				or (rp[aff]
					and rp[aff]()))
				and not lib[aff].def)
				or (t.defs[aff] 
					and lib[aff].def))
			and not t.affs[lib[aff].block]
			and not ((aff == "deafness"
					and t.affs.sensitivity)
				and not allow.deaf_no_sensi) 
			and not (lib[aff].one and lib[aff].one[class])
			and lib[aff].venom then
				tmp.v_one = aff
				break
		end
	end

	--! pick a first combination affliction
	for _, aff in ipairs(parse) do
		if ((allow[aff]
			and ((cn[aff]
				and cn[aff]())
				or not cn[aff]))
			or (cn[aff]
				and cn[aff](true)))
			and not (o.bals.ent_bal
				and aff == next_ent_aff)
			and ((((not t.affs[aff]
				and not (lib[aff].undead
					and t.affs[lib[aff].undead]))
				or (rp[aff]
					and rp[aff]()))
				and not lib[aff].def)
				or (t.defs[aff] 
					and lib[aff].def))
			and not t.affs[lib[aff].block]
			and not ((aff == "deafness"
					and t.affs.sensitivity)
				and not allow.deaf_no_sensi) 
			and not (lib[aff].one and lib[aff].one[class]) then
				tmp.ks_one = aff
				combo[aff] = true
				break
		end
	end

	if t.traits.implant then
		if t.traits.implant.trig == tmp.ks_one then
			combo[t.traits.implant.aff] = true
		end
	end

	local nocombo = {}
	if lib[tmp.ks_one].nocombo and lib[tmp.ks_one].nocombo[class] then
		for k, v in pairs(lib[tmp.ks_one].nocombo[class]) do
			nocombo[k] = true
		end
	end

	--! pick a second combination affliction
	for _, aff in ipairs(parse) do
		if ((allow[aff]
			and ((cn[aff]
				and cn[aff]())
				or not cn[aff]))
			or (cn[aff]
				and cn[aff](true)))
			and not (o.bals.ent_bal
			and aff == next_ent_aff)
			and tmp.ks_one ~= aff
			and ((((not t.affs[aff]
				and not (lib[aff].undead
					and t.affs[lib[aff].undead]))
				or (rp[aff]
					and rp[aff]()))
				and not lib[aff].def)
				or (t.defs[aff]
					and lib[aff].def))
			and not t.affs[lib[aff].block]
			and not ((aff == "deafness"
					and t.affs.sensitivity)
				and not allow.deaf_no_sensi)
			and not (lib[aff].two and lib[aff].two[class])
			and not nocombo[aff] then
				tmp.ks_two = aff
				if not (raze[class] and (t.defs.rebounding or t.defs.shielded)) then combo[aff] = true end
				break
		end
	end

	if t.traits.implant then
		if t.traits.implant.trig == tmp.ks_two then
			combo[t.traits.implant.aff] = true
		end
	end

	local nocombo = {}
	if lib[tmp.ks_two].nocombo and lib[tmp.ks_two].nocombo[class] then
		for k, v in pairs(lib[tmp.ks_two].nocombo[class]) do
			nocombo[k] = true
		end
	end

	--! pick a third combination affliction
	for _, aff in ipairs(parse) do
		if ((allow[aff]
			and ((cn[aff]
				and cn[aff]())
				or not cn[aff]))
			or (cn[aff]
				and cn[aff](true)))
			and tmp.ks_one ~= aff
			and tmp.ks_two ~= aff
			and ((not t.affs[aff]
				and not (lib[aff].undead
				and t.affs[lib[aff].undead])
				and not lib[aff].def)
				or (t.defs[aff]
					and lib[aff].def))
			and not t.affs[lib[aff].block]
			and not ((aff == "deafness"
					and t.affs.sensitivity)
				and not allow.deaf_no_sensi)
			and not (lib[aff].three and lib[aff].three[class])
			and not nocombo[aff] then
				tmp.ks_three = aff
				break
		end
	end
end

function blocked(aff)
	local t = cdb.chars[tmp.target:title()]
	if not aff then return false end
	if not lib[aff] then return false end
	if not lib[aff].block then return false end

	for i, v in ipairs(lib[aff].block) do
		if (t.affs[v] or t.traits[v]) then return true end
	end

	return false
end

function to_aff(name, venom)
	local name = name:title()
	if not cdb.chars[name] then cdb.add(name) end
	local t = cdb.chars[name]

	local aff = lib[venom].aff or lib[venom]
	if vn[venom] then
		aff = vn[venom](t)
	end

	if lib[aff].def then
		cdb.def(name, aff)
	else
		cdb.aff(name, aff, true)
	end
end

function check_allow(class, route)
	for _, aff in ipairs(prio[class][route]) do
		if not allow[aff] then
			e.warn("Affliction \'" .. aff .. "\' not allowed.", true, false)
		end
	end
	--echo("\n\n")
	--[[for k, v in pairs(allow) do
		if allow[k] and not table.contains(prio[class][route]) then
			e.kswitch("Affliction \'" .. k .. "\' allowed, but not present in priority.", true, false)
		end
	end]]
end

function cn.anorexia(bool)
	local tar = tmp.target:title()
	local stack = sets.stack
	if stack > 2 then stack = 2 end
	local t = cdb.chars[tmp.target:title()]

	local affs = { "impatience", "mental_disruption", "stupidity" }

	local num = 0
	for _, aff in ipairs(affs) do
		if t.affs[aff] or combo[aff] then
			num = num + 1
		end
	end

	return (t.affs.slickness
				or combo.slickness)
		and ((t.affs.limp_veins
			and t.status == "undead")
		or (t.affs.asthma
			and t.status == "living"))
		and (not bool
			or (bool 
				and num >= stack))
end

function cn.asleep(bool)
	local t = cdb.chars[tmp.target:title()]

	return t.affs.hypersomnia
		and t.affs.impatience
		and not bool
end

function cn.asthma(bool)
	local stack = sets.stack
	local autolock = sets.stacks.asthma
	local t = cdb.chars[tmp.target:title()]

	local num = 0
	for _, aff in ipairs(autolock) do
		if t.affs[aff] or combo[aff] then
			num = num + 1
		end
	end

	local ws_num = 0
	for _, aff in ipairs(affs.lib.focus) do
		if aff == "weariness" then
			break
		elseif t.affs[aff] or combo[aff] then
			ws_num = ws_num + 1
		end
	end
	if (ws_num >= stack or t.affs.impatience) and t.affs.weariness then num = num + 1 end

	if fs.t_fit then
		local to_t_fit = .9 - getStopWatchTime(stopwatch.t_fit)
		local fit_timer_okay = to_t_fit < timers.to_sync
	end

	return (num >= stack
		and not t.defs.fitness
		and not (fs.t_fit
			and not fit_timer_okay))
		and (not bool or (bool and allow.asthma))
end

function cn.camus(bool)
	local t = cdb.chars[tmp.target:title()]

	return t.affs.sensitivity
		and not t.defs.fangbarrier
		and not bool
end

function cn.cracked_ribs(bool)
	local t = cdb.chars[tmp.target:title()]
	return t.traits.prone
		and not bool
end

function cn.crushed_chest(bool)
	local t = cdb.chars[tmp.target:title()]
	return t.traits.prone
		and not bool
end

function cn.crushed_elbows(bool)
	local t = cdb.chars[tmp.target:title()]
	return t.traits.prone
		and not bool
end

function cn.crushed_kneecaps(bool)
	local t = cdb.chars[tmp.target:title()]
	return t.traits.prone
		and not bool
end

function cn.destroyed_throat(bool)
	local t = cdb.chars[tmp.target:title()]
		
	return (t.affs.slickness
		or (cn.slickness()
			and not (t.defs.shielded
				or t.defs.rebounding)
			and allow.slickness))
	and ((t.affs.limp_veins
			and t.status == "undead")
		or (t.affs.asthma
			and t.status == "living"))
		and ((t.affs.paresis
			or t.affs.paralysis
			or combo.paresis)
			or ((t.affs.left_arm_broken
				and t.affs.right_arm_broken)
				or (t.affs.left_arm_broken
					and combo.right_arm_broken)
				or (t.affs.right_arm_broken
					and combo.left_arm_broken))
			or t.affs.stun
			or t.affs.unconscious
			or (sets.t_parry
				and t.parry ~= "head"))
		and not bool
end

function cn.disfigurement(bool)
	local stack = sets.stack
	local autolock = sets.stacks.slickness
	local t = cdb.chars[tmp.target:title()]

	local count = #autolock
	if count < stack then
		stack = count
	end

	local num = 0
	for _, aff in ipairs(autolock) do
		if t.affs[aff] then
			num = num + 1
		end
	end

	local ws_num = 0
	for _, aff in ipairs(affs.lib.focus) do
		if aff == "weariness" then
			break
		elseif t.affs[aff] then
			ws_num = ws_num + 1
		end
	end
	if (ws_num >= stack or t.affs.impatience) and t.affs.weariness then num = num + 1 end

	return num >= stack
		and not (t.defs.fitness
			or fs.t_fit)
		and not bool
end

function cn.disrupted(bool)
	local t = cdb.chars[tmp.target:title()]

	return ((bool
		and t.affs.confusion
		and t.affs.slickness
		and ((t.affs.asthma
			and t.status == "living")
		or (t.affs.limp_veins
			and t.status == "undead"))
		and (t.affs.anorexia or t.affs.indifference)
		and (t.affs.paresis or t.affs.paralysis or not allow.paresis))
		or (not bool and t.affs.confusion))
end

function cn.distortion(bool)
	local t = cdb.chars[tmp.target:title()]
	
	return (((allow.damage
		and (t.affs.sensitivity
			or combo.sensitivity)
		and t.affs.soulchill)
		or ks.sets.route == "limb")
		and (stopwatch.t_rebounding
				and (6 - getStopWatchTime(stopwatch.t_rebounding)) <= (2 + timers.to_sync)))
		and not bool
end

function cn.frozen(bool)
	local stack = sets.stack
	local autolock = sets.stacks.slickness
	local t = cdb.chars[tmp.target:title()]

	local count = #autolock
	if count < stack then
		stack = count
	end

	local num = 0
	for _, aff in ipairs(autolock) do
		if t.affs[aff] or combo[aff] then
			num = num + 1
		end
	end

	local ws_num = 0
	for _, aff in ipairs(affs.lib.focus) do
		if aff == "weariness" then
			break
		elseif t.affs[aff] or combo[aff] then
			ws_num = ws_num + 1
		end
	end
	if (ws_num >= stack or t.affs.impatience) and t.affs.weariness then num = num + 1 end

	return num >= stack
		and ((t.affs.asthma
				or combo.asthma)
			or (t.affs.limp_veins
			or combo.limp_veins))
		and (t.affs.slickness
			or combo.slickness)
		and not (t.defs.fitness
			or fs.t_fit)
		and not bool
end

function cn.head_damaged(bool)
	local t = cdb.chars[tmp.target:title()]
	local class = o.stats.class

	return t.parry ~= "head"
		and t.restoring ~= "head"
		and not bool
end

function cn.head_mangled(bool)
	local t = cdb.chars[tmp.target:title()]
	local class = o.stats.class

	return (t.parry ~= "head"
		or (t.affs.right_arm_broken
			and t.affs.left_arm_broken)
		or (t.affs.paresis
			or t.affs.paralysis)
		or t.affs.stun
		or t.affs.unconscious)
		and t.restoring ~= "head"
		and not (combo.head_damaged
			and class == "luminary") and not bool
end

--! todo: re-arrange this - it's hellsighting when they have just asthma under 'stack 1,' but you need stack 1 to make it throw asthma in under just weariness/hypo
function cn.hellsight(bool)
	local stack = sets.stack
	local autolock = sets.stacks.hellsight
	local t = cdb.chars[tmp.target:title()]

	local count = #autolock
	if count < stack then
		stack = count
	end

	local num = 0
	for _, aff in ipairs(autolock) do
		if t.affs[aff] then
			num = num + 1
		end
	end

	local ws_num = 0
	for _, aff in ipairs(affs.lib.focus) do
		if aff == "weariness" then
			break
		elseif t.affs[aff] then
			ws_num = ws_num + 1
		end
	end
	if (ws_num >= stack or t.affs.impatience) and t.affs.weariness then num = num + 1 end

	return (num >= stack
		and ((t.affs.asthma
			and t.status == "living")
			or (t.affs.limp_veins
				and t.status == "undead"))
		and not (t.defs.fitness
			or fs.t_fit))
		and not bool
end

function cn.indifference(bool)
	local tar = tmp.target:title()
	local stack = sets.stack
	if stack > 2 then stack = 2 end
	local t = cdb.chars[tmp.target:title()]

	local affs = affs.lib.focus

	local num = 0
	for _, aff in ipairs(affs) do
		if t.affs[aff] or combo[aff] then
			num = num + 1
		end
	end

	return ((t.affs.slickness
				or combo.slickness)
			or (cn.slickness()
				and not (t.defs.shielded
					or t.defs.rebounding))
			and allow.slickness)
		and ((t.affs.limp_veins
			and t.status == "undead")
		or (t.affs.asthma
			and t.status == "living"))
		and (not bool 
			or (bool 
				and num >= stack))
end

function cn.insomnia(bool)
	local t = cdb.chars[tmp.target:title()]

	return t.affs.hypersomnia
		and t.affs.impatience
		and not bool
end

function cn.instawake(bool)
	local t = cdb.chars[tmp.target:title()]

	return t.affs.hypersomnia
		and t.affs.impatience
		and not bool
end

function cn.insulation(bool)
	local stack = sets.stack
	local autolock = sets.stacks.slickness
	local t = cdb.chars[tmp.target:title()]

	local count = #autolock
	if count < stack then
		stack = count
	end

	local num = 0
	for _, aff in ipairs(autolock) do
		if t.affs[aff] or combo[aff] then
			num = num + 1
		end
	end

	local ws_num = 0
	for _, aff in ipairs(affs.lib.focus) do
		if aff == "weariness" then
			break
		elseif t.affs[aff] or combo[aff] then
			ws_num = ws_num + 1
		end
	end
	if (ws_num >= stack or t.affs.impatience) and t.affs.weariness then num = num + 1 end

	return num >= stack
		and ((t.affs.asthma
				or combo.asthma)
			or (t.affs.limp_veins
			or combo.limp_veins))
		and (t.affs.slickness
			or combo.slickness)
		and not (t.defs.fitness
			or fs.t_fit)
		and not bool
end

function cn.left_arm_amputated(bool)
	local t = cdb.chars[tmp.target:title()]

	return t.affs.left_arm_mangled and not bool
end

function cn.left_arm_broken(bool)
	local t = cdb.chars[tmp.target:title()]

	return (not bool)
		and (t.affs.slickness
		or combo.slickness)
		and ((t.status == "undead"
			and t.affs.limp_veins)
		or (t.status == "living"
			and t.affs.asthma))
		and cn.slickness()
end

function cn.left_arm_damaged(bool)
	local t = cdb.chars[tmp.target:title()]
	local class = o.stats.class

	return (t.parry ~= "left arm"
		or (t.affs.right_arm_broken
			and t.affs.left_arm_broken)
		or (t.affs.paresis
			or t.affs.paralysis)
		or t.affs.stun
		or t.affs.unconscious)
		and (t.restoring ~= "left arm"
			or (t.affs.left_arm_bruised_critical
				and class == "teradrim"
				and allow.fracture))
		and not bool
end

function cn.left_arm_mangled(bool)
	local t = cdb.chars[tmp.target:title()]
	local class = o.stats.class

	return (t.parry ~= "left_arm"
		or (t.affs.right_arm_broken
			and t.affs.left_arm_broken)
		or (t.affs.paresis
			or t.affs.paralysis)
		or t.affs.stun
		or t.affs.unconscious)
		and (t.restoring ~= "left arm"
			or (t.affs.left_arm_bruised_critical
				and class == "teradrim"
				and allow.fracture))
		and not (combo.left_arm_damaged
			and class == "luminary") and not bool
end

function cn.left_leg_amputated(bool)
	local t = cdb.chars[tmp.target:title()]

	return t.affs.left_leg_mangled and not bool
end

function cn.left_leg_broken(bool)
	local t = cdb.chars[tmp.target:title()]

	return (not bool)
		and (t.affs.slickness
		or combo.slickness)
		and ((t.status == "undead"
			and t.affs.limp_veins)
		or (t.status == "living"
			and t.affs.asthma))
		and cn.slickness()
end

function cn.left_leg_damaged(bool)
	local t = cdb.chars[tmp.target:title()]
	local class = o.stats.class

	return (t.parry ~= "left leg"
		or (t.affs.right_arm_broken
			and t.affs.left_arm_broken)
		or (t.affs.paresis
			or t.affs.paralysis)
		or t.affs.stun
		or t.affs.unconscious)
		and (t.restoring ~= "left leg"
			or (t.affs.left_leg_bruised_critical
				and class == "teradrim"
				and allow.fracture
				and combo == {})) and not bool
end

function cn.left_leg_mangled(bool)
	local t = cdb.chars[tmp.target:title()]
	local class = o.stats.class

	return (t.parry ~= "left leg"
		or (t.affs.right_arm_broken
			and t.affs.left_arm_broken)
		or (t.affs.paresis
			or t.affs.paralysis)
		or t.affs.stun
		or t.affs.unconscious)
		and (t.restoring ~= "left leg"
			or (t.affs.left_leg_bruised_critical
				and class == "teradrim"
				and allow.fracture
				and combo == {}))
		and not (combo.left_leg_damaged
			and class == "luminary") and not bool
end

function cn.right_leg_amputated(bool)
	local t = cdb.chars[tmp.target:title()]

	return t.affs.right_leg_mangled and not bool
end

function cn.right_leg_broken(bool)
	local t = cdb.chars[tmp.target:title()]

	return (not bool)
		and (t.affs.slickness
		or combo.slickness)
		and ((t.status == "undead"
			and t.affs.limp_veins)
		or (t.status == "living"
			and t.affs.asthma))
		and cn.slickness()
end

function cn.right_leg_damaged(bool)
	local t = cdb.chars[tmp.target:title()]
	local class = o.stats.class

	return (t.parry ~= "right leg"
		or (t.affs.right_arm_broken
			and t.affs.left_arm_broken)
		or (t.affs.paresis
			or t.affs.paralysis)
		or t.affs.stun
		or t.affs.unconscious)
		and (t.restoring ~= "right leg"
			or (t.affs.right_leg_bruised_critical
				and class == "teradrim"
				and allow.fracture
				and combo == {})) and not bool
end

function cn.right_leg_mangled(bool)
	local t = cdb.chars[tmp.target:title()]
	local class = o.stats.class

	return (t.parry ~= "right leg"
		or (t.affs.right_arm_broken
			and t.affs.left_arm_broken)
		or (t.affs.paresis
			or t.affs.paralysis)
		or t.affs.stun
		or t.affs.unconscious)
		and (t.restoring ~= "right leg"
			or (t.affs.right_leg_bruised_critical
				and class == "teradrim"
				and allow.fracture
				and combo == {}))
		and not (combo.right_leg_damaged
			and class == "luminary") and not bool
end

function cn.right_arm_amputated(bool)
	local t = cdb.chars[tmp.target:title()]

	return t.affs.right_arm_mangled and not bool
end

function cn.right_arm_broken(bool)
	local t = cdb.chars[tmp.target:title()]

	return (not bool)
		and (t.affs.slickness
		or combo.slickness)
		and ((t.status == "undead"
			and t.affs.limp_veins)
		or (t.status == "living"
			and t.affs.asthma))
		and cn.slickness()
end

function cn.right_arm_damaged(bool)
	local t = cdb.chars[tmp.target:title()]
	local class = o.stats.class

	return (t.parry ~= "right arm"
		or (t.affs.right_arm_broken
			and t.affs.left_arm_broken)
		or (t.affs.paresis
			or t.affs.paralysis)
		or t.affs.stun
		or t.affs.unconscious)
		and (t.restoring ~= "right arm"
			or (t.affs.right_arm_bruised_critical
				and class == "teradrim"
				and allow.fracture
				and combo == {}))
		and not bool
end

function cn.right_arm_mangled(bool)
	local t = cdb.chars[tmp.target:title()]
	local class = o.stats.class

	return (t.parry ~= "right arm"
		or (t.affs.right_arm_broken
			and t.affs.left_arm_broken)
		or (t.affs.paresis
			or t.affs.paralysis)
		or t.affs.stun
		or t.affs.unconscious)
		and (t.restoring ~= "right arm"
			or (t.affs.right_arm_bruised_critical
				and class == "teradrim"
				and allow.fracture
				and combo == {}))
		and not (combo.right_arm_damaged
			and class == "luminary")
		and not bool
end

function cn.ruptured_eardrum(bool)
	local t = cdb.chars[tmp.target:title()]
	return (not t.defs.deafness)
		or combo.deafness
		and not bool
end

function cn.shivering(bool)
	local stack = sets.stack
	local autolock = sets.stacks.slickness
	local t = cdb.chars[tmp.target:title()]

	local count = #autolock
	if count < stack then
		stack = count
	end

	local num = 0
	for _, aff in ipairs(autolock) do
		if t.affs[aff] or combo[aff] then
			num = num + 1
		end
	end

	local ws_num = 0
	for _, aff in ipairs(affs.lib.focus) do
		if aff == "weariness" then
			break
		elseif t.affs[aff] or combo[aff] then
			ws_num = ws_num + 1
		end
	end
	if (ws_num >= stack or t.affs.impatience) and t.affs.weariness then num = num + 1 end

	return num >= stack
		and ((t.affs.asthma
				or combo.asthma)
			or (t.affs.limp_veins
			or combo.limp_veins))
		and (t.affs.slickness
			or combo.slickness)
		and not (t.defs.fitness
			or fs.t_fit)
		and not bool
end

function cn.slickness(bool)
	local stack = sets.stack
	local autolock = sets.stacks.slickness
	local t = cdb.chars[tmp.target:title()]

	local count = #autolock
	if count < stack then
		stack = count
	end

	local num = 0
	for _, aff in ipairs(autolock) do
		if t.affs[aff] or combo[aff] then
			num = num + 1
		end
	end

	local ws_num = 0
	for _, aff in ipairs(affs.lib.focus) do
		if aff == "weariness" then
			break
		elseif t.affs[aff] or combo[aff] then
			ws_num = ws_num + 1
		end
	end
	if (ws_num >= stack or t.affs.impatience) and t.affs.weariness then num = num + 1 end

	return num >= stack
		and ((t.affs.asthma
				or combo.asthma)
			or (t.affs.limp_veins
			or combo.limp_veins))
		and not (t.defs.fitness
			or fs.t_fit)
		and not bool
end

function cn.soulchill(bool)
	local t = cdb.chars[tmp.target:title()]

	return not bool
		or (t.affs.slickness
			or (cn.slickness()
			and not (t.affs.rebounding
			or t.defs.shielded))
			or combo.slickness)
end

function cn.stupidity(bool)
	local t = cdb.chars[tmp.target:title()]

	return (bool and (t.affs.anorexia or t.affs.indifference or combo.anorexia or combo.indifference) and not t.affs.impatience)
		or not bool
end

function cn.thin_blood(bool)
	local t = cdb.chars[tmp.target:title()]
	--[[local stack = sets.stack
	local autolock = sets.stacks.thin_blood
	if #autolock < stack then stack = count end
	stack = stack + 1

	local num = 0
	for _, aff in ipairs(autolock) do
		if t.affs[aff] then
			num = num + 1
		end
	end]]

	return not t.defs.fangbarrier
		and not bool
end

function cn.torso_damaged(bool)
	local t = cdb.chars[tmp.target:title()]
	local class = o.stats.class

	return (t.parry ~= "torso"
		or (t.affs.right_arm_broken
			and t.affs.left_arm_broken)
		or (t.affs.paresis
			or t.affs.paralysis)
		or t.affs.stun
		or t.affs.unconscious)
		and t.restoring ~= "torso"
		and not bool
end

function cn.torso_mangled(bool)
	local t = cdb.chars[tmp.target:title()]
	local class = o.stats.class

	return (t.parry ~= "torso"
		or (t.affs.right_arm_broken
			and t.affs.left_arm_broken)
		or (t.affs.paresis
			or t.affs.paralysis)
		or t.affs.stun
		or t.affs.unconscious)
		and t.restoring ~= "torso"
		and not bool
end

function cn.voyria(bool)
	local t = cdb.chars[tmp.target:title()]

	return t.affs.slickness
		and ((t.status == "undead"
			and t.affs.limp_veins)
		or (t.status == "living"
			and t.affs.asthma))
		and (t.affs.anorexia
			or t.affs.indifference
			or t.affs.destroyed_throat)
		and not bool
end

function cn.weariness(bool)
	local t = cdb.chars[tmp.target:title()]

	return (bool and t.affs.impatience) or not bool
end

function cn.withering(bool)
	local stack = sets.stack
	local autolock = sets.stacks.slickness
	local t = cdb.chars[tmp.target:title()]

	local count = #autolock
	if count < stack then
		stack = count
	end

	local num = 0
	for _, aff in ipairs(autolock) do
		if t.affs[aff] then
			num = num + 1
		end
	end

	local ws_num = 0
	for _, aff in ipairs(affs.lib.focus) do
		if aff == "weariness" then
			break
		elseif t.affs[aff] then
			ws_num = ws_num + 1
		end
	end
	if (ws_num >= stack or t.affs.impatience) and t.affs.weariness then num = num + 1 end

	return num >= stack
		and not (t.defs.fitness
			or fs.t_fit)
		and not bool
end

function rp.asthma()
	local fit_timer_okay
	if fs.t_fit then
		local to_t_fit = .9 - getStopWatchTime(stopwatch.t_fit)
		local fit_timer_okay = to_t_fit < timers.to_sync
	end
	return fit_timer_okay
end

function k.ascendril(route)
end

function k.cabalist(route)
end

--! todo: add tumble handling (on a toggle and timer)
--! todo: add limb route and pulverize
--! todo: add Implant
function k.carnifex(route)
	if not tmp.entourage then table.insert(prompt.q, "order loyal kill " .. tmp.target) end

	ab.instakill({ "crushed_chest", "prone" }, { "shielded" }, "hammer pulverize", { "balance" } ) --! todo: wield hammer
	ab.soul_poison(sets.carnifex.poison_thresh)
	ab.savagery(route, tmp.ks_one, tmp.ks_two)
	ab.warhounds(route, tmp.ks_three)
	ab.deathlore(route)
end

function k.indorani(route)
	if not tmp.entourage then table.insert(prompt.q, "order loyal kill " .. tmp.target) end

	inv.wield("shield", "left", sets.indorani.dagger, "right")
	ab.instakill({ "prone", "right_leg_broken", "left_leg_broken", "right_arm_broken", "left_arm_broken", "shriveled_chest" }, { "shielded" }, "vivisect", { "equilibrium" })
	ab.domination(route)
	ab.necromancy(route)
	ab.tarot(tmp.ks_one, tmp.ks_two)
end

function k.luminary(route)
	ab.contemplate()
	ab.absolve()
	ab.spirituality(route, tmp.ks_one, tmp.ks_two, tmp.ks_three)
end

function k.monk(route)
end

function k.praenomen(route)
	local rituos = _gmcp.has_skill("collect", "hematurgy") and true or false
	if not rituos and not tmp.entourage then table.insert(prompt.q, "order loyal kill " .. tmp.target) end

	ab.contemplate()
	ab.annihilate(rituos)
	if rituos then ab.hematurgy() end
	ab.sanguis(rituos, tmp.ks_one)
	ab.mentis(rituos, tmp.ks_two, tmp.ks_three)
end

function k.sciomancer(route)
end

function k.sentinel(route)
	inv.wield("dhurive", "both")
	ab.instakill({ "prone", "confusion", "right_leg_broken", "left_leg_broken" }, { "shielded" }, "dhuriv spinecut", { "balance" })
	ab.tracking(tmp.v_one)
	ab.woodlore(tmp.ks_one, tmp.ks_two)
	ab.dhuriv(route, tmp.ks_one, tmp.ks_two)
end

function k.shaman(route)
end

function k.shapeshifter(route)
end

function k.syssin(route)
	local t = cdb.chars[tmp.target:title()]

	if not (t.traits.hypnotised or t.traits.snapped) then table.insert(prompt.q, "hypnotise " .. tmp.target) end
	if not (defs.active.phased and defs.preserve.phased and not t.defs.phased) and not tmp.prehypno then
		ab.sleight()
		table.insert(prompt.q, "conjure darkflood")
		ab.subterfuge(tmp.ks_one, tmp.ks_two)
	end
	ab.suggest(route)
end

--! todo: add damage and limb routes
function k.templar(route)
	local bf_route = {
		affliction = "vorpal",
		bruising = "iceblast",
		damage = "crescent",
		limb = "iceblast"
	}

	ab.instakill({ "crippled_body", "mental_disruption", "physical_disruption" }, { "shielded" }, "retribution", { "equilibrium" })
	ab.rupture(sets.stack, "crit")
	ab.bladefire(bf_route[route], tmp.ks_three)
	ab.battlefury(route, tmp.ks_one, tmp.ks_two)
end

function k.teradrim(route)
	if not tmp.entourage then table.insert(prompt.q, "order loyal attack " .. tmp.target) end
	ab.desiccation(route, tmp.ks_three)
	ab.terramancy(route, tmp.ks_one, tmp.ks_two)
end

function k.zealot(route)
end

function ab.instakill(req_affs, no_defs, act, cons)
	if not can.reqbaleq() then return end
	if fs.queue then return end

	local t = cdb.chars[tmp.target:title()]

	local affcheck = true
	for _, aff in ipairs(req_affs) do
		if not t.affs[aff] and not t.traits[aff] then
			affcheck = false
			break
		end
	end

	local defcheck = true
	for _, def in ipairs(no_defs) do
		if t.defs[def] then
			defcheck = false
			break
		end
	end

	if affcheck and defcheck then
		table.insert(prompt.q, act .. " " .. tmp.target)
		if affs.stupidity then
			table.insert(prompt.q, act .. " " .. tmp.target)
		end

		for _, bal in ipairs(cons) do
			can.nobal(bal, true)
		end
	end
end

function ab.absolve()
	if not can.reqbaleq() then return end
	if affs.current.paralysis then return end
	if fs.queue then return end
	if allow.contemplate and not tmp.contemplated then return end
	local t = cdb.chars[tmp.target:title()]
	if t.defs.shielded then return end

	if t.mana <= 49 then
		table.insert(prompt.q, "angel absolve " .. tmp.target)
		if affs.current.stupidity then
			table.insert(prompt.q, "angel absolve " .. tmp.target)
		end
		can.nobal("equilibrium", true)
	elseif t.mana <= sets.luminary.sap_thresh then
		table.insert(prompt.q, "angel sap " .. tmp.target)
		if affs.current.stupidity then
			table.insert(prompt.q, "angel sap " .. tmp.target)
		end
		can.nobal("equilibrium", true)
	end
end

function ab.annihilate(rituos)
	if not can.reqbaleq() then return end
	if (affs.current.right_arm_broken and affs.current.left_arm_broken) or affs.current.paralysis then return end
	if fs.queue then return end
	if allow.contemplate and not tmp.contemplated then return end
	local t = cdb.chars[tmp.target:title()]

	if t.mana <= 34 then
		table.insert(prompt.q, "annihilate " .. tmp.target)
		if affs.current.stupidity then
			table.insert(prompt.q, "annihilate " .. tmp.target)
		end
		can.nobal("equilibrium", true)
		return
	elseif t.mana <= 42 and rituos and t.traits.shiftsoul then
		table.insert(prompt.q, "activate shiftsoul")
		if affs.current.stupidity then
			table.insert(prompt.q, "activate shiftsoul")
		end
		table.insert(prompt.q, "annihilate " .. tmp.target)
		if affs.current.stupidity then
			table.insert(prompt.q, "annihilate " .. tmp.target)
		end
		can.nobal("equilibrium", true)
		return
	end

	if rituos and ab.mindburrow() then
		table.insert(prompt.q, "wisp mindburrow " .. tmp.target)
		if affs.current.stupidity then
			table.insert(prompt.q, "wisp mindburrow " .. tmp.target)
		end
                if t.mana < 41 then 
                        table.insert(prompt.q, "wisp mindburrow " ..tmp.target)
                end
		can.nobal("equilibrium", true)
		return
	end
end


function ab.bladefire(abil, aff)
	if not can.reqbaleq() then return end
	if (affs.current.right_arm_broken or affs.current.left_arm_broken or affs.current.paralysis) then return end
	if fs.queue then return end
	local t = cdb.chars[tmp.target:title()]
	if t.defs.shielded then return end

	local ven
	if lib[aff].venom then ven = " " .. lib[aff].venom end
	if o.vitals.wield_left == "" then o.vitals.left_charge = nil end
	if o.vitals.wield_right == "" then o.vitals.right_charge = nil end

	local left = o.vitals.left_charge
	local right = o.vitals.right_charge

	local charge = {
		blastwave = 40,
		crescent = 150,
		iceblast = 100,
		lightning = 40,
		vorpal = 150
	}

	local both = {
		vorpal = true
	}

	if both[abil] and ((cn[abil] and cn[abil]()) or not cn[abil]) then
		if left and right then
			if left >= charge[abil]
				and right >= charge[abil] then
				table.insert(prompt.q, "blade release left " .. abil .. " " .. tmp.target .. ven)
				return true
			end
		elseif left and not right then
			if left >= charge[abil] then
				table.insert(prompt.q, "blade release left " .. abil .. " " .. tmp.target .. ven)
				return true
			end
		elseif right and not left then
			if right >= charge[abil] then
				table.insert(prompt.q, "blade release right " .. abil .. " " .. tmp.target .. ven)
				return true
			end
		end
	elseif ((cn[abil] and cn[abil]()) or not cn[abil]) then
		local bf = {}
		if left and right and left >= charge[abil] and right >= charge[abil] then
			table.insert(prompt.q, "blade release left " .. abil .. " " .. tmp.target .. ven)
			table.insert(prompt.q, "blade release right " .. abil .. " " .. tmp.target .. ven)
			return true
		else
			if left and left >= charge[abil] then
				table.insert(prompt.q, "blade release left " .. abil .. " " .. tmp.target .. ven)
				return true
			end
			if right and right>= charge[abil] then
				table.insert(prompt.q, "blade release right " .. abil .. " " .. tmp.target .. ven)
				return true
			end
		end
	end
	return false
end

function ab.battlefury(route, aff_one, aff_two)
	if not can.reqbaleq() then return end
	if (affs.current.right_arm_broken or affs.current.left_arm_broken or affs.current.paralysis) then return end
	if fs.queue then return end

	local t = cdb.chars[tmp.target:title()]
	local reb = t.defs.rebounding
	local shi = t.defs.shielded
	local atk = "dsk"

	local tar_one = " nothing"
	local tar_two = " nothing"

	if lib[aff_one].tar and lib[aff_one].tar.templar then
		tar_one = " " .. lib[aff_one].tar.templar
	end
	if lib[aff_two].tar and lib[aff_two].tar.templar then
		tar_two = " " .. lib[aff_two].tar.templar
	end

	if reb or shi then
		if route == "damage" and not tmp.dsw then
			inv.wield(unpack(sets.weaps.templar.affliction))
		else
			inv.wield(unpack(sets.weaps.templar[route]))
			if not sets.weaps.templar[route][3] then atk = "dsw" end
		end
		atk = "rsk"
		if reb and shi then
			aff_one = "blaze"
		end
	else
		if route == "damage" and not tmp.dsw then
			inv.wield(unpack(sets.weaps.templar.affliction))
		else
			inv.wield(unpack(sets.weaps.templar[route]))
			if not sets.weaps.templar[route][3] then atk = "dsw" end
		end
	end

	if aff_one == "withering" then
		local act = lib[aff_two].empower and "empower left with " or "envenom left with "
		table.insert(prompt.q, act .. lib[aff_two].venom)
		table.insert(prompt.q, "aura withering " .. tmp.target)
		table.insert(prompt.q, "rend " .. tmp.target)
		if affs.stupidity then
			table.insert(prompt.q, act .. lib[aff_two].venom)
			table.insert(prompt.q, "aura withering " .. tmp.target)
			table.insert(prompt.q, "rend " .. tmp.target)
		end			
		table.insert(prompt.q, "wipe left")
		table.insert(prompt.q, "wipe right")
		return
	end

	local v_1
	local v_2
	if tmp.sacrifice then
		v_1 = "sacrifice"
		v_2 = "sacrifice"
	elseif tmp.combustion then
		v_1 = "combustion"
		v_2 = "sacrifice"
	else
		v_1 = lib[aff_one].venom
		v_2 = lib[aff_two].venom
	end

	local suffix = v_1 .. " " .. v_2
	if tar_one and tar_two then suffix = suffix .. tar_one .. tar_two end

	table.insert(prompt.q, atk .. " " .. tmp.target .. " " .. suffix)
	if affs.stupidity then
		table.insert(prompt.q, atk .. " " .. tmp.target .. " " .. suffix)
	end
	table.insert(prompt.q, "wipe left")
	table.insert(prompt.q, "wipe right")
end

function ab.contemplate()
	if not can.reqbaleq() then return end
	if fs.queue then return end

	if allow.contemplate and not tmp.contemplated then
		table.insert(prompt.q, "contemplate " .. tmp.target)
		if affs.stupidity then
			table.insert(prompt.q, "contemplate " .. tmp.target)
		end
	end
end

function ab.deathlore(route)
	if not can.reqbaleq() then return end
	if ((affs.current.right_arm_broken or affs.current.left_arm_broken) and not defs.active.reckless) or (affs.current.right_arm_broken and affs.left_arm_broken) or affs.current.paralysis then return end
	if fs.queue then return end
	if (affs.current.confusion or affs.current.idiocy or affs.current.blood_curse) and not (affs.current.lethargy or affs.current.heartflutter or affs.current.plodding) then return end

	local t = cdb.chars[tmp.target:title()]
	local reb = t.defs.rebounding
	local shi = t.defs.shielded
	local hbal = o.bals.warhounds

	if reb and shi and not hbal then return end

	local deathlore = sets.carnifex.deathlore

	local atk
	for _, aff in ipairs(prio.carnifex.deathlore[route]) do
		local ab = lib[aff]
		if t.soul <= deathlore[aff].act
			and not cd[aff]
			and allow[aff]
			and not (t.affs[aff] 
				or t.traits[aff])
			and ((cn[aff]
				and cn[aff]())
			or not cn[aff]) then
			if ab == "implant" then
				atk = "soul implant " .. tmp.target .. " " .. deathlore.implant.ven_one .. " " .. deathlore.implant.ven_two
				break
			else
				atk = "soul " .. ab .. " " .. tmp.target
				break
			end
		end
	end

	if t.soul <= deathlore.distortion.act and not t.affs.distortion and (stopwatch.t_rebounding and (6 - getStopWatchTime(stopwatch.t_rebounding)) <= (2 + timers.to_sync)) and cn.distortion() then 
		atk = "soul distort " .. tmp.target
	end

	if atk then table.insert(prompt.q, atk) end
end

function ab.desiccation(route, aff)
	if fs.queue then return end
	if not can.reqbaleq() then return end
	if (affs.current.left_arm_broken and affs.current.right_arm_broken) or affs.current.paralysis or affs.current.stun then return end
	local t = cdb.chars[tmp.target:title()]

	local reb = t.defs.rebounding
	local shi = t.defs.shielded
	local storm = tonumber(o.vitals.sandstorm)

	if reb then
		if shi then
			if storm == 5 then
				table.insert(prompt.q, "sand slice " .. tmp.target .. " storm")
				table.insert(prompt.q, "sand slice " .. tmp.target .. " storm")
				combo.slice = true
				return
			end
		else
			if storm >= 3 then
				table.insert(prompt.q, "sand slice " .. tmp.target .. " storm")
				combo.slice = true
				return
			end
		end
	end

	if storm < 5 then return end

	if tmp.scourge then
		table.insert(prompt.q, "sand scourge " .. tmp.target .. " storm")
		return
	end

	if not allow.shred then return end

	local shred = {
		head_damaged = "sand shred " .. tmp.target .. " head",
		torso_damaged = "sand shred " .. tmp.target .. " torso",
		left_arm_damaged = "sand shred " .. tmp.target .. " left arm",
		right_arm_damaged = "sand shred " .. tmp.target .. " right arm",
		left_leg_damaged = "sand shred " .. tmp.target .. " left leg",
		right_leg_damaged = "sand shred " .. tmp.target .. " right leg",
		head_mangled = "sand shred " .. tmp.target .. " head",
		torso_mangled = "sand shred " .. tmp.target .. " torso",
		left_arm_mangled = "sand shred " .. tmp.target .. " left arm",
		right_arm_mangled = "sand shred " .. tmp.target .. " right arm",
		left_leg_mangled = "sand shred " .. tmp.target .. " left leg",
		right_leg_mangled = "sand shred " .. tmp.target .. " right leg"
	}

	local atk = shred[aff]
	table.insert(prompt.q, atk .. " storm")
end

function ab.dhuriv(route, aff_one, aff_two)
	if fs.queue then return end
	if not can.reqbaleq() then return end
	if affs.current.left_arm_broken or affs.current.right_arm_broken or affs.current.paralysis then return end
	local t = cdb.chars[tmp.target:title()]
	local v = lib[aff_one].venom and lib[aff_one].venom or ""
	local v2 = lib[aff_two].venom and lib[aff_two].venom or ""

	--! todo: tumble handling/trip/impale/gorge

	local init = {
		["addiction"] = "crosscut",
		["blindness"] = "blind",
		["blurry_vision"] = "blind",
		["confusion"] = "twirl",
		["destroyed_throat"] = "throatcrush",
		["epilepsy"] = "slam",
		["haemophilia"] = "crosscut",
		["indifference"] = "slam",
		["lethargy"] = "weaken"
	}

	local folup = {
		["crippled_throat"] = "slit",
		["heartflutter"] = "heartbreaker",
		["impatience"] = "gouge"
	}

	if t.defs.shielded and t.defs.rebounding then
		table.insert(prompt.q, "dhuriv dualraze " .. tmp.target)
		can.nobal("balance", true)
		return
	end

	local weaken_tar = ""
	if sets.t_parry and aff_one == "lethargy" then
		weaken_tar = t.parry == "left leg" and " right leg" or " left leg"
	else
		local rand = {
			"right",
			"left"
		}
		local pos = math.random(1, 2)
		weaken_tar = (aff_one == "lethargy") and " " .. rand[pos] .. " leg" or ""
	end

	if t.defs.rebounding or t.defs.shielded then
		table.insert(prompt.q, "dhuriv reave " .. tmp.target)
	elseif init[aff_one] then
		table.insert(prompt.q, "dhuriv " .. init[aff_one] .. " " .. tmp.target .. weaken_tar)
	else
		table.insert(prompt.q, "dhuriv slash " .. tmp.target .. " " .. v)
	end

	local slice_or_stab = ((t.affs.paresis or t.affs.paralysis or combo.paresis or (t.affs.right_arm_broken and (t.affs.left_arm_broken or combo.left_arm_broken)) or (t.affs.left_arm_broken and (t.affs.right_arm_broken or combo.right_arm_broken))) or (sets.t_parry and t.parry ~= "torso")) and "slice " or "stab "
	if folup[aff_two] then
		table.insert(prompt.q, "dhuriv " .. folup[aff_two] .. " " .. tmp.target)
	else
		table.insert(prompt.q, "dhuriv " .. slice_or_stab .. tmp.target .. " " .. v2)
	end
	table.insert(prompt.q, "wipe left")
	can.nobal("balance", true)
end

function ab.domination(route)
	if fs.queue then return end
	if not can.reqbaleq() then return end
	if (affs.current.left_arm_broken and affs.current.right_arm_broken) or affs.current.paralysis then return end
	local t = cdb.chars[tmp.target:title()]

	if o.bals.chimera and (route == "damage" or tmp.bonedagger) then
		table.insert(prompt.q, "order chimera headbutt")
	elseif o.bals.chimera then
		table.insert(prompt.q, "order chimera roar")
	end
end

function ab.earth_hammer()
	local t = cdb.chars[tmp.target:title()]
	local limbs = {
		"head",
		"torso",
		"left_arm",
		"right_arm",
		"left_leg",
		"right_leg"
	}

	local count = 0
	for i, v in ipairs(limbs) do
		local moderate = v .. "_bruised_moderate"
		local critical = v .. "_bruised_critical"
		if t.affs[moderate] or t.affs[critical] then
			count = count + 1
		end
	end

	return count >= 3
end

function ab.hematurgy()
	--! todo: populate ritual actions
	if not can.reqbaleq() then return end
	if (affs.current.right_arm_broken and affs.current.left_arm_broken) or affs.current.paralysis then return end
	local t = cdb.chars[tmp.target:title()]
	if (not o.traits.bloody or o.traits.bloody ~= tmp.target) then return end

	local ac = {
		bloodmeld = sets.praenomen.chanted.bloodmeld and "paint etpod on " .. tmp.target .. " with blood" or "chant abi de izuto kelo eja",
		eldritch = sets.praenomen.chanted.eldritch and "paint reri on " .. tmp.target .. " with blood" or "chant nipdo kuy du iyedlo wo kelo",
		shiftsoul = sets.praenomen.chanted.shiftsoul and "paint yomed on " .. tmp.target .. " with blood" or "chant nomru fevo kelo abi de wo ti ye de",
		thirst = sets.praenomen.chanted.thirst and "paint yomed on " .. tmp.target .. " with blood" or "chant de nud valutu nu"
	}

	for _, rit in ipairs({ "bloodmeld", "shiftsoul", "eldritch", "thirst" }) do
		if allow[rit] and not (t.affs[rit] or t.traits[rit]) then
			if t.defs.shielded and sets.praenomen.chanted[rit] then return end
			table.insert(prompt.q, ac[rit])
			can.nobal("equilibrium", true)
			break
		end
	end
end

function ab.mark()
	local t = cdb.chars[tmp.target:title()]

	local marks = {
		fatigue = "menal_fatigue",
		numbness = "numbed_skin",
		thorns = "thorns"
	}
	local mark = sets.syssin.mark
	local aff = marks[mark]

	return allow.mark and not t.affs[aff]
end

function ab.mentis(rituos, aff_one, aff_two)
	if not can.reqbaleq() then return end
	if (affs.current.right_arm_broken and affs.current.left_arm_broken) or affs.current.paralysis then return end
	if fs.queue then return end
	if allow.contemplate and not tmp.contemplated then return end
	local t = cdb.chars[tmp.target:title()]

	if not rituos then
		for _, aff in ipairs(sets.praenomen.biles) do
			if not t.affs[aff] then
				local bile = aff:gsub("effused_", ""):gsub("yellowbile", "yellow bile")
				local atk = "effuse " .. tmp.target .. " of " .. bile

				tmp.effused = aff

				table.insert(prompt.q, atk)
				if affs.current.stupidity then table.insert(prompt.q, atk) end
				return
			end
		end
	end

	aff_one = aff_one:gsub("berserking", "berserk"):gsub("clarity", "dementia")
	aff_two = aff_two:gsub("berserking", "berserk"):gsub("clarity", "dementia")

	local whisper = sets.praenomen.whisper
	local suffix = whisper == "whisper" and " " .. aff_one .. " " .. tmp.target or " " .. aff_one .. " " .. aff_two .. " " .. tmp.target

	table.insert(prompt.q, whisper .. suffix)
end

function ab.mindburrow()
	if not o.bals.mindburrow then return false end
	local t = cdb.chars[tmp.target:title()]

	local mentisaffs = {
		"agoraphobia",
		"anorexia",
		"berserking",
		"confusion",
		"dementia",
		"epilepsy",
		"impatience",
		"indifference",
		"loneliness",
		"masochism",
		"paranoia",
		"peace",
		"recklessness",
		"stupidity",
		"vertigo"
	}

	local count = 0
	for _, aff in ipairs(mentisaffs) do
		if t.affs[aff] then
			count = count + 1
		end
	end

	local damage = tonumber((count*3) + 8)
	if damage > 40 then damage = 40 end
	local mb_thresh = t.traits.shiftsoul and 42 or 34

	return (tonumber(t.mana - damage) < tonumber(mb_thresh - 11)) and true or false
end

function ab.necromancy(route)
	if fs.queue then return end
	if not can.reqbaleq() then return end
	if (affs.current.left_arm_broken and affs.current.right_arm_broken) or affs.current.paralysis then return end
	local t = cdb.chars[tmp.target:title()]
	if t.defs.shielded then return end

	if allow.shriveled_chest then table.insert(prompt.q, "shrivel chest " .. tmp.target) end

	if tmp.shrivel then
		for _, limb in ipairs({ "right leg", "left leg", "right arm", "left arm"}) do
			local aff = limb:gsub(" ", "_") .. "_broken"
			if not t.affs[aff] then
				table.insert(prompt.q, "shrivel " .. limb .. " " .. tmp.target)
				break
			end
		end
		can.nobal("equilibrium", true)
	elseif tmp.bonedagger and not t.defs.rebounding then
		table.insert(prompt.q, "fling bonedagger at " .. tmp.target .. " " .. tmp.v_one)
		can.nobal("balance", true)
	end
end

function ab.overwhelm()
	local t = cdb.chars[tmp.target:title()]

	local affcount = 0
	for k, v in pairs(t.affs) do
		if k then affcount = affcount + 1 end
	end

	local affcount_check = t.affs.sensitivity or affcount >= sets.luminary.o_thresh

	return allow.overwhelm
		and affcount_check
		and not t.defs.shielded
		and (t.traits.prone
		or t.affs.paralysis
		or t.affs.writhe_transfix
		or t.affs.writhe_bind
		or t.affs.writhe_armpitlock
		or t.affs.writhe_impaled
		or t.affs.writhe_necklock
		or t.affs.writhe_thighlock
		or t.affs.writhe_vines
		or t.affs.mob_impaled
		or t.affs.writhe_web)
end	

function ab.rupture(num, lev)
	if not can.reqbaleq() then return end
	if (affs.current.right_arm_broken or affs.current.left_arm_broken or affs.current.paralysis) then return end
	if fs.queue then return end
	local t = cdb.chars[tmp.target:title()]

	local tars = {
		"left_arm_bruised_critical",
		"left_leg_bruised_critical",
		"right_arm_bruised_critical",
		"right_leg_bruised_critical",
		"torso_bruised_critical",
		"head_bruised_critical",
		"left_arm_bruised_moderate",
		"left_leg_bruised_moderate",
		"right_arm_bruised_moderate",
		"right_leg_bruised_moderate",
		"torso_bruised_moderate",
		"head_bruised_moderate",
		"left_arm_bruised",
		"left_leg_bruised",
		"right_arm_bruised",
		"right_leg_bruised",
		"torso_bruised",
		"head_bruised"
	}

	local bruise = {
		light = {
			"left_arm_bruised",
			"left_leg_bruised",
			"right_arm_bruised",
			"right_leg_bruised",
			"torso_bruised",
			"head_bruised",
		},
		mod = {
			"left_arm_bruised_moderate",
			"left_leg_bruised_moderate",
			"right_arm_bruised_moderate",
			"right_leg_bruised_moderate",
			"torso_bruised_moderate",
			"head_bruised_moderate",
		},
		crit = {
			"left_arm_bruised_critical",
			"left_leg_bruised_critical",
			"right_arm_bruised_critical",
			"right_leg_bruised_critical",
			"torso_bruised_critical",
			"head_bruised_critical",
		}
	}

	local tar
	local count = 0
	for _, aff in ipairs(bruise[lev]) do
		if t.affs[aff] then
			count = count + 1
		end
	end

	for _, aff in ipairs(tars) do
		if t.affs[aff] then
			tar = lib[aff].tar.templar
			break
		end
	end

	if count >= num then
		inv.wield(unpack(sets.weaps.templar.bruising))
		if not cd.penance then table.insert(prompt.q, "penance " .. tmp.target) end
		table.insert(prompt.q, "rupture " .. tmp.target .. " " .. tar)
		can.nobal("balance", true)
	end
end

--! todo: code a function/table to parse which weapon attack based on wield
function ab.sanguis(rituos, aff, aff_two)
	if not can.reqbaleq() then return end
	if (affs.current.left_arm_broken and affs.current.right_arm_broken) or affs.current.paralysis or affs.current.stun then return end
	if fs.queue then return end
	if allow.contemplate and not tmp.contemplated then return end
	local t = cdb.chars[tmp.target:title()]
	local ven = lib[aff].venom

	local atk
	local weap
	if rituos then
		weap = { "scythe", "both" }
	else
		weap = sets.praenomen.weaps[sets.praenomen.hand][sets.praenomen.speed]
	end

	if not rituos then table.insert(prompt.q, "blood link " .. sets.praenomen.link) end

	if (t.defs.shielded and rituos) then
		atk = "wisp umbrage " .. tmp.target
	elseif (t.defs.shielded and not rituos) then
		if t.defs.rebounding then
			atk = "frenzy " .. tmp.target
		else
			atk = "devastate " .. tmp.target .. " " .. ven
			can.nobal("equilibrium", true)
		end
	elseif rituos and (not o.traits.bloody or o.traits.bloody ~= tmp.target) then
		atk = "scythe bloody " .. tmp.target
		can.nobal("equilibrium", true)
	elseif aff == "slickness" and not rituos then --! todo based on speed
		atk = "blood spew " .. tmp.target
	elseif (affs.current.left_arm_broken or affs.current.right_arm_broken) or not rituos and tmp.frenzy then
		if not rituos then table.insert(prompt.q, "blood " .. sets.praenomen.frenzy) end
		atk = "frenzy " .. tmp.target
	else
		if rituos then atk = "gash " .. tmp.target .. " " .. lib[aff].venom else atk = "jab " .. tmp.target .. " " .. lib[aff].venom end
	end

	local w, s, wd, sd = unpack(weap)
	inv.wield(w, s, wd, sd)
	table.insert(prompt.q, atk)

	if not rituos then
		local ent_atk
		if t.traits.prone and not t.defs.fangbarrier and allow.feast then
			ent_atk = "feast"
		elseif allow.brainboil and t.mana <= sets.praenomen.bb_thresh then
			ent_atk = "brainboil"
		elseif aff_two == "weariness" then
			ent_atk = "drain"
		elseif aff_two == "blood_fever" then
			ent_atk = "fever"
		elseif aff_two == "blood_plague" then
			ent_atk = "plague"
		end
		if ent_atk then
			table.insert(prompt.q, "blood command " .. ent_atk)
			can.nobal("equilibrium", true)
		end
	end
end

function ab.savagery(route, aff_one, aff_two)
	if not can.reqbaleq() then return end
	if ((affs.current.right_arm_broken or affs.current.left_arm_broken) and not defs.active.reckless) or (affs.current.right_arm_broken and affs.left_arm_broken) or affs.current.paralysis then return end
	if fs.queue then return end

	local route_bsl = {
		affliction = "pole ssl ",
		damage = "pole ssl ",
		limb = "hammer doublebash "
	}

	local t = cdb.chars[tmp.target:title()]
	local reb = t.defs.rebounding
	local shi = t.defs.shielded
	local atk = route_bsl[route]

	local tar_one = " nothing"
	local tar_two = " nothing"

	if lib[aff_one].tar then
		tar_one = " " .. lib[aff_one].tar
	end
	if lib[aff_two].tar then
		tar_two = " " .. lib[aff_two].tar
	end

	local crush = {
		cracked_ribs = true,
		crushed_chest = true,
		crushed_elbows = true,
		crushed_kneecaps = true
	}

	if reb and shi then
		atk = "raze "
	elseif (reb and not t.affs.distortion) or shi then
		inv.wield(unpack(sets.carnifex.bardiche))
		atk = "pole razehack "
	elseif crush[aff_one] and not (reb and not t.affs.distortion) then
		inv.wield(unpack(sets.carnifex.speed_hammer))
		local atk = "hammer crush "
	elseif allow.damage and t.affs.sensitivity and t.affs.soulchill and not shi and not (reb and not t.affs.distortion) then
		inv.wield(unpack(sets.carnifex.damage_hammer))
		tar_one = " nothing"
		tar_two = " nothing"
		local atk = "hammer bash "
	else
		inv.wield(unpack(sets.carnifex.bardiche))
	end

	local suffix
	if lib[aff_one].venom then suffix = lib[aff_one].venom end
	if lib[aff_two].venom then suffix = suffix .. " " .. lib[aff_two].venom end
	if tar_one then suffix = suffix .. tar_one end
	if tar_two then suffix = suffix .. tar_two end
	local atk = atk .. tmp.target .. " " .. suffix

	table.insert(prompt.q, atk)
	if affs.current.stupidity then
		table.insert(prompt.q, atk)
	end
end

function ab.seal()
	return tmp.seal
end

function ab.sleight()
	if fs.sleight then return end
	if ab.mark() then return end
	local t = cdb.chars[tmp.target:title()]
	if t.defs.shielded then return end

	local affcount = 0
	for k, v in pairs(t.affs) do
		if k then affcount = affcount + 1 end
	end

	local sleight = "dissipate"
	if allow.void and not (t.affs.void or t.affs.weakvoid) then
		sleight = "void"
	elseif allow.pall and (t.affs.sensitivity or affcount > sets.syssin.pall) then
		sleight = "pall"
	end

	send("qs shadow sleight " .. sleight .. " " .. tmp.target)
	fs.on("sleight")
end

function ab.soul_poison(thresh)
	local t = cdb.chars[tmp.target:title()]
	if t.affs.soul_poison then return end
	if cd.soul_poison then return end
	if t.defs.shielded then return end
	if not allow.soul_poison then return end

	local count = 0
	for k, v in pairs(t.affs) do
		if t.affs[k] then count = count + 1 end
	end

	if count >= thresh then
		table.insert(prompt.q, "soul poison " .. tmp.target)
		can.nobal("equilibrium", true)
	end
end

function ab.spirituality(route, aff_one, aff_two, aff_three)
	if fs.queue then return end
	if allow.contemplate and not tmp.contemplated then return end
	if not can.reqbaleq() then return end
	if (affs.current.right_arm_broken or affs.current.left_arm_broken or affs.current.paralysis) then return end
	local t = cdb.chars[tmp.target:title()]

	if t.traits.spiritwracked and aff_three then table.insert(prompt.q, "angel battle " .. aff_three:gsub("_", "-") .. " " .. tmp.target) end

	if ab.overwhelm() and not t.defs.shielded then
		inv.wield("tower", "left", "spiritmace", "right")
		table.insert(prompt.q, "shield overwhelm " .. tmp.target)
		table.insert(prompt.q, "chasten " .. tmp.target .. " " .. aff_two:gsub("clarity", "dementia"))
		can.nobal("balance", true)
		can.nobal("equilibrium", true)
		return
	end

	local weap = aff_one == "slickness" and "broadsword" or "spiritmace"
	local shield = sets.luminary.weaps[route] and sets.luminary.weaps[route] or "buckler"
	inv.wield(shield, "left", weap, "right")

	local smash = {
		right_leg_damaged = true,
		left_leg_damaged = true,
		right_arm_damaged = true,
		left_arm_damaged = true,
		right_leg_mangled = true,
		left_leg_mangled = true,
		right_arm_mangled = true,
		left_arm_mangled = true
	}

	if not t.defs.rebounding and not t.defs.shielded and tmp.smite then
		table.insert(prompt.q, "smite " .. tmp.target)
		can.nobal("balance", true)
		return
	elseif not t.defs.shielded and tmp.lightning then
		table.insert(prompt.q, "evoke lightning " .. tmp.target)
		return
	elseif not t.traits.spiritwracked and allow.spiritwrack then
		table.insert(prompt.q, "angel spiritwrack " .. tmp.target)
		can.nobal("equilibrium", true)
		return
	elseif not t.affs.shadow and allow.shadow then
		table.insert(prompt.q, "evoke shadow " .. tmp.target)
		can.nobal("equilibrium", true)
		return
	elseif tmp.angel_sear and not t.affs.angel_sear then
		table.insert(prompt.q, "angel sear " .. tmp.target)
		can.nobal("equilibrium", true)
		return
	elseif tmp.smash and not t.defs.shielded and smash[aff_one] then
		table.insert(prompt.q, "smash " .. lib[aff_one].tar.luminary .. " " .. tmp.target)
		can.nobal("balance", true)
		return
	end

	if t.defs.shielded and not (lib[aff_one].nr and lib[aff_one].nr.luminary) then
		table.insert(prompt.q, "shield raze " .. tmp.target)
		if affs.current.stupidity then
			table.insert(prompt.q, "shield raze " .. tmp.target)
		end
		table.insert(prompt.q, "chasten " .. tmp.target .. " " .. aff_two:gsub("clarity", "dementia"))
	else
		if not t.traits.spiritwracked and aff_three then table.insert(prompt.q, "angel battle " .. aff_three:gsub("_", "-") .. " " .. tmp.target) end
		if lib[aff_one].tar and lib[aff_one].tar.luminary then
			local t_1 = lib[aff_one].tar.luminary:gsub(" ", "")
			local t_2 = lib[aff_two].tar.luminary:gsub(" ", "")
			table.insert(prompt.q, "shield crush " .. tmp.target .. " " .. t_1 .. " " .. t_2)
			can.nobal("balance", true)
			return
		elseif aff_one == "hallucinations" or ((aff_one == "berserking" or aff_two == "berserking") and t.defs.rebounding) then
			table.insert(prompt.q, "evoke heatwave " .. tmp.target)
			if affs.current.stupidity then
				table.insert(prompt.q, "evoke heatwave " .. tmp.target)
			end
			can.nobal("equilibrium", true)
			return
		elseif (aff_one == "confusion" or aff_one == "dizziness") then
			table.insert(prompt.q, "perform dazzle " .. tmp.target)
			if affs.current.stupidity then
				table.insert(prompt.q, "perform dazzle " .. tmp.target)
			end
			can.nobal("equilibrium", true)
			return
		elseif (aff_one == "peace" or aff_one == "pacifism") then
			table.insert(prompt.q, "perform peace " .. tmp.target)
			if affs.current.stupidity then
				table.insert(prompt.q, "perform peace " .. tmp.target)
			end
			can.nobal("equilibrium", true)
			return
		elseif (not t.defs.rebounding and (aff_one == "berserking" or aff_one == "blindness") and (aff_two == "berserking" or aff_two == "blindness")) then
			table.insert(prompt.q, "shield facesmash " .. tmp.target)
			if affs.current.stupidity then
				table.insert(prompt.q, "shield facesmash " .. tmp.target)
			end
			can.nobal("balance", true)
			return
		elseif (not t.defs.rebounding and aff_one == "disrupted") then
			table.insert(prompt.q, "shield crash " .. tmp.target)
			if affs.current.stupidity then
				table.insert(prompt.q, "shield crash " .. tmp.target)
			end
			can.nobal("balance", true)
			return
		elseif aff_one == "hellsight" then
			table.insert(prompt.q, "perform hellsight " .. tmp.target)
			if affs.current.stupidity then
				table.insert(prompt.q, "perform hellsight " .. tmp.target)
			end
			can.nobal("equilibrium", true)
			return
		elseif aff_one == "slickness" then
			table.insert(prompt.q, "jab " .. tmp.target .. " gecko")
			can.nobal("balance", true)
			return
		elseif aff_one == "writhe_transfix" then
			table.insert(prompt.q, "evoke transfixion " .. tmp.target)
			if affs.current.stupidity then
				table.insert(prompt.q, "evoke transfixion " .. tmp.target)
			end
			can.nobal("equilibrium", true)
			return
		end

		local shield_atks = {
			asthma = "shield slam",
			blindness = "shield brilliance",
			fitness = "shield slam",
			limp_veins = "shield slam",
			paresis = "shield strike",
			weariness = "shield punch"
		}

		if t.defs.rebounding then
			table.insert(prompt.q, "shield raze " .. tmp.target)
			if affs.current.stupidity then
				table.insert(prompt.q, "shield raze " .. tmp.target)
			end
		else
			table.insert(prompt.q, shield_atks[aff_one] .. " " .. tmp.target)
			if affs.current.stupidity then
				table.insert(prompt.q, shield_atks[aff_one] .. " " .. tmp.target)
			end
		end

		table.insert(prompt.q, "chasten " .. tmp.target .. " " .. aff_two:gsub("clarity", "dementia"))
	end
end

function ab.subterfuge(aff_one, aff_two)
	if not can.reqbaleq() then return end
	if (affs.current.left_arm_broken and affs.current.right_arm_broken) or affs.current.paralysis then return end --! todo: figure this out if you can seal, mark, et cetera with broken arms
	if fs.queue then return end
	local t = cdb.chars[tmp.target:title()]
	local v = lib[aff_one].venom or aff_one
	local v2 = lib[aff_two].venom or aff_two

	local atk
	local weap = "dirk"
	local snap

	local bites = {
		camus = true,
		scytherus = true
	}

	if sets.syssin.snap == "atk" then snap = true end

	if bites[v] then
		weap = "whip"
		atk = "bite " .. tmp.target .. " " .. v
	elseif t.defs.shielded then
		weap = "whip"
		atk = "flay " .. tmp.target .. " shield"
	elseif ab.seal() then
		weap = "whip"
		atk = "seal " .. tmp.target .. " " .. sets.syssin.sealtimer
		if sets.syssin.snap == "seal" then snap = true end
	elseif o.bals.shadow and ab.mark() and t.defs.fangbarrier then
		weap = "whip"
		atk = "flay " .. tmp.target .. " sileris"
	elseif o.bals.shadow and ab.mark() and not t.defs.fangbarrier then
		weap = "whip"
		atk = "shadow mark numbness " .. tmp.target
	elseif aff_one == "disrupted" then
		weap = "whip"
		atk = "disrupt " .. tmp.target
	elseif t.defs.rebounding then
		weap = "whip"
		atk = "flay " .. tmp.target .. " rebounding " .. v
	elseif aff_one == "writhe_bind" then	--! todo
		table.insert(prompt.q, "outc rope")
		if affs.current.stupidity then
			table.insert(prompt.q, "outc rope")
		end
		weap = "whip"
		atk = "bind " .. tmp.target
	else
		if sets.syssin.snap == "dstab" then snap = true end
		weap = "dirk"
		atk = "dstab " .. tmp.target .. " " .. v .. " " .. v2
	end

	inv.wield("shield", "left", weap, "right")
	table.insert(prompt.q, atk)
	if affs.current.stupidity then table.insert(prompt.q, atk) end
	if snap then
		table.insert(prompt.q, "snap " .. tmp.target)
		if affs.current.stupidity then table.insert(prompt.q, "snap " .. tmp.target) end
	end
	table.insert(prompt.q, "wipe right")
end

function ab.suggest(route)
	if not can.reqbaleq() then return end
	if fs.queue then return end
	if ab.seal() then return end
	local t = cdb.chars[tmp.target:title()]

	if t.traits.snapped or t.traits.sealed then return end
	local dbl = sets.syssin.dbl_suggest
	tmp.to_suggest = tmp.to_suggest or table.shallowcopy(prio.syssin.suggest[route])
	tmp.suggested = tmp.suggested or {}

	for i, aff in ipairs(tmp.to_suggest) do
		if not allow[aff] then table.remove(tmp.to_suggest, i) end
	end

	local parse = tmp.to_suggest
	if #tmp.suggested == #parse then tmp.seal = true end

	local to_suggest = {}
	for p, aff in ipairs(parse) do
		if not tmp.suggested[p] then
			table.insert(to_suggest, aff)
		end
	end

	local suggest = dbl and to_suggest[1] .. " " .. to_suggest[2] or to_suggest[1]

	tmp.suggest = {}
	tmp.suggest[1] = to_suggest[1]
	tmp.suggest[2] = dbl and to_suggest[2] or nil

	if suggest then table.insert(prompt.q, "suggest " .. tmp.target .. " " .. suggest) end
end

function ab.tarot(aff_one, aff_two)
	if fs.queue then return end
	if not can.reqbaleq() then return end
	if (affs.current.left_arm_broken and affs.current.right_arm_broken) or affs.current.paralysis then return end
	local t = cdb.chars[tmp.target:title()]

	if t.defs.shielded then
		table.insert(prompt.q, "touch hammer " .. tmp.target)
		return
	end

	local aff_sub = {
		deafness = "sensitivity",
		fitness = "asthma",
		limp_veins = "asthma"
	}

	aff_one = aff_sub[aff_one] and aff_sub[aff_one] or aff_one
	local v = lib[aff_two].venom and lib[aff_two].venom or ""

	local tarot = {
		clumsiness = "sun",
		deafness = "sun",
		lethargy = "sun",
		paresis = "sun",
		sensitivity = "sun",
		slickness = "sun",
		vomiting = "sun",

		asthma = "moon",
		berserking = "moon",
		confusion = "moon",
		fitness = "moon",
		epilepsy = "moon",
		impatience = "moon",
		indifference = "moon",
		magic_impaired = "moon",
		stupidity = "moon",
		recklessness = "moon",

		lovers_effect = "lovers",

		justice = "justice",
		superstition = "justice",

		aeon = "aeon"
	}

	local fling = tarot[aff_one]
	local adder = tmp.devil and "" or " adder " .. v

	if not fling then e.debug("Fling caught nil on: " .. aff_one, true, false) end

	table.insert(prompt.q, "outc blank as " .. fling)
	table.insert(prompt.q, "fling " .. fling .. " at " .. tmp.target .. " " .. aff_one .. adder)
end

function ab.terramancy(route, aff_one, aff_two)
	if fs.queue then return end
	if not can.reqbaleq() then return end
	if (affs.current.left_arm_broken and affs.current.right_arm_broken) or affs.current.paralysis or affs.current.stun then return end
	local t = cdb.chars[tmp.target:title()]

	local reb = t.defs.rebounding
	local shi = t.defs.shielded

	if (not t.defs.shielded or (t.defs.shielded and combo.slice)) and ab.earth_hammer() then
		table.insert(prompt.q, "earth hammer " .. tmp.target)
		return
	end

	if (reb or shi) and not combo.slice then
		table.insert(prompt.q, "earth stoneblast " .. tmp.target)
		return
	end

	local fracture = {
		["right arm"] = true,
		["left arm"] = true,
		["right leg"] = true,
		["left leg"] = true
	}

	local t_1 = lib[aff_one].tar.teradrim
	local t_2 = lib[aff_two].tar.teradrim

	local limb = lib[aff_one].tar.teradrim:gsub(" ","_")
	local critical = limb .. "_bruised_critical"

	if tmp.batter then
		table.insert(prompt.q, "earth batter " .. tmp.target .. " nothing")
		return
	elseif tmp.furor then
		table.insert(prompt.q, "earth furor " .. tmp.target .. " " .. t_1 .. " " .. t_2)
		return
	elseif allow.fracture and t.affs[critical] and fracture[t_1] then
		table.insert(prompt.q, "earth fracture " .. tmp.target .. " " .. t_1)
		return
	end

	local atks = {
		["right arm"] = "earth slam " .. tmp.target .. " right arm",
		["left arm"] = "earth slam " .. tmp.target .. " left arm",
		["right leg"] = "earth slam " .. tmp.target .. " right leg",
		["left leg"] = "earth slam " .. tmp.target .. " left leg",
		["torso"] = "earth gutsmash " .. tmp.target,
		["head"] = "earth facesmash " .. tmp.target
	}

	local atk = atks[t_1]
	table.insert(prompt.q, atk)
end

function ab.tracking(aff_one)
	if fs.queue then return end
	if not can.reqbaleq() then return end
	if affs.current.left_arm_broken or affs.current.right_arm_broken or affs.current.paralysis then return end
	if not (tmp.xbow_reload or tmp.xbow_qshoot or tmp.combust) then return end
	local t = cdb.chars[tmp.target:title()]
	if t.defs.shielded then return end
	local v = lib[aff_one].venom and lib[aff_one].venom or "curare"

	if tmp.combust then
		table.insert(prompt.q, "resin combust")
		can.nobal("balance", true)
		return
	end

	local resinlist = {
		badulem = true,
		corsin = true,
		glauxe = true,
		harimel = true,
		hypersomnia = true,
		trientia = true
	}

	if tmp.resins then
		local resins = {
			["loki"] = "badulem",
			["corsin"] = "corsin",
			["blackout"] = "glauxe",
			["burnt_skin"] = "harimel",
			["hypersomnia"] = "lysirine",
			["ablaze"] = "trientia"
		}

		local parse = table.shallowcopy(prio.sentinel.resins)
		if #parse > 3 then
			for i, v in ipairs(parse) do
				if i > 3 then
					table.remove(parse, i)
				end
			end
		end

		for i, aff in ipairs(parse) do
			local resin = resins[v]
			if not t.resins[i] then
				v = resins[aff]
				break
			end
		end
	end

	--! todo: time alacrity, since you're queueing this
	if (defs.active.alacrity or tmp.xbow_reload) and not tmp.xbow_venom then
		table.insert(prompt.q, "crossbow load with normal coat " .. v)
		if not defs.active.alacrity then
			can.nobal("balance", true)
			return
		end
	end

	if not tmp.xbow_qshoot then return end
	if cd.quickshoot then return end

	local aff = lib[tmp.xbow_venom] or aff_one

	if ((aff and not t.affs[aff]) or resinlist[tmp.xbow_venom]) and (tmp.xbow_venom or defs.active.alacrity) then
		table.insert(prompt.q, "crossbow quickshoot " .. tmp.target)
		can.nobal("balance", true)
	end
end

function ab.warhounds(route, aff)
	if not can.reqbaleq() then return end
	if not o.bals.warhounds then return end
	if ((affs.current.right_arm_broken or affs.current.left_arm_broken) and not defs.active.reckless) or (affs.current.right_arm_broken and affs.left_arm_broken) or affs.current.paralysis then return end
	if fs.queue then return end

	local t = cdb.chars[tmp.target:title()]

	if not aff or t.affs[aff] then return end
	local wh = sets.carnifex.warhounds[aff]
	if tmp.active_warhound ~= wh then
		table.insert(prompt.q, "hound switch " .. wh)
		tmp.warhounds_switch = wh
	end

	table.insert(prompt.q, lib.warhounds[aff] .. " " .. tmp.target)
end

function ab.woodlore(aff_one, aff_two)
	if fs.queue then return end
	if not can.reqbaleq() then return end
	if affs.current.left_arm_broken or affs.current.right_arm_broken or affs.current.paralysis then return end
	local t = cdb.chars[tmp.target:title()]
	if not tmp.entourage then table.insert(prompt.q, "order loyal attack " .. tmp.target) end
	if tmp.opportunity and not cd.opportunity then table.insert(prompt.q, "opportunity") end

	if t.defs.rebounding or t.defs.shielded then return end

	local daunt = {
		["agoraphobia"] = "bear",
		["claustrophobia"] = "raloth",
		["loneliness"] = "crocodile",
		["vertigo"] = "cockatrice"
	}

	local dauntaff
	if daunt[aff_one] then
		dauntaff = aff_one
		v = lib[aff_two].venom
	elseif daunt[aff_two] then
		dauntaff = aff_two
		v = lib[aff_one].venom
	end

	if not dauntaff then return end

	if daunt[aff_one] or (daunt[aff_two] and lib[aff_one].venom) then
		table.insert(prompt.q, "order " .. daunt[dauntaff] .. " daunt " .. tmp.target)
		table.insert(prompt.q, "dhuriv flourish " .. tmp.target .. " " .. v)
		can.nobal("balance", true)
		can.nobal("equilibrium", true)
	end
end

function ac.bloodmeld()
end

function ac.eldritch()
end

function ac.shiftsoul()
end

function ac.thirst()
end

function vn.delphinium(t)
	if t.defs.insomnia then
		return "insomnia"
	elseif not t.affs.asleep then
		return "asleep"
	elseif t.defs.instawake then
		return "instawake"
	end
end

function vn.epseth(t)
	if t.affs.right_leg_broken then
		return "left_leg_broken"
	else
		return "right_leg_broken"
	end
end

function vn.epteth(t)
	if t.affs.left_arm_broken then
		return "right_arm_broken"
	else
		return "left_arm_broken"
	end
end

function vn.monkshood(t)
	if t.defs.hierophant then
		return "hierophant"
	else
		return "disfigurement"
	end
end

function vn.kalmia(t)
	if t.defs.fitness then
		return "fitness"
	else
		if t.status == "undead" then
			return "limp_veins"
		else
			return "asthma"
		end
	end
end

function vn.prefarar(t)
	if t.defs.deafness then
		return "deafness"
	elseif not t.affs.sensitivity then
		return "sensitivity"
	end
end


























































































































































































































































































--! DATA MINE - ABANDON ALL HOPE YE WHO DELVE BENEATH THIS CURSED POINT

function dep_parse_autolock(prio, lev)

	--! do clumsiness/magic_impaired

	--[[local autolock = table.contains(offense.allow, "paresis")
	local clear = table.contains(offenseprio, "paresis")

	if autolock
		and not clear then 
		table.insert(offenseprio, 1, "paresis") 
	elseif not autolock and clear then
		for i,v in pairs(offenseprio) do
			if v == "paresis" then
				table.remove(offenseprio, i)
			end
		end
	end]]

	--[[local autolock = killswitch:autolock("asthma")

	-- This check sweeps the table being parsed and, if all of the affs above clumsiness or magic_impaired are true, minus the ones that get added by this function, it will allow asthma.
	-- Added an additional check at the end for single-affliction parsing based on class, so that we're not trying to slash asthma when they don't have clumsiness, et cetera.
	tmp.autostack = true
	for i,v in pairs(offenseprio) do
		if ((v ~= "clumsiness"
			and v ~= "magic_impaired"
			and v ~= "asthma"
			and v ~= "limp_veins"
			and v ~= "slickness"
			and v ~= "thin_blood"
			and v ~= "right_leg_broken"
			and v ~= "left_leg_broken"
			and v ~= "left_arm_broken"
			and v ~= "right_arm_broken"
			and v ~= "asleep"
			and v ~= "no_insomnia"
			and v ~= "no_instawake"
			and v ~= "voyria"
			and v ~= "hellsight")
			and not t.affsv) then
			tmp.autostack = false
		elseif (v == "clumsiness"
			or v == "magic_impaired") then
				if not t.affsv
				and (o.stats.class == "bloodborn"
				or o.stats.class == "praenomen"
				or o.stats.class == "luminary") then
					tmp.autostack = false
				end
			break
		end
	end

	local autostack = tmp.autostack

	if t.status == "living" then
		tmp.clear = table.contains(offenseprio, "asthma")
	else
		tmp.clear = table.contains(offenseprio, "limp_veins")
	end

	local clear = tmp.clear

	if (autolock
		or autostack)
		and not clear then 
		if t.status == "living" then
			table.insert(offenseprio, 1, "asthma")
		else
			table.insert(offenseprio, 1, "limp_veins")
		end
	elseif not (autolock
		or autostack)
		and clear then
		for i,v in pairs(offenseprio) do
			if ((v == "asthma"
				and t.status == "living")
				or (v == "limp_veins"
				and t.status == "undead")) then
				table.remove(offenseprio, i)
			end
		end
	end]]

end

function dep_parse_affs()
	if not (bloodborn or indorani or luminary or praenomen or sentinel or syssin or templar) then return end

	killswitch:parse_autolock("venoms")
	track:t_asthma("venoms")
	if o.stats.class == "syssin" then
		for i,v in pairs(offense.match_hypno) do
			killswitch:parse_autolock_level("to_hypno", v)
			track:t_asthma_lev("to_hypno", v)
		end
	end

	local venoms = offense.venoms

	if o.stats.class == "syssin" then
		for i,v in pairs(offense.match_hypno) do
			if t.affsv then
				venoms = meta:load(offense.to_hypnov)
				break
			end
		end
	end

	-- This call populates a first venom - it specifically tracks venoms, Syssin bites, and Dhuriv attacks.
	for i,v in ipairs(venoms) do
		if not t.affsv
			and (list.to_venomv
			or (offense.dhurivv
			and offense.dhuriv.initialv
			and o.stats.class == "sentinel"))
			and not (v == "destroyed_throat"
			and not ((t.affs.paresis
			or t.affs.paralysis)
			or (t.affs.left_arm_broken
			and t.affs.right_arm_broken)))
			and not (v == "confusion"
			and not ((t.affs.paresis
			or t.affs.paralysis)
			or (t.affs.left_arm_broken
			and t.affs.right_arm_broken)))
			and not (v == "indifference"
			and not ((t.affs.paresis
			or t.affs.paralysis)
			or (t.affs.left_arm_broken
			and t.affs.right_arm_broken)))
			and not (v == "paresis"
			and t.affs.paralysis)
			and not (v == "crippled"
			and t.affs.crippled_body)
			and not (v == "thin_blood"
			and seal())
			and not (v == "no_deaf"
			and t.affs.sensitivity
			and not table.contains(offense.allow, "no_deaf"))
			and not ((v == "clumsiness"
			or v == "magic_impaired")
			and not table.contains(offense.allow, "clumsiness")) then

			if o.stats.class == "sentinel"
				and (v == "confusion"
				or v == "destroyed_throat"
				or v == "indifference"
				or v == "lethargy") then
				tmp.ks_one = v
				break

			else

				tmp.ks_one = list.to_venomv
				break

			end
		end
	end

	-- This call populates a venom for crossbow use.
	for i,v in pairs(venoms) do
		if not t.affsv
			and list.to_venomv
			and not (v == "destroyed_throat"
			and not ((t.affs.paresis
			or t.affs.paralysis)
			or (t.affs.left_arm_broken
			and t.affs.right_arm_broken)))
			and not (v == "confusion"
			and not ((t.affs.paresis
			or t.affs.paralysis)
			or (t.affs.left_arm_broken
			and t.affs.right_arm_broken)))
			and not (v == "indifference"
			and not ((t.affs.paresis
			or t.affs.paralysis)
			or (t.affs.left_arm_broken
			and t.affs.right_arm_broken)))
			and not (v == "paresis"
			and t.affs.paralysis)
			and not (v == "crippled"
			and t.affs.crippled_body)
			and not (v == "thin_blood"
			and seal())
			and not (v == "no_deaf"
			and t.affs.sensitivity
			and not table.contains(offense.allow, "no_deaf"))
			and not ((v == "clumsiness"
			or v == "magic_impaired")
			and not table.contains(offense.allow, "clumsiness")) then

			tmp.crossbow_venom = list.to_venomv
			break

		end
	end

	if o.stats.class == "bloodborn" then
		for i,v in pairs(offense.anxiety) do
			if t.affsv then
				for i,v in pairs(offense.a_venomsv) do
					if not t.affsv then
						tmp.ks_one = list.to_venomv
						break
					end
				end
			end
		end

	elseif (o.stats.class == "praenomen" and t.defs.rebounding) then
		if t.defs.rebounding then
			for i,v in pairs(offense.prae_r) do
				if not t.affsv then
					tmp.ks_one = v
					break
				end
			end
		end
	end

	if o.stats.class == "indorani" then
		for i,v in pairs(venoms) do
			if offense.tarotv
				and ((not t.affsv
				and v ~= "thin_blood"
				and v ~= "camus")
				and not (v == "paresis"
				and t.affs.paralysis)
				and not (v == "crippled"
				and t.affs.crippled_body)
				and (tmp.ks_one ~= list.to_venomv
				or ((offense.sleeplock
				or t.traits.tumble)
				and tmp.ks_one == "delphinium"
				and list.to_venomv == "delphinium"
				and not t.affs.asleep)
				or (tmp.ks_one == "epseth"
				and list.to_venomv == "epseth"
				and (not t.affs.right_leg_broken
				and not t.affs.left_leg_broken))
				or (tmp.ks_one == "epteth"
				and list.to_venomv == "epteth"
				and (not t.affs.right_arm_broken
				and not t.affs.left_arm_broken))
				or (v == "sensitivity"
				and tmp.ks_one == "prefarar"
				and not t.affs.no_deaf)
				or (tmp.ks_one == "disrupt"
				and (not t.affs.mental_disruption
				and not t.affs.physical_disruption))
				or (tmp.ks_one == "cripple"
				and (not t.affs.crippled_body
					and not t.affs.crippled)))) then

				tmp.tarot = " " .. v:gsub("limp_veins", "asthma"):gsub("no_deaf", "sensitivity")

				if offense.sunv then
					tmp.fling = "sun"
				elseif offense.moonv then
					tmp.fling = "moon"
				elseif v == "lovers_effect" then
					tmp.fling = "lovers"
				elseif v == "justice" then
					tmp.fling = "justice"
				end

				break
			end
		end

	elseif o.stats.class == "luminary" then
		for i,v in pairs(venoms) do
			if offense.strikev
				and not t.affsv
				and not (v == "paresis"
				and t.affs.paralysis)
				and not (v == "no_deaf"
				and t.affs.sensitivity
				and not table.contains(offense.allow, "no_deaf"))
				and not ((t.affs.dizziness or t.affs.confusion)
					and (offense.strikev == "perform dazzle"
						and not (t.affs.anorexia or t.affs.indifference))) 
				and not ((t.affs.berserking or t.affs.hallucinations)
					and (offense.strikev == "evoke heatwave"
						and not (t.affs.anorexia or t.affs.indifference))) then
				tmp.strike = offense.strikev
				break
			end
		end

		for i,v in pairs(venoms) do
			if offense.chastenv
				and not t.affsv then
				tmp.chasten = v:gsub("no_clarity", "dementia")
				break
			end
		end

		for i,v in pairs(venoms) do
			if offense.battlev
				and not t.affsv 
				and tmp.chasten ~= v then
				tmp.battle = v:gsub("no_deaf", "sensitivity"):gsub("self_pity", "self-pity")
				break
			end
		end
	end

	if o.stats.class == "bloodborn"
		or o.stats.class == "praenomen" then

		local autolock = killswitch:autolock("anorexia")
		local clear = table.contains(offense.dwhisper, "anorexia")

		if autolock
			and not clear then 
			table.insert(offense.dwhisper, 1, "anorexia")
			table.insert(offense.dwhisper, 1, "indifference")
		elseif not autolock and clear then
			for i,v in pairs(offense.dwhisper) do
				if v == "anorexia"
					or v == "indifference" then
					table.remove(offense.dwhisper, i)
				end
			end
		end

		for i,v in pairs(offense.dwhisper) do
			if (not t.affsv and tmp.ks_one ~= list.to_venomv) then
				tmp.whisperone = v:gsub("no_clarity","dementia")
				break
			end
		end

		for i,v in pairs(offense.dwhisper) do
			if (not t.affsv and tmp.ks_one ~= list.to_venomv and tmp.whisperone ~= v:gsub("no_clarity","dementia")) then
				tmp.whispertwo = v:gsub("no_clarity","dementia")
				break
			end
		end

	elseif not (o.stats.class == "syssin"
		or o.stats.class == "templar"
		or o.stats.class == "sentinel"
		or o.stats.class == "carnifex") then
		return

	end

	for i,v in pairs(venoms) do
		if (not t.affsv
			and (list.to_venomv
			or (offense.dhurivv
			and offense.dhuriv.secondaryv
			and o.stats.class == "sentinel")
			and v ~= "thin_blood"
			and v ~= "camus")
			and not (v == "paresis"
			and t.affs.paralysis)
			and not (v == "crippled"
			and t.affs.crippled_body)
			and not (v == "anorexia"
			and tmp.ks_one == "destroyed_throat"
			and not (t.defs.shielded or t.defs.rebounding))
			and not (v == "heartflutter"
			and not (t.defs.shielded
			or t.defs.rebounding)
			and not (((t.affs.paresis
			or t.affs.paralysis)
			and tmp.ks_one == "impatience")
			or ((t.affs.left_arm_broken
			and t.affs.right_arm_broken)
			or (tmp.ks_one == "epteth"
			and (t.affs.right_arm_broken
			or t.affs.left_arm_broken)))))
			and (tmp.ks_one ~= list.to_venomv
			or ((offense.sleeplock 
			or t.traits.tumble)
			and tmp.ks_one == "delphinium"
			and list.to_venomv == "delphinium"
			and not t.affs.asleep)
			or (tmp.ks_one == "epseth"
			and list.to_venomv == "epseth"
			and (not t.affs.right_leg_broken
			and not t.affs.left_leg_broken))
			or (tmp.ks_one == "epteth"
			and list.to_venomv == "epteth"
			and (not t.affs.right_arm_broken
			and not t.affs.left_arm_broken))
			or (v == "sensitivity"
			and tmp.ks_one == "prefarar"
			and not t.affs.no_deaf)
			or (tmp.ks_one == "disrupt"
			and (not t.affs.mental_disruption
			and not t.affs.physical_disruption))
			or (tmp.ks_one == "cripple"
			and (not t.affs.crippled_body
			and not t.affs.crippled)))
			and not ((v == "clumsiness"
			or v == "magic_impaired")
			and not table.contains(offense.allow, "clumsiness"))) then

			if o.stats.class == "sentinel"
				and (v == "heartflutter"
				or v == "impatience") then
				
				tmp.ks_two = v
				break

			else

				tmp.ks_two = list.to_venomv
				break

			end

		end
	end

	if o.stats.class ~= "templar" then return end

	for i,v in pairs(venoms) do
		if (((not t.affsv 
			and v ~= "thin_blood"
			and v ~= "camus")
			and not (v == "paresis"
			and t.affs.paralysis)
			and not (v == "crippled"
			and t.affs.crippled_body)
			and (tmp.ks_one ~= list.to_venomv
			and tmp.ks_two ~= list.to_venomv))
			or ((((tmp.ks_one == "epseth"
			or tmp.ks_two == "epseth")
			and not (tmp.ks_one == "epseth"
				and tmp.ks_two == "epseth"))
			and (list.to_venomv == "epseth"
			and (not t.affs.right_leg_broken
			and not t.affs.left_leg_broken)))
			or (((tmp.ks_one == "epteth"
			or tmp.ks_two == "epteth")
			and not (tmp.ks_one == "epteth"
				and tmp.ks_two == "epteth"))
			and (list.to_venomv == "epteth"
			and (not t.affs.right_arm_broken
			and not t.affs.left_arm_broken)))
			or (v == "sensitivity"
			and ((tmp.ks_one == "prefarar"
			or tmp.ks_two == "prefarar")
			and not (tmp.ks_one == "prefarar"
				and tmp.ks_two == "prefarar"))
			and not t.affs.no_deaf)
			or (v == "disrupt"
			and (tmp.ks_one == "disrupt"
			or tmp.ks_two == "disrupt")
			and not (tmp.ks_one == "disrupt"
				and tmp.ks_two == "disrupt"))
			and (not t.affs.mental_disruption
			and not t.affs.physical_disruption)
			or (v == "crippled_body"
			and (tmp.ks_one == "cripple"
				or tmp.ks_two == "cripple")
			and not (tmp.ks_one == "cripple"
				and tmp.ks_two == "cripple")
			and (not t.affs.crippled_body
				and not t.affs.crippled)))) then
			tmp.ks_three = list.to_venomv
			break
		end
	end
end

function engage_dep(self, class)
	if not set.killing then return end

	killswitch.bloodborn = {

		"Akirash",
		"Ashmer",
		"Dourif",
		"Edain",
		"Riluo",
		"Silai",
		"Zsadist"

	}

	killswitch.carnifex = {

		"Ashmer"

	}

	killswitch.indorani = {

		"Ashmer",
		"Rashar",
		"Yarel"
	
	}

	killswitch.luminary = {

		"Akirash",
		"Alethea",
		"Ashmer",
		"Edain",
		"Sajada"

	}

	killswitch.praenomen = {

		"Akirash",
		"Ashmer",
		"Carthenian",
		"Dourif", -- access until June 30th 2014
		"Edain",
		"Eliser",
		"Erzsebet"

	}

	killswitch.sentinel = {

		"Akirash",
		"Ashmer",
		"Edain"

	}

	killswitch.syssin = {

		"Akirash",
		"Ashmer",
		"Edain",
		"Ferrik",
		"Ishin",
		"Rashar",
		"Trager",
		"Yarel"

	}

	killswitch.templar = {

		"Ashmer",
		"Edain",
		"Sajada"

	}

	local bloodborn = table.contains(killswitch.bloodborn, o.stats.name) and true or false
	local indorani = table.contains(killswitch.indorani, o.stats.name) and true or false
	local luminary = table.contains(killswitch.luminary, o.stats.name) and true or false
	local praenomen = table.contains(killswitch.praenomen, o.stats.name) and true or false
	local sentinel = table.contains(killswitch.sentinel, o.stats.name) and true or false
	local syssin = table.contains(killswitch.syssin, o.stats.name) and true or false
	local templar = table.contains(killswitch.templar, o.stats.name) and true or false

	if not t.mana then
		track:t_reset()
		e.warn("No target data detected, resetting target variables.")
	end

	if not (t.status == "living" or t.status == "undead") then
		e.warn("Target status not populated.")
		t.status = "living"
		e.echo("Target read as: <navajo_white:firebrick>" .. t.status:title() .. "<slate_grey:black>.")
	end

	if class == "bloodborn" then
		if not bloodborn then
			echo("\n")
			e.warn("You have not purchased the offense module for Bloodborn! Don't you wish you had?")
			return
		end

		if fs.check("queue") or not can:reqbaleq() then return end

		if offense.contemplate then
			table.insert(prompt.q, "contemplate " .. tmp.target)
			if affs.stupidity then
				table.insert(prompt.q, "contemplate " .. tmp.target)
			end
			fs.on("offense", 0.5)
			return
		end

		if t.traits.shiftsoul then
			tmp.a_threshold = 41
			if not fs.check("shiftsoul") then table.insert(prompt.q, "activate shiftsoul") end
		else
			tmp.a_threshold = 34
		end

		if t.mana < tmp.a_threshold and not t.defs.shielded then
			weaponry:q_wield("scythe", "2h", "left")

			if t.traits.shiftsoul then send("activate shiftsoul") end

			table.insert(prompt.q, "annihilate " .. tmp.target)

			if affs.stupidity then 
				table.insert(prompt.q, "annihilate " .. tmp.target)
			end

			fs.on("offense", 0.5)
			return
		end

		if t.traits.tumble then
			if t.defs.fangbarrier then
				if fs.check("t_tumble") then

					table.insert(prompt.q, "breathe " .. tmp.target)

					if affs.stupidity then 
						table.insert(prompt.q, "breathe " .. tmp.target)
					end

				elseif not fs.check("t_tumble") then

					set.killing = false
					t.traits.tumble = false
					combat_echo("\n<cyan>" .. tmp.target:title() .. " <violet_red> is tumbling!")

				end

			elseif not t.defs.fangbarrier then
				table.insert(prompt.q, "feed " .. tmp.target)

				if affs.stupidity then 
					table.insert(prompt.q, "feed " .. tmp.target) 
				end

			end
			fs.on("offense", 0.5)
			return	
		end

		if (offense.bloodmeld 
			and not t.traits.bloodmeld) then
			ritual:enact("bloodmeld")
			return
		elseif (offense.shiftsoul
			and not t.traits.shiftsoul) then
			ritual:enact("shiftsoul")
			return
		end

		if t.traits.feed then return false end

		if mindburrow() and not t.defs.shielded and not fs.check("mindburrow") then
			weaponry:q_wield("scythe", "2h", "left")
			table.insert(prompt.q, "wisp mindburrow " .. tmp.target)
			if affs.stupidity then 
				table.insert(prompt.q, "wisp mindburrow " .. tmp.target)
			end
			can.nobal("equilibrium", true)
			fs.on("offense", 0.5)
			return
		end

		parse_affs()

		if (t.defs.shielded or affs.right_arm_broken or affs.left_arm_broken) and t.mana >= tmp.a_threshold then
			weaponry:q_wield("scythe", "2h", "left")
			table.insert(prompt.q, "frenzy " .. tmp.target)

			if affs.stupidity then 
				table.insert(prompt.q, "frenzy " .. tmp.target) 
			end
			
		elseif t.defs.shielded and t.mana < tmp.a_threshold then
			weaponry:q_wield("scythe", "2h", "left")
			table.insert(prompt.q, "touch hammer " .. tmp.target)

			if affs.stupidity then
				table.insert(prompt.q, "touch hammer " .. tmp.target)
			end

			fs.on("offense", 0.5)
			return

		else
			if tmp.ks_one == "writhe_transfix" then
				weaponry:q_wield("scythe", "2h", "left")
				table.insert(prompt.q, "mesmerize " .. tmp.target)

				if affs.stupidity then
					table.insert(prompt.q, "mesmerize " .. tmp.target)
				end

				fs.on("offense", 0.5)
				return

			elseif disrupt() then
				weaponry:q_wield("scythe", "2h", "left")
				table.insert(prompt.q, "disrupt " .. tmp.target)

				if affs.stupidity then
					table.insert(prompt.q, "disrupt " .. tmp.target)
				end

				fs.on("offense", 0.5)
				return

			else
				weaponry:q_wield("scythe", "2h", "left")
				table.insert(prompt.q, "gash " .. tmp.target .. " " .. tmp.ks_one)

				if affs.stupidity then
					table.insert(prompt.q, "gash " .. tmp.target .. " " .. tmp.ks_one)
				end
				table.insert(prompt.q, "wipe scythe")
			end

		end			

		tmp.loadwhisperone = tmp.whisperone:gsub("berserking", "berserk")
		tmp.loadwhispertwo = tmp.whispertwo:gsub("berserking", "berserk")

		table.insert(prompt.q, "dwhisper " .. tmp.loadwhisperone .. " " .. tmp.loadwhispertwo .. " " .. tmp.target)
		
		if affs.stupidity then
			table.insert(prompt.q, "dwhisper " .. tmp.loadwhisperone .. " " .. tmp.loadwhispertwo .. " " .. tmp.target)
		end

		fs.on("offense", 0.5)
	end

	if class == "carnifex" then
		if not carnifex then
			echo("\n")
			e.warn("You have not purchased the offense module for Carnifex! Don't you wish you had?")
			return
		end

		if fs.check("queue") or not can:reqbaleq() then return end

		parse_affs()

		if (t.defs.rebounding and t.defs.shielded) then
			table.insert(prompt.q, "soul erode " .. tmp.target)
			if affs.stupidity then
				table.insert(prompt.q, "soul erode " .. tmp.target)
			end

			return
		else
			if (t.defs.rebounding or t.defs.shielded) then
				weaponry:q_wield("bardiche", "2h", "left")
				table.insert(prompt.q, "pole razehack " .. tmp.target .. " " .. tmp.ks_one)
				table.insert(prompt.q, "hound contagion " .. tmp.target)
				if offense.implant and t.soul <= 75 and not tmp.implant_venom then
					table.insert(prompt.q, "soul implant " .. tmp.target .. " aconite slike")
				end
				if affs.stupidity then
					weaponry:q_wield("bardiche", "2h", "left")
					table.insert(prompt.q, "pole razehack " .. tmp.target .. " " .. tmp.ks_one)
					table.insert(prompt.q, "hound contagion " .. tmp.target)
					if offense.implant and t.soul <= 75 and not tmp.implant_venom then
						table.insert(prompt.q, "soul implant " .. tmp.target .. " aconite slike")
					end
				end

				return
				
			end
		end

		weaponry:q_wield("bardiche", "2h", "left")
		table.insert(prompt.q, "pole ssl " .. tmp.target .. " " .. tmp.ks_one .. " " .. tmp.ks_two)
		table.insert(prompt.q, "hound contagion " .. tmp.target)
		if offense.implant and t.soul <= 75 then
			table.insert(prompt.q, "soul implant " .. tmp.target .. " aconite slike")
		end
		if affs.stupidity then
			weaponry:q_wield("bardiche", "2h", "left")
			table.insert(prompt.q, "pole ssl " .. tmp.target .. " " .. tmp.ks_one .. " " .. tmp.ks_two)
			table.insert(prompt.q, "hound contagion " .. tmp.target)
			if offense.implant and t.soul <= 75 then
				table.insert(prompt.q, "soul implant " .. tmp.target .. " aconite slike")
			end
		end

		

	end

	if class == "indorani" then
		if not indorani then
			echo("\n")
			e.warn("You have not purchased the offense module for Indorani! Don't you wish you had?")
			return
		end

		parse_affs()

		if not can:reqbaleq() then return end
		if fs.check("queue") then return end

		if t.traits.tumble and o.bals.soulmaster then
			table.insert(prompt.q, "order " .. tmp.target .. " stop")
			if affs.stupidity then
				table.insert(prompt.q, "order " .. tmp.target .. " stop")
			end
		end

		if t.defs.shielded then		
			table.insert(prompt.q, "touch hammer " .. tmp.target)
			if affs.stupidity then
				table.insert(prompt.q, "touch hammer " .. tmp.target)
			end
			fs.on("offense", 0.5)
			return
		end

		if t.affs.right_leg_broken and t.affs.left_leg_broken and t.affs.right_arm_broken and t.affs.left_arm_broken then
			table.insert(prompt.q, "vivisect " .. tmp.target)
			if affs.stupidity then
				table.insert(prompt.q, "vivisect " .. tmp.target)
			end
			fs.on("offense", 0.5)
			return
		end

		if offense.call_entities then
			table.insert(prompt.q, "call entities")
			if affs.stupidity then
				table.insert(prompt.q, "call entities")
			end
			fs.on("offense", 0.5)
			return
		end

		if offense.hound then
			table.insert(prompt.q, "order hound track " .. tmp.target)
		end

		if offense.shrivel then
			if not (t.affs.left_arm_broken and t.affs.right_arm_broken) then
				table.insert(prompt.q, "shrivel arms " .. tmp.target)
				if affs.stupididity then
					table.insert(prompt.q, "shrivel arms " .. tmp.target)
				end
				return
			elseif not t.affs.left_leg_broken or not t.affs.right_leg_broken then
				table.insert(prompt.q, "shrivel legs " .. tmp.target)
				if affs.stupididity then
					table.insert(prompt.q, "shrivel legs " .. tmp.target)
				end
				return
			end
		end
		if offense.bonedagger then
			table.insert(prompt.q, "order chimera headbutt " .. tmp.target)
			if affs.stupidity then
				table.insert(prompt.q, "order chimera headbutt " .. tmp.target)
			end
			weaponry:q_wield("bonedagger", "1h", "left")
			weaponry:q_wield("shield", "1h", "left")
			if affs.stupidity then 
				weaponry:q_wield("bonedagger", "1h", "left")
				weaponry:q_wield("shield", "1h", "left")
			end
			table.insert(prompt.q, "flick bonedagger at " .. tmp.target .. " " .. tmp.ks_one)
			if affs.stupidity then
				table.insert(prompt.q, "flick bonedagger at " .. tmp.target .. " " .. tmp.ks_one)
			end
			fs.on("offense", 0.5)
			return
		end

		table.insert(prompt.q, "order chimera roar " .. tmp.target)

		local adder = offense.adder and " adder " .. tmp.ks_one or ""
		if offense.hide_tarot or offense.star_tarot then tmp.tarot = "" end
		if offense.star_tarot then tmp.fling = "star" end
		if _gmcp.has_skill("imprint") then
			table.insert(prompt.q, "outc blank as " .. tmp.fling)
			if affs.tupidity then
				table.insert(prompt.q, "outc blank as " .. tmp.fling)
			end
		else
			table.insert(prompt.q, "outd " .. tmp.fling)
			table.insert(prompt.q, "charge " .. tmp.fling)
			if affs.stupidity then
				table.insert(prompt.q, "outd " .. tmp.fling)
				table.insert(prompt.q, "charge " .. tmp.fling)
			end
		end
		table.insert(prompt.q, "fling " .. tmp.fling .. " at " .. tmp.target .. tmp.tarot:gsub("no_deaf", "sensitivity") .. adder)
		if affs.stupidity then
			table.insert(prompt.q, "fling " .. tmp.fling .. " at " .. tmp.target .. tmp.tarot:gsub("no_deaf", "sensitivity") .. adder)
		end
		fs.on("offense", 0.5)

	end

	if class == "luminary" then
		if not luminary then
			echo("\n")
			e.warn("You have not purchased the offense module for Luminary! Don't you wish you had?")
			return
		end

		parse_affs()

		if fs.check("queue") or not can:reqbaleq() then return end

		if offense.contemplate then
			table.insert(prompt.q, "contemplate " .. tmp.target)
			if affs.stupidity then
				table.insert(prompt.q, "contemplate " .. tmp.target)
			end
			fs.on("offense", 0.5)
			return
		end

		if t.mana < 49 then
			if not t.defs.shielded then

				table.insert(prompt.q, "angel absolve " .. tmp.target)
				if affs.stupidity then
					table.insert(prompt.q, "angel absolve " .. tmp.target)
				end			
		
				fs.on("offense", 0.5)
				return

			else

				table.insert(prompt.q, "touch hammer " .. tmp.target)
				if affs.stupidity then
					table.insert(prompt.q, "touch hammer " .. tmp.target)
				end			
		
				fs.on("offense", 0.5)
				return

			end
		end

		if (offense.sap 
			and t.mana <= set.s_threshold) then
			tmp.strike = "angel sap"
		end

		if disrupt() then
			tmp.strike = "shield crash"
		end

		if tmp.strike == "jab" then
			weaponry:q_wield("shortsword", "1h", "left")
		else
			weaponry:q_wield("spiritmace", "1h", "left")
		end
		if tmp.strike == "shield overwhelm" then
			weaponry:q_wield("tower", "1h", "right")
		else
			weaponry:q_wield("buckler", "1h", "right")
		end

		if tmp.strike == "evoke shadow" then
			table.insert(prompt.q, "evoke shadow " .. tmp.target)
			if affs.stupidity then
				table.insert(prompt.q, "evoke shadow " .. tmp.target)
			end

			fs.on("offense", 0.5)
			return
		end

		if t.defs.shielded and t.defs.rebounding then

			table.insert(prompt.q, "touch hammer " .. tmp.target)
			if affs.stupidity then
				table.insert(prompt.q, "touch hammer " .. tmp.target)
			end

			fs.on("offense", 0.5)
			return

		elseif (t.defs.shielded and not t.defs.rebounding)
			or (t.defs.rebounding and not t.defs.shielded) then

			tmp.strike = "shield raze"

		end

		table.insert(prompt.q, "angel battle " .. tmp.battle .. " " .. tmp.target)
		if affs.stupidity then
			table.insert(prompt.q, "angel battle " .. tmp.battle .. " " .. tmp.target)
		end

		if tmp.strike == "jab" then
			tmp.add = " gecko"
		else
			tmp.add = ""
		end
		
		table.insert(prompt.q, tmp.strike .. " " .. tmp.target .. tmp.add)
		if affs.stupidity then
			table.insert(prompt.q, tmp.strike .. " " .. tmp.target .. tmp.add)
		end

		if (tmp.strike == "shield strike"
			or tmp.strike == "shield punch"
			or tmp.strike == "shield raze"
			or tmp.strike == "shield brilliance"
			or tmp.strike == "smash") then

			table.insert(prompt.q, "chasten " .. tmp.target .. " " .. tmp.chasten)
			if affs.stupidity then
				table.insert(prompt.q, "chasten " .. tmp.target .. " " .. tmp.chasten)
			end

		end

		fs.on("offense", 0.5)
	end

	if class == "praenomen" then
		if not praenomen then
			echo("\n")
			e.warn("You have not purchased the offense module for Praenomen! Don't you wish you had?")
			return
		end

		if fs.check("queue") or not can:reqbaleq() then return end

		if offense.contemplate then
			table.insert(prompt.q, "contemplate " .. tmp.target)
			if affs.stupidity then
				table.insert(prompt.q, "contemplate " .. tmp.target)
			end
			fs.on("offense", 0.5)
			return
		end

		table.insert(prompt.q, "order entourage kill " .. tmp.target)

		t_locked()

		if t.mana < 34 and not t.defs.shielded then
			weaponry:wield(set.wield_weap, set.wield_set, "left")
			if set.wield_set == "1h" then weaponry:wield("shield", "1h", "right") end

			table.insert(prompt.q, "annihilate " .. tmp.target)
			if affs.stupidity then 
				table.insert(prompt.q, "annihilate " .. tmp.target)
			end

			fs.on("offense", 0.5)
			return
		end

		if t.traits.truelocked and table.contains(offense.allow, "feed") then
			if t.defs.fangbarrier then

				table.insert(prompt.q, "breathe " .. tmp.target)

				if affs.stupidity then 
					table.insert(prompt.q, "breathe " .. tmp.target)
				end

			elseif not t.defs.fangbarrier then
				table.insert(prompt.q, "feed " .. tmp.target)

				if affs.stupidity then 
					table.insert(prompt.q, "feed " .. tmp.target) 
				end

			end
				
			fs.on("offense", 0.5)
			return	
		end

		if t.traits.tumble then
			if t.defs.fangbarrier then
				if fs.check("t_tumble") then

					table.insert(prompt.q, "breathe " .. tmp.target)

					if affs.stupidity then 
						table.insert(prompt.q, "breathe " .. tmp.target)
					end

				elseif not fs.check("t_tumble") then

					set.killing = false
					t.traits.tumble = false
					combat_echo("\n<cyan>" .. tmp.target:title() .. " <violet_red> is tumbling!")

				end

			elseif not t.defs.fangbarrier then
				table.insert(prompt.q, "feed " ..target)
				if affs.stupidity then 
					table.insert(prompt.q, "feed " ..target) 
				end

			end
				
			fs.on("offense", 0.5)
			return	
		end

		if t.traits.feed then return end

		parse_affs()

		if (t.defs.shielded 
			or affs.right_arm_broken
			or affs.left_arm_broken) 
			and t.mana >= 34 then
			weaponry:q_wield(set.wield_weap, set.wield_set, "left")
			if set.wield_set == "1h" then weaponry:q_wield("shield", "1h", "right") end
			table.insert(prompt.q, "frenzy " .. tmp.target)

			if affs.stupidity then 
				table.insert(prompt.q, "frenzy " .. tmp.target) 
			end
			
		elseif t.defs.shielded and t.mana < 34 then
			weaponry:q_wield(set.wield_weap, set.wield_set, "left")
			if set.wield_set == "1h" then weaponry:q_wield("shield", "1h", "right") end
			table.insert(prompt.q, "touch hammer " .. tmp.target)

			if affs.stupidity then
				table.insert(prompt.q, "touch hammer " .. tmp.target)
			end

			fs.on("offense", 0.5)
			return

		else
			if tmp.ks_one == "writhe_transfix" then
				weaponry:q_wield(set.wield_weap, set.wield_set, "left")
				if set.wield_set == "1h" then weaponry:q_wield("shield", "1h", "right") end
				table.insert(prompt.q, "mesmerize " .. tmp.target)

				if affs.stupidity then
					table.insert(prompt.q, "mesmerize " .. tmp.target)
				end

				fs.on("offense", 0.5)
				return

			elseif disrupt() then
				weaponry:q_wield(set.wield_weap, set.wield_set, "left")
				if set.wield_set == "1h" then weaponry:q_wield("shield", "1h", "right") end
				table.insert(prompt.q, "disrupt " .. tmp.target)

					if affs.stupidity then
						table.insert(prompt.q, "disrupt " .. tmp.target)
					end

					fs.on("offense", 0.5)
					return

			elseif tmp.ks_one == "blood_poison" then
				tmp.loadwhisperone = tmp.whisperone:gsub("berserking", "berserk")
				tmp.loadwhispertwo = tmp.whispertwo:gsub("berserking", "berserk")

				table.insert(prompt.q, "dwhisper " .. tmp.loadwhisperone .. " " .. tmp.loadwhispertwo .. " " .. tmp.target)
				table.insert(prompt.q, "blood poison " .. tmp.target)
		
				if affs.stupidity then
					table.insert(prompt.q, "dwhisper " .. tmp.loadwhisperone .. " " .. tmp.loadwhispertwo .. " " .. tmp.target)
					table.insert(prompt.q, "blood poison " .. tmp.target)
				end

				fs.on("offense", 0.5)
				return

			elseif tmp.ks_one == "blood_curse" then
				tmp.loadwhisperone = tmp.whisperone:gsub("berserking", "berserk")
				tmp.loadwhispertwo = tmp.whispertwo:gsub("berserking", "berserk")

				table.insert(prompt.q, "dwhisper " .. tmp.loadwhisperone .. " " .. tmp.loadwhispertwo .. " " .. tmp.target)
				table.insert(prompt.q, "blood curse " .. tmp.target)
		
				if affs.stupidity then
					table.insert(prompt.q, "dwhisper " .. tmp.loadwhisperone .. " " .. tmp.loadwhispertwo .. " " .. tmp.target)
					table.insert(prompt.q, "blood curse " .. tmp.target)
				end

				fs.on("offense", 0.5)
				return

			elseif tmp.ks_one == "gecko" then
				tmp.loadwhisperone = tmp.whisperone:gsub("berserking", "berserk")
				tmp.loadwhispertwo = tmp.whispertwo:gsub("berserking", "berserk")
	
				table.insert(prompt.q, "blood spew " .. tmp.target)
				table.insert(prompt.q, "dwhisper " .. tmp.loadwhisperone .. " " .. tmp.loadwhispertwo .. " " .. tmp.target)
		
				if affs.stupidity then
					table.insert(prompt.q, "blood spew " .. tmp.target)
					table.insert(prompt.q, "dwhisper " .. tmp.loadwhisperone .. " " .. tmp.loadwhispertwo .. " " .. tmp.target)
				end

				fs.on("offense", 0.5)
				return

			elseif tmp.ks_one == "frenzy" then
				weaponry:q_wield(set.wield_weap, set.wield_set, "left")
				if set.wield_set == "1h" then weaponry:q_wield("shield", "1h", "right") end
				table.insert(prompt.q, "frenzy " .. tmp.target)

				if affs.stupidity then
					table.insert(prompt.q, "frenzy " .. tmp.target)
				end
			else
				weaponry:q_wield(set.wield_weap, set.wield_set, "left")
				if set.wield_set == "1h" then weaponry:q_wield("shield", "1h", "right") end
				table.insert(prompt.q, "jab " .. tmp.target .. " " .. tmp.ks_one)

				if affs.stupidity then
					table.insert(prompt.q, "jab " .. tmp.target " " .. tmp.ks_one)
				end
			end
		end

		for i,v in pairs(offense.biles) do
			if not t.affsv then
				tmp.tarbile = v
				table.insert(prompt.q, "effuse " .. tmp.target .. " of " .. list.to_praev)
				if affs.stupidity then
					table.insert(prompt.q, "effuse " .. tmp.target .. " of " .. list.to_praev)
				end
				fs.on("offense", 0.5)
				return
			end
		end

		tmp.loadwhisperone = tmp.whisperone:gsub("berserking", "berserk")
		tmp.loadwhispertwo = tmp.whispertwo:gsub("berserking", "berserk")

		table.insert(prompt.q, "dwhisper " .. tmp.loadwhisperone .. " " .. tmp.loadwhispertwo .. " " .. tmp.target)
		
		if affs.stupidity then
			table.insert(prompt.q, "dwhisper " .. tmp.loadwhisperone .. " " .. tmp.loadwhispertwo .. " " .. tmp.target)
		end

		fs.on("offense", 0.5)
	end

	if class == "syssin" then
		if not syssin then
			echo("\n")
			e.warn("You have not purchased the offense module for Syssin! Don't you wish you had?")
			return
		end

		parse_affs()

		if tmp.paused then return end

		--lightwall()
		sleight()

		if fs.check("queue") or not can:reqbaleq() then return end

		if (o.bals.primary_illusion or o.bals.secondary_illusion) then send("conjure darkflood") end

		if not tmp.hypno_count then tmp.hypno_count = 0 end

		if tmp.reset_hypno then
			send("cleanse " .. tmp.target)
		end

		if not t.traits.hypnosis
			and not o.traits.hypnosis then
			table.insert(prompt.q, "hypnotise " .. tmp.target)
		end

		if mark() then
			if t.defs.fangbarrier then
				weaponry:q_wield("whip", "1h", "left")
					if affs.stupidity then
						weaponry:q_wield("whip", "1h", "left")
					end
				weaponry:q_wield("shield", "1h", "right")

				table.insert(prompt.q, "flay " .. tmp.target .. " sileris")
					if affs.stupidity then
						table.insert(prompt.q, "flay " .. tmp.target .. " sileris")
					end

				tmp.doublesuggest = set.doublesuggest and " " .. offense.suggest2:gsub("berserking", "berserk") or ""

				if not seal() then
					table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
					if affs.stupidity then
						table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
					end
				end

				tmp.lastflay = "fangbarrier"
				fs.on("offense", 0.5)
				return

			elseif not t.defs.fangbarrier and not t.defs.shielded then
				table.insert(prompt.q, "shadow mark " .. tmp.mark .. " " .. tmp.target)
					if affs.stupidity then
						table.insert(prompt.q, "shadow mark " .. tmp.mark .. " " .. tmp.target)
					end

				tmp.doublesuggest = set.doublesuggest and " " .. offense.suggest2:gsub("berserking", "berserk") or ""

				if not seal() 
					and not t.traits.sealed then
					table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
					if affs.stupidity then
						table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
					end
				end

				fs.on("offense", 0.5)
				return
			end
		end

		if disrupt() then 
			table.insert(prompt.q, "disrupt " .. tmp.target)
			if affs.stupidity then
				table.insert(prompt.q, "disrupt " .. tmp.target)
			end

			fs.on("offense", 0.5)
			return
		end

		if (tmp.ks_one == "scytherus"
			or tmp.ks_one == "camus") then
			table.insert(prompt.q, "bite " .. tmp.target .. " " .. tmp.ks_one)

			if affs.stupidity then
				table.insert(prompt.q, "bite " .. tmp.target .. " " .. tmp.ks_one)
			end

			tmp.doublesuggest = set.doublesuggest and " " .. offense.suggest2:gsub("berserking", "berserk") or ""

			if not seal() 
				and not t.traits.sealed then
				table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
				if affs.stupidity then
					table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") ..  tmp.doublesuggest)
				end
			end

			fs.on("offense", 0.5)
			return
		end

		if seal() then
			if not tmp.sealtimer then tmp.sealtimer = "2.5" end
			if not tmp.snap then tmp.snap = "dstab" end

			table.insert(prompt.q, "seal " .. tmp.target .. " " .. tmp.sealtimer)
				if affs.stupidity then
					table.insert(prompt.q, "seal " .. tmp.target .. " " .. tmp.sealtimer)
				end

			if tmp.snap == "seal" then 
				table.insert(prompt.q, "snap " .. tmp.target) 
				if affs.stupidity then
					table.insert(prompt.q, "snap " .. tmp.target) 
				end
			end
			return
			fs.on("offense", 0.5)
		end

		if t.defs.shielded then
			weaponry:q_wield("whip", "1h", "left")
				if affs.stupidity then
					weaponry:q_wield("whip", "1h", "left")
				end

			weaponry:q_wield("shield", "1h", "right")

			table.insert(prompt.q, "flay " .. tmp.target .. " shield")
				if affs.stupidity then
					table.insert(prompt.q, "flay " .. tmp.target .. " shield")
				end

				tmp.doublesuggest = set.doublesuggest and " " .. offense.suggest2:gsub("berserking", "berserk") or ""

				if not seal() then
					table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
					if affs.stupidity then
						table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
					end
				end

			tmp.lastflay = "shielded"
			fs.on("offense", 0.5)
			return
		end

		if t.traits.tumble then

			if (t.defs.rebounding
			and fs.check("t_flay_tumble")) then

				weaponry:q_wield("whip", "1h", "left")
					if affs.stupidity then
						weaponry:q_wield("whip", "1h", "left")
					end

				weaponry:q_wield("shield", "1h", "right")

				table.insert(prompt.q, "envenom whip with " .. tmp.ks_one)
				table.insert(prompt.q, "flay " .. tmp.target .. " rebounding")
					if affs.stupidity then
						table.insert(prompt.q, "envenom whip with " .. tmp.ks_one)
						table.insert(prompt.q, "flay " .. tmp.target .. " rebounding")
					end

				tmp.doublesuggest = set.doublesuggest and " " .. offense.suggest2:gsub("berserking", "berserk") or ""

				if not seal() 
					and not t.traits.sealed then
					table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
					if affs.stupidity then
						table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
					end
				end

				tmp.lastflay = "rebounding"
				fs.on("offense", 0.5)
				return
			end

			if fs.check("t_full_tumble") then
				e.warn("<gold>Wait for it...")
				fs.on("offense", 0.5)
				return
			elseif not t.defs.rebounding then
				weaponry:q_wield("dirk", "1h", "left")
				if affs.stupidity then
					weaponry:q_wield("dirk", "1h", "left")
				end

				weaponry:q_wield("shield", "1h", "right")

				table.insert(prompt.q, "dstab " .. tmp.target .. " " .. tmp.ks_one .. " " .. tmp.ks_two)
				table.insert(prompt.q, "wipe dirk")
				table.insert(prompt.q, "wipe whip")
				if affs.stupidity then
					table.insert(prompt.q, "dstab " .. tmp.target .. " " .. tmp.ks_one .. " " .. tmp.ks_two)
					table.insert(prompt.q, "wipe dirk")
					table.insert(prompt.q, "wipe whip")
				end

				if (tmp.snap == "dstab" 
					and t.traits.sealed) then 
					table.insert(prompt.q, "snap " .. tmp.target) 
					if affs.stupidity then
						table.insert(prompt.q, "snap " .. tmp.target)
					end
				end

				tmp.doublesuggest = set.doublesuggest and " " .. offense.suggest2:gsub("berserking", "berserk") or ""

				if not seal() 
					and not t.traits.sealed then
					table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
					if affs.stupidity then
						table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
					end
				end

				fs.on("offense", 0.5)
				return

			else
				e.warn("<gold>Wait for it...")
				fs.on("offense", 0.5)
				return
			end
		end

		if offense.bind
			and t.affs.asleep
			and not (t.affs.writhe_armpitlock
			or t.affs.writhe_bind
			or t.affs.writhe_feed
			or t.affs.writhe_impaled
			or t.affs.writhe_necklock
			or t.affs.writhe_ropes
			or t.affs.writhe_thighlock
			or t.affs.writhe_transfix
			or t.affs.writhe_vines
			or t.affs.writhe_web) then

			table.insert(prompt.q, "outc rope")
			table.insert(prompt.q, "bind " .. tmp.target)

			if affs.stupidity then
				table.insert(prompt.q, "outc rope")
				table.insert(prompt.q, "bind " .. tmp.target)
			end

			tmp.doublesuggest = set.doublesuggest and " " .. offense.suggest2:gsub("berserking", "berserk") or ""

			if not seal() 
				and not t.traits.sealed then
				table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
				if affs.stupidity then
					table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
				end
			end

			fs.on("offense", 0.5)
			return
		end

		if t.defs.rebounding then
			weaponry:q_wield("whip", "1h", "left")
				if affs.stupidity then
					weaponry:q_wield("whip", "1h", "left")
				end

			weaponry:q_wield("shield", "1h", "right")

			table.insert(prompt.q, "envenom whip with " .. tmp.ks_one)
			table.insert(prompt.q, "flay " .. tmp.target .. " rebounding")
			if affs.stupidity then
				table.insert(prompt.q, "envenom whip with " .. tmp.ks_one)
				table.insert(prompt.q, "flay " .. tmp.target .. " rebounding")
			end

			if (tmp.snap == "dstab" 
				and t.traits.sealed
				and not t.traits.snapped) then 
				table.insert(prompt.q, "snap " .. tmp.target) 
					if affs.stupidity then
						table.insert(prompt.q, "snap " .. tmp.target)
					end
			end

			tmp.doublesuggest = set.doublesuggest and " " .. offense.suggest2:gsub("berserking", "berserk") or ""

			if not seal() 
				and not t.traits.sealed then
				table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
				if affs.stupidity then
					table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
				end
			end

			tmp.lastflay = "rebounding"
			fs.on("offense", 0.5)
			return
		end

		weaponry:q_wield("dirk", "1h", "left")
			if affs.stupidity then
				weaponry:q_wield("dirk", "1h", "left")
			end
		weaponry:q_wield("shield", "1h", "right")

		table.insert(prompt.q, "dstab " .. tmp.target .. " " .. tmp.ks_one .. " " .. tmp.ks_two)
		table.insert(prompt.q, "wipe dirk")
		table.insert(prompt.q, "wipe whip")
			if affs.stupidity then
				table.insert(prompt.q, "dstab " .. tmp.target .. " " .. tmp.ks_one .. " " .. tmp.ks_two)
				table.insert(prompt.q, "wipe dirk")
				table.insert(prompt.q, "wipe whip")
			end

		if (tmp.snap == "dstab" 
			and t.traits.sealed
			and not t.traits.snapped) then 
			table.insert(prompt.q, "snap " .. tmp.target) 
				if affs.stupidity then
					table.insert(prompt.q, "snap " .. tmp.target)
				end
		end

		tmp.doublesuggest = set.doublesuggest and " " .. offense.suggest2:gsub("berserking", "berserk") or ""
		
		if not seal()
			and not t.traits.sealed then
			table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
			if affs.stupidity then
				table.insert(prompt.q, "suggest " .. tmp.target .. " " .. offense.suggest1:gsub("berserking", "berserk") .. tmp.doublesuggest)
			end
		end
		fs.on("offense", 0.5)
	end

	if class == "templar" then
		if not templar then
			echo("\n")
			e.warn("You have not purchased the offense module for Templar! Don't you wish you had?")
			return
		end

		parse_affs()

		if not can:reqbaleq() then return end
		if fs.check("queue") then return end

		if t.defs.shielded then
			if t.defs.rebounding then
				weaponry:q_wield("rapier", "1h", "left")
				weaponry:q_wield("rapier", "1h", "right")
				table.insert(prompt.q, "rsk " .. tmp.target .. " blaze")
				if affs.stupidity then
					weaponry:q_wield("rapier", "1h", "left")
					weaponry:q_wield("rapier", "1h", "right")
					table.insert(prompt.q, "rsk " .. tmp.target .. " blaze")
				end
				table.insert(prompt.q, "wipe left")
				table.insert(prompt.q, "wipe right")
				fs.on("offense", 1)
				return

			else
				weaponry:q_wield("rapier", "1h", "left")
				weaponry:q_wield("rapier", "1h", "right")
				table.insert(prompt.q, "rsk " .. tmp.target .. " " .. tmp.ks_one)
				if affs.stupidity then
					weaponry:q_wield("rapier", "1h", "left")
					weaponry:q_wield("rapier", "1h", "right")
					table.insert(prompt.q, "rsk " .. tmp.target .. " " .. tmp.ks_one)
				end
				table.insert(prompt.q, "wipe left")
				table.insert(prompt.q, "wipe right")
				fs.on("offense", 1)
				return

			end

		else
			if t.defs.rebounding then
				if t.affs.mental_disruption and t.affs.physical_disruption and t.affs.crippled_body then
					weaponry:q_wield("rapier", "1h", "left")
					weaponry:q_wield("rapier", "1h", "right")
					table.insert(prompt.q, "retribution " .. tmp.target)
					if affs.stupidity then
						weaponry:q_wield("rapier", "1h", "left")
						weaponry:q_wield("rapier", "1h", "right")
						table.insert(prompt.q, "retribution " .. tmp.target)
					end
					table.insert(prompt.q, "wipe left")
					table.insert(prompt.q, "wipe right")
					fs.on("offense", 1)
					return
				end

				if t.traits.tumble then
					if not o.traits.impaling then
						weaponry:q_wield("rapier", "1h", "left")
						weaponry:q_wield("rapier", "1h", "right")
						table.insert(prompt.q, "impale " .. tmp.target)
						if affs.stupidity then
							weaponry:q_wield("rapier", "1h", "left")
							weaponry:q_wield("rapier", "1h", "right")
							table.insert(prompt.q, "impale " .. tmp.target)
						end
						return
					end
				end
		
				if tonumber(o.vitals.left_charge) >= 150 and tonumber(o.vitals.right_charge) >= 150 then
					weaponry:q_wield("rapier", "1h", "left")
					weaponry:q_wield("rapier", "1h", "right")
					table.insert(prompt.q, "blade release vorpal " .. tmp.target .. " " .. tmp.ks_one)
					table.insert(prompt.q, "rsk " .. tmp.target .. " " .. tmp.ks_two)
					if affs.stupidity then
						weaponry:q_wield("rapier", "1h", "left")
						weaponry:q_wield("rapier", "1h", "right")
						table.insert(prompt.q, "rsk " .. tmp.target .. " " .. tmp.ks_two)
					end
					table.insert(prompt.q, "wipe left")
					table.insert(prompt.q, "wipe right")
					fs.on("offense", 1)

				else
					weaponry:q_wield("rapier", "1h", "left")
					weaponry:q_wield("rapier", "1h", "right")
					table.insert(prompt.q, "rsk " .. tmp.target .. " " .. tmp.ks_one)
					if affs.stupidity then
						weaponry:q_wield("rapier", "1h", "left")
						weaponry:q_wield("rapier", "1h", "right")
						table.insert(prompt.q, "rsk " .. tmp.target .. " " .. tmp.ks_one)
					end
					table.insert(prompt.q, "wipe left")
					table.insert(prompt.q, "wipe right")
					fs.on("offense", 1)
				end

			end
		end

		if o.traits.impaling then
			weaponry:q_wield("rapier", "1h", "left")
			weaponry:q_wield("rapier", "1h", "right")
			table.insert(prompt.q, "disembowel " .. tmp.target)
			if affs.stupidity then
				weaponry:q_wield("rapier", "1h", "left")
				weaponry:q_wield("rapier", "1h", "right")
				table.insert(prompt.q, "disembowel " .. tmp.target)
			end
			return
		end

		if t.affs.mental_disruption and t.affs.physical_disruption and t.affs.crippled_body then
			weaponry:q_wield("rapier", "1h", "left")
			weaponry:q_wield("rapier", "1h", "right")
			table.insert(prompt.q, "retribution " .. tmp.target)
			if affs.stupidity then
				weaponry:q_wield("rapier", "1h", "left")
				weaponry:q_wield("rapier", "1h", "right")
				table.insert(prompt.q, "retribution " .. tmp.target)
			end
			table.insert(prompt.q, "wipe left")
			table.insert(prompt.q, "wipe right")
			fs.on("offense", 1)
			return
		end

		if t.traits.tumble then
			if not o.traits.impaling then
				weaponry:q_wield("rapier", "1h", "left")
				weaponry:q_wield("rapier", "1h", "right")
				table.insert(prompt.q, "impale " .. tmp.target)
				if affs.stupidity then
					weaponry:q_wield("rapier", "1h", "left")
					weaponry:q_wield("rapier", "1h", "right")
					table.insert(prompt.q, "impale " .. tmp.target)
				end
				return
			end
		end


		if tonumber(o.vitals.left_charge) >= 150 and tonumber(o.vitals.right_charge) >= 150 then
			weaponry:q_wield("rapier", "1h", "left")
			weaponry:q_wield("rapier", "1h", "right")
			table.insert(prompt.q, "blade release vorpal " .. tmp.target .. " " .. tmp.ks_one)
			table.insert(prompt.q, "dsk " .. tmp.target .. " " .. tmp.ks_two .. " " .. tmp.ks_three)
			if affs.stupidity then
				weaponry:q_wield("rapier", "1h", "left")
				weaponry:q_wield("rapier", "1h", "right")
				table.insert(prompt.q, "dsk " .. tmp.target .. " " .. tmp.ks_two .. " " .. tmp.ks_three)
			end
			table.insert(prompt.q, "wipe left")
			table.insert(prompt.q, "wipe right")
			fs.on("offense", 1)

		else
			weaponry:q_wield("rapier", "1h", "left")
			weaponry:q_wield("rapier", "1h", "right")
			table.insert(prompt.q, "dsk " .. tmp.target .. " " .. tmp.ks_one .. " " .. tmp.ks_two)
			if affs.stupidity then
				weaponry:q_wield("rapier", "1h", "left")
				weaponry:q_wield("rapier", "1h", "right")
				table.insert(prompt.q, "dsk " .. tmp.target .. " " .. tmp.ks_one .. " " .. tmp.ks_two)
			end
			table.insert(prompt.q, "wipe left")
			table.insert(prompt.q, "wipe right")
			fs.on("offense", 1)

		end

	end

	if class == "sentinel" then
		if not sentinel then
			echo("\n")
			e.warn("You have not purchased the offense module for Sentinel! Don't you wish you had?")
			return
		end

		parse_affs()

		if not can:reqbaleq() then return end
		if fs.check("queue") then return end

		if offense.call then
			table.insert(prompt.q, "call animals")
			if affs.stupidity then
				table.insert(prompt.q, "call animals")
			end
		end

		if (t.defs.shielded and t.defs.rebounding) then
			weaponry:q_wield("dhurive", "2h", "left")
			table.insert(prompt.q, "dhuriv dualraze " .. tmp.target)
			if affs.stupidity then
				weaponry:q_wield("dhurive", "2h", "left")
				table.insert(prompt.q, "dhuriv dualraze " .. tmp.target)
			end

			
			return

		end

		if t.affs.confusion and t.affs.right_leg_broken and t.affs.left_leg_broken and not t.defs.shielded then
			weaponry:q_wield("dhurive", "2h", "left")
			table.insert(prompt.q, "dhuriv spinecut " .. tmp.target)
			if affs.stupidity then
				weaponry:q_wield("dhurive", "2h", "left")
				table.insert(prompt.q, "dhuriv spinecut " .. tmp.target)
			end

			
			return

		end

		if offense.crossbow then

			if offense.resin then
				tmp.crossbow_venom = offense.resin
			end

			if not offense.crossbow_loaded then
				table.insert(prompt.q, "crossbow unload")
				table.insert(prompt.q, "crossbow load with normal coat " .. tmp.crossbow_venom)

				if not defs.active.alacrity then
					
					return
				end
			end

			table.insert(prompt.q, "crossbow quickshoot " .. tmp.target)

			
			return
		end

		if offense.dhuriv.initialtmp.ks_one then
			tmp.strike_one = ((t.defs.shielded or t.defs.rebounding) and not (t.defs.shielded and t.defs.rebounding)) and "reave" or offense.dhurivtmp.ks_one

		else
			tmp.strike_one = ((t.defs.shielded or t.defs.rebounding) and not (t.defs.shielded and t.defs.rebounding)) and "reave" or "slash"

		end

		if offense.dhuriv.secondarytmp.ks_two then
			if not offense.dhuriv.initialtmp.ks_one then
				tmp.strike_two = ((t.defs.shielded or t.defs.rebounding) and not (t.defs.shielded and t.defs.rebounding)) and offense.stab_or_slice or offense.dhurivtmp.ks_two

			else
				tmp.strike_two = offense.dhurivtmp.ks_two

			end

		else
			tmp.strike_two = offense.stab_or_slice

		end

		tmp.ks_one = (offense.dhuriv.initialtmp.ks_one and tmp.strike_one ~= "slash") and "" or " " .. tmp.ks_one
		tmp.ks_two = (offense.dhuriv.secondarytmp.ks_two and tmp.strike_two ~= "stab" and tmp.strike_two ~= "slice") and "" or " " .. tmp.ks_two

		weaponry:q_wield("dhurive", "2h", "left")

		if offense.combust then
			table.insert(prompt.q, "tracking combust")
			if affs.stupidity then
				table.insert(prompt.q, "tracking combust")
			end
		end

		if offense.opportunity then
			table.insert(prompt.q, "opportunity")
			if affs.stupidity then
				table.insert(prompt.q, "opportunity")
			end
		end

		if (tmp.strike_one == "weaken" or tmp.strike_one == "slam") then
			if tmp.strike_one == "weaken" then 
				table.insert(prompt.q, "dhuriv weaken " .. tmp.target .. " " .. offense.weaken_side .. " leg")
				if affs.stupidity then
					table.insert(prompt.q, "dhuriv weaken " .. tmp.target .. " " .. offense.weaken_side .. " leg")
				end
			else
				table.insert(prompt.q, "dhuriv slam " .. tmp.target)
				if affs.stupidity then
					table.insert(prompt.q, "dhuriv slam " .. tmp.target)
				end
			end

			table.insert(prompt.q, "dhuriv " .. tmp.strike_two .. " " .. tmp.target .. " " ..  tmp.ks_one)
			if affs.stupidity then
				table.insert(prompt.q, "dhuriv " .. tmp.strike_two .. " " .. tmp.target .. " " ..  tmp.ks_one)
			end

			table.insert(prompt.q, "wipe dhurive")

			
			return
		end
		
		table.insert(prompt.q, "dhuriv combo " .. tmp.target .. " " .. tmp.strike_one .. " " .. tmp.strike_two  .. tmp.ks_one .. tmp.ks_two)
		if affs.stupidity then
			table.insert(prompt.q, "dhuriv combo " .. tmp.target .. " " .. tmp.strike_one .. " " .. tmp.strike_two  .. tmp.ks_one .. tmp.ks_two)
		end

		table.insert(prompt.q, "wipe dhurive")

		

	end

end

-- Don't ever actually use this function, it's stupid.
function t_locked()
	if t.affs.asthma
		and t.affs.slickness
		and (t.affs.anorexia
			or t.affs.indifference)
		and t.affs.paralysis
		and t.affs.impatience
		and t.affs.confusion then
			t.traits.locked = true
			if t.affs.disrupted then
				t.traits.truelocked = true
			end
	end
end

function t_affcount(self, arg)
	local t_affcount = 0
	for i,v in pairs(list.afflictions) do
		if t.affsv then
			t_affcount = t_affcount + 1
		end
	end
	return t_affcount
end

function kelpstack()
	local kstack = false
	track:t_asthma("kelpstack")
		_G.offense.kelpstack = {
			"hypochondria",
			"weariness",
		}
	for i,v in pairs(offense.kelpstack) do
		if not t.affsv then
			kstack = false
			break
		elseif t.affsv then
			kstack = true
		end
	end

	return kstack and true or false
end

function disrupt()
	if not t.affs.confusion then return end

	local disrupt = false
	local count_eat = 0
	local count_focus = 0
	for i,v in pairs(offense.autolock.disrupt_eat) do
		if t.affsv then
			count_eat = count_eat + 1
		end
	end
	for i,v in pairs(offense.autolock.disrupt_focus) do
		if t.affsv then
			count_focus = count_focus + 1
			break
		end
	end

	if count_eat >= offense.countstack 
		and count_focus >= 1 then
		disrupt = true
	end

	if (track:t_has_asthma()
		and t.affs.slickness
		and (t.affs.anorexia
		or t.affs.indifference)
		and t.affs.impatience
		and t.affs.confusion
		and not t.affs.disrupted) then
		return true
	end

	return (disrupt 
		and tmp.disrupt
		and not t.affs.disrupted) 
		and true or false
end

function seal()
	local seal = true
	for i,v in pairs(offense.suggest) do
		if table.contains(list.afflictions, v) then
			seal = false
			break
		end
	end
	return (seal and not t.traits.sealed) and true or false
end

-- Bloodborn offense functions


function envenom()
	killswitch:parse_autolock("venoms")
	track:t_asthma("venoms")

	for i,v in pairs(offense.venoms) do
		if not t.affsv 
			and not (v == "paresis"
			and t.affs.paralysis) then
			tmp.envenom = list.to_venomv
			break
		end
	end

	if o.stats.class == "praenomen" and t.defs.rebounding then
		if t.defs.rebounding then
			for i,v in pairs(offense.prae_r) do
				if not t.affsv then
					tmp.envenom = v
					break
				end
			end
		end
	end

	if o.stats.class == "bloodborn" then anxiety() end
end

function dwhisper()
	if tmp.envenom == "gecko" then
		table.insert(offense.dwhisper, 1, "anorexia")
		table.insert(offense.dwhisper, 1, "indifference")
	else
		for i,v in pairs(offense.dwhisper) do
			if v == "indifference" then
				table.remove(offense.dwhisper, i)
				break
			end
		end
		for i,v in pairs(offense.dwhisper) do
			if v == "anorexia" then
				table.remove(offense.dwhisper, i)
				break
			end
		end
	end

	for i,v in pairs(offense.dwhisper) do
		if (not t.affsv and tmp.envenom ~= list.to_venomv) then
			tmp.whisperone = v:gsub("no_clarity","dementia")
			break
		end
	end

	for i,v in pairs(offense.dwhisper) do
		if (not t.affsv and tmp.envenom ~= list.to_venomv and tmp.whisperone ~= v:gsub("no_clarity","dementia")) then
			tmp.whispertwo = v:gsub("no_clarity","dementia")
			break
		end
	end
end

function mindburrow()
	track:t_mentis()
	tmp.mb_damage = tonumber((t.mentiscount*3) + 8)
	if tmp.mb_damage > 40 then tmp.mb_damage = 40 end

	return (tonumber(t.mana - tmp.mb_damage) < tonumber(tmp.a_threshold - 11)) and true or false

end

function anxiety()
	for i,v in pairs(offense.anxiety) do
		if t.affsv then
			for i,v in pairs(offense.a_venomsv) do
				if not t.affsv then
					tmp.envenom = list.to_venomv
					break
				end
			end
		end
	end
end

-- Luminary offense functions

function overwhelm()
	if not tmp.overwhelm then return false end
	if not tmp.o_threshold then return false end
	local overwhelm = false
	if killswitch:t_affcount() >= tmp.o_threshold then
		overwhelm = true
	end
	for i,v in pairs(offense.overwhelm) do
		if not t.affsv then
			overwhelm = false
		end
	end
	return overwhelm and true or false
end

-- Syssin offense functions

function lightwall()
	if fs.check("lightwall") then return end
	if not o.bals.primary_illusion
		and not o.bals.secondary_illusion then
		return 
	end
	if not t.affs.sunlight_allergy
		and not (tmp.ks_one == "darkshade"
		or tmp.ks_two == "darkshade")
		and not table.contains(weap.venoms, "darkshade") then
		return 
	end

	tmp.lightwall = false
	for k,v,i in ipairs(gmcp.Char.Items.List.items) do
		if v.name == "a lightwall" then 
			tmp.lightwall = true
			break
		end
	end

	if tmp.lightwall then return end

	tmp.room_exit = nil
	for i,v in pairs(list.exits) do
		if gmcp.Room.Info.exitsv then
			tmp.room_exit = v
			break
		end
	end

	if not tmp.room_exit then return end

	send("conjure lightwall " .. tmp.room_exit)
		if affs.stupidity then
			send("conjure lightwall " .. tmp.room_exit)
			send("conjure lightwall " .. tmp.room_exit)
		end

	fs.on("lightwall", 0.5)
end

function enven()
	if fs.check("enven") then return end
	if (meta:count(weap.venoms) >= 5
		or not (o.bals.balance
		or affs.stupidity)) then
		send("wipe dirk")
		send("wipe whip")
		weap.venoms = {}
	end
	if t.defs.shielded
		or t.defs.rebounding
		or ((killswitch:mark()
		and t.defs.fangbarrier)
		and not t.traits.tumble) then
		weaponry:_envenom("whip", tmp.ks_one)
	else
		weaponry:_envenom("dirk", tmp.ks_two)
		weaponry:_envenom("dirk", tmp.ks_one)
	end

	fs.on("enven", 0.3)
	if timers.enven then killTimer(timers.enven) end
	timers.enven = tempTimer(0.3, killswitch:enven())
end

function hypno_reset(self, last)
	t.traits.hypnosis = false
	t.traits.sealed = false
	t.traits.snapped = false
	tmp.reset_hypno = true
end

function mark()
	if tmp.hinder then return false end
	if offense.mark == "none" then return false end
	if not table.contains(offense.allow, "mark") then return false end

	local mark = offense.mark

	if not t.affsmark
		and o.bals.shadow then 
		tmp.mark = offense.to_markmark
		return true
	else
		return false
	end
end

function sleight()
	if mark() then return end
	if t.defs.shielded then return end

	if not offense.pallcount then offense.pallcount = 5 end
	if not offense.sleight then offense.sleight = "dissipate" end
	if fs.check("sleight") then return end
	if not o.bals.shadow then return end
	--if killswitch:mark() then return end
	--if killswitch:seal() and not t.traits.sealed then return end
	if t.defs.shielded then return end

	if not t.traits.snapped
		and not (t.affs.void
		or t.affs.weakvoid)
		and ((table.contains(offense.allow, "void")
		or t.affs.slickness)) then
		send("shadow sleight void " .. tmp.target)

	elseif table.contains(offense.allow, "pall")
		and (killswitch:t_affcount() >= offense.pallcount
		or killswitch:autolock("camus")) then
		send("shadow sleight pall " .. tmp.target)

	else
		send("shadow sleight " .. offense.sleight .. " " .. tmp.target)
	end

	fs.on("sleight", 0.5)
end