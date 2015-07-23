#!/bin/bash
IS_CONF_FILE=${IS_CONF_FILE-"/usr/local/lib/installscripts/.installscripts.conf"}
export IS_CONF_FILE
. $IS_CONF_FILE


printf "\033c"
yn_changehostname="n";
if [ -f /etc/init.d/baserhel7 ]; then 
	[[ -n `service baserhel7 istemplate | grep -e "I'm a template"` ]] && read -p "Do you want to change VM hostname (y\\n) [$yn_changehostname]: " yn_changehostname_input
else
	read -p "Do you want to change VM hostname (y\\n) [$yn_changehostname]: " yn_changehostname_input
fi

[ -n "$yn_changehostname_input" ] && yn_changehostname=$yn_changehostname_input


if [[ Yy == *$yn_changehostname* ]]; then
	while true; do
			skip=true;
			read -p "Please enter new hostname: " newhostname
			read -p "Are you sure you want to change the hostname to $newhostname (y\\n\\s (skip)\\e (exit)? " yn
			case $yn in
				[Ss]* ) skip=true; break;;
				[Yy]* ) skip=false; break;;
				[Ee]* ) echo "Exiting installation " ; exit;;
				[Nn]* ) ;;
				* ) ;;
			esac
	done
	if [[ $skip == false ]]; then
		echo "Changing hostname `eval hostname` to $newhostname"
		wget -qN $FILE_SERVER_PATH/.changehostname.sh
		chmod +x .change_hostname_RHEL6.4.sh
		./.change_hostname_RHEL6.4.sh --new-host-name=$newhostname
		hostname $newhostname
		while true; do
			yn_reboot="S";
			echo -e "**** Recommended! ****"
			echo -e "Shutdown the VM and take snapshot this will allow you to reuse the VM and update or change your template periodically"
			read -p "Please shutdown and take snapshot or restart to continue without snapshot - r (restart) \\ s (shutdown) [$yn_reboot]: " yn_reboot_input
			[ -n "$yn_reboot_input" ] && yn_reboot=$yn_reboot_input

			if [[ Rr == *$yn_reboot* ]]; then
				sudo reboot
				break
			elif [[ Ss == *$yn_reboot* ]]; then
				sudo poweroff
				break
			fi
		done
	fi
fi

cd $IS_DIR
yn_installtemplate="y";
read -t 30 -p "Do you want to install VM template (y\\n) [$yn_installtemplate]: " yn_installtemplate_input
[ -n "$yn_installtemplate_input" ] && yn_installtemplate=$yn_installtemplate_input

if [[ Yy == *$yn_installtemplate* ]]; then
	wget -N $FILE_SERVER_PATH/.installMachineTemplate.sh
	chmod +x ./.installMachineTemplate.sh
	./.installMachineTemplate.sh ${@:1}
fi

yn_reboot="n";
read -t 30 -p "Restarting your computer is required (y (restart)\\s (shutdown)\\n (restart later)) [$yn_reboot]: " yn_reboot_input
[ -n "$yn_reboot_input" ] && yn_reboot=$yn_reboot_input

if [[ Yy == *$yn_reboot* ]]; then
	sudo reboot
elif [[ Ss == *$yn_reboot* ]]; then
	sudo poweroff
fi

exit 0
