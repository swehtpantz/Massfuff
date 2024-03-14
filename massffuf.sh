#!/bin/bash

# Usage: ./massffuf.sh -l domains.txt -w wordlist.txt [-o output_directory] [-mc status_code(s)] [-t threads] [-r depth (int)]

match_codes=200 # Default match code
threads=3 # Default number of threads
recursion_depth=0 # Default to no recursion

while getopts ":l:w:o:mc:t:" opt; do
  case $opt in
    l)
      domains_file="$OPTARG"
      ;;
    w)
      wordlist="$OPTARG"
      ;;
    o)
      output_directory="$OPTARG"
      ;;
    mc)
      match_codes="$OPTARG"
      ;;
    t)
      threads="$OPTARG"
      ;;
    f)
      recursion_depth=$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Ensure required parameters are provided
if [ -z "$domains_file" ] || [ -z "$wordlist" ]; then
  echo "Usage: ./massffuf.sh -l domains.txt -w wordlist.txt [-o output_directory] [-mc status_code(s) (default 200)] [-t threads (default 3)] [-r depth (int)]" >&2
  exit 1
fi

# Set default output directory if not specified
if [ -z "$output_directory" ]; then
  output_directory="massffuf"
fi

# ASCII Art
echo """
 __  __           _____ _____   ______ ______ _    _ ______ 
|  \/  |   /\    / ____/ ____| |  ____|  ____| |  | |  ____|
| \  / |  /  \  | (___| (___   | |__  | |__  | |  | | |__   
| |\/| | / /\ \  \___ \\___  \  |  __| |  __| | |  | |  __|  
| |  | |/ ____ \ ____) |___) | | |    | |    | |__| | |     
|_|  |_/_/    \_\_____/_____/  |_|    |_|     \____/|_|  v1.0
by @swehtpantz
"""

# Create output directory if it doesn't exist
mkdir -p "$output_directory"
echo "Output directory : $output_directory."

# Run interlace and ffuf
if [ "$recursion_depth" -gt 0 ]; then
  interlace -tL "$domains_file" -threads "$threads" --silent -c "bash -c 'TARGET=\$(echo _target_ | sed \"s|/|_|g\"); ffuf -w $wordlist -u _target_/FUZZ -ac -mc $match_codes -recursion -recursion-depth $recursion_depth -o ${output_directory}/\${TARGET}_results.json -of json'"
else
  interlace -tL "$domains_file" -threads "$threads" --silent -c "bash -c 'TARGET=\$(echo _target_ | sed \"s|/|_|g\"); ffuf -w $wordlist -u _target_/FUZZ -ac -mc $match_codes -o ${output_directory}/\${TARGET}_results.json -of json'"
fi

# Combine results into a single file
find "$output_directory" -type f -name "*.json" -exec cat {} + > "$output_directory/all_results.json"

# Parse and print results to the results file
jq -r '.results[] | "\(.status) \(.length) \(.url)"' "$output_directory/all_results.json" > "$output_directory/all_results.txt"
rm "$output_directory"/*.json
echo "Results parsed and saved in $output_directory/all_results.txt"

# Only show response sizes that occur less than 10 times.
awk '{print $2}' "${output_directory}/all_results.txt" | sort | uniq -c | sort -nr > "${output_directory}/sizes_count.txt"
awk '$1 > 10 {print $2}' "${output_directory}/sizes_count.txt" > "${output_directory}/frequent_sizes.txt"
awk 'NR==FNR {exclude[$1]; next} !($2 in exclude)' "${output_directory}/frequent_sizes.txt" "${output_directory}/all_results.txt" > "${output_directory}/cleaned_results.txt"
rm "${output_directory}/sizes_count.txt" "${output_directory}/frequent_sizes.txt"
echo "Occurences with response sizes occuring more than 10 times removed and saved in $output_directory/cleaned_results.txt"

echo "Mass fuzzing complete at $(date)."
