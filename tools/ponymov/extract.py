#!/usr/bin/env python3
"""
Cuts what a pony.mov smite needs from your own copy of the episode, into data/ponymov/<episode>/.

The episodes belong to their creator and can't be shipped with the game, so a host who wants the
smites to have sound and pictures runs this on a copy they have. data/ is gitignored, so nothing
cut here ends up in a commit. Without it the smites still play, silently, acted out by the cast.

    python3 tools/ponymov/extract.py shed path/to/SHED.MOV.mp4

It writes:

* soundtrack.ogg, the episode's sound.
* flips/<clip>.dmi, the shots shown full screen (the gross-ups, the title, the cards), each an
  animated icon.
* subtitles.srt, if there isn't one yet: every line's timing and who says it, with the words left
  out. Fill them in to have the cast say them (the speaker before the colon is the part saying it).

It needs ffmpeg (on your PATH, or `pip install imageio-ffmpeg`) and Pillow.
"""

import argparse
import math
import pathlib
import shutil
import subprocess
import sys
import tempfile

from PIL import Image, PngImagePlugin

ROOT = pathlib.Path(__file__).resolve().parents[2]

# Per episode: the flip clips as (name, start, end, frames a second), seconds into the episode,
# and the lines as (start, end, speaker).
EPISODES = {
    "shed": {
        "flips": [
            ("discord_open", 0.0, 2.54, 10),
            ("foot", 11.42, 13.67, 10),
            ("title", 13.67, 18.12, 5),
            ("spike_bah", 18.12, 22.0, 10),
            ("spike_arm", 40.5, 42.88, 5),
            ("pinkie_face", 42.88, 47.08, 10),
            ("fs_braces", 84.54, 87.17, 10),
            ("fs_crying", 105.42, 119.08, 10),
            ("shed_bucket", 128.08, 130.25, 5),
            ("pinkie_scream", 149.67, 151.75, 10),
            ("song_pelts", 175.21, 186.0, 10),
            ("fs_monster", 200.88, 206.71, 10),
            ("rd_scream", 208.62, 209.88, 10),
            ("discord_end", 257.71, 261.79, 10),
            ("end_card", 261.79, 282.17, 2),
        ],
        "lines": [
            (3.9, 6.0, "applebloom"),
            (6.0, 8.4, "applebloom"),
            (31.0, 33.0, "rainbow"),
            (33.0, 37.0, "spike"),
            (39.0, 41.0, "spike"),
            (44.5, 47.0, "pinkie"),
            (52.0, 55.0, "rainbow"),
            (55.0, 58.0, "fluttershy"),
            (58.0, 60.0, "fluttershy"),
            (63.7, 66.5, "rainbow"),
            (66.5, 67.5, "pinkie"),
            (69.0, 71.5, "rainbow"),
            (71.5, 74.0, "rainbow"),
            (74.0, 75.5, "rainbow"),
            (75.5, 81.0, "fluttershy"),
            (81.8, 84.5, "announcer"),
            (84.5, 87.1, "fluttershy"),
            (87.2, 90.5, "rainbow"),
            (94.5, 97.5, "spike"),
            (102.2, 104.0, "rainbow"),
            (104.0, 105.4, "rainbow"),
            (105.4, 119.0, "fluttershy"),
            (119.2, 125.5, "spike"),
            (134.6, 137.5, "spike"),
            (137.5, 139.0, "rainbow"),
            (139.0, 141.5, "pinkie"),
            (141.7, 146.5, "rainbow"),
            (146.5, 149.5, "pinkie"),
            (149.7, 154.0, "spike"),
            (165.0, 170.0, "fluttershy"),
            (172.2, 173.8, "spike"),
            (173.8, 175.2, "fluttershy"),
            (175.2, 193.0, "fluttershy"),
            (215.5, 218.3, "officer"),
            (221.7, 226.0, "fluttershy"),
            (246.5, 249.5, "spike"),
            (249.5, 252.5, "pinkie"),
            (252.5, 255.0, "spike"),
        ],
    },
}

# The view's 19 by 15 tiles; clips are cut to fit inside it at half size, and drawn scaled up.
MAX_WIDTH, MAX_HEIGHT = 304, 240


def find_ffmpeg():
    found = shutil.which("ffmpeg")
    if found:
        return found
    try:
        import imageio_ffmpeg
        return imageio_ffmpeg.get_ffmpeg_exe()
    except ImportError:
        sys.exit("ffmpeg wasn't found: install it, or `pip install imageio-ffmpeg`.")


def write_dmi(path, frames, fps):
    """An animated icon of one state, "clip", playing once through and holding the last frame."""
    width, height = frames[0].size
    columns = math.ceil(math.sqrt(len(frames)))
    rows = math.ceil(len(frames) / columns)
    sheet = Image.new("RGBA", (width * columns, height * rows))
    for index, frame in enumerate(frames):
        sheet.paste(frame, ((index % columns) * width, (index // columns) * height))
    delay = ",".join([f"{10 / fps:g}"] * len(frames))
    description = "\n".join([
        "# BEGIN DMI", "version = 4.0", f"\twidth = {width}", f"\theight = {height}",
        'state = "clip"', "\tdirs = 1", f"\tframes = {len(frames)}", f"\tdelay = {delay}", "\tloop = 1",
        "# END DMI", "",
    ])
    info = PngImagePlugin.PngInfo()
    info.add_text("Description", description, zip=True)
    sheet.save(path, format="PNG", pnginfo=info, optimize=True)


def timestamp(seconds):
    whole = int(seconds)
    return f"{whole // 3600:02}:{whole // 60 % 60:02}:{whole % 60:02},{round((seconds - whole) * 1000):03}"


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("episode", choices=sorted(EPISODES))
    parser.add_argument("video", type=pathlib.Path)
    args = parser.parse_args()
    if not args.video.exists():
        sys.exit(f"There's no {args.video}.")
    episode = EPISODES[args.episode]
    ffmpeg = find_ffmpeg()
    out = ROOT / "data" / "ponymov" / args.episode
    (out / "flips").mkdir(parents=True, exist_ok=True)

    print("soundtrack.ogg")
    subprocess.run([ffmpeg, "-loglevel", "error", "-y", "-i", str(args.video), "-vn", "-ac", "2", "-ar", "44100",
                    "-c:a", "libvorbis", "-q:a", "5", str(out / "soundtrack.ogg")], check=True)

    with tempfile.TemporaryDirectory() as temp:
        for name, start, end, fps in episode["flips"]:
            print(f"flips/{name}.dmi")
            frame_dir = pathlib.Path(temp) / name
            frame_dir.mkdir()
            scale = f"scale='min({MAX_WIDTH},iw*{MAX_HEIGHT}/ih)':-2"
            subprocess.run([ffmpeg, "-loglevel", "error", "-y", "-ss", str(start), "-to", str(end), "-i", str(args.video),
                            "-vf", f"fps={fps},{scale}", str(frame_dir / "%04d.png")], check=True)
            frames = [Image.open(frame).convert("RGBA") for frame in sorted(frame_dir.glob("*.png"))]
            if frames:
                write_dmi(out / "flips" / f"{name}.dmi", frames, fps)

    subtitles = out / "subtitles.srt"
    if subtitles.exists():
        print("subtitles.srt is already there, so it's left as it is.")
    else:
        print("subtitles.srt (timings and speakers only: fill the words in)")
        cues = [f"{index}\n{timestamp(start)} --> {timestamp(end)}\n{speaker}: \n"
                for index, (start, end, speaker) in enumerate(episode["lines"], 1)]
        subtitles.write_text("\n".join(cues), encoding="utf-8")


if __name__ == "__main__":
    main()
