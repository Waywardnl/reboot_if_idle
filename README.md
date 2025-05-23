# reboot_if_idle
Reboot system when nobody has logged in succesfully for x hours

It is completely written in FreeBSD Shell (.sh)

Example, play a tune on FreeBSD when nobody has logged in Succesfulle for x hours

/usr/local/bin/reboot_if_idle.sh "/var/log/reboot_if_idle.log" "120" "/bin/echo Reboot!" "1"

Also rotate the log:
vi /etc/newsyslog.conf

Add the following line:
/var/log/reboot_if_idle.log             640  7     1000 *     JC

Add this line to crontab:
00 10 *    *    *    /usr/local/bin/reboot_if_idle.sh "/var/log/reboot_if_idle.log" "120" "/bin/echo Reboot!" "1"
