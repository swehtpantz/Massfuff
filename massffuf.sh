#!/bin/bash

# Usage: ./massffuf.sh -l domains.txt -w wordlist.txt [-o | --output-directory] [-m | --match-codes] [-t | --threads] [-r | --recursion <depth>] [--R | --rate-limit]

TEMP=$(getopt -o l:w:o:m:t:r:R: --long domains-file:,wordlist:,output-directory:,match-codes:,threads:,recursion-depth:,rate-limit: -- "$@")

if [ $? != 0 ]; then echo "Terminating..." >&2; exit 1; fi

# Note the quotes around `$TEMP`: they are essential!
eval set -- "$TEMP"

# Default values
match_codes=200
threads=3
recursion_depth=0
rate_limit=40

while true; do
    case "$1" in
        -l|--domains-file)
            domains_file="$2"; shift 2;;
        -w|--wordlist)
            wordlist="$2"; shift 2;;
        -o|--output-directory)
            output_directory="$2"; shift 2;;
        -m|--match-codes)
            match_codes="$2"; shift 2;;
        -t|--threads)
            threads="$2"; shift 2;;
        -r|--recursion-depth)
            recursion_depth="$2"; shift 2;;
        -R|--rate-limit)
            rate_limit="$2"; shift 2;;
        --)
            shift; break;;
        *)
            echo "Programming error"
            exit 3;;
    esac
done

# Ensure required parameters are provided
if [ -z "$domains_file" ] || [ -z "$wordlist" ]; then
  echo "Usage: ./massffuf.sh -l domains.txt -w wordlist.txt [-o | --output-directory] [-m | --match-codes] [-t | --threads] [-r | --recursion <depth>] [--R | --rate-limit]" >&2
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
  interlace -tL "$domains_file" -threads "$threads" --silent -c "bash -c 'TARGET=\$(echo _target_ | sed \"s|/|_|g\"); ffuf -w $wordlist -u _target_/FUZZ -ac -mc $match_codes -rate $rate_limit -recursion -recursion-depth $recursion_depth -o ${output_directory}/\${TARGET}_results.json -of json'"
else
  interlace -tL "$domains_file" -threads "$threads" --silent -c "bash -c 'TARGET=\$(echo _target_ | sed \"s|/|_|g\"); ffuf -w $wordlist -u _target_/FUZZ -ac -mc $match_codes -rate $rate_limit -o ${output_directory}/\${TARGET}_results.json -of json'"
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
