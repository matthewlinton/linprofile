#!/bin/bash
# systemprofile.sh - Generate a profile of the running system

source "./functions.sh"

PROCLOOP=100         # Number of procloops to launch
MEMLOOP=100          # Number of fillmems to launch
BOOKEND=10          # Iterations of data to collect before and after each stress test

LOGDIR="${HOME}/systemprofile"
LOGFILE="$LOGDIR/System.Profile.log"
PROCDATA="$LOGDIR/System.Profile.Processor.csv"
MEMDATA="$LOGDIR/System.Profile.Memory.csv"
OVERWRITE='true'

TOOLS='./tools'

CPUINFO='/proc/cpuinfo'
BOOTLINE='/proc/cmdline'
LOADAVG='/proc/loadavg'
VERSION='/proc/version'

# Check for existing log
if [ -f "$LOGFILE" ] && [ "$OVERWRITE" != 'true' ]; then
    echo "Log file \"$LOGFILE\' already exists."
    exit 1
fi

echo "Logging data to \"$LOGDIR\""

### Begin New Log #############################################################
echo -n "Initilizing Testing... "
mkdir -p "$LOGDIR"

# Initialize testing log 
echo "-- Testing Data -------------------------------------------" > "$LOGFILE"
echo "Date:                $(date "+%F %T")" >> "$LOGFILE"
echo "Max Process Loops:   $PROCLOOP" >> "$LOGFILE"
echo "MAX Memory Loops:    $MEMLOOP" >> "$LOGFILE"
echo "Pre/Post Data:       $BOOKEND" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Initialize processor stress log
echo -n "date,uptime,users,Load 1,Load 5,Load 15,Task tot,Task run,Task sleep," > "$PROCDATA"
echo -n "Task stop,Task zmb,CPU us,CPU sy,CPU ni,CPU id,CPU wa,CPU hi,CPU si,CPU st," >> "$PROCDATA"
echo -n "MEM tot,MEM used,MEM free,MEM buff,SWA tot,SWA used,SWA free,SWA cach," >> "$PROCDATA"
echo "Treal,Tuser,Tsys,Temp0,Temp1,Temp3" >> "$PROCDATA"

# Initialize memory stress log
cat "$PROCDATA" > "$MEMDATA"
echo "DONE"

### Gather system information #################################################
echo -n 'Gathering system information... '
echo "-- System Information -------------------------------------" >> "$LOGFILE"
echo "Hostname:            $(uname -n)" >> "$LOGFILE"
echo "Machine:             $(uname -m)" >> "$LOGFILE"
echo "Platform:            $(uname -i)" >> "$LOGFILE"
echo "Processor:           $(uname -p)" >> "$LOGFILE"
echo "Operating System:    $(uname -o)" >> "$LOGFILE"
echo "Kernel:              $(uname -s)" >> "$LOGFILE"
echo "Kernel Release:      $(uname -r)" >> "$LOGFILE"
echo "Kernel Version:      $(uname -v)" >> "$LOGFILE"
echo "Bootline:            $(cat "$BOOTLINE")" >> "$LOGFILE"
echo "Version Hash:        $(md5sum "$VERSION" | awk '{ print $1 }')" >> "$LOGFILE"
#echo "" >> "$LOGFILE"
echo 'DONE'

### Gather release information ################################################
echo -n 'Gathering release information... '
echo "-- Release Information ------------------------------------" >> "$LOGFILE"
cat /etc/*release* | \
    sed -e "s/=/:#/g" -e "s/\"//g" | \
    awk 'BEGIN{FS="#"} { printf("%-20s %s\n", $1, $2) }' >> "$LOGFILE"
echo "" >> "$LOGFILE"
echo 'DONE'

### Gather processor information ##############################################
echo -n 'Gathering processor information... '
echo "-- Processor Information ----------------------------------" >> "$LOGFILE"
echo "CPU Vendor:          $(grep '^vendor_id' "$CPUINFO" | head -n 1 | sed -e "s/^vendor_id[ \t]*: //g")" >> "$LOGFILE"
echo "CPU Model:           $(grep '^model name' "$CPUINFO" | head -n 1 | sed -e "s/^model name[ \t]*: //g")" >> "$LOGFILE"
echo "CPU Cores:           $(grep '^cpu cores' "$CPUINFO" | head -n 1 | sed -e "s/^cpu cores[ \t]*: //g")" >> "$LOGFILE"
echo "CPU Clock(MHz):      $(grep '^cpu MHz' "$CPUINFO" | head -n 1 | sed -e "s/^cpu MHz[ \t]*: //g")" >> "$LOGFILE"
echo "CPU Cache(KB):       $(grep '^cache size' "$CPUINFO" | head -n 1 | sed -e "s/^cache size[ \t]*: //g" -e "s/ KB$//g")" >> "$LOGFILE"
echo "CPU bogomips:        $(grep '^bogomips' "$CPUINFO" | head -n 1 | sed -e "s/^bogomips[ \t]*: //g")" >> "$LOGFILE"
echo "CPU LoadAvg:         $(cat "$LOADAVG")" >> "$LOGFILE"
echo "" >> "$LOGFILE"
echo 'DONE'

### Gather temprature information #############################################
echo -n "Gathering temprature information... "
echo "-- Temprature Data ----------------------------------------" >> "$LOGFILE"
for i in $(seq 1 3); do
    if [ -f "/sys/class/thermal/thermal_zone$i/temp" ]; then
        echo "Temp$1:              $(cat "/sys/class/thermal/thermal_zone$i/temp")" >> "$LOGFILE"
    fi
done
echo "" >> "$LOGFILE"
echo "DONE"

### Gather memory information #################################################
echo -n 'Gathering memory information... '
echo "-- Memory Information -------------------------------------" >> "$LOGFILE"
echo "MEM Total(KB):       $(grep '^MemTotal:' /proc/meminfo | awk '{ print $2}')" >> "$LOGFILE"
echo "MEM Free(KB):        $(grep '^MemFree:' /proc/meminfo | awk '{ print $2}')" >> "$LOGFILE"
echo "MEM Cached(KB):      $(grep '^Cached:' /proc/meminfo | awk '{ print $2}')" >> "$LOGFILE"
echo "MEM Active (KB):     $(grep '^Active:' /proc/meminfo | awk '{ print $2}')" >> "$LOGFILE"
echo "MEM Inactive(KB):    $(grep '^Inactive:' /proc/meminfo | awk '{ print $2}')" >> "$LOGFILE"
echo "" >> "$LOGFILE"
echo 'DONE'

### Gather Drive Information ##################################################
echo -n 'Gathering drive information... '
echo "-- Drive Information --------------------------------------" >> "$LOGFILE"
df -lh --sync >> "$LOGFILE"
echo "" >> "$LOGFILE"
echo "DONE"

### Gather network information ################################################
echo -n 'Gathering network information... '
echo "-- Network Information ------------------------------------" >> "$LOGFILE"
ifconfig -a | sed -e "/[ \t]*UP/d" -e "/[ \t]*[RT]X/d" -e "/[ \t]*collisions/d" >> "$LOGFILE"
echo "" >> "$LOGFILE"
echo 'DONE'

### Gather kernel module information ##########################################
echo -n "Gathering kernel module information... "
echo "-- Active Kernel Modules ------------------------------------" >> "$LOGFILE"
cat /proc/modules | \
    sed -e "s/Live 0x[a-zA-Z0-9 ()]*//g" \
    -e "s/ [0-9]* [0-9]*/ : /g" \
    -e "s/ - //g" -e "s/,[ ]*$//g" >> "$LOGFILE"
echo "" >> "$LOGFILE"
echo "DONE"

### Begin Stress Tests ########################################################
echo "-- Stress Test Results ------------------------------------" >> "$LOGFILE"
# Stress Processor
echo -n 'Stressing processor...'
launch_stress_test "$TOOLS/procloop" $PROCLOOP "$PROCDATA" "$BOOKEND"
echo "Processor stress data entered into \"$PROCDATA\"" >> "$LOGFILE"
echo ' DONE'

# Stress memory
echo -n 'Stressing memory...'
launch_stress_test "$TOOLS/fillmem" $MEMLOOP "$MEMDATA" "$BOOKEND"
echo "Memory stress data entered into \"$MEMDATA\"" >> "$LOGFILE"
echo 'DONE'

# Criple system
# TODO : Write script that uses tools to crash the system.
