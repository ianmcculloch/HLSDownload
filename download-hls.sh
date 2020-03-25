#!/bin/bash
source ~/Applications/Scripts/HLSDownload/config/downVid.config
downDir="$HOME/$downPath"
echo "Download directory: $downDir"
read filename_raw url < ~/Applications/Scripts/HLSDownload/urls.txt
echo "Raw filename: $filename_raw"
echo "URL: $url"

#if [ -z $1 ]
#then
#    echo "usage: download-hls URL [name to save]"
#    exit 1
#fi

#Filename with .ts ending
echo "Welcome to the hls-downloader. Enjoy!"
echo "Filename:"
filename_ts="$filename_raw.ts"
filename_mp4="$filename_raw.mp4"
#Original filename was the second argument
#filename=${2:-"save"}.ts
#cd "$HOME"
#Check if filename exists.
if [ -f "$downDir/$filename_ts" ]
then
    echo "File ${filename_ts} already exists!"
    exit 1
fi

echo "Save file to $downDir/$filename_ts"


status="begin"
count=1
#echo "URL:"
#url= read
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
        curl -s --show-error "${line}" >> "$downDir/$filename_ts"
        status="begin"
#        echo "$count segment(s) downloaded..."
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

echo "Finished Download - Filename: $downDir/$filename_ts"
ffmpeg -i "$downDir/$filename_ts" -c copy -bsf:a aac_adtstoasc "$downDir/$filename_mp4"
rm "$downDir/$filename_ts"
#mv "$downDir/$filename_mp4" $dir
