module(..., package.seeall)

-------------------------------------------------------

--! @file
--! @brief Affliction and curing script module for Oasis Curing System for Aetolia.

--! @copyright Copyright 2014 Alec DuBois, all rights reserved.

--! http://oasis.interimreality.com/

--! Commented in standardized format Doxygen::Lua.

-------------------------------------------------------

--! todo: finish populating 'block' fields for afflictions in different lib that block one another
--! todo: have 'last' get loaded with afflictions in the last 20 seconds
--! todo: lockbreaking and cure skills
--! todo: add conditions to cure slickness with bloodroot
--! todo: make sure it doesn't eat kelp for asthma when fitness is already firing, and vice versa
--! todo: add toggles for curing types and specific afflictions
--! todo: add handles for sip, pre-restoration and fitness settings
--! todo: setup lockbreaking cascades

current = {}		--! storage for current afflictions
last = {}			--! storage for afflictions from the last twenty seconds
check = {}			--! storage for curing methods to check
attempted = {}		--! storage for afflictions being attempted by curing functions
lastcures = {}		--! used to track attempted cures in triggers
disallow = {}		--! used to toggle individual afflictions

local af = {}		--! special conditions for curing afflictions out of order
local sw = {}		--! special conditions for curing afflictions with multiple cures 

diag = false		--! toggle for diagnosing

--! todo: key this into settings module
sets = {
	force = {
		herb = "none",
		pipe = "none",
		salve = "none",
	},
	preres = {
		head = 16,
		torso = 16,
		left_arm = 16,
		right_arm = 16,
		left_leg = 16,
		right_leg = 16
	},
	siphealth = 85,
	sipmana = 85,
	forcehealth = 50,
	forcemana = 50,
	hmoss = 75,
	mmoss = 75,
	bfloor = 100,
	mfloor = .10,
	hp_fever = 70,
	mp_fever = 70,
	hp_plague = 70,
	mp_plague = 70,
	heal = 60,
	cure_loki = 4,
	diag = 5,
	cure_count = 6,
	hid_thresh = 5,
	lock_thresh = 3,
	fitness = {
		force = false,
		count = 5,
		focus = false,
		atkr_bal = false,
		slickness_timer = 10
	}
}

--! storage for counts
count = {
	--! limb damage
	limbs = {
		head = 0,
		torso = 0,
		left_arm = 0,
		right_arm = 0,
		left_leg = 0,
		right_leg = 0
	},

	hidden = 0			--! used to keep count of hidden afflictions
}

local cr = {}	--! storage for local affliction handling functions

--! curing priority lists
prio = {
	cures = {
		"rage",
		"pipe",
		"salve",
		"herb",
		"focus",
		"tree",
		"purge",
		"renew"
	},

	herb = {
		"crippled",
		"crippled_body",
		"paralysis",
		"infested",
		"blighted",
		"slickness",
		"asthma",
		"limp_veins",
		"weariness",
		"blindness",
		"hypochondria",
		"magic_impaired",
		"clumsiness",
		"baldness",
		"lethargy",
		"thin_blood",
		"blood_fever",
		"blood_plague",
		"paresis",
		"heartflutter",
		"impatience",
		"sandrot",
		"mirroring",
		"confusion",
		"blood_poison",
		"blood_curse",
		"stormtouched",
		"mental_disruption",
		"physical_disruption",
		"deafness",
		"sensitivity",
		"recklessness",
		"sadness",
		"pacifism",
		"epilepsy",
		"sunlight_allergy",
		"haemophilia",
		"peace",
		"loneliness",
		"berserking",
		"hallucinations",
		"stupidity",
		"shyness",
		"self_pity",
		"justice",
		"masochism",
		"lovers_effect",
		"vomiting",
		"rend",
		"body_odor",
		"commitment_fear",
		"hubris",
		"waterbreathing",
		"dissonance",
		"claustrophobia",
		"agoraphobia",
		"dizziness",
		"paranoia",
		"superstition",
		"hatred",
		"addiction",
		"vertigo",
		"dementia",
		"generosity",
		"hypersomnia"
	},

	salve = {
		"burnt_skin",
		"destroyed_throat",
		"indifference",
		"anorexia",
		"crushed_chest",

		"left_leg_amputated",
		"left_leg_mangled",
		"left_leg_damaged",
		"left_leg_bruised_critical",
		"left_leg_bruised_moderate",
		"left_leg_bruised",
		"left_leg_broken",
		"left_leg_dislocated",

		"right_leg_amputated",
		"right_leg_mangled",
		"right_leg_damaged",
		"right_leg_bruised_critical",
		"right_leg_bruised_moderate",
		"right_leg_bruised",
		"right_leg_broken",
		"right_leg_dislocated",

		"left_arm_amputated",
		"left_arm_mangled",
		"left_arm_damaged",
		"left_arm_bruised_critical",
		"left_arm_bruised_moderate",
		"left_arm_broken",
		"left_arm_bruised",
		"left_arm_dislocated",

		"right_arm_amputated",
		"right_arm_mangled",
		"right_arm_damaged",
		"right_arm_bruised_critical",
		"right_arm_bruised_moderate",
		"right_arm_broken",
		"right_arm_bruised",
		"right_arm_dislocated",

		"head_bruised_critical",
		"head_mangled",
		"head_damaged",
		"head_bruised",
		"head_bruised_moderate",

		"torso_mangled",
		"torso_damaged",
		"torso_bruised_critical",
		"torso_bruised_moderate",
		"torso_bruised",
		"spinal_rip",

		"mauled_face",
		"frozen",
		"crushed_kneecaps",
		"cracked_ribs",
		"shivering",

		"ablaze",
		"blurry_vision",
		"crushed_elbows",
		"gorged",
		"effused_biles",
		"effused_yellowbile",
		"effused_phlegm",
		"effused_blood",
		"smashed_throat",

		"left_arm_preres",
		"right_arm_preres",
		"left_leg_preres",
		"right_leg_preres",
		"head_preres",
		"torso_preres",

		"density",
		"insulation",
		"burnt_eyes",
		"crippled_throat",
		"stuttering",
		"selarnia",
		"void"
	},

	pipe = {
		"check_slickness", --! meta-affliction
		"aeon",
		"slickness",
		"hellsight",
		"disfigurement",
		"withering",
		"deadening",
		"rebounding"
	},

	renew = {
		"ablaze",
		"addiction",
		"agoraphobia",
		"anorexia",
		"asthma",
		"baldness",
		"belonephobia",
		"berserking",
		"blighted",
		"blood_curse",
		"blood_poison",
		"blurry_vision",
		"body_odor",
		"claustrophobia",
		"clumsiness",
		"commitment_fear",
		"confusion",
		"cracked_ribs",
		"crushed_elbows",
		"crushed_kneecaps",
		"crippled",
		"crippled_body",
		"crippled_throat",
		"dementia",
		"dissonance",
		"dizziness",
		"epilepsy",
		"frozen",
		"generosity",
		"gorged",
		"haemophilia",
		"hallucinations",
		"hatred",
		"heartflutter",
		"hidden_anxiety",
		"hubris",
		"hypersomnia",
		"hypochondria",
		"impatience",
		"indifference",
		"infested",
		"justice",
		"left_arm_broken",
		"left_arm_dislocated",
		"left_leg_broken",
		"left_leg_dislocated",
		"lethargy",
		"limp_veins",
		"loki",
		"loneliness",
		"lovers_effect",
		"magic_impaired",
		"masochism",
		"mental_disruption",
		"mirroring",
		"pacifism",
		"paralysis",
		"paranoia",
		"paresis",
		"peace",
		"physical_disruption",
		"recklessness",
		"rend",
		"right_arm_broken",
		"right_arm_dislocated",
		"right_leg_broken",
		"right_leg_dislocated",
		"sadness",
		"sandrot",
		"selarnia",
		"self_pity",
		"sensitivity",
		"shivering",
		"shyness",
		"slickness",
		"stupidity",
		"stuttering",
		"sunlight_allergy",
		"superstition",
		"thin_blood",
		"vertigo",
		"vomiting",
		"weariness",

		--! meta-affliction
		"hidden"
	},

	tree = {
		"ablaze",
		"addiction",
		"agoraphobia",
		"anorexia",
		"asthma",
		"baldness",
		"belonephobia",
		"berserking",
		"blighted",
		"blood_curse",
		"blood_poison",
		"blurry_vision",
		"body_odor",
		"claustrophobia",
		"clumsiness",
		"commitment_fear",
		"confusion",
		"cracked_ribs",
		"crushed_elbows",
		"crushed_kneecaps",
		"crippled",
		"crippled_body",
		"crippled_throat",
		"dementia",
		"dissonance",
		"dizziness",
		"epilepsy",
		"frozen",
		"generosity",
		"gorged",
		"haemophilia",
		"hallucinations",
		"hatred",
		"heartflutter",
		"hidden_anxiety",
		"hubris",
		"hypersomnia",
		"hypochondria",
		"impatience",
		"indifference",
		"infested",
		"justice",
		"left_arm_broken",
		"left_arm_dislocated",
		"left_leg_broken",
		"left_leg_dislocated",
		"lethargy",
		"limp_veins",
		"loki",
		"loneliness",
		"lovers_effect",
		"magic_impaired",
		"masochism",
		"mental_disruption",
		"mirroring",
		"pacifism",
		"paralysis",
		"paranoia",
		"paresis",
		"peace",
		"physical_disruption",
		"recklessness",
		"rend",
		"right_arm_broken",
		"right_arm_dislocated",
		"right_leg_broken",
		"right_leg_dislocated",
		"sadness",
		"sandrot",
		"selarnia",
		"self_pity",
		"sensitivity",
		"shivering",
		"shyness",
		"slickness",
		"stupidity",
		"stuttering",
		"sunlight_allergy",
		"superstition",
		"thin_blood",
		"vertigo",
		"vomiting",
		"weariness",

		--! meta-affliction
		"hidden"
	},

	focus = {
		--! todo: check_focus, muddled, shell_fetish
		"stupidity",
		"anorexia",
		"epilepsy",
		"mirroring",
		"mental_disruption",
		"paranoia",
		"hallucinations",
		"shyness",
		"dizziness",
		"indifference",
		"berserking",
		"lovers_effect",
		"pacifism",
		"hatred",
		"generosity",
		"vertigo",
		"loneliness",
		"agoraphobia",
		"masochism",
		"recklessness",
		"weariness",
		"confusion",
		"dementia",
		"premonition"
	},

	rage = {
		"hubris",
		"pacifism",
		"peace",
		"lovers_effect",
		"superstition",
		"generosity",
		"justice"
	},

	purge = {
		"asthma",
		"blood_curse",
		"blood_poison",
		"clumsiness",
		"crippled_throat",
		"disfigurement",
		"haemophilia",
		"left_arm_broken",
		"left_leg_broken",
		"lethargy",
		"limp_veins",
		"magic_impaired",
		"paralysis",
		"paresis",
		"right_arm_broken",
		"right_leg_broken",
		"sandrot",
		"sensitivity",
		"throatclaw",
		"vomiting"
	},

	fitness = {
		"herb",
		"salve",
		"pipe"
	},

	locks = {
		blocked = {
			herb = {
				"anorexia",
				"indifference"
			},
			salve = {
				"slickness",
				"burnt_skin"
			}
		}
	}
}

lib = {
	to_cure = {
		antispasmadic = "valerian",
		bladder_slice = "ash",
		castorite_slice = "bellwort",
		demulcent = "elm",
		eyeball_slice = "kelp",
		fumeae = "caloric",
		jecis = "restoration",
		kidney = "moss",
		liver_slice = "goldenseal",
		lung_slice = "bloodroot",
		oculi = "epidermal",
		orbis = "mending",
		ovary_slice = "ginseng",
		pueri = "mass",
		sudorific = "skullcap",
		testis_slice = "lobelia"
	},

	--! cured by ash or bladder_slice
	sadness = { living = "ash", undead = "bladder_slice", cured = { herb = true, tree = true, renew = true } },
	confusion = { living = "ash", undead = "bladder_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	dementia = { living = "ash", undead = "bladder_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	hallucinations = { living = "ash", undead = "bladder_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	paranoia = { living = "ash", undead = "bladder_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	hypersomnia = { living = "ash", undead = "bladder_slice", cured = { herb = true, tree = true, renew = true } },
	hatred = { living = "ash", undead = "bladder_slice", cured = { herb = true, tree = true, renew = true } },
	blood_curse = { living = "ash", undead = "bladder_slice", cured = { herb = true, tree = true, renew = true } },
	blighted = { living = "ash", undead = "bladder_slice", cured = { herb = true, tree = true, renew = true }, block = { "premonition" } },

	--! cured by goldenseal or liver_slice
	self_pity = { living = "goldenseal", undead = "liver_slice", cured = { herb = true, tree = true, renew = true } },
	stupidity = { living = "goldenseal", undead = "liver_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	dizziness = { living = "goldenseal", undead = "liver_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	shyness = { living = "goldenseal", undead = "liver_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	epilepsy = { living = "goldenseal", undead = "liver_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	impatience = { living = "goldenseal", undead = "liver_slice", cured = { herb = true, tree = true, renew = true } },
	dissonance = { living = "goldenseal", undead = "liver_slice", cured = { herb = true, tree = true, renew = true } },
	infested = { living = "goldenseal", undead = "liver_slice", cured = { herb = true, tree = true, renew = true }, block = { "premonition" } },

	--! cured by kelp or eyeball_slice
	baldness = { living = "kelp", undead = "eyeball_slice", cured = { herb = true, tree = true, renew = true } },
	clumsiness = { living = "kelp", undead = "eyeball_slice", cured = { herb = true, tree = true, renew = true } },
	magic_impaired = { living = "kelp", undead = "eyeball_slice", cured = { herb = true, tree = true, renew = true } },
	hypochondria = { living = "kelp", undead = "eyeball_slice", cured = { herb = true, tree = true, renew = true } },
	weariness = { living = "kelp", undead = "eyeball_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	limp_veins = { living = "kelp", undead = "eyeball_slice", cured = { herb = true, tree = true, renew = true } },
	sensitivity = { living = "kelp", undead = "eyeball_slice", cured = { herb = true, tree = true, renew = true } },
	blood_poison = { living = "kelp", undead = "eyeball_slice", cured = { herb = true, tree = true, renew = true } },
	asthma = { living = "kelp", undead = "eyeball_slice", cured = { herb = true, tree = true, renew = true } },

	--! cured by lobelia or testis_slice
	commitment_fear = { living = "lobelia", undead = "testis_slice", cured = { herb = true, tree = true, renew = true } },
	recklessness = { living = "lobelia", undead = "testis_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	masochism = { living = "lobelia", undead = "testis_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	agoraphobia = { living = "lobelia", undead = "testis_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	loneliness = { living = "lobelia", undead = "testis_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	berserking = { living = "lobelia", undead = "testis_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	vertigo = { living = "lobelia", undead = "testis_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	claustrophobia = { living = "lobelia", undead = "testis_slice", cured = { focus = true, herb = true, tree = true, renew = true } },

	--! cured by ginseng or ovary_slice
	body_odor = { living = "ginseng", undead = "ovary_slice", cured = { herb = true, tree = true, renew = true } },
	haemophilia = { living = "ginseng", undead = "ovary_slice", cured = { herb = true, tree = true, renew = true } },
	mental_disruption = { living = "ginseng", undead = "ovary_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	physical_disruption = { living = "ginseng", undead = "ovary_slice", cured = { herb = true, tree = true, renew = true } },
	sunlight_allergy = { living = "ginseng", undead = "ovary_slice", cured = { herb = true, tree = true, renew = true } },
	vomiting = { living = "ginseng", undead = "ovary_slice", cured = { herb = true, tree = true, renew = true } },
	thin_blood = { living = "ginseng", undead = "ovary_slice", cured = { herb = true, tree = true, renew = true } },
	rend = { living = "ginseng", undead = "ovary_slice", cured = { herb = true, tree = true, renew = true } },
	lethargy = { living = "ginseng", undead = "ovary_slice", cured = { herb = true, tree = true, renew = true } },
	addiction = { living = "ginseng", undead = "ovary_slice", cured = { herb = true, tree = true, renew = true } },

	--! cured by bellwort or castorite_slice
	hubris = { living = "bellwort", undead = "castorite_slice", cured = { herb = true, tree = true, renew = true } },
	pacifism = { living = "bellwort", undead = "castorite_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	peace = { living = "bellwort", undead = "castorite_slice", cured = { herb = true, tree = true, renew = true } },
	lovers_effect = { living = "bellwort", undead = "castorite_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	superstition = { living = "bellwort", undead = "castorite_slice", cured = { herb = true, tree = true, renew = true } },
	generosity = { living = "bellwort", undead = "castorite_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	justice = { living = "bellwort", undead = "castorite_slice", cured = { herb = true, tree = true, renew = true } },

	--! cured by bloodroot or lung_slice
	paresis = { living = "bloodroot", undead = "lung_slice", cured = { herb = true, tree = true, renew = true } },
	paralysis = { living = "bloodroot", undead = "lung_slice", cured = { herb = true, tree = true, renew = true } },
	mirroring = { living = "bloodroot", undead = "lung_slice", cured = { focus = true, herb = true, tree = true, renew = true } },
	crippled_body = { living = "bloodroot", undead = "lung_slice", cured = { herb = true, tree = true, renew = true }, also = { "crippled" } },
	crippled = { living = "bloodroot", undead = "lung_slice", cured = { herb = true, tree = true, renew = true } },
	heartflutter = { living = "bloodroot", undead = "lung_slice", cured = { herb = true, tree = true, renew = true }, also = { "crippled_body" } },
	sandrot = { living = "bloodroot", undead = "lung_slice", cured = { herb = true, tree = true, renew = true } },

	--! cured by ginger or appendix_slice
	blood_fever = { living = "ginger", undead = "appendix_slice", cured = { herb = true } },
	blood_plague = { living = "ginger", undead = "appendix_slice", cured = { herb = true } },

	--! cured by moss or kidney_slice
	plodding = { living = "moss", undead = "kidney_slice", cured = { moss = true } },
	idiocy = { living = "moss", undead = "kidney_slice", cured = { moss = true } },

	--! cured by elm or demulcent
	aeon = { living = "elm", undead = "demulcent", cured = { pipe = true, tree = true, renew = true } },
	withering = { living = "elm", undead = "demulcent", cured = { pipe = true, tree = true, renew = true } },
	hellsight = { living = "elm", undead = "demulcent", cured = { pipe = true, tree = true, renew = true } },
	deadening = { living = "elm", undead = "demulcent", cured = { pipe = true, tree = true, renew = true } },

	--! cured by valerian or antispasmadic
	check_slickness = { living = "valerian", undead = "antispasmadic", cured = { pipe = true, tree = true, renew = true } },
	slickness = { living = "valerian", undead = "antispasmadic", cured = { pipe = true, tree = true, renew = true } },
	check_slickness = { living = "valerian", undead = "antispasmadic", cured = { pipe = true, tree = true, renew = true } },
	disfigurement = {living = "valerian", undead = "antispasmadic", cured = { pipe = true, tree = true, renew = true } },

	--! cured by epidermal or oculi
	anorexia = { living = "epidermal", undead = "oculi", target = "torso", cured = { focus = true, salve = true, tree = true, renew = true } },
 	gorged = { living = "epidermal", undead = "oculi", target = "torso", cured = { salve = true, tree = true, renew = true } },
	effused_blood = { living = "epidermal", undead = "oculi", target = "torso", cured = { salve = true, tree = true, renew = true } },
	effused_phlegm = { living = "epidermal", undead = "oculi", target = "torso", cured = { salve = true, tree = true, renew = true } },
	effused_yellowbile = { living = "epidermal", undead = "oculi", target = "torso", cured = { salve = true, tree = true, renew = true } },
	effused_biles = { living = "epidermal", undead = "oculi", target = "torso", cured = { salve = true, tree = true, renew = true } },
	indifference = { living = "epidermal", undead = "oculi", target = "head", cured = { focus = true, salve = true, tree = true, renew = true } },
	stuttering = { living = "epidermal", undead = "oculi", target = "head", cured = { focus = true, salve = true, tree = true, renew = true } },
	blurry_vision = { living = "epidermal", undead = "oculi", target = "head", cured = { salve = true, tree = true, renew = true } },
	burnt_eyes = { living = "epidermal", undead = "oculi", target = "head", cured = { salve = true, tree = true, renew = true } },

	--! cured by mending or orbis
	crushed_elbows = { living = "mending", undead = "orbis", target = "arms", cured = { salve = true } },
	crushed_kneecaps = { living = "mending", undead = "orbis", target = "legs", cured = { salve = true } },
	selarnia = { living = "mending", undead = "orbis", target = "torso", cured = { salve = true, tree = true, renew = true } },
	ablaze = { living = "mending", undead = "orbis", target = "torso", cured = { salve = true, tree = true, renew = true }, block = { "torso_damaged", "torso_mangled" } },
	cracked_ribs = { living = "mending", undead = "orbis", target = "torso", cured = { salve = true } },
	throatclaw = { living = "mending", undead = "orbis", target = "head", cured = { salve = true, tree = true, renew = true } },
	crippled_throat = { living = "mending", undead = "orbis", target = "head", cured = { salve = true, tree = true, renew = true } },
	destroyed_throat = { living = "mending", undead = "orbis", target = "head", cured = { salve = true, tree = true, renew = true } },

	right_arm_bruised_critical = { living = "mending", undead = "orbis", target = "right arm", cured = { salve = true, tree = true, renew = true } },
	right_arm_broken = { living = "mending", undead = "orbis", target = "right arm", cured = { salve = true, tree = true, renew = true }, block = { "kai_cripple", "right_arm_damaged", "right_arm_mangled", "right_arm_amputated" }, also = { "right_arm_dislocated" }  },
	right_arm_bruised_moderate = { living = "mending", undead = "orbis", target = "right arm", cured = { salve = true, tree = true, renew = true }, block = { "right_arm_damaged", "right_arm_mangled", "right_arm_amputated" }  },
	right_arm_bruised = { living = "mending", undead = "orbis", target = "right arm", cured = { salve = true, tree = true, renew = true }, block = { "right_arm_damaged", "right_arm_mangled", "right_arm_amputated" }  },
	right_arm_dislocated = { living = "mending", undead = "orbis", target = "right arm", cured = { salve = true }, block = { "right_arm_damaged", "right_arm_mangled", "right_arm_amputated" }  },
	
	left_arm_bruised_critical = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "left arm" },
	left_arm_broken = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "left arm", block = { "kai_cripple", "left_arm_damaged", "left_arm_mangled", "left_arm_amputated" }, also = { "left_arm_dislocated" } },
	left_arm_bruised_moderate = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "left arm", block = { "left_arm_damaged", "left_arm_mangled", "left_arm_amputated" } },
	left_arm_bruised = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "left arm", block = { "left_arm_damaged", "left_arm_mangled", "left_arm_amputated" } },
	left_arm_dislocated = { living = "mending", undead = "orbis", cured = { salve = true }, target = "left arm", block = { "left_arm_damaged", "left_arm_mangled", "left_arm_amputated" } },

	right_leg_bruised_critical = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "right leg" },
	right_leg_broken = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "right leg", block = { "kai_cripple", "right_leg_damaged", "right_leg_mangled", "right_leg_amputated" }, also = { "right_leg_dislocated" } },
	right_leg_bruised_moderate = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "right leg", block = { "right_leg_damaged", "right_leg_mangled", "right_leg_amputated" } },
	right_leg_bruised = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "right leg", block = { "right_leg_damaged", "right_leg_mangled", "right_leg_amputated" } },
	right_leg_dislocated = { living = "mending", undead = "orbis", cured = { salve = true }, target = "right leg", block = { "right_leg_damaged", "right_leg_mangled", "right_leg_amputated" } },

	left_leg_bruised_critical = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "left leg" },
	left_leg_broken = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "left leg", block = { "kai_cripple", "left_leg_damaged", "left_leg_mangled", "left_leg_amputated" }, also = { "left_leg_dislocated" } },
	left_leg_bruised_moderate = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "left leg", block = { "left_leg_damaged", "left_leg_mangled", "left_leg_amputated" } },
	left_leg_bruised = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "left leg", block = { "left_leg_damaged", "left_leg_mangled", "left_leg_amputated" } },
	left_leg_dislocated = { living = "mending", undead = "orbis", cured = { salve = true }, target = "left leg", block = { "left_leg_damaged", "left_leg_mangled", "left_leg_amputated" } },

	torso_bruised_critical = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "torso" },
	torso_bruised = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "torso", block = { "torso_damaged", "torso_mangled" } },
	torso_bruised_moderate = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "torso", block = { "torso_damaged", "torso_mangled" } },

	head_bruised_critical = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "head" },
	head_bruised = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "head", block = { "head_damaged", "head_mangled" } },
	head_bruised_moderate = { living = "mending", undead = "orbis", cured = { salve = true, tree = true, renew = true }, target = "head", block = { "head_damaged", "head_mangled" } },

	--! cured by caloric or fumeae
	frozen = { living = "caloric", undead = "fumeae", cured = { salve = true, tree = true, renew = true }, target = "torso" },
	shivering = { living = "caloric", undead = "fumeae", cured = { salve = true, tree = true, renew = true }, target = "torso", stack = "frozen" },

	--! cured by restoration or jecis
	crushed_chest = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "torso", block = { "cracked_ribs" } },
	spinal_rip = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "torso" },
	collapsed_lung = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "torso" },
	burnt_skin = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "torso" },
	smashed_throat = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "head" },
	mauled_face = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "head" },

	left_leg_damaged = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "left leg", also = { "left_leg_preres" } },
	left_leg_mangled = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "left leg", also = { "left_leg_preres" } },
	left_leg_amputated = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "left leg", also = { "left_leg_preres" } },
	left_leg_preres = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "left leg", also = { "left_leg_damaged", "left_leg_mangled", "left_leg_amputated" } },

	left_arm_damaged = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "left arm", also = { "left_arm_preres" } },
	left_arm_mangled = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "left arm", also = { "left_arm_preres" } },
	left_arm_amputated = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "left arm", also = { "left_arm_preres" } },
	left_arm_preres = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "left arm", also = { "left_arm_damaged", "left_arm_mangled", "left_arm_amputated" } },

	right_leg_damaged = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "right leg", also = { "right_leg_preres" } },
	right_leg_mangled = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "right leg", also = { "right_leg_preres" } },
	right_leg_amputated = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "right leg", also = { "right_leg_preres" } },
	right_leg_preres = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "right leg", also = { "right_leg_damaged", "right_leg_mangled", "right_leg_amputated" } },

	right_arm_damaged = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "right arm", also = { "right_arm_preres" } },
	right_arm_mangled = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "right arm", also = { "right_arm_preres" } },
	right_arm_amputated = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "right arm", also = { "right_arm_preres" } },
	right_arm_preres = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "right arm", also = { "right_arm_damaged", "right_arm_mangled", "right_arm_amputated" } },

	torso_damaged = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "torso", also = { "torso_preres" } },
	torso_mangled = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "torso", also = { "torso_preres" } },
	torso_preres = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "torso", also = { "torso_damaged", "torso_mangled" } },

	head_damaged = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "head", also = { "head_preres" } },
	head_mangled = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "head", also = { "head_preres" } },
	head_preres = { living = "restoration", undead = "jecis", cured = { salve = true }, target = "head", also = { "head_damaged", "head_mangled" } },

	--! defenses
	blindness = { def = true, living = "bayberry", undead = "stomach_slice", cured = { herb = true } },
	deafness = { def = true, living = "hawthorn", undead = "heart_slice", cured = { herb = true }, block = { "ruptured_eardrum" } },
	density = { def = true, living = "mass", undead = "pueri", target = "torso", cured = { salve = true } },
	insulation = { def = true, living = "caloric", undead = "fumeae", cured = { salve = true }, target = "torso" },
	rebounding = { def = true, living = "skullcap", undead = "sudorific", cured = { pipe = true } },
	waterbreathing = { def = true, living = "pricklypear", undead = "pancreas_slice", cured = { herb = true } },

	--! healing 
	health = { living = "health", undead = "analeptic" },
	mana = { living = "mana", undead = "stimulant" },
	c_moss = { living = "moss", undead = "kidney_slice" },
	reck_sip = { living = "health", undead = "analeptic" },

	--! special cures
	voyria = { living = "immunity", undead = "calmative" },
	fear = { living = "compose", undead = "compose" },
	asleep = { living = "wake", undead = "wake" },
	disrupted = { living = "concentrate", undead = "concentrate" },
	void = { living = "mass", undead = "pueri", target = "torso" },
	writhe = { living = "writhe", undead = "writhe" },

	ash = {
		"sadness",
		"confusion",
		"dementia",
		"hallucinations",
		"paranoia",
		"hypersomnia",
		"hatred",
		"blood_curse",
		"blighted"
	},

	bellwort = {
		"hubris",
		"pacifism",
		"peace",
		"lovers_effect",
		"superstition",
		"generosity",
		"justice"
	},

	bloodroot = {
		"paresis",
		"paralysis",
		"mirroring",
		"crippled_body",
		"crippled",
		"slickness",
		"heartflutter",
		"sandrot"
	},

	caloric = {
		skin = {
			"insulation",
			"frozen",
			"shivering",
			"no_insulation"
		},

		torso = {
			"insulation",
			"frozen",
			"shivering",
			"no_insulation"
		}
	},

	elm = {
		"aeon",
		"withering",
		"hellsight",
		"deadening"
	},

	epidermal = {
		skin = {
			"anorexia",
			"gorged",
			"indifference",
			"stuttering",
			"blurry_vision",
			"burnt_eyes"
		},

		head = {
			"indifference",
			"stuttering",
			"blurry_vision",
			"burnt_eyes"
		},

		torso = {
			"anorexia",
			"belonephobia",
			"gorged"
		}
	},

	goldenseal = {
		"self_pity",
		"stupidity",
		"dizziness",
		"shyness",
		"epilepsy",
		"impatience",
		"dissonance",
		"infested"
	},

	ginger = {
		"blood_fever",
		"blood_plague"
	},

	ginseng = {
		"body_odor",
		"haemophilia",
		"mental_disruption",
		"physical_disruption",
		"sunlight_allergy",
		"vomiting",
		"thin_blood",
		"rend",
		"lethargy",
		"addiction"
	},

	kelp = {
		"baldness",
		"clumsiness",
		"magic_impaired",
		"hypochondria",
		"weariness",
		"limp_veins",
		"asthma",
		"sensitivity",
		"blood_poison"
	},

	lobelia = {
		"commitment_fear",
		"recklessness",
		"masochism",
		"agoraphobia",
		"loneliness",
		"berserking",
		"vertigo",
		"claustrophobia"
	},

	mending = {

		skin = {
			"right_leg_broken",
			"left_leg_broken",
			"right_arm_broken",
			"left_arm_broken",
			"crushed_elbows",
			"crushed_kneecaps",
			"selarnia",
			"ablaze",
			"cracked_ribs",
			"crippled_throat",
			"destroyed_throat"
		},

		head = {
			"head_bruised_critical",
			"head_bruised_moderate",
			"head_bruised",
			"destroyed_throat",
			"crippled_throat",
			"throatclaw"
		},

		torso = {
			"torso_bruised_critical",
			"torso_bruised_moderate",
			"torso_bruised",
			"selarnia",
			"ablaze",
			"cracked_ribs"
		},


		right_leg = {
			"right_leg_bruised_critical",
			"right_leg_broken",
			"right_leg_bruised_moderate",
			"right_leg_bruised",
			"right_leg_dislocated"
		},

		left_leg = {
			"left_leg_bruised_critical",
			"left_leg_broken",
			"left_leg_bruised_moderate",
			"left_leg_bruised",
			"left_leg_dislocated"
		},

		right_arm = {
			"right_arm_bruised_critical",
			"right_arm_broken",
			"right_arm_bruised_moderate",
			"right_arm_bruised",
			"right_arm_dislocated"
		},

		left_arm = {
			"left_arm_bruised_critical",
			"left_arm_broken",
			"left_arm_bruised_moderate",
			"left_arm_bruised",
			"left_arm_dislocated"
		}
	},

	moss = {
		"plodding",
		"idiocy"
	},

	restoration = {
		skin = {},

		head = {
			"head_preres",
			"head_mangled",
			"head_damaged"
		},

		torso = {
			"torso_preres",
			"torso_mangled",
			"torso_damaged"
		},

		left_arm = {
			"left_arm_preres",
			"left_arm_amputated",
			"left_arm_mangled",
			"left_arm_damaged"
		},

		right_arm = {
			"right_arm_preres",
			"right_arm_amputated",
			"right_arm_mangled",
			"right_arm_damaged"
		},

		left_leg = {
			"left_leg_preres",
			"left_leg_amputated",
			"left_leg_mangled",
			"left_leg_damaged"
		},

		right_leg = {
			"right_leg_preres",
			"right_leg_amputated",
			"right_leg_mangled",
			"right_leg_damaged"
		},
	},

	valerian = {
		"slickness",
		"disfigurement"
	},

	focus = {
		--! todo: check_focus, muddled, shell_fetish
		"stupidity",
		"anorexia",
		"epilepsy",
		"mental_disruption",
		"mirroring",
		"paranoia",
		"hallucinations",
		"shyness",
		"dizziness",
		"indifference",
		"berserking",
		"lovers_effect",
		"pacifism",
		"hatred",
		"generosity",
		"vertigo",
		"loneliness",
		"agoraphobia",
		"masochism",
		"recklessness",
		"weariness",
		"confusion",
		"dementia",
		"premonition"
	},

	rage = {
		"hubris",
		"pacifism",
		"peace",
		"lovers_effect",
		"superstition",
		"generosity",
		"justice"
	},

	purge = {
		"paresis",
		"paralysis",
		"right_arm_broken",
		"left_arm_broken",
		"right_leg_broken",
		"left_leg_broken",
		"haemophilia",
		"asthma",
		"limp_veins",
		"clumsiness",
		"magic_impaired",
		"vomiting",
		"sensitivity",
		"lethargy",
		"blood_poison",
		"blood_curse",
		"throatclaw",
		"crippled_throat",
		"sandrot",
		"disfigurement"
	},

	tree = {
		"ablaze",
		"addiction",
		"agoraphobia",
		"anorexia",
		"asthma",
		"baldness",
		"belonephobia",
		"berserking",
		"blighted",
		"blood_curse",
		"blood_poison",
		"blurry_vision",
		"body_odor",
		"claustrophobia",
		"clumsiness",
		"commitment_fear",
		"confusion",
		"cracked_ribs",
		"crushed_elbows",
		"crushed_kneecaps",
		"crippled",
		"crippled_body",
		"crippled_throat",
		"dementia",
		"dissonance",
		"dizziness",
		"epilepsy",
		"frozen",
		"generosity",
		"gorged",
		"haemophilia",
		"hallucinations",
		"hatred",
		"heartflutter",
		"hidden_anxiety",
		"hubris",
		"hypersomnia",
		"hypochondria",
		"impatience",
		"indifference",
		"infested",
		"justice",
		"left_arm_broken",
		"left_arm_dislocated",
		"left_leg_broken",
		"left_leg_dislocated",
		"lethargy",
		"limp_veins",
		"loki",
		"loneliness",
		"lovers_effect",
		"magic_impaired",
		"masochism",
		"mental_disruption",
		"mirroring",
		"pacifism",
		"paralysis",
		"paranoia",
		"paresis",
		"peace",
		"physical_disruption",
		"recklessness",
		"rend",
		"right_arm_broken",
		"right_arm_dislocated",
		"right_leg_broken",
		"right_leg_dislocated",
		"sadness",
		"sandrot",
		"selarnia",
		"self_pity",
		"sensitivity",
		"shivering",
		"shyness",
		"slickness",
		"stupidity",
		"stuttering",
		"sunlight_allergy",
		"superstition",
		"thin_blood",
		"vertigo",
		"vomiting",
		"weariness",

		--! meta-affliction
		"hidden"
	}
}

function add(aff, inf, diag)
	local tally = { "hidden" }
	if table.contains(tally, aff) then count[aff] = count[aff] + 1 end
	if current[aff] and not diag then return end

	local timed  = {
		paresis = true,
		slickness = true
	}

	if timed[aff] then
		stopwatch[aff] = nil
		stopwatch[aff] = createStopWatch()
		startStopWatch(stopwatch[aff])
	end 

	fs.release()
	current[aff] = true

	if diag then
		e.aff(aff, false, true, false, true)
	elseif inf then
		e.aff(aff, false, false, true, false)
	end
end

function rem(aff, inf)
	local tally = { "hidden" }
	if table.contains(tally, aff) then
		count[aff] = count[aff] - 1
		if count[aff] > 0 then
			return
		else
			count[aff] = 0
		end
	end

	if not current[aff] then return end

	local timed  = {
		paresis = true,
		slickness = true
	}

	if timed[aff] then stopwatch[aff] = nil end 

	fs.release()
	current[aff] = nil

	if inf then
		e.aff(aff, true, false, true, false)
	end
end

function dam(l, num, inf)
	fs.release()

	if inf then
		e.limb(l, false, num, false, true, false)
	end

	l = l:gsub(" ", "_")

	count.limbs[l] = tonumber(count.limbs[l] + num)

	if count.limbs[l] >= sets.preres[l] then
		affs.add(l .. "_preres", true, false)
	else
		affs.rem(l .. "_preres", true)
	end
end

function res(l, num, inf)
	fs.release()

	if inf then
		e.limb(l, true, num, false, true, false)
	end

	l = l:gsub(" ", "_")

	count.limbs[l] = tonumber(count.limbs[l] - num)

	if count.limbs[l] >= sets.preres[l] then
		affs.add(l .. "_preres", true, false)
	else
		affs.rem(l .. "_preres", true)
	end
end

function setdam(l, num, inf)
	fs.release()
	
	if inf then
		e.limb(l, false, num, true, true, false)
	end

	l = l:gsub(" ", "_")

	count.limbs[l] = tonumber(num)

	if count.limbs[l] >= sets.preres[l] then
		affs.add(l .. "_preres", true, false)
	else
		affs.rem(l .. "_preres", true)
	end
end

function clear(tree, tar)
	if not lib[tree] then return end

	if tar then
		if not lib[tree][tar] then return end
		for _, aff in ipairs(lib[tree][tar]) do
			if current[aff] then affs.rem(aff, true) end
		end
	else
		if tree == "tree" or tree == "renew" then affs.count.hidden = 0 end
		for _, aff in ipairs(lib[tree]) do
			if current[aff] and not blocked(aff) then affs.rem(aff, true) end
		end
	end
end

function clear_lastcures()
	for k, v in pairs(affs.lastcures) do
		if v.name then
			clear(v.name, v.target)
		else
			clear(v)
		end
	end
	affs.lastcures = {}
end

function checks(all)
	if fs.checks then return end
	if all then
		check.dash = true
		check.fly = true
		check.eat = true
		check.meditate = true
		check.pipe = true
		check.recklessness = true
	end

	if not o.traits.prone then affs.rem("paralysis", true) end

	if check.recklessness and (o.vitals.hp == o.vitals.maxhp and o.vitals.mp == o.vitals.maxmp) and not current.blackout then 
		affs.add("recklessness")
		check.recklessness = false
	elseif check.recklessness and (o.vitals.hp < o.vitals.maxhp) or (o.vitals.mp < o.vitals.maxmp) then
		affs.rem("recklessness", true)
		check.recklessness = false
	end

	if check.pipe then affs.add("check_slickness", true) else affs.rem("check_slickness", true) end

	if not can.act() then return end

	if check.eat and not fs.check_eat then
		send("eat foot")
		fs.on("check_eat")
	end

	if check.paresis and not fs.check_paresis and not o.bals.tree then
		send("touch tree")
		fs.on("check_paresis")
	end

	if check.fly and not fs.check_fly and (not o.bals.balance or not o.bals.equilibrium) then
		send("fly")
		fs.on("check_fly")
	end

	if check.meditate then
		table.insert(prompt.q, "meditate")
		table.insert(prompt.q, "stand")
	end

	if check.dash and not fs.check_dash and (not o.bals.balance or not o.bals.equilibrium) and not defs.active.density then
		if not (_gmcp.has_skill("dash", "racial") or _gmcp.has_skill("dash", "shapeshifting") or _gmcp.has_skill("dash", "subterfuge") or _gmcp.has_skill("dash", "tekura")) then
			check.dash = nil
			return
		end
		send("dash up")
		fs.on("check_dash")
	end
	fs.on("checks", 0.5)
end

function cure_all(prio)

	for _, cure in ipairs(prio) do
		local bal = "to_" .. cure
		local used = cure .. "_used"
		if stopwatch[cure] and timers[used] then
			timers[bal] = timers[used] - getStopWatchTime(stopwatch[cure])
		else
			timers[bal] = 0
		end
	end

	if (timers.to_renew and not o.bals.renew) and (timers.to_sync and not o.bals.sync) then
		timers.to_renew = timers.to_renew > timers.to_sync and timers.to_renew or timers.to_sync
	elseif timers.to_renew and not o.bals.renew then
		timers.to_renew = timers.to_renew
	elseif timers.to_sync and not o.bals.sync then
		timers.to_renew = timers.to_sync
	else
		timers.to_renew = 0
	end

	cure_special()

	--! todo: table manip for priorities here

	attempted = {}

	for _, cure in ipairs(prio) do
		--[[for k, v in pairs(attempted) do
			if not current[k] then attempted[k] = nil end
		end]]

		local e = "cure_" .. cure
		local list = affs.prio[cure]
		affs[e](list)
	end

	cure_special()

	clot()
	do_sip()
end

function cure_special()
	local sip = o.stats.status == "living" and "sip " or "stick "

	if can.wake() and not fs.wake and current.asleep and can_attempt("asleep") then
		send("wake")
		if current.stupidity then 
			send("wake")
			fs.on("wake", 0.5)
		end
		attempt("wake", "asleep")
	end

	if can.compose() and not fs.compose and current.fear and can_attempt("fear") then
		send("compose")
		if current.stupidity then
			send("compose")
			fs.on("compose", 0.5)
		end
		attempt("compose", "fear")
	end

	if can.concentrate() and not fs.concentrate and (current.disrupted or (current.blackout and not o.bals.equilibrium)) and can_attempt("disrupted") then
		send("concentrate")
		if current.stupidity then
			send("concentrate")
			fs.on("concentrate", 1)
		end
		attempt("concentrate", "disrupted")
	end

	if not can.act() then return end

	local writhes = {
		"writhe_impaled",
		"writhe_transfix",
		"writhe_armpitlock",
		"writhe_web",
		"writhe_bind",
		"writhe_vines",
		"writhe_thighlock",
		"mob_impaled",
		"writhe_ropes",
		"grappled",
	}

	for _, aff in ipairs(writhes) do
		if current[aff] and can.writhe() and not fs.writhe then
			send("writhe")
			can.nobal("balance", true)
			can.nobal("equilibrium", true)
			fs.on("writhe", 0.5)
			break
		end
	end

	if not can.reqbaleq() then return end

	if current.wheel then
		table.insert(prompt.q, 1, "rip card")
		if current.stupidity then table.insert(prompt.q, 1, "rip card") end
		can.nobal("balance", true)
		can.nobal("equilibrium", true)
	end
end

function cure_herb(prio)
	if fs.herb then return end
	if not can.herb() then return end
	local force = sets.force.herb[1]

	clear_attempted("herb")

	if (current[force] or ((lib[force] and lib[force].def) and not defs.active[force] and defs.preserve[force])) and can_attempt(force, "herb") and not blocked(force) then
		local aff = force
		local cure = lib[aff][o.stats.status]
		local outc = can.outcache() and o.config_sep .. "outc " .. cure or " "
		if current.stupidity or current.bulimia then
			cure = cure .. o.config_sep .. "eat " .. cure
		end

		local def = af.insomnia()
		local def = def .. af.instawake()

		send("queue herb eat".. def .. cure .. outc)
		attempt("herb", aff)
		fs.on("herb", 0.4)
		return
	end

	for _, aff in ipairs(prio) do
		if (current[aff]
			or ((lib[aff]
				and lib[aff].def)
				and not defs.active[aff]
				and defs.preserve[aff]))
			and (af[aff]
				and af[aff]())
			and can_attempt(aff, "herb")
			and not (stacked(aff)
			or blocked(aff)) 
			and ((sw[aff]
				and sw[aff]())
			or not sw[aff]) then

			local cure = lib[aff][o.stats.status]
			local outc = can.outcache() and o.config_sep .. "outc " .. cure or " "
			if current.stupidity or current.bulimia then
				cure = "outc " .. cure .. o.config_sep .. "eat " .. cure
			end

			local def = af.insomnia()
			local def = def .. af.instawake()

			send("queue herb eat" .. def .. cure .. outc)
			attempt("herb", aff)
			fs.on("herb", 0.4)
			return
		end
	end

	for _, aff in ipairs(prio) do
		if (current[aff]
			or (lib[aff]
				and lib[aff].def
				and not defs.active[aff]
				and defs.preserve[aff]))
			and can_attempt(aff, "herb")
			and not (stacked(aff)
			or blocked(aff))
			and ((sw[aff]
				and sw[aff]())
			or not sw[aff]) then

			local cure = lib[aff][o.stats.status]
			local outc = can.outcache() and o.config_sep .. "outc " .. cure or " "
			if current.stupidity or current.bulimia then
				cure = "outc " .. cure .. o.config_sep .. "eat " .. cure
			end

			local def = af.insomnia()
			local def = def .. af.instawake()

			send("queue herb eat" .. def .. cure .. outc)
			attempt("herb", aff)
			fs.on("herb", 0.4)
			return
		end
	end

	send("queue herb", false)
	fs.on("herb", 30)
end

function cure_pipe(prio)
	if fs.pipe then return end
	if not can.pipe() then return end
	local force = sets.force.pipe[1]

	clear_attempted("pipe")

	if (current[force] or ((lib[force] and lib[force].def) and not defs.active[force] and defs.preserve[force])) and can_attempt(force, "pipe") and not blocked(force) then
		local aff = force
		local cure = lib[aff][o.stats.status]

		if o.stats.status == "living" then
			send("queue pipe light pipes" .. o.config_sep .. "smoke " .. cure)
		else
			send("queue pipe flick syringes" .. o.config_sep .. "inject " .. cure)
		end

		attempt("pipe", aff)
		fs.on("pipe", 0.3)
		return
	end

	for _, aff in ipairs(prio) do
		local _fs = aff:gsub("no_", "")
		if (current[aff]
			or (lib[aff]
				and lib[aff].def 
				and not defs.active[aff]
				and defs.preserve[aff]))
			and (af[aff]
				and af[aff]())
			and can_attempt(aff, "pipe")
			and not (stacked(aff)
			or blocked(aff)
			or fs[_fs])
			and ((sw[aff]
				and not sw[aff]())
			or not sw[aff]) then

			local cure = lib[aff][o.stats.status]
			local act = (o.stats.status == "living") and "smoke " or "inject "

			send("queue pipe light pipes" .. o.config_sep .. act .. cure)

			attempt("pipe", aff)
			fs.on("pipe", 0.3)
			return
		end
	end

	for _, aff in ipairs(prio) do
		local _fs = aff:gsub("no_", "")
		if (current[aff]
			or (lib[aff]
				and lib[aff].def 
				and not defs.active[aff]
				and defs.preserve[aff]))
			and can_attempt(aff, "pipe")
			and not (stacked(aff)
			or blocked(aff)
			or fs[_fs])
			and ((sw[aff]
				and not sw[aff]())
			or not sw[aff]) then

			local cure = lib[aff][o.stats.status]

			if o.stats.status == "living" then
				send("queue pipe light pipes" .. o.config_sep .. "smoke " .. cure)
			else
				send("queue pipe flick syringes" .. o.config_sep .. "inject " .. cure)
			end

			attempt("pipe", aff)
			fs.on("pipe", 0.3)
			return
		end
	end

	send("queue pipe", false)
	fs.on("pipe", 30)
end

function cure_salve(prio)
	if fs.salve then return end
	if not can.salve() then return end
	local force = sets.force.salve

	clear_attempted("salve")

	if (current[force] or ((lib[force] and lib[force].def) and not defs.active[force] and defs.preserve[force])) and can_attempt(force, "salve") and not blocked(force) then
		local cure = lib[aff][o.stats.status]
		local act = "apply "
		if o.stats.status == "undead" then
			act = "press "
		end
		local tar = lib[aff].target

		if not tar then e.error("No \'target\' entry defined for \'" .. aff .. ".\'", true, false) end

		if cure == "jecis" or cure == "restoration" then
			tmp.restoring = aff
		else
			tmp.restoring = nil
		end

		send("queue salve " .. act .. cure .. " to " .. tar)
		attempt("salve", aff)
		fs.on("salve", 0.5)
		return
	end

	for _, aff in ipairs(prio) do
		local cure = lib[aff][o.stats.status]
		local act = "apply "
		if o.stats.status == "undead" then act = "press " end
		local tar = lib[aff].target

		if not tar then e.error("No \'target\' entry defined for \'" .. aff .. ".\'", true, false) end

		if (current[aff]
			or (lib[aff]
				and lib[aff].def 
				and not defs.active[aff]
				and defs.preserve[aff]))
			and (af[aff]
				and af[aff]())
			and can_attempt(aff, "salve")
			and not ((restoring
				and restoring[aff])
			or stacked(aff, tar)
			or blocked(aff)) then

			if cure == "jecis" or cure == "restoration" then
				tmp.restoring = aff
			else
				tmp.restoring = nil
			end

			send("queue salve " .. act .. cure .. " to " .. tar)
			attempt("salve", aff)
			fs.on("salve", 0.5)
			return
		end
	end

	for _, aff in ipairs(prio) do
		local cure = lib[aff][o.stats.status]
		local act = "apply "
		if o.stats.status == "undead" then
			act = "press "
		end
		local tar = lib[aff].target

		if not tar then e.error("No \'target\' entry defined for \'" .. aff .. ".\'") end

		if (current[aff] 
			or (lib[aff]
				and lib[aff].def
				and not defs.active[aff]
				and defs.preserve[aff]))
			and can_attempt(aff, "salve")
			and not ((restoring
				and restoring[aff])
			or stacked(aff, tar)
			or blocked(aff)) then

			if cure == "jecis" or cure == "restoration" then
				tmp.restoring = aff
			else
				tmp.restoring = nil
			end

			send("queue salve " .. act .. cure .. " to " .. tar)
			attempt("salve", aff)
			fs.on("salve", 0.5)
			return
		end
	end

	send("queue salve", false)
	fs.on("salve", 30)
end

function cure_focus(prio)
	if not can.focus() then return end
	if not can.mana(250, 0) then return end
	if fs.focus then return end

	clear_attempted("focus")

	for _, aff in ipairs(prio) do
		if current[aff]
			and can_attempt(aff, "focus")
			and not blocked(aff) then

			send("queue focus focus")
			attempt("focus", aff)
			fs.on("focus", 1)
			break

		--elseif current.shell_fetish or current.check_focus then

			--send("focus")
			--fs.on("focus", 0.5)
			--break
		end
	end

	send("queue focus", false)
	fs.on("focus", 30)
end

function cure_tree(prio)
	if not can.tree() then return end
	if fs.tree then return end

	clear_attempted("tree")

	for _, aff in ipairs(prio) do
		if current[aff]
			and can_attempt(aff, "tree")
			and not blocked(aff) then

			send("queue tree touch tree")
			attempt("tree", aff)
			fs.on("tree", 1)
			break
		end
	end

	send("queue tree", false)
	fs.on("tree", 30)
end

function cure_renew(prio)
	if not can.renew() then return end
	if not can.mana(500, 5) then return end

	clear_attempted("renew")

	local act = "renew"
	if o.stats.race == "azudim" then
		act = "reconstitute"
	elseif o.stats.race == "idreth" then
		act = "erase"
	end

	for _, aff in ipairs(prio) do
		if current[aff]
			and can_attempt(aff, "renew")
			and not blocked(aff) then
			table.insert(prompt.q, act)
			attempt("renew", aff)
			break

		elseif current.loki then
			table.insert(prompt.q, act)
			break
		end
	end
end

function cure_rage(prio)
	if not can.rage() then return end
	if fs.rage then return end

	clear_attempted("rage")

	for _, aff in ipairs(prio) do
		if current[aff]
			and can_attempt(aff, "rage")
			and not (stacked(aff)
			or blocked(aff)) then

			send("rage")
			attempt("rage", aff)
			fs.on("rage", 0.5)
			break
		end
	end
end

function cure_purge(prio)
	if fs.deathlore_purge then return end
	if not can.purge() then return end
	if not can.mana(150, 5) then return end

	clear_attempted("purge")

	for _, aff in ipairs(prio) do
		if current[aff]
			and can_attempt(aff, "purge")
			and not blocked(aff) then
			send("soul purge")
			attempt("purge", aff)
			fs.on("deathlore_purge", 1)
			break
		end
	end
end

function cure_fitness()
	if not can.fitness() then return end
	if not (current.asthma or current.limp_veins) then return end
	local _focus = table.shallowcopy(prio.focus)
	local count = sets.fitness.count
	local focus = sets.fitness.focus
	local atkr_bal = sets.fitness.atkr_bal

	local blocked = {
		herb = false,
		salve = false,
	}

	for k, v in pairs(blocked) do
		for _, aff in ipairs(prio.locks.blocked[k]) do
			if current[aff] then
				blocked[k] = aff
				break
			end
		end
	end

	local kelp = {
		"baldness",
		"clumsiness",
		"magic_impaired",
		"hypochondria",
		"weariness"
	}

	local weariness
	for i, v in ipairs(_focus) do
		if v == "weariness" then
			break
		elseif current[v] then
			weariness = true
			break
		end
	end

	for i, v in ipairs(kelp) do
		if current[v] and ((v == "weariness" and weariness) or v ~= "weariness") then
			count = count - 1
		end
	end

	local block_herb = {
		anorexia = true,
		indifference = true
	}

	local focus_check = true
	if focus then
		if current.impatience then
			focus_check = true
		else
			for _, aff in ipairs(_focus) do
				if block_herb[aff] and not (affs.current.anorexia and affs.current.indifference) then
					focus_check = nil
					break
				else
					focus_check = true
					break
				end
			end
		end
	end

	local atkr_bal_check = true

	if (count <= 0 and atkr_bal_check) or (stopwatch.slickness and blocked.salve and getStopWatchTime(stopwatch.slickness) > sets.fitness.slickness_timer) or (blocked.herb and blocked.salve and focus_check) then
		fs.release()
		table.insert(prompt.q, "fitness")
		can.nobal("fitness", true)
		can.nobal("balance", true)
		can.nobal("equilibrium", true)
		return true
	end
end

function cure_shrug(prio, count)
	if not can.shrug() then return end
	if not can.fitness() then return end
	if fs.fitness then return end
	if not (current.asthma or current.limp_veins) then return end
	local _focus = affs.prio.focus

	local blocked = {
		herb = false,
		salve = false,
		pipe = false
	}

	for k, v in pairs(blocked) do
		for _, aff in ipairs(affs.prio.locks.blocked[v]) do
			if current[aff] then
				blocked[v] = aff
				break
			end
		end
	end

	local kelp = {
		"baldness",
		"clumsiness",
		"magic_impaired",
		"hypochondria",
		"weariness"
	}

	local weariness
	for i, v in ipairs(_focus) do
		if v == "weariness" then
			break
		elseif current[v] then
			weariness = true
			break
		end
	end

	for i, v in ipairs(kelp) do
		if current[v] and ((v == "weariness" and weariness) or v ~= "weariness") then
			count = count - 1
		end
	end

	local focus_check = true
	if focus then
		if current.impatience then
			focus_check = true
		else
			for _, aff in ipairs(_focus) do
				if aff == blocked.herb then
					focus_check = nil
					break
				else
					focus_check = true
					break
				end
			end
		end
	end

	local aff = o.stats.class == "living" and "asthma" or "limpveins"

	if count <= 0 or (stopwatch.slickness and blocked.salve and stopwatch.slickness > sets.slickness_timer) or (blocked.herb and blocked.salve and focus_check) then
		table.insert(prompt.q, "shrug " .. aff)
		can.nobal("shrug", true)
		can.nobal("balance", true)
		return true
	end
end

function cure_scour()
	if not can.fitness() then return end
	if not (current.asthma or current.limp_veins) then return end
	local _focus = table.shallowcopy(prio.focus)
	local count = sets.fitness.count
	local focus = sets.fitness.focus
	local atkr_bal = sets.fitness.atkr_bal

	local blocked = {
		herb = false,
		salve = false,
	}

	for k, v in pairs(blocked) do
		for _, aff in ipairs(prio.locks.blocked[k]) do
			if current[aff] then
				blocked[k] = aff
				break
			end
		end
	end

	local kelp = {
		"baldness",
		"clumsiness",
		"magic_impaired",
		"hypochondria",
		"weariness"
	}

	local weariness
	for i, v in ipairs(_focus) do
		if v == "weariness" then
			break
		elseif current[v] then
			weariness = true
			break
		end
	end

	for i, v in ipairs(kelp) do
		if current[v] and ((v == "weariness" and weariness) or v ~= "weariness") then
			count = count - 1
		end
	end

	local block_herb = {
		anorexia = true,
		indifference = true
	}

	local focus_check = true
	if focus then
		if current.impatience then
			focus_check = true
		else
			for _, aff in ipairs(_focus) do
				if block_herb[aff] and not (affs.current.anorexia and affs.current.indifference) then
					focus_check = nil
					break
				else
					focus_check = true
					break
				end
			end
		end
	end

	local atkr_bal_check = true

	if (count <= 0 and atkr_bal_check) or (stopwatch.slickness and blocked.salve and getStopWatchTime(stopwatch.slickness) > sets.fitness.slickness_timer) or (blocked.herb and blocked.salve and focus_check) then
		fs.release()
		table.insert(prompt.q, "fitness")
		can.nobal("fitness", true)
		can.nobal("balance", true)
		can.nobal("equilibrium", true)
		return true
	end
end

function cure_active(prio, count)
	--! todo: account for balances required for active cure here
	if not can.active() then return end
	if fs.active then return end

	local active = true
	for _, aff in ipairs(prio) do
		if not current[aff] then
			active = false
			break
		end
	end

	if count and count > 0 then
		for _, aff in ipairs(prio) do
			if current[aff] then
				count = count - 1
				if count == 0 then
					active = true
					break
				end
			end
		end
	end

	--! todo: active cure action and balance consumed table here

	if active then
		table.insert(prompt.q, act)
		for _, bal in ipairs(bals) do
			can.nobal(bal, true)
		end
	end
end

function clear_attempted(cure)
	for k, v in pairs(attempted) do
		if v == cure then
			attempted[k] = nil
		end
	end
end

function can_attempt(aff, cure)
	local parse = prio.cures
	local exceptions = { hidden = true }
	if exceptions[aff] and count[aff] > 1 then return true end

	local already_attempted = {}
	for k, v in pairs(attempted) do
		already_attempted[v] = true
	end

	if cure then
		local curebal = "to_" .. cure
		for _, c in ipairs(parse) do
			local tobal = "to_" .. c

			if c ~= cure
				and can[c]()
				and timers[tobal] <= timers[curebal]
				and (lib[aff]
					and lib[aff].cured
					and lib[aff].cured[c])
				and not already_attempted[c] then
				return false
			elseif c == cure then
				return true
			else
				return not attempted[aff]
			end

			--[[if can[v]()
				and (timers[tobal]
					and timers[curebal])
				and timers[tobal] <= timers[curebal]
				and (lib[aff]
					and lib[aff].cured
					and lib[aff].cured[v]
					and not already_attempted[v]) then
				return false
			elseif v == cure
				and can[v]()
				and ((timers[tobal]
						and timers[curebal])
					and timers[curebal] <= timers[tobal])
					or not (timers[tobal] or timers[curebal]) then
				return not attempted[aff]
			else
				return true
			end]]

		end
	else
		return not attempted[aff]
	end
end

function attempt(cure, aff)
	if not attempted then
		e.error("Global variable affs.attempted nil or false.", true, true)
		return
	end

	attempted[aff] = cure

	if not lib[aff] then return end
	local also = lib[aff].also
	if also then
		for _, aff in ipairs(also) do
			attempted[aff] = cure
		end
	end
end

function stacked(aff, tar)
	if not aff then return false end
	if not lib[aff] then return false end

	local cure = lib[aff][o.stats.status]
	local undeadcure = lib.to_cure[cure]
	local list = lib[cure] or lib[undeadcure]

	if list and tar then
		list = list[tar]
	end

	if not list then return false end
	if type(list) ~= "table" then return false end

	local stack = false
	for i, v in ipairs(list) do
		if v == aff then
			break
		elseif current[v] then
			stack = true
			break
		end
	end

	return stack and true or false
end

function blocked(aff)
	if not aff then return false end
	if not lib[aff] then return false end
	if not lib[aff].block then return false end

	for i, v in ipairs(lib[aff].block) do
		if (current[v] or o.traits[v]) then return true end
	end

	return false
end

function clot()
	if not can.clot() then return end
	if fs.clot then return end
	if o.vitals.bleeding < sets.bfloor then return end
	if current.recklessness then return end
	local mfloor = sets.mfloor

	local manadiff = math.floor(o.vitals.mp-(o.vitals.maxmp*(mfloor+0.15)))
	if manadiff < 0 then manadiff = 0 end

	local clotnum = math.floor((o.vitals.bleeding-sets.bfloor)/20)
	local clotcost = math.floor(clotnum*80)
	local clotshort = math.floor(manadiff/80)
	if clotcost > manadiff then clotnum = clotshort end

	if clotnum == 0 then return end

	if o.vitals.bleeding >= sets.bfloor then
		send("clot " .. clotnum)
		fs.on("clot", 0.5)
	end
end

function do_sip()
	if not gmcp.Char or not gmcp.Char.Vitals then return end

	local hpcent = tonumber((o.vitals.hp/o.vitals.maxhp)*100)
	local mpcent = tonumber((o.vitals.mp/o.vitals.maxmp)*100)

	local stat = o.stats.status
	
	--! Exception allowed for vitality
	local h_vitality = ((hpcent < 100) and ((defs.preserve.vitality and not defs.active.vitality) and defs.lib.vitality.skill_cache))
	local m_vitality = ((mpcent < 100) and ((defs.preserve.vitality and not defs.active.vitality) and defs.lib.vitality.skill_cache))

	if hpcent < 100 or mpcent < 100 then affs.rem("recklessness", true) end

	if can.elixir() and not fs.elixir then
		if affs.current.blood_fever then
			if not sw.blood_fever() then
				send("queue health apply " .. lib.mana[stat])
				return
			end
		elseif affs.current.blood_plague then
			if not sw.blood_plague() then
				send("queue health apply " .. lib.health[stat])
				return
			end
		end

		local act = o.stats.status == "living" and "queue health sip " or "queue health stick "

		if hpcent <= sets.forcehealth or h_vitality then
			send(act .. lib.health[stat])
			if current.stupidity then
				send(act .. lib.health[stat])
			end
			can.nobal("elixir", true)
			fs.on("elixir", 0.5)
		elseif mpcent <= sets.forcemana or m_vitality then
			send(act .. lib.mana[stat])
			if current.stupidity then
				send(act .. lib.mana[stat])
			end
			can.nobal("elixir", true)
			fs.on("elixir", 0.5)
		elseif hpcent <= sets.siphealth then
			send(act .. lib.health[stat])
			if current.stupidity then
				send(act .. lib.health[stat])
			end
			can.nobal("elixir", true)
			fs.on("elixir", 0.5)
		elseif mpcent <= sets.sipmana then
			send(act .. lib.mana[stat])
			if current.stupidity then
				send(act .. lib.mana[stat])
			end
			can.nobal("elixir", true)
			fs.on("elixir", 0.5)
		elseif current.recklessness or current.blackout then
			send(act .. lib.reck_sip[stat])
			if current.stupidity then
				send(act .. lib.reck_sip[stat])
			end
			can.nobal("elixir", true)
			fs.on("elixir", 0.5)
		else
			send("queue health", false)
			fs.on("elixir", 30)
		end
	end

	if can.moss()
		and not fs.moss
		and (hpcent <= sets.hmoss
		or mpcent <= sets.mmoss
		or current.recklessness
		or current.plodding
		or current.idiocy
		or current.blackout) then
		local moss = lib.c_moss[stat]
		local outc = ""
		if can.outcache() then outc = o.config_sep .. "outc " .. moss end
		send("queue moss eat " .. moss .. outc)
		fs.on("moss", 0.5)
	elseif not fs.moss and can.moss() then
		send("queue moss", false)
		fs.on("moss", 30)
	end
end

function resources()
	--! todo: special handling for crystal tattoo, wand tattoo, health restoration skills and mana restoration skills

	if can.core() then
		table.insert(prompt.q, "shatter core")

		can.nobal("equilibrium", true)
	end

	if can.crystal()
		and hpcent <= sets.crystal then
		table.insert(prompt.q, "touch crystal")

		can.nobal("equilibrium", true)
	end

	if can.wand()
		and mpcent <= sets.wand then
		table.insert(prompt.q, "touch wand")

		can.nobal("equilibrium", true)
	end

	if can.restore_health()
		and hpcent <= sets.restore_health then
		table.insert(prompt.q, lib.restore_health.action)

		can.nobal(lib.restore_health.bal, true)
	end

	if can.restore_mana()
		and mpcent <= sets.restore_mana then
		table.insert(prompt.q, lib.restore_mana.action)

		can.nobal(lib.restore_mana.bal, true)
	end
end

function diagnose()
	if not can.diag() then return end

	if current.loki and current.loki > sets.diag then diag = true end

	if diag then
		table.insert(prompt.q, "diag")
		can.nobal("equilibrium", true)
	end
end

function af.insomnia()
	--! todo: 'insomnia' signifies some setting to use insomnia. Build that later.
	if defs.preserve.insomnia
		and not defs.active.insomnia
		and not insomnia then
		if o.stats.status == "undead" then
			if current.stupidity then
				return " tongue_slice" .. o.config_sep .. "outc tongue_slice" .. o.config_sep .. "eat tongue_slice" .. o.config_sep .. "outc tongue_slice" .. o.config_sep .. "eat "
			else
				return " tongue_slice" .. o.config_sep .. "outc tongue_slice" .. o.config_sep .. "eat "
			end
		else
			if current.stupidity then
				return " cohosh" .. o.config_sep .. "outc cohosh" .. o.config_sep .. "eat cohosh" .. o.config_sep .. "outc cohosh" .. o.config_sep .. "eat "
			else
				return " cohosh" .. o.config_sep .. "outc cohosh" .. o.config_sep .. "eat "
			end
		end
	else
		return " "
	end
end

function af.instawake()
	if defs.preserve.instawake
		and not defs.active.instawake then
		if o.stats.status == "undead" then
			if current.stupidity then
				return " sulphurite_slice" .. o.config_sep .. "outc sulphurite_slice" .. o.config_sep .. "eat sulphurite_slice" .. o.config_sep .. "outc sulphurite_slice" .. o.config_sep .. "eat "
			else
				return " sulphurite_slice" .. o.config_sep .. "outc sulphurite_slice" .. o.config_sep .. "eat "
			end
		else
			if current.stupidity then
				return " kola" .. o.config_sep .. "outc kola" .. o.config_sep .. "eat kola" .. o.config_sep .. "outc kola" .. o.config_sep .. "eat "
			else
				return " kola" .. o.config_sep .. "outc kola" .. o.config_sep .. "eat "
			end
		end
	else
		return " "
	end
end

function af.asthma()
	return (current.slickness
			or current.burnt_skin)
end

function af.paresis()
	local sw_tree = stopwatch.tree and getStopWatchTime(stopwatch.tree) or nil
	local sw_ps = stopwatch.paresis and getStopWatchTime(stopwatch.paresis) or nil
	local sw_hb = stopwatch.herb and getStopWatchTime(stopwatch.herb) or nil

	local treebal = _gmcp.has_skill("recovery", "survival") and 10 or 15
	local time_to_treebal = sw_tree and treebal - sw_tree or 0

	local para_delay = defs.active.reckless and 8 or 4
	local time_to_para = sw_ps and para_delay - sw_ps or 0

	local time_to_herb_bal = sw_hb and 2 + (2 - sw_hb) or 0

	return (o.bals.tree or (time_to_treebal and (time_to_treebal < time_to_herb_bal)))
		or (time_to_para and (time_to_para < time_to_herb_bal))
end

function af.clumsiness()
	return (current.slickness
			or current.burnt_skin)
end

function af.limp_veins()
	return af.asthma()
end

function af.magic_impaired()
	return af.clumsiness()
end

function sw.blood_fever()
	local hpcent = tonumber((o.vitals.hp/o.vitals.maxhp)*100)
	local mpcent = tonumber((o.vitals.mp/o.vitals.maxmp)*100)	

	return hpcent <= sets.hp_fever or mpcent <= sets.mp_fever
end

function sw.blood_plague()
	local hpcent = tonumber((o.vitals.hp/o.vitals.maxhp)*100)
	local mpcent = tonumber((o.vitals.mp/o.vitals.maxmp)*100)	

	return hpcent <= sets.hp_plague or mpcent <= sets.mp_plague
end

function sw.slickness()
	local kelp = {
		"clumsiness",
		"magic_impaired",
		"hypochondria",
		"weariness"
	}

	local count = 0
	for _, aff in ipairs(kelp) do
		if affs.current[aff] then count = count + 1 end
	end

	return (affs.current.asthma or affs.current.limp_veins) and count >= 1
end