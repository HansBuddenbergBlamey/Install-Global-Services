#!/bin/sh

SCRIPT="$(realpath $0)"
BASEFOLDER="$(dirname $SCRIPT)"
LOGFOLDER="$BASEFOLDER/logs"

if [ ! -d $LOGFOLDER ]; then
	mkdir $LOGFOLDER
fi

SCRIPT_LOG=$LOGFOLDER/SystemOut.log
touch $SCRIPT_LOG

function SCRIPTENTRY(){
    timeAndDate=`date`
    script_name=`basename "$0"`
    echo "$FUNCNAME: $script_name" >> $SCRIPT_LOG
}

function SCRIPTEXIT(){
    script_name=`basename "$0"`
    echo "$FUNCNAME: $script_name" >> $SCRIPT_LOG
}

function ENTRY(){
    local cfn="${FUNCNAME[1]}"
    local tstamp=`date`
    local msg="> $cfn $FUNCNAME"
    echo -e "[$tstamp] [DEBUG]\t$msg" >> $SCRIPT_LOG
}

function RETURN(){
    local cfn="${FUNCNAME[1]}"
    local tstamp=`date`
    local msg="< $cfn $FUNCNAME"
    echo -e "[$tstamp] [DEBUG]\t$msg" >> $SCRIPT_LOG
}
function INFO()
{
    local msg="$1"
    local tstamp=`date`
    echo -e "[$tstamp] [INFO]\t$msg" >> $SCRIPT_LOG
}

function DEBUG()
{
    local msg="$1"
    local tstamp=`date`
    echo -e "[$tstamp] [DEBUG]\t$msg" >> $SCRIPT_LOG
}

function ERROR()
{
    local msg="$1"
    local tstamp=`date`
    echo -e "[$tstamp] [ERROR]\t$msg" >> $SCRIPT_LOG
}
