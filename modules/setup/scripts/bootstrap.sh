#!/bin/bash

# Variables
USER_NAME=opc
USER_HOME=/home/${USER_NAME}
APP_NAME=$1
WALLET_PASSWORD=$2
INSTALL_LOG_FILE_NAME=install-${APP_NAME}.log
INSTALL_LOG_FILE=${USER_HOME}/${INSTALL_LOG_FILE_NAME}
SSHD_BANNER_FILE=/etc/ssh/sshd-banner
SSHD_CONFIG_FILE=/etc/ssh/sshd_config

INSTALLATION_IN_PROGRESS="
    #################################################################################################
    #                                           WARNING!                                            #
    #   ${APP_NAME} Installation is still in progress.                                              #
    #   To check the progress of the installation run -> tail -f ${INSTALL_LOG_FILE_NAME}           #
    #################################################################################################
"

USAGE_INFO="
    =================================================================================================
                                        Welcome to ${APP_NAME}
    =================================================================================================
"

start=`date +%s`

# yum install packages are listed here. This same list is used for update too
PACKAGES_TO_INSTALL=(
    git
    sqlcl
)

# Log file
sudo -u ${USER_NAME} touch ${INSTALL_LOG_FILE}
sudo -u ${USER_NAME} chmod +w ${INSTALL_LOG_FILE}

# Sending all stdout and stderr to log file
exec >> ${INSTALL_LOG_FILE}
exec 2>&1

echo "Installing ${APP_NAME}"
echo "------------------------"

echo "Creating sshd banner"
sudo touch ${SSHD_BANNER_FILE}
sudo echo "${INSTALLATION_IN_PROGRESS}" | sudo tee -a  ${SSHD_BANNER_FILE} > /dev/null
sudo echo "${USAGE_INFO}" | sudo tee -a  ${SSHD_BANNER_FILE} > /dev/null
sudo echo "Banner ${SSHD_BANNER_FILE}" | sudo tee -a  ${SSHD_CONFIG_FILE} > /dev/null
sudo systemctl restart sshd.service

####### Installing yum packages #########

echo "Packages to install ${PACKAGES_TO_INSTALL[@]}"
sudo yum -y install ${PACKAGES_TO_INSTALL[@]} && echo "#################### Successfully installed all yum packages #####################"

####### Installing yum packages -End #########



####### Adding environment variables #########
sudo -u ${USER_NAME} echo 'alias sql="/opt/oracle/sqlcl/bin/sql"' >> ${USER_HOME}/.bashrc

sudo -u ${USER_NAME} echo "export TF_VAR_tenancy_ocid=$(oci-metadata -g tenancy_id --value-only)" >> ${USER_HOME}/.bashrc
####### Adding environment variables - End #########

################ Setup Wallet #################
sudo mkdir -p /opt/oracle/wallet
sudo mv /tmp/autonomous_database_wallet.zip /opt/oracle/wallet/
sudo unzip /opt/oracle/wallet/autonomous_database_wallet.zip -d /opt/oracle/wallet/
echo 'export TNS_ADMIN=/opt/oracle/wallet/' >> ${USER_HOME}/.bashrc
source ${USER_HOME}/.bashrc

sudo sed -i -e 's|oracle.net.wallet_location=|'"# oracle.net.wallet_location="'|' \
-e 's|#javax.net.ssl.|'"javax.net.ssl."'|' \
-e 's|<password_from_console>|'"${WALLET_PASSWORD}"'|' \
/opt/oracle/wallet/ojdbc.properties
###############################################

end=`date +%s`

executionTime=$((end-start))

echo "--------------------------------------------------------------"
echo "Installation of ${APP_NAME} is complete. (Took ${executionTime} seconds)"

sudo echo "${USAGE_INFO}" | sudo tee ${SSHD_BANNER_FILE} > /dev/null

# exec -l $SHELL