// https://osu.ppy.sh/wiki/en/Client/File_formats/osr_%28file_format%29

#include <type/leb128.pat>
#include <std/string.pat>
#include <std/time.pat>
#include <type/time.pat>

using uLEB128 = type::uLEB128;
using string_t = std::string::SizedString<uLEB128>;
using time64_t = type::time64_t;

enum StringType : u8 {
    Empty,
    String = 0x0b
};

struct Empty {};

struct String {
    StringType flag;
    match (flag) {
        (StringType::Empty): Empty;
        (StringType::String): string_t string;
    }
};

enum GameMode : u8 {
    std   = 0,
    taiko = 1,
    ctb   = 2,
    mania = 3
};

struct Judgements_std {
    u16 judge_100;
    u16 judge_50;
    u16 judge_geki;
    u16 judge_katu;
};

struct Judgements_taiko {
    u16 judge_150;
    // no idea what these are, there's two places in the ui that seem to be zeroes though
    padding[6];
};

struct Judgements_ctb {
    u16 judge_100;
    u16 judge_small_fruits;
    u16 unknown_a; // TODO: figure out what these are
    u16 unknown_b;
};

struct Judgements_mania {
    u16 judge_100;
    u16 judge_50;
    u16 judge_max_300;
    u16 judge_200;

};

struct Judgements {
    u16 judge_300;
    match ($[0]) {
        (GameMode::std):   Judgements_std   [[inline]];
        (GameMode::taiko): Judgements_taiko [[inline]];
        (GameMode::ctb):   Judgements_ctb   [[inline]];
        (GameMode::mania): Judgements_mania [[inline]];
    }
    u16 judge_miss;
};

enum Combo : u8 {
    Normal,
    Full
};

bitfield Mod_flags {
    no_fail          : 1;
    easy            : 1;
    touch_device     : 1;
    hidden          : 1;
    hardRock        : 1;
    SuddenDeath     : 1;
    DoubleTime      : 1;
    Relax           : 1;
    HalfTime        : 1;
    Nightcore       : 1; // always with DT
    Flashlight 	    : 1;
    Autoplay        : 1;
    SpunOut         : 1;
    Relax2          : 1;
    Perfect         : 1;
    Key4            : 1;
    Key5            : 1;
    Key6            : 1;
    Key7            : 1;
    Key8            : 1;
    keyMod          : 1;
    FadeIn          : 1;
    Random          : 1;
    LastMod         : 1;
    TargetPractice  : 1; // CE only
    Key9            : 1;
    Coop            : 1;
    Key1            : 1;
    Key3            : 1;
    Key2            : 1;
    ScoreV2         : 1;
    Mirror          : 1;
};

// TODO: figure out how to use this
fn timestamp_to_date(u64 ts) {
    const u64 ticks_per_second = 10000000U; // 10_000_000
    u64 seconds = ts / ticks_per_second;

    return std::time::to_utc(seconds);
};

struct Osu {
    GameMode mode;
    u32 version;
    String beatmap_hash;
    String player;
    String replay_hash;
    Judgements judgements;
    u32 score;
    u16 max_combo;
    Combo combo_type;
    Mod_flags mods;
    String life_bar_graph;
    time64_t timestamp; // TODO: find a better way to decode this (win32 ticks)
    u32 compressed_replay_length;
    u8 compressed_replay_data[compressed_replay_length]; // LZMA
    u64 online_score_id;
    
    if (mods.TargetPractice) { double tp_hit_accuracy; }
};

Osu wu @ 0x0;