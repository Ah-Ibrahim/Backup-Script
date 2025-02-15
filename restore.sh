#!/bin/bash

source_dir=$1
backup_dir=$2

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

echo_warning() {
	echo_color "-- (WARNING) $1 --" $YELLOW
}

echo_log() {
	echo_color "-- (LOG) $1 --" $CYAN
}

restore() {
	local restored_dir=${backup_dir_list[$index]}
	cp -r "$restored_dir/." "$source_dir"
	echo_log "Restored $restored_dir"
}

echo_startup() {
	echo_color '\n----------------------------------------------------------------' $WHITE
	echo_color '\t\t\t Starting Restore' $GREEN
	echo_color '\t\t\t-----------------' $WHITE
}

echo_menu() {
	echo_color '\n Backups:' $GREEN
	echo_color '--------' $WHITE

	local i=0
	while [ $i -lt "${#backup_dir_list[@]}" ]; do
		if [ $i -eq $index ]; then
			echo_color "- ${backup_dir_list[$i]}" $YELLOW
		else
			echo_color "- ${backup_dir_list[$i]}" $WHITE
		fi
		i=$(expr $i + 1)
	done

	echo_color "\n 1) Restore back" $WHITE
	echo_color "2) Restore forward" $WHITE
	echo_color "3) Exit" $WHITE
	echo ""
}

handle_menu_input() {
	while true; do
		read -p " Enter a number (1 - 3): " num
		if [[ $num =~ ^[1-3]$ ]]; then
			break
		else
			echo_warning "Invalid input. Please try again."
		fi
	done

	if [ $num -eq 1 ]; then
		if [ $(expr $index - 1) -ge $MIN_INDEX ]; then
			index=$(expr $index - 1)
			restore
		else
			echo_warning "No older backups avaliable for restore"
		fi

		sleep $sleep_interval
	elif [ $num -eq 2 ]; then
		if [ $(expr $index + 1) -le $MAX_INDEX ]; then
			index=$(expr $index + 1)
			restore
		else
			echo_warning "No newer backups avaliable for restore"
		fi

		sleep $sleep_interval
	else
		echo_log "Ending session"
		exit 0
	fi
}

# Step 1 -> Handling initial errors

if [ $# -lt 2 ]; then
	echo_error 'Restore need 2 arguments, please enter them all'
	exit 0
elif [ ! -d $source_dir ]; then
	echo_error 'Source dir was not found'
	exit 0
elif [ ! -d $backup_dir ]; then
	echo_error 'Backup dir was not found'
	exit 0
elif [ -z "$(ls $backup_dir)" ]; then
	echo_error 'There is no backups'
	exit 0
fi

# Step 2 -> Initialization

backup_dir_list=($(find $backup_dir -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' | sort -n | cut -d ' ' -f 2))
MIN_INDEX=0
MAX_INDEX=$(expr "${#backup_dir_list[@]}" - 1)
index=$MAX_INDEX
sleep_interval=1

echo_startup
restore

while true; do
	echo_menu
	handle_menu_input
done
