#!/bin/bash

: ${1?"Usage: $0 FPS (i.e. 25, 29.97, 60000/1001)"}

fps=$1
samplerate=48000
size=1920x1080
debug="-hide_banner"
#debug="-loglevel debug" # verbose
fontfile="UbuntuMono-R.ttf"

ffmpeg $debug -re -f lavfi -i "smptehdbars=r=$fps:s=$size" \
        -sample_rate $samplerate -channels 1 -f s16le -i <(while true; do printf '\xFF\x7F'; head -c $[samplerate*2-2] /dev/zero; done) \
        -vf "\
        drawtext=box=1:x=(w-tw)/2: y=(2*lh):fontfile=$fontfile:text='TC\:':timecode='00\:00\:00\:00':r=$fps:fontsize=150, \
        drawtext=text=%{n}:x=(w-tw):y=h-(lh):fontfile=$fontfile:fontcolor=white:box=1:boxcolor=0x00000099, \
        drawbox=width=32:height=64:x=iw/2-w/2:y=ih/2-h/2:color=red@0.5[bg]; \
        color=color=red:r=$fps:s=32x32[box];[bg][box] \
        overlay=y=H*3/4-h/2-H*cos(mod(t\,1)*2*PI)/5:x=W/2-w/2+H*sin(mod(t\,1)*2*PI)/5" \
        -map 0:v:0 -c:v libx264 -force_key_frames "expr:gte(n,n_forced*5*$fps)" -pix_fmt yuv420p -preset ultrafast -tune:v animation -b:v 1000k \
        -map 1:a:0 -ac 2 -c:a aac -b:a 100k -f flv rtmp://localhost/stream_test/tc
