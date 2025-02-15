#!/bin/bash

source_dir=$1
backup_dir=$2
interval_secs=$3
max_backups=$4

# COLORS

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NO_COLOR='\033[0m'

echo_color() {
	echo -e "${2} $1 ${NO_COLOR}"
}

echo_error() {
	echo_color "-- (ERROR) $1 --" $RED
}

echo_log() {
	echo_color "-- (LOG) $1 --" $CYAN
}

echo_startup() {
	echo_color '\n----------------------------------------------------------------' $WHITE
	echo_color '\t\t\t Starting Backup' $GREEN
	echo_color '\t\t\t-----------------' $WHITE
	echo_log "Backup directory is ready at $backup_dir/"
}

create_backup() {
	printf -v date '%(%Y-%m-%d-%H-%M-%S)T' -1
	cp -r $source_dir $backup_dir/$date
	echo_log "Backup created at $backup_dir/$date"
}

# Step 1 -> Handling initial errors

integer_regex='^[0-9]+$'
number_regex='^[0-9]+([.][0-9]+)?$'

if [ $# -lt 4 ]; then
	echo_error 'Bashupd need 4 arguments, please enter them all'
	exit 0
elif [ ! -d $source_dir ]; then
	echo_error 'Source dir was not found'
	exit 0
elif [[ ! $interval_secs =~ $number_regex ]]; then
	echo_error 'Interval secs should be a number'
	exit 0
elif [[ ! $max_backups =~ $integer_regex ]]; then
	echo_error 'Max backups should be an integer'
	exit 0
fi

# Step 2 -> Initialization

counter=0

ls -lR $source_dir >directory-info.last
echo_startup
create_backup
counter=$(expr $counter + 1)

# Step 3 -> Check forever

while [ true ]; do
	sleep $interval_secs
	ls -lR $source_dir >directory-info.new
	diff directory-info.last directory-info.new >/dev/null

	if [ ! $? -eq 0 ]; then
		create_backup
		counter=$(expr $counter + 1)
		cat directory-info.new >directory-info.last
	fi

	if [ $counter -gt $max_backups ]; then
		rm -rf "$(find $backup_dir -type d -printf '%T@ %p\n' | sort -n | head -n 1 | cut -d ' ' -f 2)"
		counter=$(expr $counter - 1)
	fi
done
