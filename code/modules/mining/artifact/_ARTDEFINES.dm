// If you modify the number of artifacts, make sure to change these!!!
#define FIRST		0
#define LAST		21

// BEGIN DEFINING TYPES
	// TINY
#define A_GIZMO		0
#define A_GPS		1
#define A_TSPORTER	2
#define A_SPHERE	3
#define A_DEVICE	4
#define A_RING		5
	// MEDIUM
#define A_ROD		6
#define A_BOX		7
#define A_TOME		8
#define A_TOTEM		9
#define A_GUN		10
#define A_INJECTOR	11
	// HUGE
#define A_STAFF		12
#define A_CUTTER	13
#define A_RENDER	14
#define A_ARMOR		15
#define A_HAMMER	16
	// STATIONARY
#define A_PROBE		17
#define A_PYRAMID	18
#define A_MACHINE	19
#define A_CRYSTAL	20
#define A_CELL		21

// BEGIN DEFINING POWERS
// Generally try to keep the powers restricted by size, although some can go either way - for instance, large artifacts could use
// stationary powers and vice versa. Just make sure the code supports it.
	// Stationary powers
#define A_SHIELD	0 // Creates a square of forcewalls around the artifact.
#define A_PUSH		1 // Pushes things away.
#define A_PULL		2 // Pulls things towards it.
#define A_SLEEP		3 // Puts mobs around it to sleep.
#define A_HEAL		4 // Heals nearby mobs.
#define A_SEAL		5 // Turns space into floors, repairs broken tiles, and restores air around it.
#define A_EXPLODE	6 // Explodes within thirty seconds of activation, if it is not deactivated before then.
#define A_SLIME		7 // Slowly turns people around it into slimes.
#define A_FIRE		8 // Spawns a bunch of fire all over the place.
#define A_PARTY		9 // Rave time! Might have a few intoxicating effects as well...
#define A_MONOLITH	10 // The artifact begins to glow. If not deactivated, soon after it will turn into a monolith.
#define A_XTINGUISH	11 // The opposite of A_FIRE. Puts out nearby fires and cools down the area.
#define A_NIGHTMARE	12 // Causes hallucinations and brain damage around where the artifact is located.
#define A_MUTATE	13 // People around it gain and lose random mutations.
#define A_ELECTRIC  14 // Electrocutes nearby mobs and sends them flying.
	// Tiny item powers
#define A_DETECT	15 // Detects nearby artifacts.
#define A_BLINK		16 // Randomly teleports the user a few tiles away.
#define A_PHASE		17 // Allows you to walk through windows and grilles.
#define A_MAGIC		18 // Creates a neutral shadow creature nearby that drains sanity.
#define A_CLOAK		19 // The holder turns invisible, similar to the cloaking device.
#define A_INJECT	20 // Works like the hypospray. Injects people with 5-15 units of a random chemical.
#define A_THERMAL 	21 // The artifact changes your temperature based on its own temperature.
#define A_CLEAN		22 // The janitor's friend! Cleans the surrounding area.
#define A_DIRTY		23 // The janitor's enemy. Spews a bunch of dirt and grime everywhere.
#define A_LUBE		24 // Just keep it away from the clown.
#define A_LIGHT		25 // Creates a magical light that follows you around.
#define A_RECHARGE	26 // Instantly recharge all nearby electronics, including borgs and APCs.
#define A_LOCATE	27 // Acts as a radar, detecting nearby crewmembers.
#define A_FORCEWALL	28 // Creates a single forcewall.
#define A_BREATH	29 // Allows you to breathe without breathing. Pretty nifty.
#define A_PLANT		30 // Causes various flora to appear. Plants will grow inside of soil and trays, and mushrooms may appear.
#define A_ELECTRICS 31 // Smaller version of the stationary one. Doesn't deal damage, but causes stun and small knockback.
#define A_EMPS		32 // Creates a small EMP.
	// Medium and huge item powers
#define A_IRRADIATE	33 // I don't feel so good... Irradiates a small area around it.
#define A_SURGERY	34 // A surgical multitool! Can be used for pretty much anything.
#define A_REPAIR	35 // Heals cyborgs and people with robotic limbs.
#define A_DECLONE	36 // Deals 5-25 clone damage, extremely dangerous -- chance of fun, other things happening as well!
#define A_MINING	37 // Cuts through asteroid tiles like butter.
#define A_HONK		38 // OH GOD WHY???
#define A_FORCEPORT	39 // Blinks the contents of a tile.
#define A_SAPLIFE	40 // Steals the hit person's health
#define A_BLOB		41 // Creates green goo on the tile, which turns into a blob node slightly after.
#define A_VIRUS		42 // Contains infectuous viruses.
#define A_PINKSLIME	43 // Causes slimes to become friendly!
#define A_CLONEMKY	44 // Resurrects dead monkeys. Helpful for xenobiology!
#define A_REFLECT	46 // Causes projectiles to bounce off of the wearer.
#define A_TELEPORT	47 // Teleport to a specific tile.
#define A_WORMHOLE	48 // Creates wormholes around the selected tile.
#define A_SMOKE		49 // Creates a cloud of smoke - intensity is pre-determined. Sometimes has random chems in it.
#define A_SHOCKER	50 // Touching it results in a shock if you aren't insulated. Getting hit by it does the same.
#define A_DEMOLISH	51 // Explodes turfs in a small radius around it. Does not damage humans.
#define A_MELEE		52 // A melee weapon with random damage and random damage type. (Cannot deal clone or brain damage.)
#define A_PROJ		53 // Fires a randomly-determined projejctile. Requires no ammo, but has a cooldown. Potentially quite deadly.
#define A_MAGICPROJ	54 // Fires a random magic projectile. Zany!
#define A_TRAVEL	55 // Allows you to phase into another Z-level.

// BEGIN DEFINING STIMULI
#define A_FORCE		0 // Hit the artifact with an object with a force from 10-24.
#define A_SHOCK		1 // The artifact must recieve electricity.
#define A_RADS		2 // Must recieve a certain amount of radiation to activate.
#define A_HEAT		3 // Heat the artifact to a certain temperature to activate it.
#define A_EMP		4 // The artifact only activates if it's hit by an EMP blast.
#define A_EXPLODE	5 // The artifact will trigger when it gets hit by an explosion of a certain power.

// BEGIN DEFINING USE TYPES
#define A_CLICK		0 // Click on the item while it's in your hand
#define A_TOUCH		1 // Touching the item, as any type of mob (except ghost)
#define A_TOUCH_H	2 // Touching the item as a human
#define A_TOUCH_C	3 // Touching the item as a carbon
#define A_TOUCH_S	4 // Touching the item as a robot
#define A_CONSTANT	5 // The item uses its ability persistently as long as it's activated
#define A_TILE		6 // Click on a tile with the item in-hand
#define A_TILE_A	7 // Adjacent tiles.
#define A_RETALIATE	8 // Upon getting hit, the artifact's power will activate.
#define A_ATTACK	9 // Uses power after hitting something.