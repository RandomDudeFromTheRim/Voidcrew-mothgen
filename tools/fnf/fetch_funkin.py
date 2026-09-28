#!/usr/bin/env python3
"""
Downloads Friday Night Funkin' songs for the battle microphone into data/fnf/songs/.

The songs belong to The Funkin' Crew and can't be shipped with the game, so this pulls them for
a local server straight from their public assets repository (github.com/FunkinCrew/funkin.assets).
data/ is gitignored, so nothing downloaded here ends up in a commit.

Only the base version of each song is fetched: its chart, its metadata, Inst.ogg, and the two
singers' Voices files. That's around 150 MB for the lot.

    python3 tools/fnf/fetch_funkin.py                  every song
    python3 tools/fnf/fetch_funkin.py bopeebo fresh    just these
"""

import json
import pathlib
import shutil
import subprocess
import sys
import tempfile

REPO = "https://github.com/FunkinCrew/funkin.assets"
ROOT = pathlib.Path(__file__).resolve().parents[2]
DEST = ROOT / "data" / "fnf" / "songs"


def git(*args, cwd):
    subprocess.run(["git", *args], cwd=cwd, check=True)


def voice_names(metadata):
    characters = metadata.get("playData", {}).get("characters", {})
    names = []
    for key, fallback in (("playerVocals", "player"), ("opponentVocals", "opponent")):
        vocals = characters.get(key) or ([characters[fallback]] if characters.get(fallback) else [])
        names.extend(vocals[:1])
    return names


def main():
    wanted = set(sys.argv[1:])
    with tempfile.TemporaryDirectory() as tmp:
        clone = pathlib.Path(tmp) / "assets"
        print("Fetching the song list...")
        git("clone", "--depth", "1", "--filter=blob:none", "--sparse", REPO, str(clone), cwd=tmp)
        git("sparse-checkout", "set", "--no-cone", "/preload/data/songs/", cwd=clone)

        songs = {}
        for song_dir in sorted((clone / "preload" / "data" / "songs").iterdir()):
            song_id = song_dir.name
            chart = song_dir / f"{song_id}-chart.json"
            meta = song_dir / f"{song_id}-metadata.json"
            if not chart.exists() or not meta.exists() or (wanted and song_id not in wanted):
                continue
            songs[song_id] = (chart, meta, voice_names(json.loads(meta.read_text(encoding="utf-8"))))
        if not songs:
            print("No songs matched.")
            return

        patterns = ["/preload/data/songs/"]
        for song_id, (_, _, voices) in songs.items():
            patterns.append(f"/songs/{song_id}/Inst.ogg")
            patterns.extend(f"/songs/{song_id}/Voices-{voice}.ogg" for voice in voices)
        print(f"Fetching audio for {len(songs)} songs...")
        git("sparse-checkout", "set", "--no-cone", *patterns, cwd=clone)

        for song_id, (chart, meta, voices) in songs.items():
            audio = clone / "songs" / song_id
            if not (audio / "Inst.ogg").exists():
                print(f"  {song_id}: no Inst.ogg, skipped")
                continue
            out = DEST / song_id
            out.mkdir(parents=True, exist_ok=True)
            shutil.copy2(chart, out / chart.name)
            shutil.copy2(meta, out / meta.name)
            shutil.copy2(audio / "Inst.ogg", out / "Inst.ogg")
            for voice in voices:
                if (audio / f"Voices-{voice}.ogg").exists():
                    shutil.copy2(audio / f"Voices-{voice}.ogg", out / f"Voices-{voice}.ogg")
            print(f"  {song_id}")
    print(f"Done. Songs are in {DEST}.")


if __name__ == "__main__":
    main()
