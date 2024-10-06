#!/bin/zsh
# Script to manage unwanted files and directories by moving them to a trash directory.
# The script will move the files to a trash directory and create a log file with the 
# details of the deleted file/directory. This will help in restoring the files if needed.

# Set the trash directory
TRASH_DIR="$HOME/.trash"
# Create trash directory if it doesn't exist
if [ ! -d "$TRASH_DIR" ]; then
    mkdir -p "$TRASH_DIR"
fi

# Set the log file
LOG_FILE="$HOME/.trash.log"
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
fi

# Show help message
show_help() {
    echo "Usage: trash [OPTION]... [FILE]..."
    echo "Move unwanted files and directories to a trash directory."
    echo ""
    echo "Options:"
    echo "  -h, --help                          Display this help message"
    echo "  -f, --files				remove only files, leave the directories"
    echo "  -d, --delete                        Remove the files permanently"
    echo "  -e, --empty                         Empty the trash directory"
    echo "  -s, --size                          Display the disk usage of the trash directory"
    echo "  -l, --list                          List the files in the trash directory"
}

# Empty the trash directory
empty_trash() {
    rm -rf "$TRASH_DIR"/*
    echo "" > "$LOG_FILE"
    echo "Trash emptied."
    exit 0
}

# list the files in the trash directory
list_files() {
    # TODO - reverse the log file to show the latest files first
    cat "$LOG_FILE"
}

# Display the disk usage of the trash directory
disk_usage() {
    du -sh "$TRASH_DIR"
}

# Parse options using getopt
OPTIONS=$(getopt -o hfdesl -l help,files,delete,empty,size,list -- "$@")
if [ $? -ne 0 ]; then
    show_help  # Show help message if there was an error with getopt
    exit 1     # Exit with error status
fi

# Reassign positional parameters based on parsed options
eval set -- "$OPTIONS"

# Process each option
while true; do
  case "$1" in
    -h | --help )
      show_help  # Display the help message
      shift
      exit 0
      ;;
    -f | --files )
      FILES=true  # Set a flag to indicate that only files should be removed
      shift
      ;;
    -d | --delete )
      DELETE=true  # Set a flag to indicate that files should be deleted permanently
      shift
      ;;
    -e | --empty )
      empty_trash  # Empty the trash directory
      shift
      exit 0
      ;;
    -s | --size )
      disk_usage  # Display the disk usage of the trash directory
      shift
      exit 0
      ;;
    -l | --list )
      list_files  # List the files in the trash directory	
      shift
      exit 0
      ;;
    -- )
      shift  # Skip the '--' that marks the end of options
      break
      ;;
    * )
      break  # Break the loop if there are no more options
      ;;
  esac
done

declare -A processed_paths
timestamp=$(date +%y-%m-%d\ %H:%M:%S)
dir_paths=($(find "$@" -type d))
file_paths=($(find "$@" ! -type d))

if [ -z "$FILES" ]; then
  for dir in $dir_paths; do
    if [ -z "${processed_paths["$dir"]}" ]; then
      # Mark as processed
      processed_paths["$dir"]=1
      r_path=$(realpath $dir)
      children=$(find "$r_path" ! -type d)
      empty=0
      if [ -z "$children" ]; then 
	empty=1
      fi

      # hash=$(echo "$timestamp-$r_path" | xxhsum | awk '{print $1}')
      # echo "$(timestamp) | $(r_path) | $hash" >> "$LOG_FILE"
      echo "$timestamp | $r_path | $dir |   | $empty" >> "$LOG_FILE"
      
    fi
  done
fi


for file in $file_paths; do
  if [ -z "${processed_paths["$file"]}" ]; then
    # Mark as processed
    processed_paths["$file"]=1
    r_path=$(realpath $file)

    hash=$(echo "$timestamp$r_path" | xxhsum | awk '{print $1}')
    echo "$timestamp | $r_path | $file | $hash | 0">> "$LOG_FILE"
    # mv $r_path "$TRASH_DIR/$hash" 
  fi
done






