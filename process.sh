# concat video
echo 'Compiling video with settings:'
echo 	$READ_DIR \
		$WRITE_DIR \
		$NAME \
		$DURATION \
		$PRESET \
		$CRF \
		$VIDEO_CODEC \
		$AUDIO_CODEC \
		$AUDIO_BITRATE \
		$PIX_FMT

# internal field separator
IFS=$'\n'

# glob MXF files in subdirectories, expects video folder mounted at /video
MXF_FILES=$(find $READ_DIR -type f -name '*.MXF')

printf "file '%s'\n" $MXF_FILES > $WRITE_DIR/data.txt

if [ $DURATION -eq -1 ]
then
	ffmpeg -y -f concat -safe 0 -i $WRITE_DIR/data.txt -pix_fmt $PIX_FMT -vf yadif -c:v $VIDEO_CODEC -preset $PRESET -crf $CRF -c:a $AUDIO_CODEC -b:a $AUDIO_BITRATE -ac 2 -map 0 -loglevel error $WRITE_DIR/$NAME.mp4
else
	ffmpeg -y -f concat -safe 0 -i $WRITE_DIR/data.txt -t $DURATION -pix_fmt $PIX_FMT -vf yadif -c:v $VIDEO_CODEC -preset $PRESET -crf $CRF -c:a $AUDIO_CODEC -b:a $AUDIO_BITRATE -ac 2 -map 0 -loglevel error $WRITE_DIR/$NAME.mp4
fi

rm $WRITE_DIR/data.txt