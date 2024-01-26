#################################################
#litegapps functions
#################################################
BASED=$BASED
CONFIG=$BASED/config
read_config(){
	getp "$1" $CONFIG
	}
make_flashable_litegapps(){
	for WFL in MAGISK RECOVERY AUTO; do
		printlog "- Build flashable [$WFL]"
		cdir $tmp/$WFL
		copy_binary_flashable $BIN_ARCH $tmp/$WFL/bin/$BIN_ARCH
			# copy core/utils/magisk or kopi installer
			for W in 27-litegapps.sh litegapps-functions litegapps-post-fs litegapps; do
				if [ -f $base/core/utils/$W ]; then
					cp -pf $base/core/utils/$W $tmp/$WFL/bin/
				else
					ERROR "utils <$base/core/utils/$W> not found"
				fi
			done
			
			# Customize.sh
			if [ -f $base/core/utils/customize.sh ]; then
				cp -pf $base/core/utils/customize.sh $tmp/$WFL/
			else
				ERROR "Customize.sh <$base/core/utils/customize.sh> not found"
			fi
			# LICENSE
			if [ -f $base/core/utils/LICENSE ]; then
				cp -pf $base/core/utils/LICENSE $tmp/$WFL/
			else
				ERROR "LICENSE <$base/core/utils/LICENSE> not found"
			fi
			# copy core/utils files
			for W in README.md; do
				if [ -f $BASED/utils/$W ]; then
				cp $BASED/utils/$W $tmp/$WFL/
				else
				ERROR "magisk files <$BASED/utils/$W> not found"
				fi
			done
		case $WFL in
			MAGISK)
				cp -af $base/core/utils/magisk/* $tmp/$WFL/
			;;
			RECOVERY)
				cp -af $base/core/utils/kopi/* $tmp/$WFL/
				#kopi mode install kopi (recovery)
				SED "$(getp typeinstall $tmp/$WFL/module.prop)" "kopi" $tmp/$WFL/module.prop
			;;
			AUTO)
				cp -af $base/core/utils/kopi/* $tmp/$WFL/
			;;
		esac
		# copy file.tar.(type archive) in tmp
		cdir $tmp/$WFL/files
		if [ $(get_config litegapps.tar) = "multi" ] && [ -f $tmpfiles/files.tar.$(get_config compression) ]; then
		cp -pf $tmpfiles/files.tar.$(get_config compression) $tmp/$WFL/files/
		else
		cp -pf $tmp/files.tar.$(get_config compression) $tmp/$WFL/files
		
		fi
		# add modules files
		if [ $(read_config modules) = true ]; then
			test ! -d $tmp/$WFL/modules && cdir $tmp/$WFL/modules
			if [ -d $BASED/modules/$W_ARCH/$W_SDK ]; then
				cp -af $BASED/modules/$W_ARCH/$W_SDK/* $tmp/$WFL/modules/
			else
				printlog "[ERROR] <$BASED/modules/$W_ARCH/$W_SDK> not found"
				sleep 3s
				continue
			fi
		else
			print "# Modules is disable"
		fi
			
		local MODULE_PROP=$tmp/$WFL/module.prop
		local MODULE_DESC=`read_config desc`
		local MODULE_UPDATE=https://raw.githubusercontent.com/litegapps/updater/main/core/litegapps/$VARIANT/${W_ARCH}/${W_SDK}/$WFL/update.json
		SED "$(getp litegapps_type $MODULE_PROP)" "litegapps_regular" $MODULE_PROP
		SED "$(getp litegapps_apk_compress $MODULE_PROP)" "${apk_compessed_type}" $MODULE_PROP
		SED "$(getp litegapps_apk_compress_level $MODULE_PROP)" "$litegapps_apk_compress_level" $MODULE_PROP
		SED "$(getp name $MODULE_PROP)" "$NAME $W_ARCH $(get_android_version $W_SDK) $PROP_STATUS" $MODULE_PROP
		SED "$(getp id $MODULE_PROP)" "litegapps" $MODULE_PROP
		SED "$(getp author $MODULE_PROP)" "$PROP_BUILDER" $MODULE_PROP
		SED "$(getp version $MODULE_PROP)" "v${PROP_VERSION}" $MODULE_PROP
		SED "$(getp versionCode $MODULE_PROP)" "$PROP_VERSIONCODE" $MODULE_PROP
		SED "$(getp date $MODULE_PROP)" "$(date +%d-%m-%Y)" $MODULE_PROP
		SED "$(getp description $MODULE_PROP)" "$MODULE_DESC" $MODULE_PROP
		sed -i 's,'"$(getp updateJson $MODULE_PROP)"','"${MODULE_UPDATE}"',g' $MODULE_PROP
		
		#set time stamp
		set_time_stamp $tmp/$WFL
			
		local NAME_ZIP="${WFL}-$PRODUCT-$VARIANT-${W_ARCH}-$(get_android_version $W_SDK)-$(date +%Y%m%d)-${PROP_STATUS}.zip"
		local OUT_ZIP=$out/litegapps/$W_ARCH/$W_SDK/$(read_config dir_name)/$(date +%Y-%m-%d)/$NAME_ZIP
		make_zip $tmp/$WFL $OUT_ZIP
	done
	}

#################################################
#Core
#################################################
if [ $ARCH_IN == $ARCH_IN ]; then
CONFIG_ARCH=$ARCH_IN
else
CONFIG_ARCH=`read_config arch | sed "s/,/ /g"`
fi
if [ $SDK_IN == $SDK_IN ]; then
CONFIG_SDK=$SDK_IN
else
CONFIG_SDK=`read_config sdk | sed "s/,/ /g"`
fi

if [ $PRODUCT = $PRODUCT ]; then
NAME=$PRODUCT
else
NAME=`read_config name`
fi

if [ $VARIANT = $VARIANT ]; then
VARIANT=$VARIANT
else
VARIANT=`read_config dir_name`
fi

for W_ARCH in $CONFIG_ARCH; do
	#binary copy architecture type
	BIN_ARCH=$W_ARCH
	for W_SDK in $CONFIG_SDK; do
		sedlog "Building $NAME"
		printmid "Building $NAME"
		printlog " "
		printlog "Version : $PROP_VERSION (${PROP_VERSIONCODE})"
		printlog "Builder : $PROP_BUILDER"
		printlog "Status  : $PROP_STATUS"
		printlog "Variant : $VARIANT"
		printlog "Compressions : $PROP_COMPRESSION"
		printlog "Compressions Level : $PROP_COMPRESSION_LEVEL"
		printlog "Architecture : $W_ARCH"
		printlog "SDK : $W_SDK"
		printlog "Android Target : $(get_android_version $W_SDK)"
		printlog " "
		[ -d $tmp ] && del $tmp && cdir $tmp || cdir $tmp
		#copying gapps
		tmpfiles=$base/tmp_files/litegapps/$W_ARCH/$W_SDK
		
		if [ $(get_config litegapps.tar) = "multi" ] && [ -f $tmpfiles/files.tar.$(get_config compression) ]; then
		printlog "- Skipping copying gapps files"
		elif [ -d $BASED/gapps/$W_ARCH/$W_SDK ]; then
			test ! -d $tmp/$W_ARCH/$W_SDK && cdir $tmp/$W_ARCH/$W_SDK
			cp -af $BASED/gapps/$W_ARCH/$W_SDK/* $tmp/$W_ARCH/$W_SDK/
		else
			printlog "[ERROR] <$BASED/gapps/$W_ARCH/$W_SDK> not found"
			sleep 3s
			continue
		fi
		
		if [ $(get_config litegapps.tar) = "multi" ] && [ ! -f $tmpfiles/files.tar.$(get_config compression) ]; then
		printlog "- make archive files.tar <multi config is active>"
		make_tar_arch
		make_archive
		cdir $tmpfiles
		cp -pf $tmp/files.tar.$(get_config compression) $tmpfiles/
		elif [ $(get_config litegapps.tar) = "multi" ] && [ -f $tmpfiles/files.tar.$(get_config compression) ]; then
		printlog "- Skipping make archive files.tar <multi config is active>"
		else
		make_tar_arch
		make_archive
		fi
		make_flashable_litegapps
	done
done

