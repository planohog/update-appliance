#!/bin/bash
##
C50="#################################################"
CH204=""  # final display for chk204
CH240=""  # final display for chk240
FVERSION=""
#######################################################
function finaldisplay {
echo "${C50}"
echo "${FVERSION}"
echo "${C50}"
echo "${CH204}"
echo "${CH240}"
echo "syslog restarted ..."
echo "${C50}"
echo "${C50}"
}
#######################################################
function backwsm {
 /sbin/iptables-save > /home/albert/iptables-save-restore.txt
##  /sbin/iptables-restore < /path/to/savefile ##
sudo cat /etc/sysconfig/iptables > /home/albert/iptables.backup
sudo iptables -nL > /home/albert/iptables-nl.txt
sudo cat /wsm/log/ipsets.saved  > /home/albert/ipsets.saved
sudo rsync -a /etc/sysconfig/ /tmp/sysconfig/
sudo perl /wsm/bin/backup.pl 2
echo "Safety Backup done...."
}
#######################################################
function checkfiles {
if [ -f $1 ] && [ -f $2 ] ; then
 cmp -s $1 $2 > /dev/null
 if [ $? -eq 1 ]; then
    echo "$1 and $2 are different"
 else
    echo "$1 and $2 are equal "
 fi
fi
}
#######################################################
function testfiles {
echo ${C50}
echo ${C50}
checkfiles /etc/sysconfig/iptables /home/albert/iptables.backup
checkfiles /wsm/log/ipsets.saved /home/albert/ipsets.saved
sudo iptables -nL > /tmp/iptables-nl2.txt
checkfiles /tmp/iptables-nl2.txt /home/albert/iptables-nl.txt
echo ${C50}
echo ${C50}
}
#######################################################
function yumupdate {
sudo yum clean all
sudo yum makecache
#sudo yum --disablerepo=* --enablerepo=WSM1,CentOS
sudo yum update al-wsm-sensor
##sudo sudo yum upgrade al-wsm-sensor-4.4.3.1
FVERSION=$(cat /wsm/bin/VERSION )
echo "YUM Done...."
}
#######################################################
function  chk204 {
ISIT=0
sudo iptables -nL | grep -c "204.110.218\|204.110.219"
ISIT=$(sudo iptables -nL | grep -c "204.110.218\|204.110.219")
if [ ${ISIT} -gt 0 ];  then
CH204=$(echo "204.110.218\|204.110.219 test [OK] ")
else
CH204=$(echo "204.110.218\|204.110.219 test [FAIL] ")
fi
}
#######################################################
function chk240  {
ISIT=0
sudo iptables -nL -t nat |grep "to:240."
ISIT=$(sudo iptables -nL -t nat |grep -c "to:240." )
if [ ${ISIT} -gt 0 ] ; then
CH240=$(echo "IPTABLES ROUTE 240 [PRESENT]")
else
CH240=$(echo "IPTABLES ROUTE 240 [NOT-PRESENT] MUST FOR ROUTING MODE NOT REVERSE MODE")
fi
}
#######################################################
function restartsyslog {
sudo /etc/init.d/syslog-ng stop
sudo /etc/init.d/syslog-ng start
}
#################################################
################ MAIN ###########################
#################################################
backwsm
yumupdate
chk204
chk240
restartsyslog
testfiles
finaldisplay
#################################################
