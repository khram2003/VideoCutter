#!/usr/bin/env bash
while read -r line; do
        filename="$(echo "$line" | grep -oP "^(.*?)(?= *[\d:]* -- [\d:]*)")"
        time="$(echo "$line" | grep -oP "([\d:]* -- [\d:]*)")"
        time="$(echo "$time" | sed "s/ -- / /")"
        time_array=($time)
        if ! [[ ${#time_array[@]} == 0 ]]; then
                id="$(./gdrive list -m 10000 --name-width 256 --no-header --query "'18OQH_flL1HaeIeVv0fc4WcWnUc67LK3m' in parents and name = '$filename.mp4'" | grep -oP "^([^\s]*)")"
                ./gdrive download "$id"

                if [[ ${#time_array[@]} == 2 ]]; then
                        mv "$filename.mp4" "_$filename.mp4"
                        ffmpeg -hide_banner -loglevel error -i "_$filename.mp4" -ss "${time_array[0]}" -to "${time_array[1]}" -c copy "$filename.mp4"
                        ./gdrive upload -p '1J-RuxX4b6XEKSp7--ljrDfMW1wwxBvr2' "$filename.mp4"
                        rm "_$filename.mp4"
                else
                        for i in "${!time_array[@]}"; do
                                let mod=$i%2
                                if [[ $mod == 0 ]]; then
                                        let part_=$i+1
                                        let partname=($i+2)/2
                                        ffmpeg -hide_banner -loglevel error -i "$filename.mp4" -ss "${time_array[$i]}" -to "${time_array[$part_]}" -c copy "$filename part $partname.mp4"
                                        ./gdrive upload -p '1J-RuxX4b6XEKSp7--ljrDfMW1wwxBvr2' "$filename part $partname.mp4"
                                        rm "$filename part $partname.mp4"
                                fi
                        done
                fi
                rm "$filename.mp4"
        fi
done < "$1"