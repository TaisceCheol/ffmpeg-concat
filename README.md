###FFMPEG Docker image for ITMA field recording videos

Extends https://github.com/jrottenberg/ffmpeg image to concatenate MXF files in supplied folder, using the two-pass method. Will create surrogate files less than 5GB in size.

The following environment variables may be set and will be passed as input variables to ffmpeg:

```bash
READ_DIR [the input directory]
WRITE_DIR [the output directory]
NAME [output filename]
DURATION [output duration, -1 for full duration]
PRESET [ffmpeg preset, default fast]
VIDEO_CODEC [default libx264]
AUDIO_CODEC [default aac]
AUDIO_BITRATE [default 256k]
PIX_FMT [default yuv420p]
```
