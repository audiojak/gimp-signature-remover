#!/bin/zsh

if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_filename>"
    exit 1
fi

input_file="$1"
output_file="${input_file%.*}_cleaned.png"
script_path="$(dirname "$0")/cleanup-signature.scm"

# Check for GIMP command
if command -v gimp &> /dev/null; then
    GIMP_CMD="gimp"
elif command -v gimp-console &> /dev/null; then
    GIMP_CMD="gimp-console"
elif [ -x "/Applications/GIMP.app/Contents/MacOS/gimp" ]; then
    GIMP_CMD="/Applications/GIMP.app/Contents/MacOS/gimp"
else
    echo "Error: GIMP not found. Please install GIMP or add it to your PATH."
    exit 1
fi

# Check if the script file exists
if [ ! -f "$script_path" ]; then
    echo "Error: cleanup-signature.scm not found in the same directory as this script."
    exit 1
fi

# Run GIMP with verbose output and capture it
$GIMP_CMD -i -c -d -f --verbose --console-messages \
    -b '(begin
          (load "'$script_path'")
          (script-fu-cleanup-signature "'$input_file'" "'$output_file'")
          (gimp-quit 0))' \
    2>&1 | tee gimp_output.log

echo "GIMP execution completed. Check gimp_output.log for details."
