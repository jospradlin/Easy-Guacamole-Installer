#!/bin/bash
#######################################################################################################################
# Add Duo (MFA) support to Guacamole
# For Ubuntu / Debian / Raspbian
# David Harrop
# April 2023
#######################################################################################################################

# If run as standalone and not from the main installer script, check the below variables are correct.

# Prepare text output colours
GREY='\033[0;37m'
DGREY='\033[0;90m'
GREYB='\033[1;37m'
LRED='\033[0;91m'
LGREEN='\033[0;92m'
LYELLOW='\033[0;93m'
NC='\033[0m' #No Colour

clear

if ! [[ $(id -u) = 0 ]]; then
    echo
    echo -e "${LGREEN}Please run this script as sudo or root${NC}" 1>&2
    exit 1
fi
TOMCAT_VERSION=$(ls /etc/ | grep tomcat)
GUAC_VERSION=$(grep -oP 'Guacamole.API_VERSION = "\K[0-9\.]+' /var/lib/${TOMCAT_VERSION}/webapps/guacamole/guacamole-common-js/modules/Version.js)
GUAC_SOURCE_LINK="http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VERSION}"

echo
wget -q --show-progress -O guacamole-auth-sso-${GUAC_VERSION}.tar.gz ${GUAC_SOURCE_LINK}/binary/guacamole-auth-ssjo-${GUAC_VERSION}.tar.gz
tar -xzf guacamole-auth-sso-${GUAC_VERSION}.tar.gz
mv -f guacamole-auth-sso-${GUAC_VERSION}/openid/guacamole-auth-sso-openid-${GUAC_VERSION}.jar /etc/guacamole/extensions/
chmod 664 /etc/guacamole/extensions/guacamole-auth-sso-openid-${GUAC_VERSION}.jar
echo -e "${LGREEN}Installed guacamole-auth-sso-openid-${GUAC_VERSION}${GREY}"
echo "openid-authorization-endpoint: " >>/etc/guacamole/guacamole.properties
echo "openid-jwks-endpoint: " >>/etc/guacamole/guacamole.properties
echo "openid-issuer: " >>/etc/guacamole/guacamole.properties
echo "openid-client-id: " >>/etc/guacamole/guacamole.properties
echo "openid-redirect-uri: " >>/etc/guacamole/guacamole.properties
echo
systemctl restart ${TOMCAT_VERSION}
systemctl restart guacd

echo -e "${LYELLOW}You must now set up your online OpenID/Okta account with a new 'Application' record."
echo
echo "Next you must copy the API settings from your Okta/OpenID account into /etc/guacamole/guacamole.properties in the EXACT below format."
echo -e "Be VERY careful to avoid extra trailing spaces or other line feed characters when pasting!${GREY}"
echo
echo "openid-authorization-endpoint: ??????????"
echo "openid-jwks-endpoint: ??????????"
echo "openid-issuer: ??????????"
echo "openid-client-id: ??????????"
echo "openid-redirect-uri: ??????????"
echo
echo "Once this change is complete, restart Guacamole with sudo systemctl restart ${TOMCAT_VERSION}"

rm -rf guacamole-*

echo
echo -e ${NC}
