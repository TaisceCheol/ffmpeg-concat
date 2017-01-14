FROM jrottenberg/ffmpeg

RUN apt-get update
RUN apt-get install -y bc

COPY process.sh .

RUN chmod +x process.sh

# ffmpeg parameters
ENV READ_DIR=/video \
	WRITE_DIR=/video \
	NAME=access_copy \
	DURATION=-1 	\
	PRESET=fast 	\
	VIDEO_CODEC=libx264\
	AUDIO_CODEC=libfdk_aac \
	AUDIO_BITRATE=320 \
	PIX_FMT=yuv420p

ENTRYPOINT ["/bin/bash","process.sh"]
