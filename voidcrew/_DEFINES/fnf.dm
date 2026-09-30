// Rhythm battles (voidcrew/modules/fnf)

/// Server time in deciseconds, including how far into the current tick we are. Key presses
/// arrive mid-tick, so world.time alone would round every press to the tick.
#define FNF_NOW (world.time + world.tick_lag * TICK_USAGE_REAL / 100)

/// How far off a press can be from its note and still count, in milliseconds either side.
#define FNF_WINDOW_SICK 55
#define FNF_WINDOW_GOOD 100
#define FNF_WINDOW_BAD 140
#define FNF_WINDOW_SHIT 175

/// A long note let go this close to its end counts as held to the end, in milliseconds.
#define FNF_HOLD_GRACE 90

/// Battle states.
#define FNF_STATE_READY 0
#define FNF_STATE_COUNTDOWN 1
#define FNF_STATE_PLAYING 2
#define FNF_STATE_OVER 3

/// Health runs from 0 (the challenger on the right lost) to 100 (the opponent on the left lost).
#define FNF_HEALTH_MAX 100

/// Layout, in pixels: the strums' height above the singer's tile, how far below them notes
/// start, the gap between lanes, and the health bar's size.
#define FNF_STRUM_Y 60
#define FNF_TRAVEL_PX 150
#define FNF_LANE_GAP 22
#define FNF_BAR_WIDTH 128
#define FNF_BAR_HEIGHT 6

/// Trait source for being kept on the floor through a game over.
#define FNF_GAME_OVER_TRAIT "fnf_game_over"
/// Trait source for being locked into singing.
#define FNF_BATTLE_TRAIT "fnf_battle"
/// How far a singer's screen zooms in on the stage.
#define FNF_ZOOM 2
/// Priority of a summoned opponent's skin colour over their limbs: the lowest, so anything else
/// that recolours limbs (a hulk's green) still wins.
#define FNF_SKIN_PRIORITY 1

// Corruption+ songs (voidcrew/modules/fnf/corruption.dm).
/// The colour corruption coats things in.
#define FNF_CORRUPTION_COLOUR "#261636"
/// What corrupted hands turn.
#define FNF_CORRUPTION_HANDS "#a8102c"
/// How much of the corruption it takes to swallow one piece of the body, start to finish.
#define FNF_CORRUPTION_SPAN 0.35
/// How far a head's taken over before its face is the corruption's.
#define FNF_CORRUPTION_FACE 0.75
