# Function definitions for the profile scripts

# output_top_data - Takes the first five lines of top and outputs them as a comma seperated list.
# it also appends timing information on executing an ssh keygen.
# Does not follow output with a newline. 
# USAGE : output_top_data
function output_top_data () {
    # gather top information
    top -bn 10 | head -n 5 | tr '\n' ',' | sed -e "s/up/,/g" -e "s/[a-zA-Z: \(\)\%-]*//g"
    # see how long it takes to run a command
    { time ssh-keygen -q -t rsa -f /tmp/$(date +%F%T) -P $(date +%s); } 2>&1 | sed -e "s/^[a-z]*[ \t]//g" -e "/^$/d" | tr '\n' ','
    # get temprature information if it exists
    for i in $(seq 1 3); do
        if [ -f "/sys/class/thermal/thermal_zone$i/temp" ]; then
            cat "/sys/class/thermal/thermal_zone$i/temp" | tr '\n' ','
        fi
    done
    echo ""
}

# capture_top_data - loops "$1" number of times and outputs top data in a comma seperated list.
# USAGE : capture_top_data <loop>
function capture_top_data () {
    for i in $(seq 1 $1); do
        output_top_data
        sleep 1
    done
}

# flood_app - launches a binary ($1) a number of times ($2).
# flood_app does not clean up after itself. That is left to the calling function.
# USAGE : flood_app <exacutable> <loop> <lockfile>
function flood_app () {
    i=0
    while [ $i -lt $2 ]; do
        "$1" &
        sleep 1
        i=$(expr $i + 1)
    done
    sleep 3
    killall "$(basename $1)" 2>&1 >/dev/null
    rm -f "$3"
}

# launch_stress_test - launch a stress test and collect data.
# USAGE : launch_stress_test <binary> <loop> <logfile> <bookend>
function launch_stress_test () {
    lockfile="/tmp/flood_app_$(date +%s).lock"
    # Capture leadin
    capture_top_data $4 >> "$3"
    # Start flooding the processor
    touch "$lockfile"
    flood_app "$1" $2 "$lockfile" &
    # Begin capture data
    i=0
    while [ -f "$lockfile" ]; do
        output_top_data >> "$3"
        echo "$(ps aux | grep "$1" | wc -l)" > tmp.log
        i=$(expr $i + 1)
        if [ $(expr $i % 10) -eq 0 ]; then echo -n "."; fi
        sleep 1
    done
    # Capture cooldown
    capture_top_data $4 >> "$3"
}
