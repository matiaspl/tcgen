#!/bin/bash

: ${1?"Usage: $0 FPS (i.e. 25, 29.97, 60000/1001)"}

fps=$1
#nodebug="-nostats -loglevel 0"
nodebug="-loglevel debug"
fontfile="/usr/local/Homebrew/Library/Homebrew/vendor/portable-ruby/2.3.3/lib/ruby/2.3.0/rdoc/generator/template/darkfish/fonts/SourceCodePro-Bold.ttf"

ffplay $nodebug -fs -f lavfi -i "smptehdbars=r=$fps:s=1280x720" -vf "\
	drawtext=box=1:x=(w-tw)/2: y=(2*lh):fontfile=$fontfile:text='TC\:':timecode='00\:00\:00\:00':r=$fps:fontsize=150, \
	drawtext=text=%{n}:x=(w-tw):y=h-(lh):fontfile=$fontfile:fontcolor=white:box=1:boxcolor=0x00000099[back]; \
	nullsrc=s=1280x720,drawgrid=width=32:height=32:thickness=2:color=red@0.5,crop=32*10+2:32*ceil($fps/10)+2:0:0[grid]; \
	[back][grid]overlay=0:0[back+grid]; \
	color=white:s=32x32:r=$fps[box]; \
	[back+grid][box]overlay=x='32*mod(n-1,10)':y='32*floor(mod(n-1,$fps)/10)' \
	"
