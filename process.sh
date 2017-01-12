# concat video and generate MP4 surrogate

# set ffmpeg log-level
LOGLEVEL=error

# internal field separator
IFS=$'\n'

# glob MXF files in subdirectories, expects video folder mounted at /video
MXF_FILES=$(find $READ_DIR -type f -name '[!.]*.MXF')

# we want to produce surrogates < 5GB in size
IDEAL_FILE_SIZE=$(echo '4900 * 8192' | bc)
TOTAL_MXF_DURATION=0.0;

for f in $MXF_FILES; 
	do
		fdur=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $f);
		TOTAL_MXF_DURATION=$(echo $TOTAL_MXF_DURATION + $fdur | bc);
	done

VIDEO_BITRATE=$( echo $IDEAL_FILE_SIZE / $TOTAL_MXF_DURATION | bc)
VIDEO_BITRATE=$( echo $VIDEO_BITRATE - $AUDIO_BITRATE | bc)

# make directory to store concat textfile
FILELIST_PATH=/var/tmp/ffmpeg_concat
mkdir -p $FILELIST_PATH

# sort files by name and generate filelist 
printf "file '%s'\n" $(ls $MXF_FILES) > $FILELIST_PATH/filelist.txt

echo 'WARNING: CRF value will be ignored as video bitrate is calculated to achieve target filesize < 5GB'

# run ffmpeg, checking if duration is set
if [ $DURATION -eq -1 ]
then
	# FULL DURATION, IGNORE DURATION ENV VAR
		# first pass
	time ffmpeg -y -f concat -safe 0 -i $FILELIST_PATH/filelist.txt  \
				-c:v $VIDEO_CODEC -preset $PRESET -b:v ${VIDEO_BITRATE}k -pix_fmt $PIX_FMT -vf yadif  \
				-c:a $AUDIO_CODEC -b:a ${AUDIO_BITRATE}k -ac 2  \
				-map 0 -pass 1 \
				-loglevel $LOGLEVEL -f mp4 /dev/null && \
		# second pass
		 ffmpeg -y -f concat -safe 0 -i $FILELIST_PATH/filelist.txt  \
				-c:v $VIDEO_CODEC -preset $PRESET -b:v ${VIDEO_BITRATE}k -pix_fmt $PIX_FMT -vf yadif \
				-c:a $AUDIO_CODEC -b:a ${AUDIO_BITRATE}k -ac 2  \
				-map 0 -movflags +faststart -pass 2 \
				-loglevel $LOGLEVEL $WRITE_DIR/$NAME.mp4
else
	# USE DURATION ENV VAR
		# first pass
	time ffmpeg -y -f concat -safe 0 -i $FILELIST_PATH/filelist.txt  -t $DURATION \
				-c:v $VIDEO_CODEC -preset $PRESET -b:v ${VIDEO_BITRATE}k -pix_fmt $PIX_FMT -vf yadif  \
				-c:a $AUDIO_CODEC -b:a ${AUDIO_BITRATE}k -ac 2  \
				-map 0 -pass 1 \
				-loglevel $LOGLEVEL -f mp4 /dev/null && \
		# second pass
		  ffmpeg -y -f concat -safe 0 -i $FILELIST_PATH/filelist.txt  -t $DURATION \
				-c:v $VIDEO_CODEC -preset $PRESET -b:v ${VIDEO_BITRATE}k  -pix_fmt $PIX_FMT -vf yadif \
				-c:a $AUDIO_CODEC -b:a ${AUDIO_BITRATE}k -ac 2  \
				-map 0 -movflags +faststart -pass 2 \
				-loglevel $LOGLEVEL $WRITE_DIR/$NAME.mp4					
fi

rm $FILELIST_PATH/filelist.txt