###### 
# concat video and generate MP4 surrogate, expects following VARS:
# 	READ_DIR=/video \
# 	WRITE_DIR=/video \
# 	NAME=access_copy \
# 	DURATION=-1 	\
# 	PRESET=fast 	\
# 	VIDEO_CODEC=libx264\
# 	AUDIO_CODEC=libfdk_aac \
# 	AUDIO_BITRATE=320 \
# 	PIX_FMT=yuv420p
###### 

function ffmpeg_cmd() {
	# parameters:  1 - pass number | 2 - output file
	ffmpeg -y -f concat -safe 0 -i $FILELIST_PATH -t $DURATION \
		-c:v $VIDEO_CODEC -preset $PRESET -b:v ${VIDEO_BITRATE}k -pix_fmt $PIX_FMT -vf yadif  \
		-c:a $AUDIO_CODEC -b:a ${AUDIO_BITRATE}k -ac 2  \
		-map 0 -movflags +faststart -pass $1 \
		-loglevel $LOGLEVEL -f mp4 $2
}

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
		inc_dur=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $f);
		TOTAL_MXF_DURATION=$(echo $TOTAL_MXF_DURATION + $inc_dur | bc);
	done

VIDEO_BITRATE=$( echo $IDEAL_FILE_SIZE / $TOTAL_MXF_DURATION | bc)
VIDEO_BITRATE=$( echo $VIDEO_BITRATE - $AUDIO_BITRATE | bc)

# make directory to store concat textfile
FILELIST_DIR=/var/tmp/ffmpeg_concat
mkdir -p $FILELIST_DIR
FILELIST_PATH=$FILELIST_DIR/$NAME\_filelist.txt

# sort files by name and generate filelist 
printf "file '%s'\n" $(ls $MXF_FILES) > $FILELIST_PATH

echo 'WARNING: CRF value will be ignored as video bitrate is calculated to achieve target filesize < 5GB'

# check if duration is set, if not use calculated total duration
if [ $DURATION -eq -1 ]
then
	DURATION=$TOTAL_MXF_DURATION				
fi

#ffmpeg two-pass 
time 	ffmpeg2pass 1 /dev/null && \
		ffmpeg2pass 2 $WRITE_DIR/$NAME.mp4

