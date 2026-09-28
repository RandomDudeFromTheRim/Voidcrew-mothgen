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
