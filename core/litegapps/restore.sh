BASED=$BASED
CONFIG=$BASED/config
GAPPS_FILES=$BASED/files
GAPPS=$BASED/gapps
MODULES=$BASED/modules
MODULES_FILES=$BASED/modules_files
read_config(){
	getp "$1" $CONFIG
	}
for i in $GAPPS $GAPPS_FILES $MODULES $MODULES_FILES; do
[ ! -d $i ] && cdir $i
done
LIST_ARCH=`read_config restore.arch | sed "s/,/ /g"`
LIST_SDK=`read_config restore.sdk | sed "s/,/ /g"`
NAME=`read_config name`

printlog " "
printlog "        Restore $NAME"
printlog " "


NUM_6070=0
for D_ARCH in $LIST_ARCH; do
	for D_SDK in $LIST_SDK; do
		if [ -f $GAPPS_FILES/$D_ARCH/$D_SDK/$D_SDK.zip ]; then
			if [ -d $GAPPS/$D_ARCH/$D_SDK ]; then
				del $GAPPS/$D_ARCH/$D_SDK
				cdir $GAPPS/$D_ARCH/$D_SDK
			else
				cdir $GAPPS/$D_ARCH/$D_SDK
			fi
			NUM_6070=$((NUM_6070 +1 ))
			printlog "${NUM_6070}. Available •> <$GAPPS_FILES/$D_ARCH/$D_SDK/$D_SDK.zip>"
			printlog "     Extracting : $D_ARCH/$D_SDK.zip"
			unzip -o $GAPPS_FILES/$D_ARCH/$D_SDK/$D_SDK.zip -d $GAPPS/$D_ARCH/$D_SDK > /dev/null 2>&1
			if [ $? -eq 0 ]; then
				printlog "     Extrating status : Successful"
			else
				printlog "     Extrating status : Failed !!"
				printlog "     REMOVING FILES"
				del $GAPPS_FILES/$D_ARCH/$D_SDK/$D_SDK.zip
				del $GAPPS/$D_ARCH/$D_SDK
				exit 1
			fi
			printlog " "
		else
		NUM_6070=$((NUM_6070 +1 ))
		printlog "${NUM_6070}. Downloading : $D_ARCH/$D_SDK.zip"
		if [ -d $GAPPS/$D_ARCH/$D_SDK ]; then
			del $GAPPS/$D_ARCH/$D_SDK
			cdir $GAPPS/$D_ARCH/$D_SDK
		else
			cdir $GAPPS/$D_ARCH/$D_SDK
		fi
       if [ -d $GAPPS_FILES/$D_ARCH/$D_SDK ]; then
       	del $GAPPS_FILES/$D_ARCH/$D_SDK 
       	cdir $GAPPS_FILES/$D_ARCH/$D_SDK 
       else
       	cdir $GAPPS_FILES/$D_ARCH/$D_SDK 
       fi
       curl --progress-bar -L -o $GAPPS_FILES/$D_ARCH/$D_SDK/$D_SDK.zip https://sourceforge.net/projects/litegapps/files/files-server/litegapps/$D_ARCH/$D_SDK/$D_SDK.zip/download
       if [  $? -eq 0 ]; then
       	printlog "     Downloading status : Successful"
       	printlog "     File size : $(du -sh $GAPPS_FILES/$D_ARCH/$D_SDK/$D_SDK.zip | cut -f1)"
       else
       	printlog "     Downloading status : Failed"
       	printlog "     ! PLEASE CEK YOUR INTERNET CONNECTION AND RESTORE AGAIN"
       	del $GAPPS/$D_ARCH/$D_SDK
       	del $GAPPS_FILES/$D_ARCH/$D_SDK/$D_SDK.zip
       	exit 1
       fi
       unzip -o $GAPPS_FILES/$D_ARCH/$D_SDK/$D_SDK.zip -d $GAPPS/$D_ARCH/$D_SDK >/dev/null 2>&1
       if [ $? -eq 0 ]; then
       	printlog "     Unzip : $GAPPS_FILES/$D_ARCH/$D_SDK/$D_SDK.zip"
       	printlog "     unzip status : Successful"
       else
       	printlog "     Unzip : $GAPPS_FILES/$D_ARCH/$D_SDK/$D_SDK.zip"
       	printlog "     unzip status : Failed"
       	printlog "     REMOVING FILES"
       	del $GAPPS/$D_ARCH/$D_SDK
       	del $GAPPS_FILES/$D_ARCH/$D_SDK/$D_SDK.zip
       	exit 1
       fi
       
	fi
	done
done


NUM_6070=0
for D_ARCH in $LIST_ARCH; do
	for D_SDK in $LIST_SDK; do
		[ ! -d $BASED/$D_ARCH/$D_SDK ] && break
		for L_RESTORE in $(ls -1 $BASED/$D_ARCH/$D_SDK); do
			if [ -f $BASED/$D_ARCH/$D_SDK/$L_RESTORE ]; then
			F_RESTORE=$BASED/$D_ARCH/$D_SDK/$L_RESTORE
				for L_MODULES in $(cat $F_RESTORE); do
					if [ -f $MODULES/$D_ARCH/$D_SDK/$L_RESTORE/$L_MODULES.zip ]; then
						
						test ! -d $MODULES/$D_ARCH/$D_SDK/$L_RESTORE && cdir $MODULES/$D_ARCH/$D_SDK/$L_RESTORE
						test -f $MODULES/$D_ARCH/$D_SDK/$L_RESTORE/$L_MODULES.zip && del $MODULES/$D_ARCH/$D_SDK/$L_RESTORE/$L_MODULES.zip
						NUM_6070=$((NUM_6070 +1 ))
						printlog "${NUM_6070}. Available •> <$MODULES_FILES/$D_ARCH/$D_SDK/$L_RESTORE/$L_MODULES.zip>"
						printlog "     Moving : $D_ARCH/$D_SDK/$L_RESTORE/$L_MODULES.zip"
						cp -pf $MODULES_FILES/$D_ARCH/$D_SDK/$L_RESTORE/$L_MODULES.zip $MODULES/$D_ARCH/$D_SDK/$L_RESTORE
						printlog " "
					else
						NUM_6070=$((NUM_6070 +1 ))
						printlog "${NUM_6070}. Downloading : $D_ARCH/$D_SDK/$L_RESTORE/$L_MODULES.zip"
						test ! -d $MODULES/$D_ARCH/$D_SDK/$L_RESTORE && cdir $D_ARCH/$D_SDK/$L_RESTORE
						test ! -d $MODULES_FILES/$D_ARCH/$D_SDK/$L_RESTORE && cdir $MODULES_FILES/$D_ARCH/$D_SDK/$L_RESTORE
						test -f $MODULES_FILES/$D_ARCH/$D_SDK/$L_RESTORE/$L_MODULES.zip && del $MODULES_FILES/$D_ARCH/$D_SDK/$L_RESTORE/$L_MODULES.zip
       		 		#download
       		 		SERVER=https://sourceforge.net/projects/litegapps/files/addon/
       		 		curl --progress-bar -L -o $MODULES_FILES/$D_ARCH/$D_SDK/$L_RESTORE/$L_MODULES.zip $SERVER/$D_ARCH/$D_SDK/$L_RESTORE/$D_SDK.zip
       		 		if [  $? -eq 0 ]; then
       		 			printlog "     Downloading status : Successful"
       		 			printlog "     File size : $(du -sh $MODULES_FILES/$D_ARCH/$D_SDK/$L_RESTORE/$L_MODULES.zip | cut -f1)"
       	     		else
       	     			printlog "     Downloading status : Failed"
       	     			printlog "     ! PLEASE CEK YOUR INTERNET CONNECTION AND RESTORE AGAIN"
       	     			del $MODULES_FILES/$D_ARCH/$D_SDK/$L_RESTORE/$L_MODULES.zip
       	     			exit 1
       		 		fi
       		 		printlog "     Moving : $D_ARCH/$D_SDK/$L_RESTORE/$L_MODULES.zip"
       		 		cp -pf $MODULES_FILES/$D_ARCH/$D_SDK/$L_RESTORE/$L_MODULES.zip $MODULES/$D_ARCH/$D_SDK/$L_RESTORE
			 		fi
				done
			fi
		done
	done
done

