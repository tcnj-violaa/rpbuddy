#!/bin/bash

#Modify these to configure rpbuddy
BUFFER=testscript #This file contains the message you want to type
APP_NAME="Guild Wars 2" #Name of the app window we move to
MAX_MSG_SIZE=200 #Maximum size of chat/other buffer in app
INTRO="/e | " #Prepend this to each message the original gets split into
CONTINUE=" >" #Append this to each message except the last

POST_LENGTH=$(wc -c "$BUFFER" | awk '{ print $1 }')
echo $POST_LENGTH

#get length of intro and continue char to know the real max length of typeable characters
INTRO_LEN=$(echo $INTRO | wc -c)
CONT_LEN=$(echo $CONTINUE | wc -c)
ACTUAL_MAX=$(($MAX_MSG_SIZE - ($INTRO_LEN+$CONT_LEN))) 
echo $ACTUAL_MAX

#We type in order to get around excessive message ratelimiting.
#Obviously it takes longer, but that's okay.
type_out () {

	xdotool search "$APP_NAME" windowactivate --sync
	xdotool key --delay 1000 Return type --delay 150 "$1"
	xdotool key --delay 1000 Return
}



# --- SPLIT UP BUFFER AND TYPE IT ---
DEF_IFS=$IFS #store the default IFS value
IFS=$'\n' #iterate over just lines -- is it weird to change IFS for this???

NUM_LINES=$(cat "$BUFFER" | wc -l)
COUNTER=0 #We use this to determine if it's the last line and avoid spurious $CONTINUEs

TEMPBUF=""
for line in $(cat "$BUFFER")
do

	IFS=$DEF_IFS #reset; recognize spaces and iterate over words
	for word in $line 
	do
		#check if it's longer than the max
		TESTBUF="$TEMPBUF $word" #first iteration, this adds an extra space between intro and actual text
		if [ $(echo $TESTBUF | wc -c) -gt $ACTUAL_MAX ]
		then

			#clear out buffer and keep going...
			echo Typed this: "$INTRO$TEMPBUF$CONTINUE" #we'll type this out...
			type_out "$INTRO$TEMPBUF$CONTINUE"
			TEMPBUF=""

		fi

		#Add word by word
		TEMPBUF="$TEMPBUF $word"

	done
	
	COUNTER=$(( $COUNTER + 1))

	#Don't add the continue symbol on the last line?
	if [ $COUNTER -eq $NUM_LINES ]
	then
		#echo Typed this: "$INTRO$TEMPBUF"
		type_out "$INTRO$TEMPBUF"
	else
		#echo Typed this: "$INTRO$TEMPBUF$CONTINUE"
		type_out "$INTRO$TEMPBUF$CONTINUE"
	fi

	TEMPBUF=""

done
