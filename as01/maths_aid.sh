#!/bin/bash

echo "=============================================================="
echo "Welcome to the Maths Authoring Aid"
echo "=============================================================="
echo "Please select from one of the following options:"
echo "    (l)ist existing creations"
echo "    (p)lay an existing creation"
echo "    (d)elete an existing creation"
echo "    (c)reate a new creation"
echo "    (q)uit authoring tool"
echo ""

DIR=./jlim064_data/
if [ ! -d "$DIR" ]; then
	mkdir "$DIR" 2> /dev/null
fi


function readInput()
{
	read -p "Enter a selection [l/p/d/c/q]: " CHOICE
	
}

function confirmQuit()
{
	while true; do
		read -p "Do you want to quit the program? [y/n] " QUIT
	case $QUIT in
		[Yy]* ) echo "Program exited" && exit 0;;
		[Nn]* ) echo "Back to menu ..." && echo "" && break;;
		* ) echo "error: Invalid input. Please enter (y)es or (n)o." >&2;;
	esac
	done
}

function listCreations()
{
cd "$DIR"
count=$(ls -l | grep ^d | wc -l)	#counting number of creation directories
if [ $count == 0 ]; then
        echo "You don't have any creations to list!" >&2
else
	index=1
	for d in *; do
		echo ""$index") $d"
		let "index += 1"
	done
fi
cd ..
}

function deletion()
{
	cd "$DIR"
	count=$(ls -l | grep ^d | wc -l)	#counting number of creation directories
	if [ $count == 0 ]; then
		echo "You don't have any creations to delete!" >&2
	else
		PS3="Please enter a number of creation to delete [1-"$count"]: "
		select d in *;do test -n "$d" && break;
			echo "Invalid Selection. Re-enter the selection between [1-"$count"]" >&2; done
		while true; do	
			read -p "Do you want to delete the creation '"$d"'? [y/n] "
			case $REPLY in
				[Yy]* ) rm -r "$d"
					echo ""$d" deleted. Back to menu ..." && echo "" && break;;
				[Nn]* ) echo "Deletion cancelled. Back to menu ..." && echo "" && break;;
				* ) echo "error: Invalid input. Please enter either (y)es or (n)o." >&2
			esac
		done
	fi
	cd ..
}

function createCreations()
{
	cd "$DIR"
	while true ; do
		read -p "Please enter the name of the new creation: " NAME
		if test -d "$NAME" && true; then
			read -p ""$NAME" already exists! Do you want to overwrite it? [y/n] :"
			case $REPLY in
				[Yy]* ) rm -r "$NAME"
					mkdir "$NAME";;
				[Nn]* ) continue;;
				* ) echo "error: Invalid input. Please enter either (y)es or (n)o." >&2;;

			esac
		else
			mkdir "$NAME"
		fi
			cd "$NAME"
			while true; do
				read -p "Please enter a number to be used for the creation: " NUMBER
				re='^[0-9]+$'
				if ! [[ $NUMBER =~ $re ]] ; then
				echo "error: You must enter a number!" >&2;
				else
				# create a video based on the number entered above
				mkdir video
				echo -n "Video file being generated... please wait... "
				ffmpeg -f lavfi -i color=c=pink:s=320x240:d=3 -vf "drawtext=fontfile=/usr/share/fonts/truetype/freefont/FreeSansBold.ttf:fontsize=30: fontcolor=black:x=(w-text_w)/2:y=(h-text_h)/2:text="$NUMBER"" ./video/output.mp4 2> /dev/null 
				echo "Video file successfully created!"
				
				# records the user voice for the number the user entered
				mkdir audio
				echo "You will be given 3 seconds to record"
				read -n 1 -s -r -p "When ready, press any key to start recording... "
				ffmpeg -f alsa -i hw:0 -t 3 -acodec pcm_s16le -ar 16000 -ac 1 -y ./audio/voice.wav
				echo "Audio file successfully created!"
				# merge the video and audio files created above		
				mkdir final
				echo -n "Video and audioo files being merged... please wait... "
				ffmpeg -i ./video/output.mp4 -i ./audio/voice.wav -c:v copy -c:a aac -strict experimental ./final/FINAL.mp4 2> /dev/null
				echo "Video and audio files successfully merged!"
				
				cd ..
				break 2
				fi
			done
	done
	cd ..
}

function playCreations()
{
	cd "$DIR"
	count=$(ls -l | grep ^d | wc -l)
	if [ $count == 0 ]; then
			echo "You don't have any creations to play!" >&2
	else
		PS3="Please enter a number of creation to play [1-"$count"]: "
		select d in *;do test -n "$d" && break;
			echo "error: Invalid Selection. Please enter a number between [1-"$count"]" >&2; done
		read -p "Do you want to play the creation '"$d"'? [y/n] "
		case $REPLY in
				[Yy]* ) cd "$d"/final
				ffplay -autoexit FINAL.mp4 2> /dev/null
				cd ..
				cd ..
						echo ""$d" played. Back to menu ...";;
				[Nn]* ) echo "Play cancelled. Back to menu ...";;
		esac
	fi
	cd ..
}

while true ; do
 readInput
	case $CHOICE in
	l )
		listCreations
		read -n 1 -s -r -p "Press any key to continue..."
		echo "";;
	p )
		playCreations ;;
	d )
		deletion ;;
	c )
		createCreations ;;
	q )
		confirmQuit ;;
	* )
		echo "Please enter one of l/p/d/c/q."
		echo "";;
	esac
done

