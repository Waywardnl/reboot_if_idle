# reboot_if_idle
Reboot system when nobody has logged in succesfully for x hours

It is completely written in FreeBSD Shell (.sh)

Example, play a tune on FreeBSD when nobody has logged in Succesfulle for x hours

/usr/local/bin/reboot_if_idle.sh "/var/log/reboot_if_idle.log" "120" "/bin/echo \"\msl16oldcd4mll8pcb-agf+4.g4\" > /dev/speaker"
