#!/bin/bash
. downVid.config
dir="$downPath"
echo "$dir"
#if [ -z $1 ]
#then
#    echo "usage: download-hls URL [name to save]"
#    exit 1
#fi

#Filename with .ts ending
echo "Welcome to the hls-downloader. Enjoy!"
echo "Filename:"
filename_raw=$2
filename="$filename_raw.ts"
#Original filename was the second argument
#filename=${2:-"save"}.ts

#Check if filename exists.
if [ -f "$filename" ]
then
    echo "File ${filename} already exists!"
    exit 1
fi

echo "Save file to $filename"


status="begin"
count=1
#echo "URL:"
#url= read
url="$1"
curl "$url" > temp.m3u8
cat temp.m3u8 | \
while read line; do
    if [[ $line == \#EXTINF* ]]
    then
        status="reading"
        continue
    fi

    if [[ $status == "reading" ]]
    then
        curl -s --show-error "${line}" >> "$filename"
        status="begin"
        echo "$count segment(s) downloaded..."
        let "count += 1"
        continue
    fi

    if [[ $line == "#EXT-X-ENDLIST" ]]
    then
        status="done"
        echo "Download finished"
        rm temp.m3u8
        exit 0
    fi
done

echo "Filename: $filename"
ffmpeg -i $filename -c copy -bsf:a aac_adtstoasc "$filename_raw.mp4"
rm $filename
mv "$filename_raw.mp4" $dir
