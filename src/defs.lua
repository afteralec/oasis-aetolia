module(..., package.seeall)

-------------------------------------------------------

--! @file
--! @brief Defense script module for Oasis Curing System for Aetolia.

--! @copyright Copyright 2014 Alec DuBois, all rights reserved.

--! http://oasis.interimreality.com/

--! Commented in standardized format Doxygen::Lua.

-------------------------------------------------------

--! todo: populate Carnifex and Infernal defenses
--! todo: double-check all defense tables to make sure they're complete
--! todo: double-check all 'requires' entries to make sure they're accurate

--! todo: populate the defense sets
--! todo: consider interaction between defs and killswitch during combat
--! todo: conservation mode and mana handling on defenses

--! To add a defense to the database:
--! Create an entry for it in the library
--! Add it to the appropriate priority
--! Add it to the appropriate defense sets

active = {}		--! storage for active defenses
preserve = {}	--! storange for defenses to preserve
loaded = {}		--! lists in order of last preserved defenses
trait = {}		--! storage for defense-like traits
conserve = {}	--! storage for defenses to drop if resources become a danger

--! defines limb to parry
parry = {
	limb = "torso",

	manual = true,
	random = false,

	timer = false,
	on_sync = false,

	allowed = {
		"head",
		"torso",
		"left leg",
		"right leg",
		"left arm",
		"right arm"
	}
}

--! defines dodging and diversion
dodge = {
	current = "melee",
	last = "melee",
	default = "melee"
}

local ac = {}	--! special conditions for defense actions
local cn = {}	--! special conditions for defense consuming balances
local kd = {}	--! special conditions for defenses that require other defenses
local nd = {}	--! special conditions for rotating defenses
local wd = {}	--! special conditions for wielding

--! defense priority list
prio = {
	
	--! defense priority list loaded into prompt.q
	q = {

		--! free defenses
		"mindseye",
		"parrying",
		"dodging",
		"endgame",
		"metawake",
		"soulharvest",
		"avoidance_fortify",
		"nimbleness",
		"momentum",
		"vigilance",
		"boosting",
		"shine",
		"entwine",
		"kai_trance",
		"conservation",
		"consciousness",
		"furor",
		"stalwart",
		"kaido_regeneration",
		"boost_kaido_regeneration",
		"toughness",
		"resistance",
		"weathering",
		"projectiles",
		"mist_blue",
		"mist_red",
		"mist_green",
		"mist_yellow",
		"skywatch",
		"treewatch",
		"eagleeye",
		"gripping",
		"numerology_constitution",
		"shroud",

		--! critical priority
		"spheres",
		"channel_air",
		"channel_earth",
		"channel_fire",
		"channel_shadow",
		"channel_spirit",
		"channel_water",
		"berserk",
		"reflection",
		"blackwind",
		"lightform",
		"phased",
		"shielded",
		"wisp_sacrifice",
		"bloodmeld",
		"shiftsoul",
		"fitness",
		"vitality",
		"sanguispect",
		"lifebloom",
		"link",
		"cloak",
		"standfirm",
		"fixed",
		"rebirth",
		"soul_substitute",
		"soulcage",
		"clarity",
		"alacrity",
		"disperse",
		"immunity",
		"splitting",
		"wisp_form",
		"trill",
		"mindsurge",
		"tonguelash",
		"stilltongue",
		"slicktongue",
		"soulthirst",
		"reckless",

		--! high priority
		"reveling",
		"soul_fortify",
		"soul_fracture",
		"boneshaking",
		"echoing",
		"snarling",
		"attuning",	
		"earthenform",
		"adder",
		"devilpact",
		"eclipse",
		"bladefury",
		"shamanism_spiritsight",
		"greenfoot",
		"oath_blade",
		"oath_durdalis",
		"oath_forestwalker",
		"oath_primeval",
		"oath_rhythm",
		"oath_shaman",
		"oath_tranquility",
		"blue_major",
		"gold_major",
		"green_major",
		"purple_major",
		"red_major",
		"yellow_major",
		"blue_minor",
		"gold_minor",
		"green_minor",
		"purple_minor",
		"red_minor",
		"yellow_minor",
		"accuracy_aura",
		"accuracy_blessing",
		"cleansing_aura",
		"cleansing_blessing",
		"healing_aura",
		"healing_blessing",
		"justice_aura",
		"justice_blessing",
		"meditation_aura",
		"meditation_blessing",
		"pestilence_aura",
		"pestilence_blessing",
		"protection_aura",
		"protection_blessing",
		"purity_aura",
		"purity_blessing",
		"redemption_aura",
		"redemption_blessing",
		"spellbane_aura",
		"spellbane_blessing",
		"recognition",
		"hierophant",
		"hardening",
		"boilingblood",
		"discharge",
		"constitution",
		"waterward",
		"galeward",
		"bracing",
		"cornering",
		"tekura_dodging",
		"weaving",
		"elusion",
		"shaman_warding",
		"imbue_erosion",
		"imbue_stonefury",
		"twinsoul",
		"wisp_anxiety",
		"wisp_bloodshield",
		"wisp_stigmata",
		"scythestance",
		"shun_life",
		"armblock",
		"bodyblock",
		"evadeblock",
		"legblock",
		"pinchblock",
		"ricochet",
		"thickhide",
		"maingauche",
		"coagulation",
		"balancing",
		"flexibility",
		"lifesap",
		"deathaura",
		"putrefaction",
		"earth_resonance",
		"energy_shell",
		"protection",
		"fortify",
		"barkskin",
		"warding",
		"hardiness",
		"fireblock",
		"lightshield",
		"fireveil",
		"stoneskin",
		"inspiration_constitution",
		"inspiration_dexterity",
		"inspiration_intelligence",
		"inspiration_strength",
		"thorncoat",
		"blood_concentrate",
		"potence",
		"metabolism",
		"shadowblow",
		"stillmind",
		"celerity",
		"surefooted",
		"mindnet",
		"lifescent",
		"alertness",
		"pacing",
		"divine_speed",
		"foreststride",

		--! low priority
		"auresae_symbol",
		"damariel_symbol",
		"dhar_symbol",
		"haern_symbol",
		"lleis_symbol",
		"herculeanrage",
		"fearless",
		"bodyheat",
		"bloodshade",
		"spiritsight",
		"lifevision",
		"heatsight",
		"shadowsight",
		"shadowslip",
		"hypersight",
		"detection",
		"telesense",
		"vengeance",
		"stonebind",
		"acidblood",
		"astralblur",
		"masked_scent",
		"concealed",
		"sand_conceal",
		"stealth",
		"ghosted",
		"gravechill",
		"elemental_fortify",
		"spiritbond",
		"tethering",
		"mindcloak",
		"veiled",
		"soulmask",
		"deathsight",
		"hidden",
		"blending",
		"bloodsense",
		"lipreading",
		"bloodchill",
		"masquerade"

	},

	--! defense priority list loaded into prompt.d
	e = {

		--! free defenses
		"thirdeye",
		"nightsight",
		"temperance",
		"vigor",
		"speed",
		"fangbarrier",
		"nightsight",
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower",
		"contemplate_yuef",
		"contemplate_ef_tig",
		"contemplate_rafic",
		"contemplate_jherza",
		"contemplate_yi",
		"contemplate_jhako",
		"contemplate_lgakt",

	}

}

--! defense library namespace

--! each def organized by parameter active, keep, action, requires, and consumes
--! todo: code toggles for mindseye and thirdeye based on skill/tat present
lib = {
	--! these defenses are parsed through the curing functions
	blindness = { action = "eat bayberry" },
	insulation = { action = "apply caloric" },
	deafness = { action = "eat hawthorn" },
	density = { action = "apply mass" },
	rebounding = { action = "smoke skullcap" },
	waterbreathing = { action = "eat pricklypear" },

	--! these defenses are parsed through prompt.d
	fangbarrier = { action = "apply sileris", requires = function() return can.salve() and not fs.fangbarrier and not affs.current.slickness end, consumes = {}, skill = true },
	insomnia = { action = "eat cohosh", requires = function() return can.herb() and (o.bals.herb or _gmcp.has_skill("insomnia", "survival")) end, consumes = {}, skill = true },
	instawake = { action = "eat kola", requires = function() return can.herb() and o.bals.herb end, consumes = {}, skill = true },
	levitation = { action = "sip levitation", requires = function() return can.affelixir() end, consumes = { "affelixir" }, skill = true },
	nightsight = { action = "nightsight", requires = function() return not tmp.paused end, consumes = {}, skill = { "nightsight", "vision", "nightsight", "corpus", "nightsight", "illumination", "nightsight", "sciomancy", "nightsight", "kaido", "nightsight", "shapeshifting", "nightsight", "necromancy" } },
	speed = { action = "sip speed", requires = function() return can.sip() and not fs.speed end, consumes = {}, skill = true },
	temperance = { action = "sip frost", requires = function() return can.sip() end, consumes = {}, skill = true },
	thirdeye = { action = "thirdeye", requires = function() return not tmp.paused end, consumes = {}, skill = true },
	venom_resistance = { action = "sip venom", requires = function() return can.affelixir() end, consumes = { "affelixir" }, skill = true },
	vigor = { action = "sip vigor", requires = function() return can.sip() end, consumes = {}, skill = true },

	--! these defenses are parsed through prompt.q

	--! free
	cloak = { action = "touch cloak", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = true },
	disperse = { action = "disperse", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = true },
	divine_speed = { action = "grace", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = true },
	endgame = { action = "endgame", requires = function() return can.reqbaleqprone() and can.endgame_def() end, consumes = {}, skill = true },
	mindseye = { action = "touch allsight", requires = function() return can.reqbaleq() end, consumes = {}, skill = true },
	mist_blue = { action = "activate ceruleanorb", requires = function() return can.reqbaleq() end, consumes = {}, skill = true },
	mist_green = { action = "activate greenorb", requires = function() return can.reqbaleq() end, consumes = {}, skill = true },
	mist_red = { action = "activate crimsonorb", requires = function() return can.reqbaleq() end, consumes = {}, skill = true },
	mist_yellow = { action = "activate amberorb", requires = function() return can.reqbaleq() end, consumes = {}, skill = true },
	shielded = { action = "touch shield", requires = function() return not affs.current.umbrage_curse and can.reqbaleq() end, consumes = { "equilibrium" }, skill = true },

	--! defenses shared by multiple classes
	alertness = { action = "alertness", off = "alertness off", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "alertness", "deathlore", "alertness", "vision" } },
	blood_concentrate = { action = "concentrate blood", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, wield = {}, skill = { "concentration", "sanguis", "concentration", "hematurgy" } },
	celerity = { action = "celerity", requires = function() return can.celerity() end, consumes = {}, skill = { "celerity", "corpus", "endurance", "shapeshifting" } },
	deathsight = { action = "deathsight", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "deathsight", "deathlore", "deathsight", "mentis", "deathsight", "necromancy", "deathsight", "vision" } },
	elemental_fortify = { action = "fortify entities on", requires = function() return can.reqbaleq() end, skill = { "fortification", "elemancy", "fortification", "sciomancy" } },
	fitness = { action = "fitness", requires = function() return can.reqbaleq() and can.fitness() end, consumes = { "balance", "equilibrium", "fitness" }, skill = { "fitness", "battlefury", "fitness", "chivalry", "fitness", "corpus", "fitness", "savagery", "fitness", "spirituality", "fitness", "kaido", "fitness", "woodlore" } },
	gripping = { action = "grip", off = "relax grip", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "gripping", "battlefury", "gripping", "chivalry", "gripping", "savagery" } },
	hidden = { action = "hide", requires = function() return can.reqbaleq() and not active.phased end, consumes = { "balance" }, skill = { "hide", "subterfuge", "hide", "woodlore", "hide", "corpus" } },
	lifevision = { action = "lifevision", requires = function() return can.reqeq() end, consumes = { "equilibrium" }, skill = { "lifevision", "necromancy", "lifevision", "mentis" } },
	pacing = { action = "pacing on", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "pacing", "subterfuge", "pacing", "shapeshifting" } },
	parrying = { action = "parry torso", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "guarding", "tekura", "parrying", "weaponry", "pawguard", "shapeshifting" } },
	reflection = { action = "cast reflection me", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, kdef = { "channel_air", "channel_fire" }, skill = { "reflection", "elemancy", "reflection", "sciomancy" } },
	resistance = { action = "resistance", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "resistance", "chivalry", "resistance", "kaido", "resistance", "spirituality" } },
	shroud = { action = "shroud", requires = function() return (can.reqbaleq() or (o.stats.class == "syssin" and can.illusion())) and not active.phased end, consumes = {}, skill = { "shroud", "deathlore", "shroud", "necromancy", "cloak", "subterfuge" } },
	soulmask = { action = "soulmask", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "soulmask", "necromancy", "soulmask", "deathlore" } },
	standfirm = { action = "stand firm", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "sturdiness", "battlefury", "sturdiness", "chivalry", "sturdiness", "kaido" } },
	toughness = { action = "toughness", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "toughness", "kaido", "toughness", "spirituality" } },
	vitality = { action = "vitality", requires = function() return can.reqbaleq() and can.vitality() end, consumes = { "balance" }, skill = { "vitality", "kaido", "vitality", "woodlore" } },
	warding = { action = "warding", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "warding", "corpus", "warding", "subterfuge" } },
	weathering = { action = "weathering", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "weathering", "chivalry", "weathering", "kaido", "weathering", "shapeshifting" } },

	--! animation
	twinsoul = { action = "golem twinsoul on", off = "golem twinsoul off", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "twinsoul", "animation" } },

	--! avoidance
	avoidance_fortify = { action = "divert fortify", requires = function() return can.reqbaleq() and o.bals.avoidance end, consumes = { "avoidance "}, nodef = { "nimbleness" }, skill = { "fortify", "avoidance" } },
	dodging = { action = "dodge melee", requires = function() return can.reqbaleq() end, consumes = {}, nodef = { "diverting" }, skill = { "dodging", "avoidance" } },
	diverting = { action = "divert melee", requires = function() return can.reqbaleq() and not _gmcp.has_skill("reflexivediversion", "avoidance") end, consumes = {}, nodef = {}, skill = { "diversion", "avoidance" } },
	nimbleness = { action = "nimbleness", requires = function() return can.reqbaleq() and o.bals.avoidance end, consumes = { "avoidance" }, nodef = { "avoidance_fortify" }, skill = { "nimbleness", "avoidance" } },

	--! battlefury
	maingauche = { action = "maingauche", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "maingauche", "battlefury" } },

	--! bladefire
	bladefury = { action = "bladefury on", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "bladefury", "bladefire" } },

	--! corpus
	elusion = { action = "elusion on", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "elusion", "corpus" } },
	masquerade = { action = "masquerade on", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "masquerade", "corpus" } },
	potence = { action = "potence on", off = "potence off", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "potence", "corpus" } },
	fortify = { action = "fortify", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "fortify", "corpus" } },
	lifescent = { action = "lifescent on", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "lifescent", "corpus" } },

	--! deathlore
	--! todo: soulstone handling for embed
	soul_fortify = { action = "soul fortify", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "fortify", "deathlore" } },
	soul_fracture = { action = "soul fracture", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "fracture", "deathlore" } },
	soul_substitute = { action = "soul substitute", requires = function() return can.reqbaleq() and not defs.active.starburst end, consumes = { "equilibrium" }, skill = { "substitute", "deathlore" } },
	soulharvest = { action = "soul harvest on", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "harvest", "deathlore" } },
	soulthirst = { action = "soul thirst", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "soulthirst", "deathlore" } },
	spiritsight = { action = "soul spiritsight", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "spiritsight", "deathlore" } },

	--! devotion - todo: Devotion threshold check
	inspiration_constitution = { action = "perform inspiration constitution", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "inspiration_dexterity", "inspiration_intelligence", "inspiration_strength" }, skill = { "inspiration", "devotion" } },
	inspiration_dexterity = { action = "perform inspiration dexterity", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "inspiration_constitution", "inspiration_intelligence", "inspiration_strength" }, skill = { "inspiration", "devotion" } },
	inspiration_intelligence = { action = "perform inspiration intelligence", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "inspiration_constitution", "inspiration_dexterity", "inspiration_strength" }, skill = { "inspiration", "devotion" } },
	inspiration_strength = { action = "perform inspiration strength", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "inspiration_constitution", "inspiration_dexterity", "inspiration_intelligence" }, skill = { "inspiration", "devotion" } },

	--! desiccation
	disturbances = { action = "sand disturbances on", off = "sand disturbances off", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "disturbances", "desiccation" } },
	sand_conceal = { action = "sand conceal on", off = "sand conceal off", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "concealment", "dessication" } },
	sand_swelter = { action = "sand swelter on", off = "sand swelter off", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "swelter", "dessication" } },

	--! dhuriv
	balancing = { action = "balancing on", off = "balancing off", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "nimble", "dhuriv" } },
	flexibility = { action = "flexibility", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "flexibility", "dhuriv" } },

	--! elemancy
	fireveil = { action = "cast veil", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, kdef = { "channel_fire" }, skill = { "veil", "elemancy" } },
	waterward = { action = "cast waterward", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, kdef = { "channel_water" }, skill = { "waterward", "elemancy" } },

	--! hematurgy
	scythestance = { action = "scythe stance", requires = function() return can.reqbaleq() end, consumes = { "balance" }, wield = { "scythe", "left" }, skill = { "stance", "hematurgy" } },
	wisp_anxiety = { action = "wisp anxiety on", requires = function() return can.reqbaleq() and active.wisp_form end, consumes = { "equilibrium" }, skill = { "anxiety", "hematurgy" } },
	wisp_bloodshield = { action = "wisp bloodshield on", requires = function() return can.reqbaleq() and active.wisp_form end, consumes = { "equilibrium" }, skill = { "bloodshield", "hematurgy" } },
	wisp_form = { action = "wisp form", requires = function() return can.reqbaleq() and not active.wisp_sacrifice end, consumes = { "equilibrium" }, skill = { "form", "hematurgy" } },
	wisp_sacrifice = { action = "wisp sacrifice", requires = function() return can.reqbaleq() and active.wisp_form end, consumes = { "equilibrium" }, skill = {"sacrifice", "hematurgy" } },
	wisp_stigmata = { action = "wisp stigmata on", requires = function() return can.reqbaleq() and active.wisp_form end, consumes = { "equilibrium" }, skill = { "stigmata", "hematurgy" } },

		--! hematurgy rituals - todo: skill parse
		acidblood = { action = "chant ompe kelo wo de ti ite de", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "acidblood", "hematurgy" } },
		astralblur = { action = "chant bujev kuy wo de ulo du elnur nu", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "blur", "hematurgy" } },
		bloodchill = { action = "nid du nasu iyedlo telvi kelo", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "bloodchill", "hematurgy" } },
		bloodmeld = { action = "chant abi de izuto kelo eja", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "bloodmeld", "hematurgy" } },
		bloodshade = { action = "de vusba sas neno atdum wo kelo", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "bloodshade", "hematurgy" } },
		broken_circle = { action = "chant el mot kelo bagri de", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "circle", "hematurgy" } },
		mindsurge = { action = "chant vismu du ive nipdo", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "slicktongue", "stilltongue", "tonguelash" }, skill = { "mindsurge", "hematurgy" } },
		sanguispect = { action = "chant nomru fevo kelo de miduda viru le afu de", requires = function() return can.reqbaleq() and can.vitality() end, consumes = { "equilibrium" }, skill = { "sanguispect", "hematurgy" } },
		shadowblow = { action = "chant nu lura fevo dilo ti wo nu elnur atdum", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "shadowblow", "hematurgy" } },
		shiftsoul = { action = "chant nomru fevo kelo abi de wo ti ye de", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "shiftsoul", "hematurgy" } },
		shun_life = { action = "chant zazmi amborsa sota elsa", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "shun", "hematurgy" } },
		slicktongue = { action = "tatansa wo ti lifge nipdo abi du", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "slicktongue", "hematurgy" } },
		stillmind = { action = "chant tab nes ye nid du nipdo de", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "stillmind", "hematurgy" } },
		stilltongue = { action = "chant ansosa ive nid du le ena wo de", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "mindsurge", "slicktongue", "tonguelash" }, skill = { "stilltongue", "hematurgy" } },
		tonguelash = { action = "chant sota tazi ye do dor kelo", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "mindsurge", "slicktongue", "stilltongue" }, skill = { "tonguelash", "hematurgy" } },
		trill = { action = "remeza vas de balu zoyo tatansa", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "trill", "hematurgy" } },

	--! illumination - todo: Spark threshold check
	boilingblood = { action = "evoke boilingblood on", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "boilingblood", "illumination" } },
	discharge = { action = "evoke discharge", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "discharge", "illumination" } },
	fireblock = { action = "evoke fireblock", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "fireblock", "illumination" } },
	lightform = { action = "evoke lightform", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "lightform", "illumination" } },
	lightshield = { action = "evoke lightshield", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "lightshield", "illumination" } },
	rebirth = { action = "evoke rebirth", requires = function() return can.reqbaleq() and not active.starburst end, consumes = { "balance" }, skill = { "rebirth", "illumination" } },
	shine = { action = "evoke shine", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "shine", "illumination" } },

	--! kaido
	boost_kaido_regeneration = { action = "boost regeneration", requires = function() return can.reqbaleq() and (active.kaido_regeneration or preserve.kaido_regeneration) end, consumes = {}, skill = { "boosting", "kaido" } },
	consciousness = { action = "consciousness on", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "consciousness", "kaido" } },
	conservation = { action = "kai conservation", requires = function() return can.reqbaleq() and not cd.conservation end, consumes = {}, skill = { "conservation", "kaido" }, chan = true },
	constitution = { action = "constitution", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "constitution", "kaido" } },
	immunity = { action = "immunity", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "immunity", "kaido" } },
	kaido_regeneration = { action = "regeneration on", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "regeneration", "kaido" } },
	kai_recursion = { action = "kai recursion on", requires = function() return can.reqbaleq() and not active.kai_trance end, consumes = {}, skill = {"recursion", "kaido"} },
	kai_trance = { action = "kai trance", requires = function() return can.reqbaleq() end, consumes = {}, nodef = { "kai_recursion" }, skill = { "trance", "kaido" }, chan = true },
	projectiles = { action = "projectiles on", off = "projectils off", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "projectiles", "kaido" } },
	splitting = { action = "split mind", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "splitting", "kaido" } },

	--! mentis
	bloodsense = { action = "bloodsense on", requires = function() return can.reqbaleq() and o.stats.spec == "Rituos" end, consumes = { "equilibrium" }, skill = { "bloodsense", "mentis" } },

	--! naturalism
	greenfoot = { action = "nature greenfoot on", off = "nature greenfoot off", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "greenfoot", "equilibrium" } },
	blending = { action = "nature blend", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "blending", "equilibrium" } },
	thorncoat = { action = "nature thorncoat me", requires = function() return can.reqbaleq() and not fs.thorncoat end, consumes = { "equilibrium" }, skill = { "thorncoat", "equilibrium" } },

	--! necromancy
	blackwind = { action = "blackwind", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "blackwind", "necromancy" } },
	corruption = { action = "corruption", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "corruption", "necromancy" } },
	deathaura = { action = "deathaura", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "deathaura", "necromancy" } },
	gravechill = { action = "gravechill", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "gravechill", "necromancy" } },
	putrefaction = { action = "putrefaction", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "putrefaction", "necromancy" } },
	soulcage = { action = "soulcage", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "soulcage", "necromancy" } },
	vengeance = { action = "vengeance", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "vengeance", "necromancy" } },

	--! numerology
	fixed = { action = "elicit fix me", requires = function() return can.reqbaleq() and (active.contemplate_rafic or active.spheres) end, consumes = { "equilibrium" }, kdef = {}, skill = { "fix", "numerology" } },
	link = { action = "elicit link", requires = function() return can.reqbaleq() and ((active.contemplate_jherza and active.contemplate_yi and active.contemplate_jhako) or active.spheres) end, consumes = { "equilibrium" }, kdef = {}, skill = { "link", "numerology" } },
	numerology_constitution = { action = "elicit constitution", requires = function() return can.reqbaleq() and (active.contemplate_jherza or active.spheres) end, consumes = {}, kdef = {}, skill = { "constitution", "numerology" } },
	recognition = { action = "elicit recognition", requires = function() return can.reqbaleq() and ((active.contemplate_jherza and active.contemplate_jhako) or defs.active.spheres) end, consumes = { "equilibrium" }, kdef = {}, skill = { "recognition", "numerology" } },
	spheres = { action = "contemplate spheres", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "spheres", "numerology" }, chan = true },
	veiled = { action = "elicit veil", requires = function() return can.reqbaleq() and ((active.contemplate_rafic and active.contemplate_yi) or active.spheres) end, consumes = { "equilibrium" }, kdef = {}, skill = { "veil", "numerology" } },

	--! primality
	boosting = { action = "commune boost", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, wield = { "quarterstaff", "left" }, skill = { "boosting", "primality" } },
	lifebloom = { action = "commune lifebloom", requires = function() return can.reqbaleq() and can.vitality() end, consumes = { "equilibrium" }, wield = { "quarterstaff", "left" }, skill = { "lifebloom", "primality" } },

	--! refining
	energy_shell = { action = "refining shell", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "shell", "refining" } },

	--! righteousness - todo: populate - todo: prio.q - todo: special handling
	accuracy_aura = { action = "aura accuracy", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = {}, skill = { "accuracy", "righteousness" } },
	accuracy_blessing = { action = "aura blessing accuracy", requires = function() return can.reqbaleq() and _gmcp.has_skill("blessing", "righteousness") end, consumes = { "equilibrium" }, skill = { "accuracy", "righteousness" } },
	cleansing_aura = { action = "aura cleansing", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = {}, skill = { "cleansing", "righteousness" } },
	cleansing_blessing = { action = "aura blessing cleansing", requires = function() return can.reqbaleq() and _gmcp.has_skill("blessing", "righteousness") end, consumes = { "equilibrium" }, skill = { "cleansing", "righteousness" } },
	healing_aura = { action = "aura healing", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = {}, skill = { "healing", "righteousness" } },
	healing_blessing = { action = "aura blessing healing", requires = function() return can.reqbaleq() and _gmcp.has_skill("blessing", "righteousness") end, consumes = { "equilibrium" }, skill = { "healing", "righteousness" } },
	justice_aura = { action = "aura justice", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = {}, skill = { "justice", "righteousness" } },
	justice_blessing = { action = "aura blessing justice", requires = function() return can.reqbaleq() and _gmcp.has_skill("blessing", "righteousness") end, consumes = { "equilibrium" }, skill = { "justice", "righteousness" } },
	meditation_aura = { action = "aura meditation", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = {}, skill = { "meditation", "righteousness" } },
	meditation_blessing = { action = "aura blessing meditation", requires = function() return can.reqbaleq() and _gmcp.has_skill("blessing", "righteousness") end, consumes = { "equilibrium" }, skill = { "meditation", "righteousness" } },
	pestilence_aura = { action = "aura pestilence", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = {}, skill = { "pestilence", "righteousness" } },
	pestilence_blessing = { action = "aura blessing pestilence", requires = function() return can.reqbaleq() and _gmcp.has_skill("blessing", "righteousness") end, consumes = { "equilibrium" }, skill = { "pestilence", "righteousness" } },
	protection_aura = { action = "aura protection", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = {}, skill = { "protection", "righteousness" } },
	protection_blessing = { action = "aura blessing protection", requires = function() return can.reqbaleq() and _gmcp.has_skill("blessing", "righteousness") end, consumes = { "equilibrium" }, skill = { "protection", "righteousness" } },
	purity_aura = { action = "aura purity", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = {}, skill = { "purity", "righteousness" } },
	purity_blessing = { action = "aura blessing purity", requires = function() return can.reqbaleq() and _gmcp.has_skill("blessing", "righteousness") end, consumes = { "equilibrium" }, skill = { "purity", "righteousness" } },
	redemption_aura = { action = "aura redemption", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = {}, skill = { "redemption", "righteousness" } },
	redemption_blessing = { action = "aura blessing redemption", requires = function() return can.reqbaleq() and _gmcp.has_skill("blessing", "righteousness") end, consumes = { "equilibrium" }, skill = { "redemption", "righteousness" } },
	spellbane_aura = { action = "aura spellbane", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = {}, skill = { "spellbane", "righteousness" } },
	spellbane_blessing = { action = "aura blessing spellbane", requires = function() return can.reqbaleq() and _gmcp.has_skill("blessing", "righteousness") end, consumes = { "equilibrium" }, skill = { "spellbane", "righteousness" } },

	--! sanguis
	blood_affinity = { action = "blood affinity minion", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "affinity", "sanguis" } },

	--! savagery
	bruteforce = { action = "hammer force", requires = function() return can.reqbaleq() end, consumes = { "balance" }, wield = { "warhammer", "both" }, skill = { "bruteforce", "savagery" } },
	fearless = { action = "fearless", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "fearless", "savagery" } },
	furor = { action = "furor", requires = function() return can.reqbaleq() and o.bals.furor end, consumes = {}, skill = { "furor", "savagery" } },
	herculeanrage = { action = "hammer rage on", requires = function() return can.reqbaleq() end, consumes = { "balance" }, wield = { "warhammer", "both" }, skill = { "herculeanrage", "savagery" } },
	reckless = { action = "recklessness on", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "reckless", "savagery" } },
	reveling = { action = "reveling on", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "reveling", "savagery" } },
	stalwart = { action = "stalwart on", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "stalwart", "savagery" } },

	--! sciomancy
	stoneskin = { action = "cast stoneskin", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, kdef = { "channel_earth" }, skill = { "stoneskin", "sciomancy" } },
	galeward = { action = "cast galeward", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, kdef = { "channel_air" }, skill = { "galeward", "sciomancy" } },

	--! shamanism
	oath_blade = { action = "oath blade activate", off = "oath blade disable", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "oaths", "shamanism" } },
	oath_durdalis = { action = "oath durdalis activate", off = "oath durdalis disable", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "oaths", "shamanism" } },
	oath_forestwalker = { action = "oath forestwalker activate", off = "oath forestwalker disable", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "oaths", "shamanism" } },
	oath_primeval = { action = "oath primeval activate", off = "oath primeval disable", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "oaths", "shamanism" } },
	oath_rhythm = { action = "oath rhythm activate", off = "oath rhythm disable", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "oaths", "shamanism" } },
	oath_shaman = { action = "oath shaman activate", off = "oath shaman disable", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "oaths", "shamanism" } },
	oath_tranquility = { action = "oath tranquility activate", off = "oath tranquility disable", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "oaths", "shamanism" } },
	protection = { action = "shaman protection", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "protection", "shamanism" } },
	shaman_warding = { action = "shaman warding", requires = function() return can.reqbaleq() end, consumes = { "equilibrium"}, skill = { "warding", "shamanism" } },
	shamanism_spiritsight = { action = "shaman spiritsight on", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "spiritsight", "shamanism" } },
	spiritbond = { action = "familiar spiritbond on", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "spiritbond", "shamanism" } },
	tethering = { action = "familiar tether on", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "tethering", "shamanism" } },

	--! shapeshifting
	berserk = { action = "berserk", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "berserk", "shapeshifting" } },
	bodyheat = { action = "bodyheat", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "bodyheat", "shapeshifting" } },
	bracing = { action = "brace", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "bracing", "shapeshifting" } },
	cornering = { action = "corner on", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "cornering", "shapeshifting" } },
	heatsight = { action = "heatsight", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "heatsight", "shapeshifting" } },
	hardening = { action = "harden bones", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "hardening", "shapeshifting" } },
	metabolism = { action = "metabolize on", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "metabolism", "shapeshifting" } },
	salivating = { action = "salivate", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "salivate", "shapeshifting" } },
	stealth = { action = "stealth on", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "stealth", "shapeshifting" } },
	thickhide = { action = "thickhide", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "thickhide", "shapeshifting" } },

	--! spirituality
	auresae_symbol = { action = "paint shield auresae", requires = function() return can.reqbaleq() end, consumes = { "balance" }, wield = { "shield", "left" }, nodef = { "damariel_symbol", "dhar_symbol", "haern_symbol", "lleis_symbol" }, skill = { "symbols", "spirituality" } },
	damariel_symbol = { action = "paint shield damariel", requires = function() return can.reqbaleq() end, consumes = { "balance" }, wield = { "shield", "left" }, nodef = { "auresae_symbol", "dhar_symbol", "haern_symbol", "lleis_symbol" }, skill = { "symbols", "spirituality" } },
	dhar_symbol = { action = "paint shield dhar", requires = function() return can.reqbaleq() end, consumes = { "balance" }, wield = { "shield", "left" }, nodef = { "auresae_symbol", "damariel_symbol", "haern_symbol", "lleis_symbol" }, skill = { "symbols", "spirituality" } },
	haern_symbol = { action = "paint shield haern", requires = function() return can.reqbaleq() end, consumes = { "balance" }, wield = { "shield", "left" }, nodef = { "auresae_symbol", "damariel_symbol", "dhar_symbol", "lleis_symbol" }, skill = { "symbols", "spirituality" } },
	lleis_symbol = { action = "paint shield lleis", requires = function() return can.reqbaleq() end, consumes = { "balance" }, wield = { "shield", "left" }, nodef = { "auresae_symbol", "damariel_symbol", "dhar_symbol", "haern_symbol" }, skill = { "symbols", "spirituality" } },

	--! subterfuge
	ghosted = { action = "conjure ghost", requires = function() return can.reqbaleq() and can.illusion() and not active.phased end, consumes = {}, skill = { "ghost", "subterfuge" } },
	shadowsight = { action = "shadowsight", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "shadowsight", "subterfuge" } },
	shadowslip = { action = "shadowslip on", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "shadowslip", "subterfuge" } },
	lipreading = { action = "lipread", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "lipread", "subterfuge" } },
	phased = { action = "phase", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "phase", "subterfuge" }, chan = true },
	weaving = { action = "weaving on", off = "weaving off", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "weaving", "subterfuge" } },

	--! survival
	clarity = { action = "clarity", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "clarity", "survival" } },
	metawake = { action = "metawake on", off = "metawake off", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "metawake", "survival" } },

	--! tarot
	adder = { action = "fling adder at ground", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "adder", "tarot" } },
	devilpact = { action = "fling devil at ground", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "devil", "tarot" } },
	eclipse = { action = "fling eclipse at me", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "eclipse", "tarot" } },
	hierophant = { action = "fling hierophant at me", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "hierophant", "tarot" } },

	--! tekura
	armblock = { action = "asb", requires = function() return can.reqbaleq() end, consumes = { "balance" }, nodef = { "legblock" }, skill = { "armblock", "tekura" } },
	bodyblock = { action = "bdb", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "bodyblock", "tekura" } },
	evadeblock = { action = "evb", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "evadeblock", "tekura" } },
	legblock = { action = "lsb", requires = function() return can.reqbaleq() end, consumes = { "balance" }, nodef = { "armblock" }, skill = { "legblock", "tekura" } },
	pinchblock = { action = "pnb", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "pinchblock", "tekura" } },
	tekura_dodging = { action = "dodging on", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "tekura_dodging", "tekura" } },

	--! telepathy
	mindcloak = { action = "mindcloak on", off = "mindcloak off", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "mindcloak", "telepathy" } },
	mindnet = { action = "mindnet on", off = "mindnet off", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "mindnet", "telepathy" } },

	--! terramancy
	earth_resonance = { action = "earth resonance", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "resonance", "terramancy" } },
	earthenform = { action = "earthenform embrace", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "earthenform", "terramancy" }, chan = true },
	entwine = { action = "earth entwine", requires = function() return can.reqbaleq() end, consumes = {}, wield = { "shield", "left", "flail", "right" }, skill = { "entwine", "terramancy" } },
	imbue_erosion = { action = "earth imbue erosion", requires = function() return can.reqbaleq() end, consumes = { "balance" }, wield = { "shield", "left", "flail", "right" }, skill = { "erosion", "terramancy" } },
	imbue_stonefury = { action = "earth imbue stonefury", requires = function() return can.reqbaleq() end, consumes = { "balance" }, wield = { "shield", "left", "flail", "right" }, skill = { "stonefury", "terramancy" } },
	imbue_will = { action = "prepare earthenwill", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "earthenwill", "terramancy" } },
	momentum = { action = "earth momentum", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "momentum", "terramancy" } },
	ricochet = { action = "earth ricochet", requires = function() return can.reqbaleq() end, consumes = { "balance" }, wield = { "shield", "left", "flail", "right" }, skill = { "ricochet", "terramancy" } },
	stonebind = { action = "earth stonebind", requires = function() return can.reqbaleq() end, consumes = { "balance" }, wield = { "shield", "left", "flail", "right" }, skill = { "stonebind", "terramancy" } },
	surefooted = { action = "earth surefooted", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "surefooted", "terramancy" } },

		--! runemark
		blue_major = { action = "earth inscribe rune upon blue", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "gold_major", "green_major", "purple_major", "red_major", "yellow_major" }, skill = { "runemark", "terramancy" } },
		blue_minor = { action = "earth inscribe blue upon rune", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "gold_minor", "green_minor", "purple_minor", "red_minor", "yellow_minor" }, skill = { "runemark", "terramancy" } },
		gold_major = { action = "earth inscribe rune upon gold", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "blue_major", "green_major", "purple_major", "red_major", "yellow_major" }, skill = { "runemark", "terramancy" } },
		gold_minor = { action = "earth inscribe gold upon rune", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "blue_minor", "green_minor", "purple_minor", "red_minor", "yellow_minor" }, skill = { "runemark", "terramancy" } },
		green_major = { action = "earth inscribe rune upon green", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "blue_major", "gold_major", "purple_major", "red_major", "yellow_major" }, skill = { "runemark", "terramancy" } },
		green_minor = { action = "earth inscribe green upon rune", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "blue_minor", "gold_minor", "purple_minor", "red_minor", "yellow_minor" }, skill = { "runemark", "terramancy" } },
		purple_major = { action = "earth inscribe rune upon purple", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "blue_major", "gold_major", "green_major", "red_major", "yellow_major" }, skill = { "runemark", "terramancy" } },
		purple_minor = { action = "earth inscribe purple upon rune", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "blue_minor", "gold_minor", "green_minor", "red_minor", "yellow_minor" }, skill = { "runemark", "terramancy" } },
		red_major = { action = "earth inscribe rune upon red", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "blue_major", "gold_major", "green_major", "purple_major", "yellow_major" }, skill = { "runemark", "terramancy" } },
		red_minor = { action = "earth inscribe red upon rune", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "blue_minor", "gold_minor", "green_minor", "purple_minor", "yellow_minor" }, skill = { "runemark", "terramancy" } },
		yellow_major = { action = "earth inscribe rune upon yellow", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "blue_major", "gold_major", "green_major", "purple_major", "red_major" }, skill = { "runemark", "terramancy" } },
		yellow_minor = { action = "earth inscribe yellow upon rune", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, nodef = { "blue_minor", "gold_minor", "green_minor", "purple_minor", "red_minor" }, skill = { "runemark", "terramancy" } },

	--! tracking
	alacrity = { action = "crossbow alacrity", requires = function() return can.reqbaleq() and not cd.alacrity end, consumes = { "balance", "alacrity" }, skill = { "alacrity", "tracking" } },
	masked_scent = { action = "mask scent", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "masking", "tracking" } },

	--! vision
	detection = { action = "detection on", off = "detection off", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "detection", "vision" } },
	eagleeye = { action = "eagleeye on", off = "eagleeye off", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "eagleeye", "vision" } },
	hypersight = { action = "hypsersight on", off = "hypersight off", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "hypersight", "vision" } },
	skywatch = { action = "skywatch on", off = "skywatch off", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "skywatch", "vision" } },
	telesense = { action = "telesense on", off = "telesense off", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "telesense", "vision" } },
	treewatch = { action = "treewatch on", off = "treewatch off", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "treewatch", "vision" } },
	vigilance = { action = "vigilance on", off = "vigilance off", requires = function() return can.reqbaleq() end, consumes = {}, skill = { "vigilance", "vision" } },

	--! vocalizing
	boneshaking = { action = "boneshaking on", off = "boneshaking off", requires = function() return can.reqeq() end, consumes = { "equilibrium" }, skill = { "boneshaking", "vocalizing" } },
	echoing = { action = "echoing on", off = "echoing off", requires = function() return can.reqeq() end, consumes = { "equilibrium" }, skill = { "echoing", "vocalizing" } },
	snarling = { action = "snarling on", off = "attuning off", requires = function() return can.reqeq() end, consumes = { "equilibrium" }, skill = { "snarling", "vocalizing" } },
	attuning = { action = "attuning on", off = "attuning off", requires = function() return can.reqeq() end, consumes = { "equilibrium" }, skill = { "attuning", "vocalizing" } },	

	--! warhounds - todo: populate - todo: prio.q

	--! weaponry
	hand_returning = { action = "returning on", requires = function() can.reqbaleq() end, consumes = {}, nodef = { "inventory_returning" }, skill = { "returning", "weaponry"} },
	inventory_returning = { action = "returning on inventory", requires = function() can.reqbaleq() end, consumes = {}, nodef = { "hand_returning" }, skill = { "returning", "weaponry"} },

	--! woodlore
	barkskin = { action = "barkskin", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "barkskin", "woodlore" } },
	coagulation = { action = "coagulation on", off = "coagulation off", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "coagulation", "woodlore" } },
	concealed = { action = "conceal", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "conceal", "woodlore" } },
	foreststride = { action = "foreststride", requires = function() return can.reqbaleq() end, consumes = { "balance" }, skill = { "foreststriding", "woodlore" } },
	hardiness = { action = "hardiness", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "hardiness", "woodlore" } },
	lifesap = { action = "lifesap", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "lifesap", "woodlore" } },

	--! defense-like traits

	--! elemental channels
	bind_air = { action = "bind air", requires = function() return can.reqbaleq() and active.channel_air end, consumes = { "equilibrium"}, skill = { "binding", "healing", "binding", "sciomancy" } },
	bind_earth = { action = "bind earth", requires = function() return can.reqbaleq() and active.channel_earth end, consumes = { "equilibrium"}, skill = { "binding", "healing", "binding", "sciomancy" } },
	bind_fire = { action = "bind fire", requires = function() return can.reqbaleq() and active.channel_fire end, consumes = { "equilibrium"}, skill = { "binding", "elemancy", "binding", "healing" } },
	bind_shadow = { action = "bind shadow", requires = function() return can.reqbaleq() and active.channel_shadow end, consumes = { "equilibrium"}, skill = { "binding", "sciomancy" } },
	bind_spirit = { action = "bind spirit", requires = function() return can.reqbaleq() and active.channel_spirit end, consumes = { "equilibrium"}, skill = { "binding", "elemancy", "binding", "healing" } },
	bind_water = { action = "bind water", requires = function() return can.reqbaleq() and active.channel_water end, consumes = { "equilibrium"}, skill = { "binding", "elemancy", "binding", "healing", } },
	channel_air = { action = "channel air", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "channel", "healing", "channel", "sciomancy" } },
	channel_earth = { action = "channel earth", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "channel", "healing", "channel", "sciomancy" } },
	channel_fire = { action = "channel fire", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "channel", "elemancy", "channel", "healing" } },
	channel_shadow = { action = "channel shadow", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "channel", "sciomancy" } },
	channel_spirit = { action = "channel spirit", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "channel", "elemancy", "channel", "healing" } },
	channel_water = { action = "channel water", requires = function() return can.reqbaleq() end, consumes = { "equilibrium" }, skill = { "channel", "elemancy", "channel", "healing" } },

	--! numerology contemplations
	contemplate_yuef = { action = "contemplate yuef", requires = function() return can.contemplate() end, consumes = { "contemplate" }, nodef = {}, skill = { "yuef", "numerology" } },
	contemplate_ef_tig = { action = "contemplate ef_tig", requires = function() return can.contemplate() end, consumes = { "contemplate" }, nodef = {}, skill = { "ef'tig", "numerology" } },
	contemplate_rafic = { action = "contemplate rafic", requires = function() return can.contemplate() end, consumes = { "contemplate" }, nodef = {}, skill = { "rafic", "numerology" } },
	contemplate_jherza = { action = "contemplate jherza", requires = function() return can.contemplate() end, consumes = { "contemplate" }, nodef = {}, skill = { "jherza", "numerology" } },
	contemplate_yi = { action = "contemplate yi", requires = function() return can.contemplate() end, consumes = { "contemplate" }, nodef = {}, skill = { "yi", "numerology" } },
	contemplate_jhako = { action = "contemplate jhako", requires = function() return can.contemplate() end, consumes = { "contemplate" }, nodef = {}, skill = { "jhako", "numerology" } },
	contemplate_lgakt = { action = "contemplate lgakt", requires = function() return can.contemplate() end, consumes = { "contemplate" }, nodef = {}, skill = { "lgakt", "numerology" } },

	--! vocalizing howls
	howl_amnesia = { action = "howl traumatic", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "traumatic", "vocalizing" } },
	howl_anorexia = { action = "howl distasteful", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "distasteful", "vocalizing" } },
	howl_asleep = { action = "howl lulling", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "lulling", "vocalizing" } },
	howl_berserking = { action = "howl berserking", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "berserking", "vocalizing" } },
	howl_blurry_vision = { action = "howl blurring", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "blurring", "vocalizing" } },
	howl_enfeebling = { action = "howl enfeebling", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "enfeebling", "vocalizing" } },
	howl_claustrophobia = { action = "howl claustrophobic", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "claustrophobic", "vocalizing" } },
	howl_confusion = { action = "howl confusion", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "confusion", "vocalizing" } },
	howl_disrupted = { action = "howl disturbing", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "disturbing", "vocalizing" } },
	howl_endurance = { action = "howl invigorating", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "invigorating", "vocalizing" } },
	howl_fear = { action = "howl fearful", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "fearful", "vocalizing" } },
	howl_hallucinations = { action = "howl deranged", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "deranged", "vocalizing" } },
	howl_hatred = { action = "howl angry", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "angry", "vocalizing" } },
	howl_health = { action = "howl soothing", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "soothing", "vocalizing" } },
	howl_health_drain = { action = "howl wailing", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "wailing", "vocalizing" } },
	howl_hypersomnia = { action = "howl hypnotic", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "hypnotic", "vocalizing" } },
	howl_idiocy = { action = "howl dumbing", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "dumbing", "vocalizing" } },
	howl_lethargy = { action = "howl lethargic", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "lethargic", "vocalizing" } },
	howl_magic_impaired = { action = "howl muddling", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "muddling", "vocalizing" } },
	howl_mana = { action = "howl comforting", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "comforting", "vocalizing" } },
	howl_mana_drain = { action = "howl screeching", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "screeching", "vocalizing" } },
	howl_prone = { action = "howl forceful", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "forceful", "vocalizing" } },
	howl_no_deaf = { action = "howl piercing", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "piercing", "vocalizing" } },
	howl_paresis = { action = "howl paralyzing", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "paralyzing", "vocalizing" } },
	howl_plodding = { action = "howl deep", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "deep", "vocalizing" } },
	howl_portalbane = { action = "howl disruptive", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "disruptive", "vocalizing" } },
	howl_recklessness = { action = "howl rousing", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "recklessness", "vocalizing" } },
	howl_sensitivity = { action = "howl baleful", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "baleful", "vocalizing" } },
	howl_serenading = { action = "howl serenading", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "serenading", "vocalizing" } },
	howl_stupidity = { action = "howl mind_numbing", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "mind-numbing", "vocalizing" } },
	howl_vomiting = { action = "howl stomach_turning", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "stomach-turning", "vocalizing" } },
	howl_weariness = { action = "howl debilitating", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "debilitating", "vocalizing" } },
	howl_willpower = { action = "howl rejuvenating", requires = function() return can.howl() end, consumes = { "howl" }, nodef = {}, skill = { "rejuvenating", "vocalizing" } }
}

--! sets of defenses to be kept up, by handle
sets = {
	
	--! defense set to initially raise defenses
	defup = {

		name = "defup",

		--! these defenses require balance/equilibrium
		q = {

			--! cure defenses
			"blindness",
			"deafness",
			"insulation",
			"waterbreathing",

			--! free defenses
			"parrying",
			"diverting",
			"dodging",
			"mindseye",
			"endgame",
			"consciousness",
			"kaido_regeneration",
			"boost_kaido_regeneration",
			"toughness",
			"resistance",
			"entwine",
			"gripping",
			"numerology_constitution",
			"elemental_fortify",

			--! critical priority
			"spheres",
			"fitness",
			"vitality",
			"sanguispect",
			"lifebloom",
			"reckless",
			"link",
			"cloak",
			"channel_air",
			"channel_earth",
			"channel_fire",
			"channel_shadow",
			"channel_spirit",
			"channel_water",
			"rebirth",
			"soul_substitute",
			"soulcage",
			"clarity",
			"immunity",
			"splitting",
			"wisp_form",
			"mindsurge",
			"soulthirst",

			--! high priority
			"soul_fracture",
			"soul_fortify",
			"boneshaking",
			"snarling",
			"attuning",
			"earthenform",
			"adder",
			"devilpact",
			"eclipse",
			"hierophant",
			"hardening",
			"discharge",
			"constitution",
			"waterward",
			"galeward",
			"shaman_warding",
			"imbue_erosion",
			"twinsoul",
			"wisp_anxiety",
			"wisp_bloodshield",
			"wisp_stigmata",
			"scythestance",
			"ricochet",
			"thickhide",
			"red_major",
			"blue_minor",
			"purity_aura",
			"healing_blessing",
			"pestilence_blessing",
			"cleansing_blessing",
			"maingauche",
			"flexibility",
			"lifesap",
			"earth_resonance",
			"protection",
			"fortify",
			"barkskin",
			"warding",
			"hardiness",
			"fireblock",
			"lightshield",
			"fireveil",
			"stoneskin",
			"inspiration_dexterity",
			"blood_concentrate",
			"shadowblow",
			"stillmind",
			"celerity",
			"surefooted",
			"mindnet",
			"lifescent",
			"divine_speed",
			"foreststride",

			--! low priority
			"damariel_symbol",
			"stalwart",
			"weathering",
			"bodyheat",
			"spiritsight",
			"lifevision",
			"heatsight",
			"shadowsight",
			"shadowslip",
			"vengeance",
			"stonebind",
			"acidblood",
			"astralblur",
			"masked_scent",
			"concealed",
			"sand_conceal",
			"stealth",
			"ghosted",
			"shroud",
			"spiritbond",
			"tethering",
			"mindcloak",
			"veiled",
			"fearless",
			"soulmask",
			"deathsight",
			"hidden",
			"bloodsense",
			"lipreading"

		},

		--! these defenses do not require balance/equilibrium
		e = {

			--! free defenses
			"thirdeye",
			"nightsight",
			"temperance",
			"speed",
			"fangbarrier",
			"nightsight",

			--! eat defenses
			"insomnia",
			"instawake",

			--! affelixir defenses
			"levitation",
			"venom_resistance"

		}
			
	},

	--! defense set that only maintains critical defenses or defenses with no balance cost
	quiet = {

		name = "quiet",

		--! these defenses require balance/equilibrium
		q = {

			--! cure defenses
			"blindness",
			"deafness",
			"insulation",
			"waterbreathing",

			--! free defenses
			"parrying",
			"diverting",
			"dodging",
			"mindseye",
			"endgame",
			"conservation",
			"consciousness",
			"kaido_regeneration",
			"boost_kaido_regeneration",
			"toughness",
			"resistance",
			"gripping",

			--! critical priority
			"cloak",

			--! high priority

			--! low priority

		},

		--! these defenses do not require balance/equilibrium
		e = {

			--! free defenses
			"thirdeye",
			"nightsight",
			"temperance",
			"speed",
			"fangbarrier",
			"nightsight",

			--! eat defenses
			"insomnia",
			"instawake",

			--! affelixir defenses
			"levitation",
			"venom_resistance"

		}

	}

}

--! @brief Checks defenses kept against active defenses
function check(inf)
	local dchk = true

	for k, v in pairs(preserve) do
		if not lib[k] then
			e.error("No defense library entry exists for \'" .. k .. ".'")
			return
		end
		
		if not active[k] and lib[k].skill_cache then
			if inf then e.warn("Defense \'" .. k .. "\' is preserved but not active.", false, true) end
			dchk = false
		end
	end

	if dchk and inf then e.echo("All preserved defenses are active.", false, true) end

	return dchk
end

--! @brief Defines the defense database 'skill' parameter post-gmcp capture.
function build()
	for k, v in pairs(lib) do
		if v.skill then
			local stype = type(v.skill)
			if stype == "boolean" then
				v.skill_cache = true
			elseif stype == "table" then
				for i = 1, #v.skill, 2 do
					local sk = v.skill[i]
					local ab = v.skill[i+1]

					if _gmcp.has_skill(sk, ab) then
						v.skill_cache = true
						break
					else
						v.skill_cache = false
					end
				end
			else
				v.skill_cache = false
			end
		else
			v.skill_cache = false
		end
	end
end

--! todo: code function to drop unnecessary defenses that cause drain

function affelixir()
	if fs.affelixir then return end

	for i, v in ipairs({ "venom_resistance", "levitation" }) do
		local rq = lib[v].requires
		rq = rq()

		if rq and ((not active[v] and preserve[v]) or (affs.current.voyria and not fs.voyria)) then
			local act = lib[v].action
			local acts = act:gsub(" ", "_")
			if ac[acts] then act = ac[acts]() end

			if affs.current.voyria then act = ac.sip_immunity() end

			send("queue elixir " .. act)
			fs.on("affelixir", 0.5)
		end
	end
end

--! @brief Iterates over the defense priority and raises inactive, preserved defenses that require balance/equilibrium.
function defup_q()

	if active.miasma
		or active.safeguard
		or active.ward
		or active.warmth then
		active.endgame = true
	else
		active.endgame = false
	end

	draw_parry()

	if tmp.dodge then
		active.dodging = false
		active.diverting = false
	end

	if check() then return end

	for i, v in ipairs(prio.q) do
		local kdef = lib[v].kdef
		local acts = lib[v].action:gsub(" ", "_")

		if kd[acts] then
			kdef = kd[acts]()
		end

		if kdef and not active[v] and preserve[v] and lib[v].skill_cache then
			for i, v in ipairs(kdef) do
				keep(v, false)
			end
			break
		end
	end

	for i, v in ipairs(prio.q) do
		local rq = lib[v].requires
		rq = rq()

		local off = lib[v].off or "relax " .. v

		if active[v] and conserve[v] then
			nokeep(v, true)
			table.insert(prompt.q, off)
		end

		if rq and not active[v] and preserve[v] and lib[v].skill_cache then
			if o.debug then
				--! todo: debug
			end

			local act = lib[v].action
			local consm = lib[v].consumes
			local acts = act:gsub(" ", "_")
			local w = lib[v].wield
			local chan = lib[v].chan

			if ac[acts] then
				act = ac[acts]()
			end

			if cn[acts] then
				consm = cn[acts]()
			end

			if wd[acts] then
				w = wd[acts]()
			end

			if w then
				local item, side, item_two, side_two = unpack(w)
				inv.wield(item, side, item_two, side_two)
			end

			if type(act) == "string" then
				table.insert(prompt.q, act)
			elseif type(act) == "table" then
				for _, e in ipairs(act) do
					table.insert(prompt.q, e)
				end
			end

			for _, bal in ipairs(consm) do
				can.nobal(bal, true)
			end

			if o.debug then
				--! todo: debug
			end

			if chan then
				channel.attempting(v)
				break
			end

			if not (tmp.bals.balance or tmp.bals.equilibrium) then break end
		end
	end
end

--! @brief Iterates over the defense priority and raises inactive, preserved defenses that do not require balance/equilibrium.
function defup()
	if check() then return end

	for i, v in ipairs(prio.e) do
		if not lib[v].requires then
			if o.debug then
				--! todo: debug
			end
			return
		end

		local rq = lib[v].requires
		rq = rq()

		if rq and not active[v] and preserve[v] and lib[v].skill_cache then
			local act = lib[v].action
			local consm = lib[v].consumes
			local acts = act:gsub(" ", "_")

			if ac[acts] then
				act = ac[acts]()
			end

			if cn[acts] then
				consm = cn[acts]()
			end

			if type(act) == "string" then
				table.insert(prompt.d, act)
			elseif type(act) == "table" then
				for _, e in ipairs(act) do
					table.insert(prompt.d, e)
				end
			end

			for _, bal in ipairs(consm) do
				can.nobal(bal, true)
			end

			if o.debug then
				--! todo: debug
			end
		end
	end
end

--! @brief Checks parry mode and populates parry.limb.
function draw_parry()
	if tmp.parry then active.parrying = false end
	if parry.manual then return end

	local limbs = {
		"head",
		"torso",
		"left leg",
		"right leg",
		"left arm",
		"right arm"
	}

	for i, v in ipairs(limbs) do
		if not table.contains(parry.allowed, v) then
			table.remove(limbs, i)
		end
	end

	if parry.random and tmp.parry then
		local pos = math.random(1, #limbs)
		parry.limb = limbs[pos]
		e.warn("Parrying " .. parry.limb .. ".", true, false)
	elseif parry.most_damaged then
		--! todo: parry most damaged
	end

	--! todo: mode to confuse sapience
end

--! @brief Preserves the defined defense or defense set.
--! @param def Accepts a string or table as the defense or defense set to be preserved.
--! @param inf Accepts a boolean. If true, displays an echo.
function keep(def, inf)
	fs.off("queue")

	if not def then def = "defup" end

	if type(def) == "table" then
		if not def.q then
			e.error("No prompt bal/eq queue priority found in specified table.")
			return
		end
		if not def.e then
			e.error("No prompt executable queue priority found in specified table.")
			return
		end
		
		preserve = {}
		loaded = {}

		for _, d in pairs(def.q) do
			local act = lib[d].action
			local acts = act:gsub(" ", "_")
			local nodef = lib[d].nodef

			if acts then
				if nd[acts] then
					nodef = nd[acts]()
				end
			end

			preserve[d] = true
			table.insert(loaded, d)
			if nodef and lib[d].skill_cache then
				for _, nd in ipairs(nodef) do
					preserve[nd] = nil
					table.iremovekey(loaded, nd)
				end
			end
		end

		for _, d in pairs(def.e) do
			preserve[d] = true
			table.insert(loaded, d)
		end

		if inf then e.echo("<indian_red>You will now <gold>keep up <indian_red>the <gold>" .. def.name .. " <indian_red>defence set.", true, false) end
	elseif type(def) == "string" then

		if not lib[def] then
			e.error("No defense found in database called \'" .. def .. ".\'")
			return
		end

		local act = lib[def].action
		local acts = act:gsub(" ", "_")
		local nodef = lib[def].nodef

		if nd[acts] then
			nodef = nd[acts]()
		end

		if nodef and lib[def].skill_cache then
			for _, nd in ipairs(nodef) do
				preserve[nd] = nil
				table.iremovekey(loaded, nd)
			end
		end	

		preserve[def] = true
		table.insert(loaded, def)
		if inf then e.echo("<indian_red>You will now <gold>keep up <indian_red>the <gold>" .. def .. " <indian_red>defence.", true, false) end
	else
		e.error("Function defs.keep() allows only string or table input.")

		if o.debug then
			--! todo: debug
		end
	end
end

--! @brief Conserves against the drain caused by the defined defense or defense set.
--! @param def Accepts a string or table as the defense or defense set to be conserved against.
--! @param inf Accepts a boolean. If true, displays an echo.
function disallow(res, def, inf)
	fs.off("queue")

	if not def then
		for k, v in pairs(active) do
			if lib[k].drain == "mana" then
				conserve[v] = true
			end
		end	
		e.warn("<indian_red>You will now <gold>disallow <indian_red>all defenses that <gold>drain mana<indian_red>.", false, true)
		return
	end

	if type(def) == "table" then
		if not def.c then
			e.error("No conservation list found in specified table.")
			return
		end
		
		conserve = {}

		for _, d in ipairs(def.q) do
			if lib[d].drain == res then
				conserve[d] = true
			end
		end

		for _, d in ipairs(def.e) do
			if lib[d].drain == res then
				conserve[d] = true
			end
		end

		if inf then e.warn("<indian_red>You will now <gold>disallow <indian_red>all defenses in the <gold>" .. def .. " defense set that drain <gold>" .. res .. "<indian_red>.", false, true) end
	elseif type(def) == "string" then
		if not lib[def] then
			e.error("No defense found in database called \'" .. def .. ".\'")
			return
		end

		conserve[def] = true
		if inf then e.warn("<indian_red>You will now <gold>disallow <indian_red>the <gold>" .. def .. " <indian_red>defense.", false, true) end
	else
		e.error("Function defs.disallow() allows only string or table input.")

		if o.debug then
			--! todo: debug
		end
	end
end

--! @brief Stops preserving the defined defense.
--! @param def Accepts a string as the defense to no longer be preserved.
--! @param inf Accepts a boolean. If true, displays an echo.
function nokeep(def, inf)
	fs.off("queue")

	if def == "all" then
		preserve = {}
		loaded = {}
		e.echo("<gold>All defences removed <indian_red>from the <gold>preserved <indian_red>list.", true, true)
		return
	end

	if not lib[def] then
		e.error("No defense found in database called '" .. def .. ".'", true, true)
		return
	end

	preserve[def] = nil
	table.iremovekey(loaded, def)
	if inf then e.echo("<indian_red>You will no longer keep up the <gold>" .. def .. " <indian_red>defense.", true, true) end
end


--! @brief Stops conserving the drain caused by the defined defense.
--! @param def Accepts a string as the defense to no longer be conserved against.
--! @param inf Accepts a boolean. If true, displays an echo.
function allow(def, inf)
	fs.off("queue")
	if def == "all" then
		conserve = {}
		e.echo("<indian_red>Will now <gold>allow all defenses <indian_red>regardless of drain.")
		return
	end
	if not lib[def] then
		e.error("No defense found in database called '" .. def .. ".'", true, true)
		return
	end
	conserve[def] = nil
	if inf then e.echo("<indian_red>Will now allow the <gold>" .. def .. " <indian_red>defense.", true, true) end
end

--! @brief Adds a defense to the active defenses.
--! @param def Accepts a string as the defense to be added.
--! @param inf Accepts a boolean. If true, displays an echo.
--! @param deft Accepts a boolena. If true, indicates this is being added from the defense table.
function add(def, inf, deft)
	fs.release()
	if active[def] then return end

	active[def] = true
	if inf then
		if deft then
			deleteLine()
			e.def(def, false, true, true, true)
		else
			e.def(def, false, false, true, false)
		end
	end
end

--! @brief Removes a defense from the active defenses.
--! @param def Accepts a string as the defense to be removed.
--! @param inf Accepts a boolean. If true, displays an echo.
function rem(def, inf)
	fs.release(true)
	if not active[def] then return end

	active[def] = nil
	if inf then
		e.def(def, true, false, true, false)
	end
end

--! @brief Tracks status of defense-like traits.
--! @param trt Accepts a string as the trait to be tracked.
--! @param rem Accepts a boolean. If true, will remove the trait.
function traits(trt, rem)
	fs.off("queue")

	if not rem then
		if trait[trt] then return end
		trait[trt] = true
	else
		if not trait[trt] then return end
		trait[trt] = nil
	end
end

function ac.alertness() 
	if _gmcp.has_skill("alertness", "deathlore")
		and not _gmcp.has_skill("alertness", "vision") then
		return "soul alertness on"
	else
		return "alertness"
	end
end

function ac.apply_sileris()
	if o.stats.status == "living" then
		return { "apply sileris", "outc sileris" }
	elseif o.stats.status == "undead" then
		return { "squeeze bone_slice", "outc bone_slice" }
	end
end

function ac.aura_accuracy()
	return { "aura off", "aura off blessing accuracy", "aura accuracy" }
end

function ac.aura_cleansing()
	return { "aura off", "aura off blessing cleansing", "aura cleansing" }
end

function ac.aura_healing()
	return { "aura off", "aura off blessing healing", "aura healing" }
end

function ac.aura_justice()
	return { "aura off", "aura off blessing justice", "aura justice" }
end

function ac.aura_meditation()
	return { "aura off", "aura off blessing meditation", "aura meditation" }
end

function ac.aura_pestilence()
	return { "aura off", "aura off blessing pestilence", "aura pestilence" }
end

function ac.aura_protection()
	return { "aura off", "aura off blessing protection", "aura protection" }
end

function ac.aura_purity()
	return { "aura off", "aura off blessing purity", "aura purity" }
end

function ac.aura_redemption()
	return { "aura off", "aura off blessing redemption", "aura redemption" }
end

function ac.aura_spellbane()
	return { "aura off", "aura off blessing spellbane", "aura spellbane" }
end

function ac.aura_blessing_accuracy()
	local blessings = {
		"accuracy_blessing",
		"cleansing_blessing",
		"healing_blessing",
		"justice_blessing",
		"meditation_blessing",
		"pestilence_blessing",
		"protection_blessing",
		"purity_blessing",
		"redemption_blessing",
		"spellbane_blessing",
	}

	local act = { "aura blessing accuracy" }

	for i, v in ipairs(blessings) do
		if not preserve[v] and active[v] then
			table.insert(act, 1, "aura off blessing " .. v:gsub("_blessing", ""))
		end
	end

	if active.cleansing_aura then
		table.insert(act, 1, "aura off")
	end

	return act
end

function ac.aura_blessing_cleansing()
	local blessings = {
		"accuracy_blessing",
		"cleansing_blessing",
		"healing_blessing",
		"justice_blessing",
		"meditation_blessing",
		"pestilence_blessing",
		"protection_blessing",
		"purity_blessing",
		"redemption_blessing",
		"spellbane_blessing",
	}

	local act = { "aura blessing cleansing" }

	local count = 0
	for i, v in ipairs(blessings) do
		if active[v] then
			count = count + 1
		end
	end

	if count == 3 then
		for i, v in ipairs(blessings) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "aura off blessing " .. v:gsub("_blessing", ""))
				break
			end
		end
	end

	if active.cleansing_aura then
		table.insert(act, 1, "aura off")
	end

	return act
end

function ac.aura_blessing_healing()
	local blessings = {
		"accuracy_blessing",
		"cleansing_blessing",
		"healing_blessing",
		"justice_blessing",
		"meditation_blessing",
		"pestilence_blessing",
		"protection_blessing",
		"purity_blessing",
		"redemption_blessing",
		"spellbane_blessing",
	}

	local act = { "aura blessing healing" }

	local count = 0
	for i, v in ipairs(blessings) do
		if active[v] then
			count = count + 1
		end
	end

	if count == 3 then
		for i, v in ipairs(blessings) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "aura off blessing " .. v:gsub("_blessing", ""))
				break
			end
		end
	end

	if active.healing_aura then
		table.insert(act, 1, "aura off")
	end

	return act
end

function ac.aura_blessing_justice()
	local blessings = {
		"accuracy_blessing",
		"cleansing_blessing",
		"healing_blessing",
		"justice_blessing",
		"meditation_blessing",
		"pestilence_blessing",
		"protection_blessing",
		"purity_blessing",
		"redemption_blessing",
		"spellbane_blessing",
	}

	local act = { "aura blessing justice" }

	local count = 0
	for i, v in ipairs(blessings) do
		if active[v] then
			count = count + 1
		end
	end

	if count == 3 then
		for i, v in ipairs(blessings) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "aura off blessing " .. v:gsub("_blessing", ""))
				break
			end
		end
	end

	if active.justice_aura then
		table.insert(act, 1, "aura off")
	end

	return act
end

function ac.aura_blessing_meditation()
	local blessings = {
		"accuracy_blessing",
		"cleansing_blessing",
		"healing_blessing",
		"justice_blessing",
		"meditation_blessing",
		"pestilence_blessing",
		"protection_blessing",
		"purity_blessing",
		"redemption_blessing",
		"spellbane_blessing",
	}

	local act = { "aura blessing meditation" }

	local count = 0
	for i, v in ipairs(blessings) do
		if active[v] then
			count = count + 1
		end
	end

	if count == 3 then
		for i, v in ipairs(blessings) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "aura off blessing " .. v:gsub("_blessing", ""))
				break
			end
		end
	end

	if active.meditation_aura then
		table.insert(act, 1, "aura off")
	end

	return act
end

function ac.aura_blessing_pestilence()
	local blessings = {
		"accuracy_blessing",
		"cleansing_blessing",
		"healing_blessing",
		"justice_blessing",
		"meditation_blessing",
		"pestilence_blessing",
		"protection_blessing",
		"purity_blessing",
		"redemption_blessing",
		"spellbane_blessing",
	}

	local act = { "aura blessing pestilence" }

	local count = 0
	for i, v in ipairs(blessings) do
		if active[v] then
			count = count + 1
		end
	end

	if count == 3 then
		for i, v in ipairs(blessings) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "aura off blessing " .. v:gsub("_blessing", ""))
				break
			end
		end
	end

	if active.pestilence_aura then
		table.insert(act, 1, "aura off")
	end

	return act
end

function ac.aura_blessing_protection()
	local blessings = {
		"accuracy_blessing",
		"cleansing_blessing",
		"healing_blessing",
		"justice_blessing",
		"meditation_blessing",
		"pestilence_blessing",
		"protection_blessing",
		"purity_blessing",
		"redemption_blessing",
		"spellbane_blessing",
	}

	local act = { "aura blessing protection" }

	local count = 0
	for i, v in ipairs(blessings) do
		if active[v] then
			count = count + 1
		end
	end

	if count == 3 then
		for i, v in ipairs(blessings) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "aura off blessing " .. v:gsub("_blessing", ""))
				break
			end
		end
	end

	if active.protection_aura then
		table.insert(act, 1, "aura off")
	end

	return act
end

function ac.aura_blessing_purity()
	local blessings = {
		"accuracy_blessing",
		"cleansing_blessing",
		"healing_blessing",
		"justice_blessing",
		"meditation_blessing",
		"pestilence_blessing",
		"protection_blessing",
		"purity_blessing",
		"redemption_blessing",
		"spellbane_blessing",
	}

	local act = { "aura blessing purity" }

	local count = 0
	for i, v in ipairs(blessings) do
		if active[v] then
			count = count + 1
		end
	end

	if count == 3 then
		for i, v in ipairs(blessings) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "aura off blessing " .. v:gsub("_blessing", ""))
				break
			end
		end
	end

	if active.purity_aura then
		table.insert(act, 1, "aura off")
	end

	return act
end

function ac.aura_blessing_redemption()
	local blessings = {
		"accuracy_blessing",
		"cleansing_blessing",
		"healing_blessing",
		"justice_blessing",
		"meditation_blessing",
		"pestilence_blessing",
		"protection_blessing",
		"purity_blessing",
		"redemption_blessing",
		"spellbane_blessing",
	}

	local act = { "aura blessing redemption" }

	local count = 0
	for i, v in ipairs(blessings) do
		if active[v] then
			count = count + 1
		end
	end

	if count == 3 then
		for i, v in ipairs(blessings) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "aura off blessing " .. v:gsub("_blessing", ""))
				break
			end
		end
	end

	if active.redemption_aura then
		table.insert(act, 1, "aura off")
	end

	return act
end

function ac.aura_blessing_spellbane()
	local blessings = {
		"accuracy_blessing",
		"cleansing_blessing",
		"healing_blessing",
		"justice_blessing",
		"meditation_blessing",
		"pestilence_blessing",
		"protection_blessing",
		"purity_blessing",
		"redemption_blessing",
		"spellbane_blessing",
	}

	local act = { "aura blessing spellbane" }

	local count = 0
	for i, v in ipairs(blessings) do
		if active[v] then
			count = count + 1
		end
	end

	if count == 3 then
		for i, v in ipairs(blessings) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "aura off blessing " .. v:gsub("_blessing", ""))
				break
			end
		end
	end

	if active.spellbane_aura then
		table.insert(act, 1, "aura off")
	end

	return act
end

function ac.blood_affinity_minion()
	return { "blood beckon minion", "blood affinity minion" }
end

function ac.celerity()
	if o.stats.class == "shapeshifter" then
		return "endurance"
	else
		return "celerity"
	end
end

function ac.channel_air()
	if _gmcp.has_skill("simultaneity", "sciomancy") then
		return "simultaneity"
	else
		return "channel air"
	end
end

function ac.channel_earth()
	if _gmcp.has_skill("simultaneity", "sciomancy") then
		return "simultaneity"
	else
		return "channel earth"
	end
end
function ac.channel_fire()
	if _gmcp.has_skill("simultaneity", "elemancy") then
		return "simultaneity"
	else
		return "channel fire"
	end
end

function ac.channel_shadow()
	if _gmcp.has_skill("simultaneity", "sciomancy") then
		return "simultaneity"
	else
		return "channel shadow"
	end
end

function ac.channel_spirit()
	if _gmcp.has_skill("simultaneity", "elemancy") then
		return "simultaneity"
	else
		return "channel spirit"
	end
end

function ac.channel_water()
	if _gmcp.has_skill("simultaneity", "elemancy") then
		return "simultaneity"
	else
		return "channel water"
	end
end

function ac.chant_abi_de_izuto_kelo_eja()
	local step = lib.bloodmeld.step

	if step == 0 then
		return "chant abi de izuto kelo eja"
	elseif step == 1 then
		return "paint etpod on " .. tmp.target .. " with blood of " .. tmp.target
	elseif step == 2 then
		return "slit palms"
	elseif step == 3 then
		return "incise yewo into tablet"
	elseif step == 4 then
		return "infuse yewo on tablet"
	end
end

function ac.chant_nomru_fevo_kelo_abi_de_wo_ti_ye_de()
	local step = lib.shiftsoul.step

	if step == 0 then
		return "chant nomru fevo kelo abi de wo ti ye de"
	elseif step == 1 then
		return "paint yomed on me with blood of " .. tmp.target
	elseif step == 2 then
		return { "empty pipe", "put stomach_slice in emptypipe", "light pipes", "smoke stomach_slice", "outc stomach_slice", "slit palms" }
	elseif step == 3 then
		return "incise ryuo into tablet"
	elseif step == 4 then
		return "infuse ryuo on tablet"
	elseif step == 5 then
		return { "crush pineal_slice", "outc pineal_slice" }
	end
end


function ac.concentrate_blood()
	if _gmcp.has_skill("concentration", "hematurgy") then
		return "chant abi wo kelo adesda de"
	else
		return "concentrate blood"
	end
end

function ac.contemplate_yuef()
	local num = {
		"contemplate_yuef",
		"contemplate_ef_tig",
		"contemplate_rafic",
		"contemplate_jherza",
		"contemplate_yi",
		"contemplate_jhako",
		"contemplate_lgakt",
	}

	local act = { "contemplate yuef" }

	local count = 0
	for i, v in ipairs(num) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "duality", "triunity" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "numerology") then
			allowed = allowed + 1
		end
	end

	if count == 3 then
		for i, v in ipairs(num) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "forget " .. v:gsub("contemplate_", ""):gsub("f_t", "f't"))
				break
			end
		end
	end

	return act
end

function ac.contemplate_ef_tig()
	local num = {
		"contemplate_yuef",
		"contemplate_ef_tig",
		"contemplate_rafic",
		"contemplate_jherza",
		"contemplate_yi",
		"contemplate_jhako",
		"contemplate_lgakt",
	}

	local act = { "contemplate ef'tig" }

	local count = 0
	for i, v in ipairs(num) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "duality", "triunity" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "numerology") then
			allowed = allowed + 1
		end
	end

	if count == 3 then
		for i, v in ipairs(num) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "forget " .. v:gsub("contemplate_", ""):gsub("f_t", "f't"))
				break
			end
		end
	end

	return act
end
		
function ac.contemplate_rafic()
	local num = {
		"contemplate_yuef",
		"contemplate_ef_tig",
		"contemplate_rafic",
		"contemplate_jherza",
		"contemplate_yi",
		"contemplate_jhako",
		"contemplate_lgakt",
	}

	local act = { "contemplate rafic" }

	local count = 0
	for i, v in ipairs(num) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "duality", "triunity" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "numerology") then
			allowed = allowed + 1
		end
	end

	if count == 3 then
		for i, v in ipairs(num) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "forget " .. v:gsub("contemplate_", ""):gsub("f_t", "f't"))
				break
			end
		end
	end

	return act
end

function ac.contemplate_jherza()
	local num = {
		"contemplate_yuef",
		"contemplate_ef_tig",
		"contemplate_rafic",
		"contemplate_jherza",
		"contemplate_yi",
		"contemplate_jhako",
		"contemplate_lgakt",
	}

	local act = { "contemplate jherza" }

	local count = 0
	for i, v in ipairs(num) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "duality", "triunity" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "numerology") then
			allowed = allowed + 1
		end
	end

	if count == 3 then
		for i, v in ipairs(num) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "forget " .. v:gsub("contemplate_", ""):gsub("f_t", "f't"))
				break
			end
		end
	end

	return act
end

function ac.contemplate_yi()
	local num = {
		"contemplate_yuef",
		"contemplate_ef_tig",
		"contemplate_rafic",
		"contemplate_jherza",
		"contemplate_yi",
		"contemplate_jhako",
		"contemplate_lgakt",
	}

	local act = { "contemplate yi" }

	local count = 0
	for i, v in ipairs(num) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "duality", "triunity" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "numerology") then
			allowed = allowed + 1
		end
	end

	if count == 3 then
		for i, v in ipairs(num) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "forget " .. v:gsub("contemplate_", ""):gsub("f_t", "f't"))
				break
			end
		end
	end

	return act
end

function ac.contemplate_jhako()
	local num = {
		"contemplate_yuef",
		"contemplate_ef_tig",
		"contemplate_rafic",
		"contemplate_jherza",
		"contemplate_yi",
		"contemplate_jhako",
		"contemplate_lgakt",
	}

	local act = { "contemplate jhako" }

	local count = 0
	for i, v in ipairs(num) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "duality", "triunity" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "numerology") then
			allowed = allowed + 1
		end
	end

	if count == 3 then
		for i, v in ipairs(num) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "forget " .. v:gsub("contemplate_", ""):gsub("f_t", "f't"))
				break
			end
		end
	end

	return act
end

function ac.contemplate_lgakt()
	local num = {
		"contemplate_yuef",
		"contemplate_ef_tig",
		"contemplate_rafic",
		"contemplate_jherza",
		"contemplate_yi",
		"contemplate_jhako",
		"contemplate_lgakt",
	}

	local act = { "contemplate lgakt" }

	local count = 0
	for i, v in ipairs(num) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "duality", "triunity" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "numerology") then
			allowed = allowed + 1
		end
	end

	if count == 3 then
		for i, v in ipairs(num) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "forget " .. v:gsub("contemplate_", ""):gsub("f_t", "f't"))
				break
			end
		end
	end

	return act
end

function ac.deathsight()
	local skills = { "deathlore", "mentis", "necromancy", "vision" }
	local has_skill = false

	for _, e in ipairs(skills) do
		if _gmcp.has_skill("deathsight", e) then
			has_skill = true
			break
		end
	end

	if has_skill then
		return "deathsight"
	else
		if o.stats.status == "living" then
			return { "eat skullcap", "outc skullcap" }
		elseif o.stats.status == "undead" then
			return { "outc pineal_slice", "eat pineal_slice" }
		end
	end
end

function ac.dodge_melee()
	return "dodge " .. dodge.current
end

function ac.divert_melee()
	return "divert " .. dodge.current
end

function ac.earth_inscribe_rune_upon_blue()
	local runes = {
		"blue_minor",
		"gold_minor",
		"green_minor",
		"purple_minor",
		"red_minor",
		"yellow_minor"
	}

	local rune = "blue"

	for i, v in ipairs(runes) do
		if preserve[v] then
			rune = v:gsub("_minor", "")
			break
		end
	end

	return { "outc " .. rune .. "ink", "outc 2 blueink", "earth inscribe " .. rune .. " upon blue" }
end

function ac.earth_inscribe_rune_upon_gold()
	local runes = {
		"blue_minor",
		"gold_minor",
		"green_minor",
		"purple_minor",
		"red_minor",
		"yellow_minor"
	}

	local rune = "blue"

	for i, v in ipairs(runes) do
		if preserve[v] then
			rune = v:gsub("_minor", "")
			break
		end
	end

	return { "outc " .. rune .. "ink", "outc 2 goldink", "earth inscribe " .. rune .. " upon gold" }
end

function ac.earth_inscribe_rune_upon_green()
	local runes = {
		"blue_minor",
		"gold_minor",
		"green_minor",
		"purple_minor",
		"red_minor",
		"yellow_minor"
	}

	local rune = "blue"

	for i, v in ipairs(runes) do
		if preserve[v] then
			rune = v:gsub("_minor", "")
			break
		end
	end

	return { "outc " .. rune .. "ink", "outc 2 greenink", "earth inscribe " .. rune .. " upon green" }
end

function ac.earth_inscribe_rune_upon_purple()
	local runes = {
		"blue_minor",
		"gold_minor",
		"green_minor",
		"purple_minor",
		"red_minor",
		"yellow_minor"
	}

	local rune = "blue"

	for i, v in ipairs(runes) do
		if preserve[v] then
			rune = v:gsub("_minor", "")
			break
		end
	end

	return { "outc " .. rune .. "ink", "outc 2 purpleink", "earth inscribe " .. rune .. " upon purple" }
end

function ac.earth_inscribe_rune_upon_red()
	local runes = {
		"blue_minor",
		"gold_minor",
		"green_minor",
		"purple_minor",
		"red_minor",
		"yellow_minor"
	}

	local rune = "blue"

	for i, v in ipairs(runes) do
		if preserve[v] then
			rune = v:gsub("_minor", "")
			break
		end
	end

	return { "outc " .. rune .. "ink", "outc 2 redink", "earth inscribe " .. rune .. " upon red" }
end

function ac.earth_inscribe_rune_upon_yellow()
	local runes = {
		"blue_minor",
		"gold_minor",
		"green_minor",
		"purple_minor",
		"red_minor",
		"yellow_minor"
	}

	local rune = "blue"

	for i, v in ipairs(runes) do
		if preserve[v] then
			rune = v:gsub("_minor", "")
			break
		end
	end

	return { "outc " .. rune .. "ink", "outc 2 yellowink", "earth inscribe " .. rune .. " upon yellow" }
end

function ac.earth_inscribe_blue_upon_rune()
	local runes = {
		"blue_major",
		"gold_major",
		"green_major",
		"purple_major",
		"red_major",
		"yellow_major"
	}

	local rune = "blue"

	for i, v in ipairs(runes) do
		if preserve[v] then
			rune = v:gsub("_major", "")
			break
		end
	end

	return { "outc blueink", "outc 2 " .. rune .. "ink", "earth inscribe blue upon " .. rune }
end

function ac.earth_inscribe_gold_upon_rune()
	local runes = {
		"blue_major",
		"gold_major",
		"green_major",
		"purple_major",
		"red_major",
		"yellow_major"
	}

	local rune = "blue"

	for i, v in ipairs(runes) do
		if preserve[v] then
			rune = v:gsub("_major", "")
			break
		end
	end

	return { "outc goldink", "outc 2 " .. rune .. "ink", "earth inscribe gold upon " .. rune }

end

function ac.earth_inscribe_green_upon_rune()
	local runes = {
		"blue_major",
		"gold_major",
		"green_major",
		"purple_major",
		"red_major",
		"yellow_major"
	}

	local rune = "blue"

	for i, v in ipairs(runes) do
		if preserve[v] then
			rune = v:gsub("_major", "")
			break
		end
	end

	return { "outc greenink", "outc 2 " .. rune .. "ink", "earth inscribe green upon " .. rune }
end

function ac.earth_inscribe_purple_upon_rune()
	local runes = {
		"blue_major",
		"gold_major",
		"green_major",
		"purple_major",
		"red_major",
		"yellow_major"
	}

	local rune = "blue"

	for i, v in ipairs(runes) do
		if preserve[v] then
			rune = v:gsub("_major", "")
			break
		end
	end

	return { "outc purpleink", "outc 2 " .. rune .. "ink", "earth inscribe purple upon " .. rune }
end

function ac.earth_inscribe_red_upon_rune()
	local runes = {
		"blue_major",
		"gold_major",
		"green_major",
		"purple_major",
		"red_major",
		"yellow_major"
	}

	local rune = "blue"

	for i, v in ipairs(runes) do
		if preserve[v] then
			rune = v:gsub("_major", "")
			break
		end
	end

	return { "outc redink", "outc 2 " .. rune .. "ink", "earth inscribe red upon " .. rune }
end

function ac.earth_inscribe_yellow_upon_rune()
	local runes = {
		"blue_major",
		"gold_major",
		"green_major",
		"purple_major",
		"red_major",
		"yellow_major"
	}

	local rune = "blue"

	for i, v in ipairs(runes) do
		if preserve[v] then
			rune = v:gsub("_major", "")
			break
		end
	end

	return { "outc yellowink", "outc 2 " .. rune .. "ink", "earth inscribe yellow upon " .. rune }
end

function ac.eat_cohosh()
	--! todo: code toggle for insomnia versus concoctions cure
	if insomnia then
		return "insomnia"
	elseif o.stats.status == "living" then
		return { "eat cohosh", "outc cohosh" }
	elseif o.stats.status == "undead" then
		return { "eat tongue_slice", "outc tongue_slice" }
	end
end

function ac.eat_kola()
	if o.stats.status == "living" then
		return { "eat kola", "outc kola" }
	elseif o.stats.status == "undead" then
		return { "eat sulphurite_slice", "outc sulphurite_slice" }
	end
end

function ac.endgame()
	if o.stats.race == "azudim" then
		return "miasma"
	elseif o.stats.race == "idreth" then
		return "safeguard"
	elseif o.stats.race == "yeleni" then
		return "warmth"
	elseif o.stats.race == "ankyrean" then
		return "aegis"
	end
end

function ac.fling_adder_at_ground()
	if _gmcp.has_skill("imprint", "tarot") then
		return { "outc blank as adder", "fling adder at ground" }
	else
		return { "outd adder", "charge adder", "fling adder at ground" }
	end
end

function ac.fling_devil_at_ground()
	if _gmcp.has_skill("imprint", "tarot") then
		return { "outc blank as devil", "fling devil at ground" }
	else
		return { "outd devil", "charge devil", "fling devil at ground" }
	end
end

function ac.fling_eclipse_at_me()
	if _gmcp.has_skill("imprint", "tarot") then
		return { "outc blank as eclipse", "fling eclipse at me" }
	else
		return { "outd eclipse", "charge eclipse", "fling eclipse at me" }
	end
end

function ac.fling_hierophant_at_me()
	if _gmcp.has_skill("imprint", "tarot") then
		return { "outc blank as hierophant", "fling hierophant at me" }
	else
		return { "outd hierophant", "charge hierophant", "fling hierophant at me" }
	end
end

function ac.golem_twinsoul_on()
	return { "golem call", "order golem follow me", "golem twinsoul on" }
end

function ac.hide()
	if _gmcp.has_skill("veil", "corpus") then
		return "veil"
	else
		return "hide"
	end
end

function ac.howl_angry()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl angry" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_baleful()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl baleful" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_berserking()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl berserking" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_blurring()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl blurring" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_claustrophobic()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl claustrophobic" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_comforting()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl comforting" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_confusion()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl confusion" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_debilitating()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl debilitating" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_deep()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl deep" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_deranged()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl deranged" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_disruptive()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl disruptive" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_distasteful()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl distasteful" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_disturbing()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl disturbing" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_dumbing()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl dumbing" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_enfeebling()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl enfeebling" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_fearful()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl fearful" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_forceful()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl forceful" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_hypnotic()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl hypnotic" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_invigorating()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl invigorating" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_lethargic()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl lethargic" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_lulling()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl lulling" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_mind_numbing()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl mind-numbing" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_muddling()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl muddling" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_paralyzing()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl paralyzing" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_piercing()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl piercing" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_rousing()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl rousing" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_rejuvenating()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl rejuvenating" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_screeching()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl screeching" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_serenading()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl serenading" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_soothing()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl soothing" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_stomach_turning()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl stomach-turning" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end


function ac.howl_traumatic()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl traumatic" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.howl_wailing()
	local howls = {
		"howl_amnesia",
		"howl_anorexia",
		"howl_asleep",
		"howl_berserking",
		"howl_blurry_vision",
		"howl_enfeebling",
		"howl_claustrophobia",
		"howl_confusion",
		"howl_disrupted",
		"howl_endurance",
		"howl_fear",
		"howl_hallucinations",
		"howl_hatred",
		"howl_health",
		"howl_health_drain",
		"howl_hypersomnia",
		"howl_idiocy",
		"howl_lethargy",
		"howl_magic_impaired",
		"howl_mana",
		"howl_mana_drain",
		"howl_prone",
		"howl_no_deaf",
		"howl_paresis",
		"howl_plodding",
		"howl_portalbane",
		"howl_recklessness",
		"howl_sensitivity",
		"howl_serenading",
		"howl_stupidity",
		"howl_vomiting",
		"howl_weariness",
		"howl_willpower"
	}

	local to_ab = {
		["howl_amnesia"] = "traumatic",
		["howl_anorexia"] = "distasteful",
		["howl_asleep"] = "lulling",
		["howl_berserking"] = "berserking",
		["howl_blurry_vision"] = "blurring",
		["howl_enfeebling"] = "enfeebling",
		["howl_claustrophobia"] = "claustrophobic",
		["howl_confusion"] = "confusion",
		["howl_disrupted"] = "disturbing",
		["howl_endurance"] = "invigorating",
		["howl_fear"] = "fearful",
		["howl_hallucinations"] = "deranged",
		["howl_hatred"] = "angel",
		["howl_health"] = "soothing",
		["howl_health_drain"] = "wailing",
		["howl_hypersomnia"] = "hypnotic",
		["howl_idiocy"] = "dumbing",
		["howl_lethargy"] = "lethargic",
		["howl_magic_impaired"] = "muddling",
		["howl_mana"] = "comforting",
		["howl_mana_drain"] = "screeching",
		["howl_prone"] = "forceful",
		["howl_no_deaf"] = "piercing",
		["howl_paresis"] = "paralyzing",
		["howl_plodding"] = "deep",
		["howl_portalbane"] = "disruptive",
		["howl_recklessness"] = "rousing",
		["howl_sensitivity"] = "baleful",
		["howl_serenading"] = "serenading",
		["howl_stupidity"] = "mind-numbing",
		["howl_vomiting"] = "stomach-turning",
		["howl_weariness"] = "weariness",
		["howl_willpower"] = "rejuvenating"
	}

	local act = { "howl wailing" }

	local count = 0
	for i, v in ipairs(howls) do
		if active[v] then
			count = count + 1
		end
	end

	local allowed = 1
	local skills = { "dualpitch", "triplepitch" }
	for i, v in ipairs(skills) do
		if _gmcp.has_skill(v, "vocalizing") then
			allowed = allowed + 1
		end
	end

	if count == allowed then
		for i, v in ipairs(howls) do
			if not preserve[v] and active[v] then
				table.insert(act, 1, "cease " .. to_ab[v])
				break
			end
		end
		if active.attuning then table.insert(act, 1, "attuning off") end
	end

	return act
end

function ac.paint_shield_auresae()
	return { "outc goldink", "outc redink", "paint shield auresae" }
end

function ac.paint_shield_damariel()
	return { "outc goldink", "outc yellowink", "paint shield damariel" }
end

function ac.paint_shield_dhar()
	return { "outc goldink", "outc purpleink", "paint shield dhar" }
end

function ac.paint_shield_haern()
	return { "outc goldink", "outc greenink", "paint shield haern" }
end

function ac.paint_shield_lleis()
	return { "outc goldink", "outc blueink", "paint shield lleis" }
end

function ac.parry_torso()
	if _gmcp.has_skill("guarding", "tekura") then
		return "guard " .. parry.limb
	else
		return "parry " .. parry.limb
	end
end

function ac.sand_swelter_on()
	return { "sand flood", "sand swelter on" }
end

function ac.shroud()
	if o.stats.class == "carnifex" then
		return "soul shroud"
	elseif (o.stats.class == "indorani" or o.stats.class == "cabalist") then
		return "shroud"
	elseif o.stats.class == "syssin" then
		return "conjure cloak"
	end
end

function ac.sip_frost()
	if o.stats.status == "living" then
		return "sip frost"
	elseif o.stats.status == "undead" then
		return "stick refrigerative"
	end
end

function ac.sip_immunity()
	if o.stats.status == "living" then
		return "sip immunity"
	elseif o.stats.status == "undead" then
		return "stick calmative"
	end
end

function ac.sip_levitation()
	if o.stats.status == "living" then
		return "sip levitation"
	elseif o.stats.status == "undead" then
		return "stick euphoric"
	end
end

function ac.sip_speed()
	if o.stats.status == "living" then
		return "sip speed"
	elseif o.stats.status == "undead" then
		return "stick nervine"
	end
end

function ac.sip_venom()
	if o.stats.status == "living" then
		return "sip venom"
	elseif o.stats.status == "undead" then
		return "stick carminative"
	end
end

function ac.sip_vigor()
	if o.stats.status == "living" then
		return "sip vigor"
	elseif o.stats.status == "undead" then
		return "stick apocroustic"
	end
end

function ac.soulmask()
	if _gmcp.has_skill("soulmask", "deathlore") then
		return "soul mask"
	else
		return "soulmask"
	end
end

function ac.thirdeye()
	if _gmcp.has_skill("thirdeye", "vision") then
		return "thirdeye"
	else
		if o.stats.status == "living" then
			return { "outc echinacea", "eat echinacea" }
		elseif o.stats.status == "undead" then
			return { "outc spleen_slice", "eat spleen_slice" }
		end
	end
end

function ac.touch_allsight()
	return tmp.mindseye and "touch mindseye" or "touch allsight"
end

function ac.touch_shield()
	if _gmcp.has_skill("shield", "hematurgy") and active.wisp_form then
		return "wisp shield"
	elseif _gmcp.has_skill("soulshield", "deathlore") then
		return "soul shield"
	elseif _gmcp.has_skill("aura", "spirituality") then
		return "angel aura"
	elseif _gmcp.has_skill("shield", "desiccation") then
		return "sand shield"
	else
		return "touch shield"
	end
end

function ac.warding()
	if (o.stats.class == "bloodborn" or o.stats.class == "praenomen") then
		return "ward"
	elseif o.stats.class == "syssin" then
		return "warding"
	end
end

function cn.celerity()
	if o.stats.class == "shapeshifter" then
		return { "equilibrium" }
	else
		return { "balance" }
	end
end

function cn.chant_abi_de_izuto_kelo_eja()
	local step = lib.bloodmeld.step

	if step == 0 then
		return { "equilibrium" }
	elseif step == 1 then
		return { "balance" }
	elseif step == 2 then
		return { "balance" }
	elseif step == 3 then
		return { "balance" }
	elseif step == 4 then
		return { "balance" }
	end
end

function cn.chant_nomru_fevo_kelo_abi_de_wo_ti_ye_de()
	local step = lib.shiftsoul.step

	if step == 0 then
		return { "equilibrium" }
	elseif step == 1 then
		return { "balance" }
	elseif step == 2 then
		return { "balance" }
	elseif step == 3 then
		return { "balance" }
	elseif step == 4 then
		return { "balance" }
	elseif step == 5 then
		return { "balance" }
	end
end

function cn.conjure_ghost()
	if tmp.bals.primary_illusion then
		return { "primary_illusion" }
	else
		return { "secondary_illusion" }
	end
end

function cn.shroud()
	if o.stats.class == "syssin" then
		if tmp.bals.primary_illusion then
			return { "primary_illusion" }
		else
			return { "secondary_illusion" }
		end
	elseif _gmcp.has_skill("shroud", "deathlore") then
		return {}
	else
		return { "equilibrium" }
	end
end

function kd.elicit_fix()
	if _gmcp.has_skill("spheres", "numerology") then
		return {}
	else
		return { "contemplate_rafic" }
	end
end

function kd.elicit_link()
	if _gmcp.has_skill("spheres", "numerology") then
		return {}
	else
		return { "contemplate_jherza", "contemplate_yi", "contemplate_jhako" }
	end
end

function kd.elicit_constitution()
	if _gmcp.has_skill("spheres", "numerology") then
		return {}
	else
		return { "contemplate_jherza" }
	end
end

function kd.elicit_recognition()
	if _gmcp.has_skill("spheres", "numerology") then
		return {}
	else
		return { "contemplate_jherza", "contemplate_jhako" }
	end
end

function kd.elicit_veil()
	if _gmcp.has_skill("spheres", "numerology") then
		return {}
	else
		return { "contemplate_rafic", "contemplate_yi" }
	end
end

function nd.aura_accuracy()
	return {
		"accuracy_blessing",

		"cleansing_aura",
		"healing_aura",
		"justice_aura",
		"meditation_aura",
		"pestilence_aura",
		"protection_aura",
		"purity_aura",
		"redemption_aura",
		"spellbane_aura",
	}
end

function nd.aura_cleansing()
	return {
		"cleansing_blessing",

		"accuracy_aura",
		"healing_aura",
		"justice_aura",
		"meditation_aura",
		"pestilence_aura",
		"protection_aura",
		"purity_aura",
		"redemption_aura",
		"spellbane_aura",
	}
end

function nd.aura_healing()
	return {
		"healing_blessing",

		"accuracy_aura",
		"cleansing_aura",
		"justice_aura",
		"meditation_aura",
		"pestilence_aura",
		"protection_aura",
		"purity_aura",
		"redemption_aura",
		"spellbane_aura",
	}
end

function nd.aura_justice()
	return {
		"justice_blessing",

		"accuracy_aura",
		"cleansing_aura",
		"healing_aura",
		"meditation_aura",
		"pestilence_aura",
		"protection_aura",
		"purity_aura",
		"redemption_aura",
		"spellbane_aura",
	}
end

function nd.aura_meditation()
	return {
		"meditation_blessing",

		"accuracy_aura",
		"cleansing_aura",
		"healing_aura",
		"justice_aura",
		"pestilence_aura",
		"protection_aura",
		"purity_aura",
		"redemption_aura",
		"spellbane_aura",
	}
end

function nd.aura_pestilence()
	return {
		"pestilence_blessing",

		"accuracy_aura",
		"cleansing_aura",
		"healing_aura",
		"justice_aura",
		"meditation_aura",
		"protection_aura",
		"purity_aura",
		"redemption_aura",
		"spellbane_aura",
	}
end

function nd.aura_protection()
	return {
		"protection_blessing",

		"accuracy_aura",
		"cleansing_aura",
		"healing_aura",
		"justice_aura",
		"meditation_aura",
		"pestilence_aura",
		"purity_aura",
		"redemption_aura",
		"spellbane_aura",
	}
end

function nd.aura_purity()
	return {
		"purity_blessing",

		"accuracy_aura",
		"cleansing_aura",
		"healing_aura",
		"justice_aura",
		"meditation_aura",
		"pestilence_aura",
		"protection_aura",
		"redemption_aura",
		"spellbane_aura",
	}
end

function nd.aura_redemption()
	return {
		"redemption_blessing",

		"accuracy_aura",
		"cleansing_aura",
		"healing_aura",
		"justice_aura",
		"meditation_aura",
		"pestilence_aura",
		"protection_aura",
		"purity_aura",
		"spellbane_aura",
	}
end

function nd.aura_spellbane()
	return {
		"spellbane_blessing",

		"accuracy_aura",
		"cleansing_aura",
		"healing_aura",
		"justice_aura",
		"meditation_aura",
		"pestilence_aura",
		"protection_aura",
		"redemption_aura",
		"purity_aura",
	}
end

function nd.aura_blessing_accuracy()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("_blessing") then
			count = count + 1
		end
	end

	if count >= 3 then
		local down = count - 2
		for i, v in ipairs(loaded) do
			if down == 0 then
				break
			elseif v:match("_blessing") then
				table.insert(ret, v)
				down = down - 1
				if down < 0 then down = 0 end
			end
		end
	end

	if preserve.accuracy_aura then
		table.insert(ret, "accuracy_aura")
	end

	return ret
end

function nd.aura_blessing_cleansing()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("_blessing") then
			count = count + 1
		end
	end

	if count >= 3 then
		local down = count - 2
		for i, v in ipairs(loaded) do
			if v:match("_blessing") then
				table.insert(ret, v)
				down = down - 1
				if down < 0 then down = 0 end
			end

			if down == 0 then break end
		end
	end

	if preserve.cleansing_aura then
		table.insert(ret, "cleansing_aura")
	end

	return ret
end

function nd.aura_blessing_healing()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("_blessing") then
			count = count + 1
		end
	end

	if count >= 3 then
		local down = count - 2
		for i, v in ipairs(loaded) do
			if v:match("_blessing") then
				table.insert(ret, v)
				down = down - 1
				if down < 0 then down = 0 end
			end

			if down == 0 then break end
		end
	end

	if preserve.healing_aura then
		table.insert(ret, "healing_aura")
	end

	return ret
end

function nd.aura_blessing_justice()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("_blessing") then
			count = count + 1
		end
	end

	if count >= 3 then
		local down = count - 2
		for i, v in ipairs(loaded) do
			if v:match("_blessing") then
				table.insert(ret, v)
				down = down - 1
				if down < 0 then down = 0 end
			end

			if down == 0 then break end
		end
	end

	if preserve.justice_aura then
		table.insert(ret, "justice_aura")
	end

	return ret
end

function nd.aura_blesing_meditation()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("_blessing") then
			count = count + 1
		end
	end

	if count >= 3 then
		local down = count - 2
		for i, v in ipairs(loaded) do
			if v:match("_blessing") then
				table.insert(ret, v)
				down = down - 1
				if down < 0 then down = 0 end
			end

			if down == 0 then break end
		end
	end

	if preserve.meditation_aura then
		table.insert(ret, "meditation_aura")
	end

	return ret
end

function nd.aura_blessing_pestilence()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("_blessing") then
			count = count + 1
		end
	end

	if count >= 3 then
		local down = count - 2
		for i, v in ipairs(loaded) do
			if v:match("_blessing") then
				table.insert(ret, v)
				down = down - 1
				if down < 0 then down = 0 end
			end

			if down == 0 then break end
		end
	end

	if preserve.pestilence_aura then
		table.insert(ret, "pestilence_aura")
	end

	return ret
end

function nd.aura_blessing_protection()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("_blessing") then
			count = count + 1
		end
	end

	if count >= 3 then
		local down = count - 2
		for i, v in ipairs(loaded) do
			if v:match("_blessing") then
				table.insert(ret, v)
				down = down - 1
				if down < 0 then down = 0 end
			end

			if down == 0 then break end
		end
	end

	if preserve.protection_aura then
		table.insert(ret, "protection_aura")
	end

	return ret
end

function nd.aura_blessing_purity()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("_blessing") then
			count = count + 1
		end
	end

	if count >= 3 then
		local down = count - 2
		for i, v in ipairs(loaded) do
			if v:match("_blessing") then
				table.insert(ret, v)
				down = down - 1
				if down < 0 then down = 0 end
			end

			if down == 0 then break end
		end
	end

	if preserve.purity_aura then
		table.insert(ret, "purity_aura")
	end

	return ret
end

function nd.aura_blessing_redemption()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("_blessing") then
			count = count + 1
		end
	end

	if count >= 3 then
		local down = count - 2
		for i, v in ipairs(loaded) do
			if v:match("_blessing") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	if preserve.redemption_aura then
		table.insert(ret, "redemption_aura")
	end

	return ret
end

function nd.aura_blessing_spellbane()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("_blessing") then
			count = count + 1
		end
	end

	if count >= 3 then
		local down = count - 2
		for i, v in ipairs(loaded) do
			if v:match("_blessing") then
				table.insert(ret, v)
				down = down - 1
			end

			if down == 0 then break end
		end
	end

	if preserve.spellbane_aura then
		table.insert(ret, "spellbane_aura")
	end

	return ret
end

function nd.contemplate_yuef()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("contemplate_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triunity", "numerology") then
		allowed = 3
	elseif _gmcp.has_skill("duality", "numerology") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("contemplate_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.contemplate_ef_tig()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("contemplate_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triunity", "numerology") then
		allowed = 3
	elseif _gmcp.has_skill("duality", "numerology") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("contemplate_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.contemplate_rafic()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("contemplate_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triunity", "numerology") then
		allowed = 3
	elseif _gmcp.has_skill("duality", "numerology") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("contemplate_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.contemplate_jherza()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("contemplate_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triunity", "numerology") then
		allowed = 3
	elseif _gmcp.has_skill("duality", "numerology") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("contemplate_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.contemplate_yi()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("contemplate_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triunity", "numerology") then
		allowed = 3
	elseif _gmcp.has_skill("duality", "numerology") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("contemplate_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.contemplate_jhako()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("contemplate_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triunity", "numerology") then
		allowed = 3
	elseif _gmcp.has_skill("duality", "numerology") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("contemplate_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.contemplate_lgakt()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("contemplate_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triunity", "numerology") then
		allowed = 3
	elseif _gmcp.has_skill("duality", "numerology") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("contemplate_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.divert_melee()
	if not _gmcp.has_skill("reflexivediversion", "avoidance") then
		return { "dodging" }
	else
		return {}
	end
end

function nd.dodge_melee()
	if not _gmcp.has_skill("reflexivediversion", "avoidance") then
		return { "diverting" }
	else
		return {}
	end
end

function nd.howl_angry()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_baleful()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_berserking()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_blurring()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_claustrophobic()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_comforting()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_confusion()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_debilitating()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_deep()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_deranged()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_disruptive()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_distasteful()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_disturbing()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_dumbing()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_enfeebling()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_fearful()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_forceful()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_hypnotic()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_invigorating()	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_lethargic()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_lulling()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	elseif _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	end

	if count >= allowed then
		local down = count - (allowed - 1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
				if down < 0 then down = 0 end
			end

			if down == 0 then break end
		end
	end

	return ret
end

function nd.howl_mind_numbing()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_muddling()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_paralyzing()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_piercing()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_rousing()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_rejuvenating()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_screeching()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	elseif _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	end

	if count >= allowed then
		local down = count - (allowed - 1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
				if down < 0 then down = 0 end
			end

			if down == 0 then break end
		end
	end

	return ret
end

function nd.howl_serenading()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_soothing()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_stomach_turning()	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end


function nd.howl_traumatic()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function nd.howl_wailing()
	local ret = {}

	local count = 0
	for i, v in ipairs(loaded) do
		if v:match("howl_") then
			count = count + 1
		end
	end

	local allowed = 1
	if _gmcp.has_skill("triplepitch", "vocalizing") then
		allowed = 3
	elseif _gmcp.has_skill("dualpitch", "vocalizing") then
		allowed = 2
	end

	if count >= allowed then
		local down = count - (allowed-1)
		for i, v in ipairs(loaded) do
			if v:match("howl_") then
				table.insert(ret, v)
				down = down - 1
			end

			if down <= 0 then break end
		end
	end

	return ret
end

function wd.concentrate_blood()
	if o.stats.class == "bloodborn" then
		return { "shield", "left", false, "athame", "right", false }
	else
		return nil
	end
end