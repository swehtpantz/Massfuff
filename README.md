```
 __  __           _____ _____   ______ ______ _    _ ______ 
|  \/  |   /\    / ____/ ____| |  ____|  ____| |  | |  ____|
| \  / |  /  \  | (___| (___   | |__  | |__  | |  | | |__   
| |\/| | / /\ \  \___ \\___ \  |  __| |  __| | |  | |  __|  
| |  | |/ ____ \ ____) |___) | | |    | |    | |__| | |     
|_|  |_/_/    \_\_____/_____/  |_|    |_|     \____/|_|  v1.0
by @swehtpantz
```

Massffuf is a tool that uses interlace and ffuf to fuzz multiple domains at once with a given wordlist.

## Useage:

`./massffuf.sh -l domains.txt -w wordlist.txt [-o output_directory] [-mc status_code(s) (default 200)] [-t threads (default 3)]`

## Options:

```
Required:
-l         List of domains/URLs to fuzz
-w         Wordlist to use

Optional:
-o         Directory to save to. Default: $pwd/massffuf
-mc        Codes to match. Default: 200
-t         Number of threads to run. Default: 3
-r <int>   Level of recursion. Default 0.      
```

### Upcoming changes:
-  Minor tweaks to allow for more efficient automation pipeline integration (more dynamic variables).
