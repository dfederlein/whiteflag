#!/bin/sh
# This script was generated using Makeself 2.1.5

CRCsum="2946186455"
MD5="5090dc208308eb84b0c76accbbcff8a0"
TMPROOT=${TMPDIR:=/tmp}

label="Ansible Tower Report"
script="./report.sh"
scriptargs=""
targetdir="ansible"
filesizes="2237"
keep=n

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_Progress()
{
    while read a; do
	MS_Printf .
    done
}

MS_diskspace()
{
	(
	if test -d /usr/xpg4/bin; then
		PATH=/usr/xpg4/bin:$PATH
	fi
	df -kP "$1" | tail -1 | awk '{print $4}'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
    { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
      test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
}

MS_Help()
{
    cat << EOH >&2
Makeself version 2.1.5
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive
 
 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --noexec              Do not run embedded script
  --keep                Do not erase target directory after running
			the embedded script
  --nox11               Do not spawn an xterm
  --nochown             Do not give the extracted files to the current user
  --target NewDirectory Extract in NewDirectory
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || type md5`
	test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || type digest`
    PATH="$OLD_PATH"

    MS_Printf "Verifying archive integrity..."
    offset=`head -n 401 "$1" | wc -c | tr -d " "`
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$MD5_PATH"; then
			if test `basename $MD5_PATH` = digest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test $md5 = "00000000000000000000000000000000"; then
				test x$verb = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test "$md5sum" != "$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				else
					test x$verb = xy && MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test $crc = "0000000000"; then
			test x$verb = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test "$sum1" = "$crc"; then
				test x$verb = xy && MS_Printf " CRC checksums are OK." >&2
			else
				echo "Error in checksums: $sum1 is different from $crc"
				exit 2;
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    echo " All good."
}

UnTAR()
{
    tar $1vf - 2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
}

finish=true
xterm_loop=
nox11=n
copy=none
ownership=y
verbose=n

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 36 KB
	echo Compression: gzip
	echo Date of packaging: Tue Jul  8 13:58:58 UTC 2014
	echo Built with Makeself version 2.1.5 on 
	echo Build command was: "makeself-2.1.5/makeself.sh \\
    \"/vagrant/tower_report/ansible\" \\
    \"tower-report.sh\" \\
    \"Ansible Tower Report\" \\
    \"./report.sh\""
	if test x$script != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
	echo archdirname=\"ansible\"
	echo KEEP=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5\"
	echo OLDUSIZE=36
	echo OLDSKIP=402
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n 401 "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n 401 "$0" | wc -c | tr -d " "`
	arg1="$2"
	shift 2
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | tar "$arg1" - $*
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
	shift
	;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir=${2:-.}
	shift 2
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --xwin)
	finish="echo Press Return to close this window...; read junk"
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

case "$copy" in
copy)
    tmpdir=$TMPROOT/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test "$nox11" = "n"; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm rxvt dtterm eterm Eterm kvt konsole aterm"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -title "$label" -e "$0" --xwin "$initargs"
                else
                    exec $XTERM -title "$label" -e "./$0" --xwin "$initargs"
                fi
            fi
        fi
    fi
fi

if test "$targetdir" = "."; then
    tmpdir="."
else
    if test "$keep" = y; then
	echo "Creating directory $targetdir" >&2
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp $tmpdir || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target OtherDirectory' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x$SETUP_NOCHECK != x1; then
    MS_Check "$0"
fi
offset=`head -n 401 "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 36 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

MS_Printf "Uncompressing $label"
res=3
if test "$keep" = n; then
    trap 'echo Signal caught, cleaning up >&2; cd $TMPROOT; /bin/rm -rf $tmpdir; eval $finish; exit 15' 1 2 3 15
fi

leftspace=`MS_diskspace $tmpdir`
if test $leftspace -lt 36; then
    echo
    echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (36 KB)" >&2
    if test "$keep" = n; then
        echo "Consider setting TMPDIR to a directory with more free space."
   fi
    eval $finish; exit 1
fi

for s in $filesizes
do
    if MS_dd "$0" $offset $s | eval "gzip -cd" | ( cd "$tmpdir"; UnTAR x ) | MS_Progress; then
		if test x"$ownership" = xy; then
			(PATH=/usr/xpg4/bin:$PATH; cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
echo

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$verbose" = xy; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval $script $scriptargs $*; res=$?;
		fi
    else
		eval $script $scriptargs $*; res=$?
    fi
    if test $res -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi
if test "$keep" = n; then
    cd $TMPROOT
    /bin/rm -rf $tmpdir
fi
eval $finish; exit $res
‹ "ù»SíkoÛ82Ÿõ+fÓiÈ¶$?¶r@Úf{=d÷Šæöp‡¢0h‰¶u‘HU¤œx÷òßoF%9qšpìë®ˆæsf8Ãy‘J§{ğì¥‡e4Ğ¯3ìõ›¿¦8®7pVtĞsÇíÀà`%Sš¥ K6O™Ğ÷Î{hü;-nÊ™êZìMşÛ¯åï¹(w4t ×ÊÿÙË‹ ;EwÊÔl~mYL¨pq;‰Øj*å%ØK°m_
Á}JqIŸE`‡p”×Réã#(Ñ*¬ƒ¶|ú‚{Nıöû÷Ûÿ‘gôßzê¿çz­şï¢Ø@ú«ÆPé²P+{Ù}©Œ¸cÅ.U½Uó?ˆş“`Ÿ5
|Büç:é¿ëºÃ6şÛ¥üîşÈ¿OöĞw[ùïAşŸ±,ÒÛµO×ÿ7hó¿½Ê?f¡ØVLø`üçnÉ„ÿÚøo'ñŸm[/ÀˆfaÄa&Ó6Æû“Å¥ş“ü·>İş÷‡}¯µÿ{ÿ‚‰ âéşıßiå¿Oùïİÿ·÷?;ôÿFì­ÿÿ“ûÿ˜k¶õK€§çÿış¨Íÿö&ÿmÚşGØoä¸·ä?tèş§µÿ»±ÿs±ëÕ$3Iü,Ó™a%³‹9ö\ùi˜OùAœ0±*'•-x)ó,z…S¢ĞçBñ±©ÀË÷Ï—î1¼}k¿ù÷1píÓ´8“òÉq²D”cp:.½ ÿğ†Gò
XÊE$ÓèŸb~–¦\èhlÉÂˆ!€üÅ	™@‚bË×ë)¸Â
ÓÀ’WhYNg¿fÔ‚@Š#Šób,_lĞ!\*ÜŒÒÇqÄ¢àRe"€+~„´Í±7DAÀƒıÁÄÚvÎĞ1œçà¡Üq1Ho+¸GS˜ÊĞTFMï¹àièÿúË‡=¥Ó\ûdÊ^æT¨QUû±ª½65·×„.”w¦ø#à»§Qwu¯ª{9^1Ç`:ÙoR<ŒÇíáÊ·Ş|½›o.Ş=™)çZ÷c§WWºêÖU¯®öMõu½ìu½l­ºÆ”_§™ĞÙÃäD™¦³%íÿÒ´Óze¨>!šf’r?4âµák†v‘U`S–†bnZŠe~G§¨k¼»8?»xÄ1é]|ôšŠ7N}4œ‹k·Ùğ6Èú<Ùõ“¥ıOCöˆ#‡æmQqšQ1A}Í8ÿ­âŞÕ[«{¬Ï4ŸË4äß2wLÁU¨•±«M$›Ê%?®í!K4Ä÷BCDµ´Y~$³ Qsßm6ç>o6SvmšH7ÇÁ†€i6eŠ¯·ÆBª¯Ñ­¾º‡/‘%‰1çxR¥µ¬
®¯dzYµæ_²yÕT+$!.êW|j­SÀ…OÛƒÏ_r¶£U¯Í9°à)òU ¢ıÈ÷¿‹¨çÚÌJ0°^ÔBfQ S»äğ:¥¬Ae(iBÊcU.¾£Ï_
ÉAX8&t(kˆ
IËÚ!8k+ñß§³Ów?Ÿuâ`Ûñÿ7â?·7êß¾ÿé¹^ÿí¢|¢óşy'e±¬S˜¢òÏšAÈY~8sõ˜ËR-:–õ‰ÍB<½¨Ê²Á`Dˆ®ÂNiŠ
µ	Áb¶!5©„§<E˜®rèeˆA”âÑdZã¬ÕˆP!EF“à'œ
”¢ğQOÃ‚¨¼uöÖE³dM(@@¨¢Rœ‘6•pV¡Xªø¦ ™ L%Î*¬’¨ -¶İ?Ññ‘ö¯ó!çÄ&V*®ua,Ìºüâ%ÇİÜò\–&(hO4lä’«
sv)¿ó~wL›M
W7¬÷™èÖ<FÚr–°†¦›¡ÜŞğ2b>İL@ÊY ³Tb¸Œscªc·å<’Sò1D„—!B¢/ˆÂc˜§2K ¨£óì¼ºWæ¹ÇãQ„Œ×4‹·™N¦‘¸İ$†ğ!Ãû5û\q9AŸ•3(ÀT8Œq5ås–9š©3Gˆ8V2¤Ø@yLçx³ğtŞené¼H—¬j#[Z§yRyvFÌ¸uÊŒÎÉÁª<kêQ‘Üå[)Î)!†o>¦.5ìœfFş’ô^şõ?ŸÓ‘'µÅ¸D^ñàU§½üãİÿh¦.÷÷ş7ìy#w˜¿ÿÚ÷¿ıÉË€ÄÎĞuoÉèõÛøo‡ï?¹Øï<şPò5Íæcò^':Œ9²*NÖ»ËÔk„©e™ÙÇ@ İF9VıÒÈ±ŒÑêÅÉï¿Cc=ÜÜß âÑü»ĞƒÉtU²8:«ÜÑäü.2Ys/†QÂÉ5AÅçP,±AL¨‹`|ÿâÒ‰@';ù’âææˆ‚3}r¸BÔ¡Y‡DBé/'y4ßÜ[J5™±8Ä|úæ†ôæ°¦8Í„ ½S¾˜~0¢N-0„)à ;Ke¼SN@@ğ¸K’™|É	"ÊıqØ×ãÉ¤Br‡
©™äDÁÕ‚‹µ>Š!0DÅ:hœEªÔ\ÊOAM Ÿ€mcàE9ØŸ $Ğßs‚Q4MU|)†6á½G–['„€›nÃ›âÈ×ŒÙ¯ıç1]m÷ §¿ÿıöıoòÏ“Å½½ÿb§“ÿıg@ß¶òßü‹+îí€}ÿã¸ƒJştñ‡£}§ÿvRŒ*ş²‹äßä¼«V
,«á»ó§áDÛs®©
&’›^ôåƒH›V×ú¿ãï?zƒámû?t†í÷ÿ;ÌÿHìwÒ¿*ã[Ov'4Ö¡FºöÆÁ½¦İ7‡"ûÆZÅ1›£äĞjÕcèê8éjyÅS» ‘–Wdâ|Ëº•óH[æß¬4,va‡É	oš~°g8mš’ã¬B¸Éˆ²«ë¢ƒk?o`i-N[ÚÒ–¶´¥-miK[ÚÒ–}•ÿ¾Åº P  