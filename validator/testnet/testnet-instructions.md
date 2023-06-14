# Join testnet - Manual setup with Cosmovisor
## Prerequisites
1. Verify hardware requirements are met
2. Install package dependencies

    * Note: You may need to run as sudo
    * Required packages installation

    ```### Packages installations  
    sudo apt update # in case of permissions error, try running with sudo  
    sudo apt install -y unzip logrotate git jq sed wget curl coreutils systemd  
    
    ### Create the temp dir for the installation  
    temp_folder=$(mktemp -d) && cd $temp_folder```

    * Go installation

### Configurations
go_package_url="https://go.dev/dl/go1.18.linux-amd64.tar.gz"
go_package_file_name=${go_package_url##*\/}
# Download GO
wget -q $go_package_url
# Unpack the GO installation file
sudo tar -C /usr/local -xzf $go_package_file_name
# Environment adjustments
echo "export PATH=\$PATH:/usr/local/go/bin" >>~/.profile
echo "export PATH=\$PATH:\$(go env GOPATH)/bin" >>~/.profile
source ~/.profile`

    * Installation verifications

    a. You can verify the installed go version by running: go version
    b. The command go env GOPATH should include $HOME/go If not, then, export GOPATH=$HOME/go
    c. PATH should include $HOME/go/bin To verify PATH, run echo $PATH
