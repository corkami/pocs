# JPEG/MP3 accidental polyglots (no ID3 structures)


# manual polyglots

Polyglots MP3/JPG with JPG data first or last

- MP3: pure L3 frames, no ID3 structures
- JPG: 6x2 RGB


# `pVG.jpg`


the original *JPEG gets played as MP3* file:
- [VirusTotal](https://www.virustotal.com/gui/file/bf7ae3238b7effe130fd86d6bc3cb55e17afa91a961b877ef327580d7536de60/detection)
- metadata
 - Size `98304` bytes
 - Md5 `66b2438780fe58098775eca2e8249a6c`
 - Sha-1 `5ab80370fbe9edad519b3a673ba17116dd531721`
 - Sha-256 `bf7ae3238b7effe130fd86d6bc3cb55e17afa91a961b877ef327580d7536de60`
- original github [issue](https://github.com/mpv-player/mpv/issues/3973)
 - Reproduction steps: `mpv 1468861116228.jpg --loop=yes`
 - Expected behavior: I should see a muscular girl in the JPEG file
 - Actual behavior: I hear industrial music instead
 - Workaround: Passing `--demuxer-lavf-hacks=no` seems to mitigate the issue.
 - Log file: `[ffmpeg] Probing jpeg_pipe score:6 size:2048... [ffmpeg] Probing jpeg_pipe score:6 size:4096`

It *has* appended data and it sounds like an actual (short - 810ms) song.
