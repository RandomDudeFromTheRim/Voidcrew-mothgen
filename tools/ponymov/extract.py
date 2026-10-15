#!/usr/bin/env python3
"""
Cuts what a pony.mov smite needs from your own copy of the episode, into data/ponymov/<episode>/.

The episodes belong to their creator and can't be shipped with the game, so a host who wants the
smites to have sound runs this on a copy they have. data/ is gitignored, so nothing cut here ends
up in a commit. Without it the smites still play, silently, acted out by the cast.

    python3 tools/ponymov/extract.py shed path/to/SHED.MOV.mp4

It writes:

* soundtrack.ogg, the episode's sound.
* subtitles.srt, if there isn't one yet: every line's timing and who says it. With faster-whisper
  installed (`pip install faster-whisper`), the words are heard off the soundtrack and filled in;
  without it they're left blank, to fill in by hand or leave out (the cast just won't talk). The
  speaker before the colon is the part saying it.

It needs ffmpeg (on your PATH, or `pip install imageio-ffmpeg`).
"""

import argparse
import pathlib
import shutil
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]

# Per episode, its lines: (start, end, speaker), seconds into the episode.
EPISODES = {
    "shed": [
        (3.9, 6.34, "applebloom"),
        (7.04, 8.62, "applebloom"),
        (9.38, 10.98, "applebloom"),
        (34.26, 37.06, "rainbow"),
        (37.46, 40.84, "spike"),
        (41.34, 42.68, "spike"),
        (43.08, 46.74, "pinkie"),
        (50.18, 52.86, "rainbow"),
        (53.62, 57.0, "fluttershy"),
        (58.2, 59.34, "fluttershy"),
        (60.58, 62.54, "rainbow"),
        (62.84, 63.24, "pinkie"),
        (65.46, 66.82, "rainbow"),
        (67.74, 70.1, "rainbow"),
        (70.9, 75.98, "fluttershy"),
        (77.56, 81.06, "announcer"),
        (82.06, 86.94, "fluttershy"),
        (88.42, 90.4, "rainbow"),
        (94.26, 98.06, "spike"),
        (100.74, 105.74, "rainbow"),
        (110.36, 116.28, "fluttershy"),
        (117.2, 118.88, "fluttershy"),
        (122.1, 125.44, "spike"),
        (134.28, 137.82, "spike"),
        (141.12, 141.54, "rainbow"),
        (141.86, 144.46, "pinkie"),
        (144.76, 149.06, "rainbow"),
        (149.44, 150.4, "pinkie"),
        (151.28, 158.68, "spike"),
        (164.58, 169.32, "fluttershy"),
        (171.2, 172.14, "spike"),
        (173.14, 174.8, "fluttershy"),
        (184.26, 186.96, "fluttershy"),
        (188.92, 192.24, "fluttershy"),
        (193.96, 202.88, "fluttershy"),
        (202.88, 206.34, "fluttershy"),
        (206.34, 207.88, "fluttershy"),
        (208.2, 216.14, "fluttershy"),
        (218.38, 221.6, "officer"),
        (222.38, 225.78, "fluttershy"),
        (246.94, 249.4, "spike"),
        (250.26, 252.74, "pinkie"),
        (254.36, 256.24, "spike"),
    ],
}


def find_ffmpeg():
    found = shutil.which("ffmpeg")
    if found:
        return found
    try:
        import imageio_ffmpeg
        return imageio_ffmpeg.get_ffmpeg_exe()
    except ImportError:
        sys.exit("ffmpeg wasn't found: install it, or `pip install imageio-ffmpeg`.")


def hear_words(soundtrack):
    """Every word heard on the soundtrack as (start, word), or None without faster-whisper."""
    try:
        from faster_whisper import WhisperModel
    except ImportError:
        return None
    import numpy
    print("hearing the words (faster-whisper; a few minutes, and a download the first time)...")
    # Decoded here rather than by faster-whisper, whose own decoding breaks on newer PyAV.
    raw = subprocess.run([find_ffmpeg(), "-loglevel", "error", "-i", str(soundtrack), "-f", "s16le", "-ac", "1", "-ar", "16000", "-"],
                         check=True, capture_output=True).stdout
    audio = numpy.frombuffer(raw, numpy.int16).astype(numpy.float32) / 32768
    model = WhisperModel("small.en", device="cpu", compute_type="int8")
    segments, _ = model.transcribe(audio, word_timestamps=True)
    return [(word.start, word.word.strip()) for segment in segments for word in segment.words]


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
    out = ROOT / "data" / "ponymov" / args.episode
    out.mkdir(parents=True, exist_ok=True)

    print("soundtrack.ogg")
    subprocess.run([find_ffmpeg(), "-loglevel", "error", "-y", "-i", str(args.video), "-vn", "-ac", "2", "-ar", "44100",
                    "-c:a", "libvorbis", "-q:a", "5", str(out / "soundtrack.ogg")], check=True)

    subtitles = out / "subtitles.srt"
    if subtitles.exists():
        print("subtitles.srt is already there, so it's left as it is.")
        return
    words = hear_words(out / "soundtrack.ogg")
    cues = []
    for index, (start, end, speaker) in enumerate(EPISODES[args.episode], 1):
        said = " ".join(word for at, word in words if start - 0.3 <= at < end) if words else ""
        cues.append(f"{index}\n{timestamp(start)} --> {timestamp(end)}\n{speaker}: {said}\n")
    subtitles.write_text("\n".join(cues), encoding="utf-8")
    print("subtitles.srt" + ("" if words else " (timings and speakers only: install faster-whisper, or fill the words in)"))


if __name__ == "__main__":
    main()
