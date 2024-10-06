#!/bin/zsh

# Set the trash directory
TRASH_DIR="$HOME/.trash"
# Create trash directory if it doesn't exist
if [ ! -d "$TRASH_DIR" ]; then
    echo "error: no trash directory"
    exit 1
fi

# Set the log file
LOG_FILE="$HOME/.trash.log"
if [ ! -f "$LOG_FILE" ]; then
    echo "error: no log file"
    exit 1
fi

# Show help message
show_help() {
    echo "Usage: trash [OPTION]... [FILE]..."
    echo "Move unwanted files and directories to a trash directory."
    echo ""
    echo "Options:"
    echo "  -h, --help                         Display this help message"
    echo "  -l, --list                         List the files in the trash directory"
    echo "  -d, --destination		       Specify the destination directory"
}

# list the files in the trash directory
list_files() {
    # TODO - reverse the log file to show the latest files first
    cat "$LOG_FILE"
}

}

collision() {
    if [ -z $all ]; then
	echo $1	
	read -r response
    fi

    case "$response" in
	y|Y)
	    echo "You selected Yes."
	    ;;
	n|N)
	    echo "You selected No."
	    ;;
	a|A)
	    response="y"
	    all=1
	    ;;
	q|Q)
	    response="n"
	    all=1
	    ;;
	*)
	    echo "Invalid option. Please enter y, n, a, or q."
	    ;;
    esac
}

# Restore the most recently deleted file
undo() {
    last_line=$(tail -n 1 "$LOG_FILE")
    # most recent remove batch
    timestamp=$(echo "$last_line" | awk -F '|' '{print $1}')
    while IFS= read -r line; do
	IFS=' | ' read -r ts og_path key empty <<< "$last_line" 

	# break if new batch
	if [ "$ts" != "$timestamp" ]; then
	    break
	fi
	
	# restore to original path
	if [ -z "$DESTINATION" ]; then
	    # filename=$(basename "$og_path")
	    
	    # log entry is a directory
	    if [ -z "$TRASH_DIR/$key" ]; then # TODO - check for collision
		# check if file already exists
		if [ -e "$og_path" ]; then
		    collision "File already exists. Do you want to overwrite it? (a/y/n/q)" $og_path
		else # file does not exist
		    mkdir -p "$og_path"
		fi

	    else # log entry is a file
		if [ -e "$og_path" ]; then
		    collision "File already exists. Do you want to overwrite it? (a/y/n/q)" $og_path $TRASH_DIR/$key
		else # file does not exist
		    mv -p "$TRASH_DIR/$key" "$og_path"
		fi
	    fi
	else # restore to specified destination

	fi

    # Remove the last line from the file
    sed -i '' -e '$d' "$LOG_FILE"

    done < <(tac "$LOG_FILE")
    exit 0
}

# Restore the specified file
restore_file() {
    echo "Restore file not implemented yet."
    exit 0
}


# Parse options using getopt
OPTIONS=$(getopt -o hld: -l help,list,destination: -- "$@")
if [ $? -ne 0 ]; then
    show_help  # Show help message if there was an error with getopt
    exit 1     # Exit with error status
fi

# Reassign positional parameters based on parsed options
eval set -- "$OPTIONS"

# Process each option
while true; do
  case "$1" in
    -l | --list )
      list_files  # List the files in the trash directory	
      shift
      ;;
    -h | --help )
      show_help  # Display the help message
      shift
      exit 0
      ;;
    -d | --destination )
	DESTINATION=$2  # Display the help message
      shift
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

# response=$(collision "Do you want to restore the most recently deleted file? (y/n)")
# echo $response

t() {
    # Manually echo the prompt
    echo "$1"
    
    # Read the user's response
    read -r response
    
}

t "Do you want to restore the most recently deleted file? (y/n)")
echo "$response"

# exit 0
#
# if [ -z $@ ]; then
# 	undo
# 	exit 0     # Exit with error status
# fi
