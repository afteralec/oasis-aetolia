module(..., package.seeall)

-------------------------------------------------------

--! @file
--! @brief Settings module for Oasis Curing System for Aetolia.

--! @copyright Copyright 2014 Alec DuBois, all rights reserved.

--! http://oasis.interimreality.com/

--! Commented in standardized format Doxygen::Lua.

-------------------------------------------------------


sets = {
	affs = {
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
		heal = 60,
		cure_loki = 4,
		diag = 5,
		cure_count = 6,
		hid_thresh = 5,
		lock_thresh = 3
	},

	bash = {},

	defs = {
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
				"conservation",
				"consciousness",
				"kaido_regeneration",
				"boost_kaido_regeneration",
				"toughness",
				"resistance",
				"entwine",
				"gripping",
				"numerology_constitution",

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
				"shamanism_spiritsight",
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
				"armblock",
				"bodyblock",
				"evadeblock",
				"legblock",
				"pinchblock",
				"ricochet",
				"thickhide",
				"blue_major",
				"blue_minor",
				"purity_aura",
				"healing_blessing",
				"protection_blessing",
				"cleansing_blessing",
				"maingauche",
				"balancing",
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
				"elemental_fortify",
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
	},

	ks = {
		allow = {},					--! todo: populate with preferred allow sets
		route = "affliction",
		stack = 2,
		stacks = {
			asthma = {
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
			deathlore = {
				bloodburst = { act = 80 },
				chill = { act = 80 },
				disease = { act = 80 },
				distortion = { act = 90 },
				frailty = { act = 75 },
				implant = { act = 75, ven_one = "aconite", ven_two = "slike" },
				wraith = { act = 90 }
			},
			warhounds = {
				["epilepsy"] = "24990",
				["frozen"] = "31255",
				["insulation"] = "31255",
				["loki"] = "31214",
				["rupture"] = "31214",
				["shivering"] = "31255",
				["stupidity"] = "24990"
			}	
		},
		indorani = {},
		luminary = {},
		monk = {},
		praenomen = {},
		sciomancer = {},
		sentinel = {},
		shaman = {},
		shapeshifter = {},
		syssin = {
			snap = "dstab",
			sealtimer = "2.5"
		},
		templar = {},
		teradrim = {},
		zealot = {},

		weaps = {
			carnifex = {
				affliction = { "bardiche", "both" },
				limb = { "warhammer", "both" }
			},
			templar = {
				affliction = { "broadsword", "left", "broadsword", "right" },
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
		}
	}
}

prio = {
	ks = {
		ascendril = {},
		cabalist = {},
		carnifex = {
			affliction = {
				"crushed_chest",
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
				"cracked_ribs",
				"right_arm_broken",
				"left_arm_broken",
				"crushed_elbows",
				"stupidity",
				"deafness",
				"sensitivity",
				"vomiting",
				"sunlight_allergy",
				"haemophilia",
				"blindness"
			},
			limb = {},
			deathlore = {
				"wraith",
				"distortion",
				"glasslimb",
				"soulchill",
				"soul_disease",
				"implant"
			},
			warhounds = {
				"insulation",
				"shivering",
				"frozen",
				"rupture",
				"stupidity",
				"loki"
			}
		},	
		indorani = {},
		luminary = {},
		monk = {},
		praenomen = {},
		sciomancer = {},
		sentinel = {},
		shaman = {},
		shapeshifter = {},
		syssin = {
			--! todo: figure out parsing in affs based on hypnosis aff
			affliction = {
				"fitness",
				"insomnia",
				"asleep",
				"instawake",
				"voyria",
				"thin_blood",
				"camus",
				"peace",
				"paresis",
				"clumsiness",
				"weariness",
				"asthma",
				"slickness",
				"destroyed_throat",
				"anorexia",
				"indifference",
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

			hypnosis = {}
		},
		templar = {
			affliction = {
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
			}	
		},
		teradrim = {},
		zealot = {}
	},	

	bash = {},

	defs = {},

	ks = {}
}

registered = {
	ks = {
		allow = {},
		prio = {
			carnifex = {
				one = {
					affliction = {
						"crushed_chest",
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
						"cracked_ribs",
						"right_arm_broken",
						"left_arm_broken",
						"crushed_elbows",
						"stupidity",
						"deafness",
						"sensitivity",
						"vomiting",
						"sunlight_allergy",
						"haemophilia",
						"blindness"
					}
				},
				two = {
					affliction = {
						"crushed_chest",
						"fitness",
						"voyria",
						"peace",
						"paresis",
						"clumsiness",
						"weariness",
						"asthma",
						"slickness",
						"stupidity",
						"anorexia",
						"disfigurement",
						"crushed_kneecaps",
						"left_leg_broken",
						"right_leg_broken",
						"cracked_ribs",
						"right_arm_broken",
						"left_arm_broken",
						"crushed_elbows",
						"deafness",
						"sensitivity",
						"vomiting",
						"sunlight_allergy",
						"haemophilia",
						"blindness"
					}
				},
				three = {
					affliction = {
						"crushed_chest",
						"fitness",
						"voyria",
						"peace",
						"paresis",
						"clumsiness",
						"deafness",
						"sensitivity",
						"vomiting",
						"weariness",
						"asthma",
						"slickness",
						"anorexia",
						"disfigurement",
						"crushed_kneecaps",
						"left_leg_broken",
						"right_leg_broken",
						"cracked_ribs",
						"right_arm_broken",
						"left_arm_broken",
						"crushed_elbows",
						"stupidity",
						"sunlight_allergy",
						"haemophilia",
						"blindness"
					}
				},
				four = {
					affliction = {
						"crushed_chest",
						"fitness",
						"voyria",
						"peace",
						"paresis",
						"clumsiness",
						"deafness",
						"sensitivity",
						"vomiting",
						"weariness",
						"asthma",
						"slickness",
						"stupidity",
						"anorexia",
						"disfigurement",
						"crushed_kneecaps",
						"left_leg_broken",
						"right_leg_broken",
						"cracked_ribs",
						"right_arm_broken",
						"left_arm_broken",
						"crushed_elbows",
						"sunlight_allergy",
						"haemophilia",
						"blindness"
					}
				},
				five = {
					affliction = {
						"crushed_chest",
						"fitness",
						"voyria",
						"peace",
						"paresis",
						"clumsiness",
						"deafness",
						"sensitivity",
						"weariness",
						"asthma",
						"slickness",
						"stupidity",
						"anorexia",
						"disfigurement",
						"crushed_kneecaps",
						"left_leg_broken",
						"right_leg_broken",
						"cracked_ribs",
						"right_arm_broken",
						"left_arm_broken",
						"crushed_elbows",
						"vomiting",
						"sunlight_allergy",
						"haemophilia",
						"blindness"
					}
				},
				six = {
					affliction = {
						"crushed_chest",
						"fitness",
						"voyria",
						"peace",
						"paresis",
						"clumsiness",
						"deafness",
						"sensitivity",
						"weariness",
						"asthma",
						"slickness",
						"anorexia",
						"disfigurement",
						"crushed_kneecaps",
						"left_leg_broken",
						"right_leg_broken",
						"cracked_ribs",
						"right_arm_broken",
						"left_arm_broken",
						"crushed_elbows",
						"stupidity",
						"vomiting",
						"sunlight_allergy",
						"haemophilia",
						"blindness"
					}
				}
			}
		}
	}
}

function register(group, class, field, entry, save)
	local module_list = {
		"affs",
		"bash",
		"defs",
		"ks"
	}

	for _, mod in ipairs(module_list) do
		if mod == group then
			mod[class][field] = entry
			break
		end
	end

	if save then
		config[group][class][field] = entry
	end
end

function push(group, class)
end

function pull(group, class)
end

function save()
end

function load()
end