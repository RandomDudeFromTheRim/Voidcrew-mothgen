// Box2D physics for the limb rig (voidcrew/modules/limb_rig/physics/).

/// Pixels to a metre. A human-sized body comes out about 1.8 metres tall.
#define LIMB_PHYSICS_PPM 20
/// Every physics step is exactly this long, in seconds, whatever the server's doing: the
/// simulation only depends on how many steps it's taken, never on how long they took.
#define LIMB_PHYSICS_DT (1 / 60)
/// Steps taken each time the subsystem fires (every decisecond): a tenth of a second's worth.
#define LIMB_PHYSICS_STEPS_PER_FIRE 6
#define LIMB_PHYSICS_VELOCITY_ITERATIONS 8
#define LIMB_PHYSICS_POSITION_ITERATIONS 3
/// Earth's.
#define LIMB_PHYSICS_GRAVITY -9.8
/// The collision group a ragdoll's pieces share. Negative, so they never collide with each other,
/// only with the floor and walls.
#define LIMB_PHYSICS_RAGDOLL_GROUP -1
/// Box2D body types.
#define LIMB_PHYSICS_STATIC 0
#define LIMB_PHYSICS_DYNAMIC 2
/// How high a human's hand is, where held items are drawn from (as the sprite rig has it).
#define LIMB_PHYSICS_HUMAN_HAND_Y 12.5
/// The trait source Serverblight holds its victim still with.
#define SERVERBLIGHT_TRAIT "serverblight"
