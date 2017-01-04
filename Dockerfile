FROM jrottenberg/ffmpeg

COPY process.sh .

RUN chmod +x process.sh

# ffmpeg parameters
ENV READ_DIR /video 		&& \
	WRITE_DIR /video 		&& \
	NAME access_copy 		&& \
	DURATION -1 			&& \
	PRESET slow 			&& \
	CRF 19 					&& \
	VIDEO_CODEC libx264 	&& \
	AUDIO_CODEC aac 		&& \
	AUDIO_BITRATE 256k 		&& \
	PIX_FMT yuv420p

ENTRYPOINT ["/bin/bash","process.sh"]
