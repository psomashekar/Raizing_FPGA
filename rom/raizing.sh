#!/bin/bash

cd $JTUTIL/src
make || exit $?
cd -
echo "------------"

OUTDIR="mra"

mkdir -p "$OUTDIR"
mkdir -p "${OUTDIR}/$ALTD"

#AUXTMP=/tmp/$RANDOM
#jtcfgstr -target=mist -output=bash -def $DEF|grep _START > $AUXTMP
#source $AUXTMP

if [ ! -d xml ]; then
  mkdir xml
fi

function mra {
    local GAME=$1
    local ALT=${2//[:]/}
    local BUTSTR="$3"
    local DIP="$4"

    if [ ! -e xml/$GAME.xml ]; then
        if [ ! -f $GAME.xml ]; then
            mamefilter $GAME
        fi
        mv $GAME.xml xml/
    fi

    ALTD=_alt/_"$ALT"
    mkdir -p $OUTDIR/"$ALTD"

    echo -----------------------------------------------
    echo "Dumping $GAME"
    mame2dip xml/$GAME.xml -rbf batrider -outdir $OUTDIR -altfolder "$ALTD" \
        -order maincpu audiocpu gp9001_0 oki1 oki2 \
        -dipbase 8 \
        -start maincpu    0x0       \
        -start audiocpu   0x200000  \
        -start gp9001_0   0x240000  \
        -start oki1       0x1240000 \
        -start oki2       0x1340000 \
        -setword maincpu  16 \
        -setword gp9001_0 16 reverse \
        -frac 1 gp9001_0 2 \
        -order-roms gp9001_0 0 2 1 3 \
        -dipdef $DIP \
        -corebuttons 3 \
        -buttons $BUTSTR
}

mra  batrider "Armed Police Batrider"  "Shot,Bomb,Formation" "00,00,00"

function mra {
    local GAME=$1
    local ALT=${2//[:]/}
    local BUTSTR="$3"
    local DIP="$4"

    if [ ! -e xml/$GAME.xml ]; then
        if [ ! -f $GAME.xml ]; then
            mamefilter $GAME
        fi
        mv $GAME.xml xml/
    fi

    ALTD=_alt/_"$ALT"
    mkdir -p $OUTDIR/"$ALTD"

    echo -----------------------------------------------
    echo "Dumping $GAME"
    mame2dip xml/$GAME.xml -rbf bakraid -outdir $OUTDIR -altfolder "$ALTD" \
        -order maincpu audiocpu gp9001_0 ymz \
        -ignore eeprom \
        -dipbase 8 \
        -start maincpu    0x0       \
        -start audiocpu   0x200000  \
        -start gp9001_0   0x240000  \
        -start oki1       0x1240000 \
        -start oki2       0x1340000 \
        -setword maincpu  16 \
        -setword gp9001_0 16 reverse \
        -frac 1 gp9001_0 2 \
        -order-roms gp9001_0 0 2 1 3 \
        -nvram 512 \
        -dipdef $DIP \
        -corebuttons 3 \
        -buttons $BUTSTR
}

mra  bbakraid "Battle Bakraid"         "Shot,Bomb,Formation" "00,00,00"

function mra {
    local GAME=$1
    local ALT=${2//[:]/}
    local BUTSTR="$3"
    local DIP="$4"

    if [ ! -e xml/$GAME.xml ]; then
        if [ ! -f $GAME.xml ]; then
            mamefilter $GAME
        fi
        mv $GAME.xml xml/
    fi

    ALTD=_alt/_"$ALT"
    mkdir -p $OUTDIR/"$ALTD"

    echo -----------------------------------------------
    echo "Dumping $GAME"
    mame2dip xml/$GAME.xml -rbf garegga -outdir $OUTDIR -altfolder "$ALTD" \
        -nobootlegs \
        -order maincpu audiocpu gp9001_0 text oki1 \
        -dipbase 8 \
        -start maincpu    0x0       \
        -start audiocpu   0x100000  \
        -start gp9001_0   0x120000  \
        -start text       0x920000  \
        -start oki1       0x928000  \
        -setword maincpu  16 \
        -setword gp9001_0 16 reverse \
        -frac 1 gp9001_0 2 \
        -order-roms maincpu 1 0 \
        -order-roms gp9001_0 0 2 1 3 \
        -dipdef $DIP \
        -corebuttons 3 \
        -buttons $BUTSTR
}

mra  bgaregga "Battle Garegga"         "Shot,Bomb,Formation" "00,00,00"

function mra {
    local GAME=$1
    local ALT=${2//[:]/}
    local BUTSTR="$3"
    local DIP="$4"

    if [ ! -e xml/$GAME.xml ]; then
        if [ ! -f $GAME.xml ]; then
            mamefilter $GAME
        fi
        mv $GAME.xml xml/
    fi

    ALTD=_alt/_"$ALT"
    mkdir -p $OUTDIR/"$ALTD"

    echo -----------------------------------------------
    echo "Dumping $GAME"
    mame2dip xml/$GAME.xml -rbf garegga -outdir $OUTDIR -altfolder "$ALTD" \
        -order maincpu audiocpu gp9001_0 text oki1 \
        -dipbase 8 \
        -start maincpu    0x0       \
        -start audiocpu   0x80000   \
        -start gp9001_0   0x90000   \
        -start text       0x290000  \
        -start oki1       0x298000  \
        -setword maincpu  16 \
        -setword gp9001_0 16 reverse \
        -frac 1 gp9001_0 2 \
        -order-roms gp9001_0 0 1 \
        -dipdef $DIP \
        -corebuttons 3 \
        -buttons $BUTSTR
}

mra  sstriker "Sorcer Striker"         "Shot,Bomb,Formation" "00,00,00"

function mra {
    local GAME=$1
    local ALT=${2//[:]/}
    local BUTSTR="$3"
    local DIP="$4"

    if [ ! -e xml/$GAME.xml ]; then
        if [ ! -f $GAME.xml ]; then
            mamefilter $GAME
        fi
        mv $GAME.xml xml/
    fi

    ALTD=_alt/_"$ALT"
    mkdir -p $OUTDIR/"$ALTD"

    echo -----------------------------------------------
    echo "Dumping $GAME"
    mame2dip xml/$GAME.xml -rbf garegga -outdir $OUTDIR -altfolder "$ALTD" \
        -order maincpu audiocpu gp9001_0 text oki1 \
        -dipbase 8 \
        -start maincpu    0x0       \
        -start audiocpu   0x100000  \
        -start gp9001_0   0x110000  \
        -start text       0x510000  \
        -start oki1       0x518000  \
        -setword maincpu  16 reverse \
        -setword gp9001_0 16 reverse \
        -frac 1 gp9001_0 2 \
        -order-roms gp9001_0 0 1 \
        -dipdef $DIP \
        -corebuttons 3 \
        -buttons $BUTSTR
}

mra  kingdmgp "Kingdom Grandprix"      "Shot,Bomb,Formation" "00,00,00"

exit 0
