```
 __  __           _____ _____   ______ ______ _    _ ______ 
|  \/  |   /\    / ____/ ____| |  ____|  ____| |  | |  ____|
| \  / |  /  \  | (___| (___   | |__  | |__  | |  | | |__   
| |\/| | / /\ \  \___ \\___ \  |  __| |  __| | |  | |  __|  
| |  | |/ ____ \ ____) |___) | | |    | |    | |__| | |     
|_|  |_/_/    \_\_____/_____/  |_|    |_|     \____/|_|  v1.0
by @swehtpantz
```

Massffuf is a tool that uses interlace and ffuf to fuzz multiple domains at once with a given wordlist. Produces fuzzing data similar to that of reconftw, minus many false positives.

Inspired by:

meg (https://github.com/tomnomnom/meg)

ffuf (https://github.com/ffuf/ffuf)

reconftw (https://github.com/six2dez/reconftw)

## Important:

Use with a VPS and run with caution (set your rate-limit accordingly)! 

Running this tool too quickly will likely generate warnings from target cloud providers and may result in actions taken against your IP.

*You have been warned!*

## Requirements:
ffuf : `https://github.com/ffuf/ffuf`

interlace : `https://github.com/codingo/Interlace`

jq : `sudo apt update && sudo apt install jq -y`

## Useage:

`./massffuf.sh -l domains.txt -w wordlist.txt [-o | --output-directory] [-m | --match-codes] [-t | --threads] [-r | --recursion <depth>] [--R | --rate-limit]`

## Options:

```
Required:
-l  | --domains-file      List of domains/URLs to fuzz
-w  | --wordlist          Wordlist to use

Optional:
-o  | --output-directory  Directory to save to. Default: $pwd/massffuf
-m  | --match-codes       Codes to match. Default: 200
-t  | --threads           Number of threads to run. Default: 3
-r  | --recursion-depth   Level of recursion. Default 0.
-R  | --rate-limit        Rate limit. Default 0.
```

### Upcoming changes:
-  Minor tweaks to allow for more efficient automation pipeline integration (more dynamic variables).
