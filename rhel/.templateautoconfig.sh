#!/bin/bash
. $1

CP $1 $IS_DIR/
wget -qN $IS_REPO_PATH/installMachineTemplate.sh -P $IS_DIR/
chmod +x $IS_DIR/installMachineTemplate.sh

