#!/bin/sh

## When unsuccessfull login for x hours then reboot system
#

## Paramters
#
## $1 = Log file
## $2 = Number of hours in difference before executing command
## $3 = Command to execute
#

LOGFile=$1
DIFFHours=$2
STARTCommand=$3
PLAYSound=$4
TelErrors=0

echo "Starting: reboot_if_idle.sh"
echo ""

## Check the user input and give advice
#
if [ "$LOGFile" != "" ]; then
  length=$(echo -n "$LOGFile" | wc -c)
  if [ "$length" -gt "3" ]; then
    echo "Log File : $LOGFile" 1
  else
    ## No log file known, print it to the screen
    #
    echo "Log File : Unknown ($LOGFile)"
    TelErrors=$(( $TelErrors + 1 ))
  fi
else
  ## No log file known, print it to the screen
  #
  echo "Log FIle : Unknown ($LOGFile)"
  TelErrors=$(( $TelErrors + 1 ))
fi

if [ "$TelErrors" -lt "1" ]; then
        ## write logs
        #
        function_log()
          {
            message=$1
            printonscreen=$2

            LOGVANDAAG=`date +'%a %d %b %Y %T'`

            echo "[$LOGVANDAAG] $message" >> $LOGFile

            if [ "$printonscreen"  -gt "0" ]; then
               echo $message
            fi
          }

        if [ "$DIFFHours" != "" ]; then
          if [ "$DIFFHours" -gt "0" ]; then
            function_log "Difference in hours : $DIFFHours" 1
          else
            function_log "Difference in hours : Unknown ($DIFFHours)" 1
            TelErrors=$(( $TelErrors + 1 ))
          fi
        else
           function_log "Difference in hours : Unknown ($DIFFHours)" 1
           TelErrors=$(( $TelErrors + 1 ))
        fi

        if [ "$STARTCommand" != "" ]; then
          length=$(echo -n "$STARTCommand" | wc -c)
          if [ "$length" -gt "3" ]; then
            function_log "Command to Start : $STARTCommand" 1
          else
            function_log "Command to Start : Unknown ($STARTCommand)" 1
            TelErrors=$(( $TelErrors + 1 ))
          fi
        else
          function_log "Command to Start : Unknown ($STARTCommand)" 1
          TelErrors=$(( $TelErrors + 1 ))
        fi

        if [ "$PLAYSound" != "" ]; then
          if [ "$PLAYSound" -gt "0" ]; then
            function_log "Play Sound on action : Yes" 1
          else
            function_log "Play Sound on action : No" 1
          fi
        else
          function_log "Play Sound on action : No" 1
          PLAYSound=0
        fi

else
  echo "We cannot perform other functions without a log file"
fi

if [ "$TelErrors" -gt "0" ]; then
  echo ""
  echo "Errors found! Usage:"
  echo "reboot_if_idle.sh <Logfile (FullPath + Filename)> <Difference in Hours (Integer)> <Command to start> <Play sound on action (0 = No / 1 = Yes)>"
  echo ""
  echo "Example:"
  echo '/usr/local/bin/reboot_if_idle.sh "/var/log/reboot_if_idle.log" "120" "/bin/echo "Reboot!" "1"'
else
        # Capture command output into positional parameters
        set -- $(lastlogin -t)  # Example: Captures `ls` output

        ## Pak dit jaar omdat dit het snijpunt is
        #
        mydate=$(date +'%Y')

        ONELINENUMBER=7
        Count=0
        jaar=0
        maand=0
        dag=0
        datumone=0
        datumtwo=0
        lastitem=0

        ## Datum van vandaag
        ## https://forums.freebsd.org/threads/elapsed-time.70942/
        #
        VANDAAG=`date +%s`

        tellen=0
        LOWESTDelta=10000000

        ## Loop through the captured values
        #
        for item in "$@"; do
            ## Print all value's to the log file
            #
            function_log "$Count: $item" 0

            if [ "$item" == "$mydate" ]; then
              Count=0
              jaar=$item
              maand=$datumthree
              dag=$datumtwo
              tijd=$datumone

              LOGINdate=$(date -j -f "%b %d %T %Y" "${maand} ${dag} ${tijd} ${jaar}" "+%s")
              DELTA=$(( VANDAAG-LOGINdate ))
              function_log "Calculate delta Time: $VANDAAG -/- $LOGINdate = $DELTA" 0

              HOURS=$(( DELTA/3600 ))
              MIN=$(( (DELTA-HOURS*3600)/60 ))
              SEC=$(( DELTA-HOURS*3600-MIN*60 ))

              function_log "Verschil in tijd (Hours:Minutes:Seconds): $HOURS:$MIN:$SEC --> Delta Hours : $HOURS -LessThan- Lowest Delta : $LOWESTDelta ?" 0

              if [ "$HOURS" -lt "$LOWESTDelta" ]; then
                ## Delta is less than maximum hours no login activity, note the lowest number
                #
                if [ "$HOURS" -lt "$LOWESTDelta" ]; then
                        LOWESTDelta=$HOURS
                        function_log "Lowest number of hours not logged in with any user name is changed to: $LOWESTDelta" 1
                fi
              fi
              ## For trouble shooting
              #
              #echo "------------------"
              #echo "Jaar = $jaar"
              #echo "Maand = $maand"
              #echo "Dag = $dag"
              #echo "Tijd = $tijd"
              #echo "------------------"
              function_log "What is present in the Strings?! --> Jaar = $jaar, Maand = $maand, Dag = $dag, Tijd = $tijd" 0
            else
              ## Put the right value's in the right strings
              #
              datumone=$item
              datumtwo=$lastitem
              datumthree=$firstitem
              firstitem=$lastitem
              lastitem=$item
            fi
            Count=$(( $Count + 1 ))
        done

        ## Check if lowest Delta is lower than maximum hours of not logged in in any user account on this ssystem
        #
        if [ "$LOWESTDelta" -lt "$DIFFHours" ]; then
          ## Lowest Delta hours is less than maximum diffhours, so all is good
          #
          function_log "Lowest Delta hours is: $LOWESTDelta, that is less than the maximum number of Hours nodbody has logged on in to this system: $DIFFHours. That is a GOOD thing! We don't need todo anything" 1
        else
          ## Lowest delta hours is bigger than miximum different hours, so we need to todo the assignment
          #
          function_log "Lowest Delta hours is: $LOWESTDelta, that !more! than the maximum number of Hours nodbody has logged on in to this system: $DIFFHours. That is a BAD thing! Execute command: $STARTCommand" 1

          ## Do we need to play a sounf on action?
          #
          if [ "$PLAYSound" -gt "0" ]; then
                eval "kldload speaker"
                eval '/bin/echo "\msl16old" > /dev/speaker'
          fi

          ## Start command
          #
          eval "$STARTCommand"
        fi
fi
