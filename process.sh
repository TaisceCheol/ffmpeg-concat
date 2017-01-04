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

# make directory to store concat textfile
FILELIST_PATH=/var/tmp/ffmpeg_concat/
mkdir -p $FILELIST_PATH

# sort files by name and generate filelist 
printf "file '%s'\n" $(ls $MXF_FILES) > $FILELIST_PATH/filelist.txt

# run ffmpeg checking if duration is set
if [ $DURATION -eq -1 ]
then
	time ffmpeg -y -f concat -safe 0 -i $FILELIST_PATH/filelist.txt -pix_fmt $PIX_FMT -vf yadif -c:v $VIDEO_CODEC -preset $PRESET -crf $CRF -c:a $AUDIO_CODEC -b:a $AUDIO_BITRATE -ac 2 -map 0 -loglevel error $WRITE_DIR/$NAME.mp4
else
	time ffmpeg -y -f concat -safe 0 -i $FILELIST_PATH/filelist.txt -t $DURATION -pix_fmt $PIX_FMT -vf yadif -c:v $VIDEO_CODEC -preset $PRESET -crf $CRF -c:a $AUDIO_CODEC -b:a $AUDIO_BITRATE -ac 2 -map 0 -loglevel error $WRITE_DIR/$NAME.mp4
fi

rm $FILELIST_PATH/filelist.txt