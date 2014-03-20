#!/bin/bash
# ipcop Update Accelerator Log addon binary installer Ver 1.0.0 for IPCop 2.0.x and UpdateXlrator 2.2.1
#
# created 07 March 2014 by Umberto 'joeyramone76' Miceli <joeyramone76@altervista.org>
#
#
# $Id: install.sh v 1.0.1 2014-03-07 17:56:23Z joeyramone76 $
#

SCRIPTPATH=`dirname $0`
CMD="$1"

STEP=1
UPDATE=0

UPDLOGVER=1.0.1
UPDLOGURL=http://joeyramone76.altervista.org/updxlrlog/latest
LOGDIR="/var/log/updxlrlog"


#error handling
err()
{
    echo " "
    echo "Error : $1 "
    echo " "
    echo "Choose your option:"
    echo " "
    echo "./install -i   ---> to install"
    echo "./install -u   ---> to uninstall"
    echo " "
    exit
}


# installation
ai()
{
    echo ""
    echo "===================================================="
    echo "  IPCop 2.0 Update Accelerator Log 1.0.0 add-on installation"
    echo "===================================================="
    echo ""

    
	## verify if updatexlrator is installed
    if [ ! -e /usr/sbin/updxlrator ]; then
        
		echo "UPDATE ACCELLERATOR addon is not installed! Setup terminated"
		exit 1
    fi

    echo "Step $STEP: Creating directories"
    echo "--------------------------------------------"

    for DIR in /var/ipcop/addons/updxlrlog 
    do
        echo "$DIR"
        if [ ! -d $DIR ]; then
            mkdir $DIR
        fi
    done

    echo " "
    let STEP++



    echo "Step $STEP: Patching system files"
    echo "--------------------------------------------"

    echo "Patching language files"
    addtolanguage UpdatXlrLog en,it $SCRIPTPATH/langs

    echo " "
    let STEP++



    echo "Step $STEP: Copying files"
    echo "--------------------------------------------"

    echo "/home/httpd/cgi-bin/updxlrlog.cgi"
    addcgi $SCRIPTPATH/cgi/updxlrlog.cgi
	
    echo "/var/ipcop/addons/updxlrlog/updxlrlog-lib.pl"
    cp $SCRIPTPATH/cgi/updxlrlog-lib.pl /var/ipcop/addons/updxlrlog/updxlrlog-lib.pl

	echo "/var/ipcop/proxy/updxlrlog/viewersettings"
    cp $SCRIPTPATH/setup/viewersettings /var/ipcop/addons/updxlrlog/viewersettings
    
    echo "/var/ipcop/addons/updxlrlog/version"
    echo "$UPDLOGVER" > /var/ipcop/addons/updxlrlog/version
 

    rm -rf /var/ipcop/addons/updxlrlog/latestVersion
	
	touch -t 201402100000 /var/ipcop/addons/updxlrlog/.up2date

    echo " "
    let STEP++


    echo "Step $STEP: Setting ownerships and permissions"
    echo "--------------------------------------------"

    echo "Setting ownership and permissions (updxlrlog)"
    chown -R nobody:nobody /var/ipcop/addons/updxlrlog

    
    echo " "
    let STEP++


    if [ "$UPDATE" == 1 ]; then

        echo " "
    fi

    echo " "
}

# deinstallation
au()
{

    echo "===================================================="
    echo "  IPCop 2.0 updxlrlog Log 1.0.0 add-on uninstall"
    echo "===================================================="
    echo ""

    if [ ! -e "/home/httpd/cgi-bin/updxlrlog.cgi" ] && [ ! -d "/var/ipcop/addons/updxlrlog" ]; then
        echo "ERROR: updxlrlog Log add-on is not installed."
        exit
    fi


    echo "Step $STEP: Removing directories"
    echo "--------------------------------------------"

    for DIR in /var/ipcop/addons/updxlrlog 
    do
        echo "$DIR"
        if [ -d "$DIR" ]; then
            rm -rf $DIR
        fi
    done

    echo ""
    let STEP++


    echo "Step $STEP: Deleting updxlrlog files"
    echo "--------------------------------------------"

    echo "/home/httpd/cgi-bin/updxlrlog.cgi"
    removecgi updxlrlog.cgi

	echo "/home/httpd/cgi-bin/updxlrlog-lib.pl"
	rm -f /home/httpd/cgi-bin/updxlrlog-lib.pl
	
    echo ""
    let STEP++


    echo "Step $STEP: Restoring system files"
    echo "--------------------------------------------"

   
    echo "Removing language texts"
    removefromlanguage UpdatXlrLog

    echo ""
    let STEP++

}


if [ ! -e /usr/lib/ipcop/library.sh ]; then
    echo "Upgrade your IPCop, library.sh is missing"
    exit 1
fi

. /usr/lib/ipcop/library.sh

# check IPCop version
VERSIONOK=1
if [ 0$LIBVERSION -ge 2 ]; then
    isversion 2.0.3 newer
    VERSIONOK=$?
fi
#DEBUG:
#echo "VERSIONOK: $VERSIONOK"
if [ $VERSIONOK -ne 0 ]; then
    echo "Upgrade your IPCop, this Addon requires at least IPCop 2.0.3"
    exit 1
fi


case $CMD in
    -i|i|install)
        echo " "
        ai
        echo " "
        ;;

    -u|u|uninstall)
        echo " "
        au
        echo " "
        ;;

    *)
        err "Invalid Option"
        ;;
esac
sync

#end of file
