FROM jrottenberg/ffmpeg

COPY process.sh .

RUN chmod +x process.sh

# ffmpeg parameters
ENV READ_DIR /video
ENV WRITE_DIR /video
ENV NAME access_copy
ENV DURATION -1
ENV PRESET slow
ENV CRF 19
ENV VIDEO_CODEC libx264
ENV AUDIO_CODEC aac
ENV AUDIO_BITRATE 256k
ENV PIX_FMT yuv420p

ENTRYPOINT ["/bin/bash","process.sh"]
