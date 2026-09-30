#!/usr/bin/env python3
"""
Downloads Corruption+'s songs for the battle microphone into data/fnf/songs/.

Friday Night Funkin': Corruption+ is Carlito049's fan extension of Phantom Fear and Pincer's
Corruption mod (gamejolt.com/games/fnfcorruptionplus/793089). Its Demo 1 has three weeks: Kapi's
arcade (Wild Eyed, Claws, Growl), Skarlet Bunny's hunt (Vile Vice, Feral, Broken Wires) and Carol's
church (Lullaby, Cursed, Purification). Carlito lets its music, charts and sprites be used with
credit, but asks that the mod itself only be downloaded from GameJolt, so this fetches it from there
for a local server rather than the songs being shipped. data/ is gitignored.

Credits, as the mod gives them: Carlito049 (Corruption+), FellowDesert51 (Broken Wires), Phantom
Fear and Pincer (the original Corruption mod), PaperKitty (Kapi), Rechi (Skarlet Bunny), bb-panzu
(Carol).

The download is about 430 MB (the whole mod), of which the songs are about 90 MB.

    python3 tools/fnf/fetch_corruption_plus.py
    python3 tools/fnf/fetch_corruption_plus.py --from path/to/early-access-demo-plus.zip
    python3 tools/fnf/fetch_corruption_plus.py --from path/to/unpacked/mod/folder
"""

import json
import pathlib
import shutil
import sys
import tempfile
import urllib.request
import zipfile

GAME = 793089
ROOT = pathlib.Path(__file__).resolve().parents[2]
SONGS = ROOT / "data" / "fnf" / "songs"
WEEKS = ROOT / "data" / "fnf" / "weeks"
# GameJolt turns away Python's own user agent (403), so ask as a browser would.
USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0 Safari/537.36"


def api(path, data=None):
    request = urllib.request.Request(
        f"https://gamejolt.com/site-api/web/discover/games/{path}",
        data=json.dumps(data).encode() if data is not None else None,
        headers={"Content-Type": "application/json", "User-Agent": USER_AGENT},
    )
    with urllib.request.urlopen(request, timeout=60) as reply:
        return json.load(reply)["payload"]


def download(to):
    """The mod's zip, from GameJolt."""
    builds = api(f"overview/{GAME}").get("builds") or []
    if not builds:
        sys.exit("GameJolt lists no downloads for Corruption+.")
    url = api(f"builds/get-download-url/{builds[0]['id']}", {"forceDownload": True})["url"]
    print(f"Downloading {builds[0]['primary_file']['filename']} ({builds[0]['primary_file']['filesize'] // 1_000_000} MB)...")
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=600) as reply, open(to, "wb") as out:
        shutil.copyfileobj(reply, out)


def find_mod(folder):
    """The mod's own folder: the one whose week lists name songs it has (the game's own assets
    folder is laid out the same way, so there can be more than one)."""
    best, most = None, 0
    for weeks in folder.rglob("weeks"):
        mod = weeks.parent
        if not (mod / "data").is_dir() or not (mod / "songs").is_dir():
            continue
        songs = 0
        for week_file in weeks.glob("week*.json"):
            try:
                week = json.loads(week_file.read_text(encoding="utf-8-sig"))
            except ValueError:
                continue
            songs += sum(1 for entry in week.get("songs", []) if (mod / "songs" / entry[0] / "Inst.ogg").exists())
        if songs > most:
            best, most = mod, songs
    if not best:
        sys.exit(f"No Psych Engine mod with songs found in {folder}.")
    return best


def main():
    args = sys.argv[1:]
    source = None
    if "--from" in args:
        source = pathlib.Path(args[args.index("--from") + 1]).expanduser().resolve()
    with tempfile.TemporaryDirectory() as tmp:
        tmp = pathlib.Path(tmp)
        if source and source.is_dir():
            unpacked = source
        else:
            archive = source or tmp / "corruption_plus.zip"
            if not source:
                download(archive)
            unpacked = tmp / "mod"
            with zipfile.ZipFile(archive) as zipped:
                zipped.extractall(unpacked)
        mod = find_mod(unpacked)
        SONGS.mkdir(parents=True, exist_ok=True)
        WEEKS.mkdir(parents=True, exist_ok=True)
        weeks = sorted(p for p in (mod / "weeks").glob("*.json") if p.stem.startswith("week"))
        for number, week_file in enumerate(weeks, 1):
            week = json.loads(week_file.read_text(encoding="utf-8-sig"))
            ids = [entry[0] for entry in week.get("songs", [])]
            for song in ids:
                charts, audio = mod / "data" / song, mod / "songs" / song
                if not charts.is_dir() or not (audio / "Inst.ogg").exists():
                    print(f"  {song}: missing its chart or its audio, skipped")
                    continue
                dest = SONGS / song
                dest.mkdir(exist_ok=True)
                for chart in charts.glob("*.json"):
                    shutil.copy2(chart, dest / chart.name)
                for sound in audio.glob("*.ogg"):
                    shutil.copy2(sound, dest / sound.name)
                print(f"  {song}")
            (WEEKS / f"corruption-{number}.json").write_text(json.dumps({"name": week.get("storyName") or week_file.stem, "songs": ids}))
        print(f"Done: {SONGS}")


if __name__ == "__main__":
    main()
