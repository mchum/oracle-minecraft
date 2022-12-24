#!/bin/bash
set -x

installer_filename='installer.jar'
server_dir='/fabric'
mc_version='1.19.2'
installer_version='0.11.1'

# Download dependencies
sudo apt update && sudo apt upgrade
sudo apt install -y openjdk-17-jre-headless wget

# Download the server installer
mkdir -p "${server_dir}"
wget -O "${server_dir}/${installer_filename}" "https://maven.fabricmc.net/net/fabricmc/fabric-installer/${installer_version}/fabric-installer-${installer_version}.jar"

# Install the server and remove the installer
cd "${server_dir}"
java -jar "${server_dir}/${installer_filename}" server \
    -mcversion "${mc_version}" -downloadMinecraft
rm "${server_dir}/${installer_filename}"

# Auto agree to EULA
echo 'eula=true' > 'eula.txt'

# Run the server
java -jar "${server_dir}/fabric-server-launch.jar"