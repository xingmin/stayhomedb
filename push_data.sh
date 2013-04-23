#!/bin/bash
function pull(){
    sr=$1
    dr=$2
    if ! [ -d "$dr" ]; then
        mkdir -p "$dr"
    fi
    if ! [ -e "$dr/.git" ]; then
        git clone $sr $dr
    else
        git --git-dir="$dr/.git" pull origin master
    fi
}
function push(){
    lr=$1
    lrgd="$lr/.git"
    for i in {1..10} 
    do  
        echo "Trying push my data to remote repo: $i time(s)"
	git --git-dir="$lrgd" add .
	git --git-dir="$lrgd" commit -m "test"
        git --git-dir="$lrgd" pull origin master
        git --git-dir="$lrgd" push origin master
	if [ $? -ne 0 ]; then
	    sleep 5
	    continue
	fi
	break
    done
}
function usage(){
    echo "usage:$1 -m pull/push -s \"remote repo\" -d \"local repo path\""
}
mode="pull"
drepo=""
srepo=""

while getopts "m:s:d:h" opt;do
    case $opt in
        m) 
	    mode=$OPTARG
	    case $mode in
	        "push") mode="push"
		;;
	        "pull") mode="pull"
		;;
	    esac
	;;
	s) 
	    srepo="$OPTARG"
	;;
	d)
	    drepo="$OPTARG"
	;;
	h|\?)
	    usage $0
	    exit 0
	;;
    esac
        
done

if [ -z $drepo ]||[ -z $srepo ]; then
    usage $0
    exit 1
fi

case $mode in
    "pull")
        pull $srepo $drepo
        ;;
    "push")
        push $drepo
esac
    





