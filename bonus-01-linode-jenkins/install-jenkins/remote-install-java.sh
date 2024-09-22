#/bin/bash

# load key value pairs from config file
source remote.properties
source ../.env

# ssh into remote with newly created user to download Java and Gradle
ssh $ROOT_USER@$REMOTE_ADDRESS <<EOF
apt-get update
apt-get install -y openjdk-17-jdk-headless

which_java=\$(which java)
installations=\$(java --version)

if [ -z "\$installations" ] || [ -z "\$which_java" ]
  then
    is_java_installed=false
  else
    is_java_installed=true
fi

if [ "\$is_java_installed" = true ]
  then
    echo "java install path: \$which_java"
    echo -e "installed java versions: \n\$installations"
  else
    echo "no java version installed"
fi

#head -n 1: Takes the first line of input
#awk -F '"' '{print \$2}': Splits Input by double quote character and prints the second field
java_version_num=\$(java -version 2>&1 | grep -i version | head -n 1 | awk -F '"' '{print \$2}')

#awk -F '.' '{print \$1}': splits the input by dots and prints the first field
java_major_version=\$( echo \$java_version_num | awk -F '.' '{print \$1}' )

if [ ! -z "\$java_major_version" ] && [ "\$java_major_version" -ge 11 ]
  then
    installation_successful=true
    echo "Java Installation Successful."
    echo "java major version: \$java_major_version"
  else
    installation_successful=false
    echo "Installation error. Java Major Version 11 or greater not installed."
fi

EOF
