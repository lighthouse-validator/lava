# Join testnet - Manual setup with Cosmovisor
## Prerequisites
1. Verify hardware requirements are met
2. Install package dependencies

    * Note: You may need to run as sudo
    * Required packages installation

       ```
       ### Packages installations  
       sudo apt update # in case of permissions error, try running with sudo  
       sudo apt install -y unzip logrotate git jq sed wget curl coreutils systemd  

       ### Create the temp dir for the installation  
       temp_folder=$(mktemp -d) && cd $temp_folder
       ```
 
   * Go installation

      ```
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
      source ~/.profile
      ```
   
    * Installation verifications

       a. You can verify the installed go version by running: go version  
       b. The command go env GOPATH should include $HOME/go If not, then, export GOPATH=$HOME/go  
       c. PATH should include $HOME/go/bin To verify PATH, run echo $PATH  

## 1. Set up a local node
### Download app configurations
   * Download setup configuration Download the configuration files needed for the installation
      ```
      # Download the installation setup configuration
      git clone https://github.com/lavanet/lava-config.git
      cd lava-config/testnet-1
      # Read the configuration from the file
      # Note: you can take a look at the config file and verify configurations
      source setup_config/setup_config.sh
      ```
   * Set app configurations Copy lavad default config files to config Lava config folder
      ```
      echo "Lava config file path: $lava_config_folder"
      mkdir -p $lavad_home_folder
      mkdir -p $lava_config_folder
      cp default_lavad_config_files/* $lava_config_folder
      ```
   ### Set the genesis file
   * Set the genesis file in the configuration folder
      ```
      # Copy the genesis.json file to the Lava config folder
      cp genesis_json/genesis.json $lava_config_folder/genesis.json
      ```
      
   ## 2. Join the Lava Testnet

   The following sections will describe how to install Cosmovisor for automating the upgrades process.
   
   ### Set up Cosmovisor

   * Set up cosmovisor to ensure any future upgrades happen flawlessly. To install Cosmovisor:
      ```
      go install github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@v1.0.0
      # Create the Cosmovisor folder and copy config files to it
      mkdir -p $lavad_home_folder/cosmovisor
      # Download the latest cosmovisor-upgrades from S3
      wget https://lava-binary-upgrades.s3.amazonaws.com/testnet/cosmovisor-upgrades/cosmovisor-upgrades.zip
      unzip cosmovisor-upgrades.zip
      cp -r cosmovisor-upgrades/* $lavad_home_folder/cosmovisor
      ```
      ```
      # Set the environment variables
      echo "# Setup Cosmovisor" >> ~/.profile
      echo "export DAEMON_NAME=lavad" >> ~/.profile
      echo "export CHAIN_ID=lava-testnet-1" >> ~/.profile
      echo "export DAEMON_HOME=$HOME/.lava" >> ~/.profile
      echo "export DAEMON_ALLOW_DOWNLOAD_BINARIES=true" >> ~/.profile
      echo "export DAEMON_LOG_BUFFER_SIZE=512" >> ~/.profile
      echo "export DAEMON_RESTART_AFTER_UPGRADE=true" >> ~/.profile
      echo "export UNSAFE_SKIP_BACKUP=true" >> ~/.profile
      source ~/.profile
      ```
      ```     
      # Initialize the chain
      $lavad_home_folder/cosmovisor/genesis/bin/lavad init \
      my-node \
      --chain-id lava-testnet-1 \
      --home $lavad_home_folder \
      --overwrite
      cp genesis_json/genesis.json $lava_config_folder/genesis.json
      ```

      :::caution Please note that cosmovisor will throw an error ⚠️ This is ok. The following error will be thrown, lstat /home/ubuntu/.lava/cosmovisor/current/upgrade-info.json: no such file or directory :::
      ```
      cosmovisor version
      ```
      Create the systemd unit file
      ```
      # Create Cosmovisor unit file

      echo "[Unit]
      Description=Cosmovisor daemon
      After=network-online.target
      [Service]
      Environment="DAEMON_NAME=lavad"
      Environment="DAEMON_HOME=${HOME}/.lava"
      Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
      Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
      Environment="DAEMON_LOG_BUFFER_SIZE=512"
      Environment="UNSAFE_SKIP_BACKUP=true"
      User=$USER
      ExecStart=${HOME}/go/bin/cosmovisor start --home=$lavad_home_folder --p2p.seeds $seed_node
      Restart=always
      RestartSec=3
      LimitNOFILE=infinity
      LimitNPROC=infinity
      [Install]
      WantedBy=multi-user.target
      " >cosmovisor.service
      sudo mv cosmovisor.service /lib/systemd/system/cosmovisor.service
      ```
   ### Download the latest Lava data snapshot (optional)

   *Coming soon*
   
   ### Enable and start the Cosmovisor service
   
   * Configure the Cosmovisor service to run on boot, and start it  
      
      ```
      # Enable the cosmovisor service so that it will start automatically when the system boots
      sudo systemctl daemon-reload
      sudo systemctl enable cosmovisor.service
      sudo systemctl restart systemd-journald
      sudo systemctl start cosmovisor
      ```
## 3. Verify

### Verify `cosmovisor` setup

Make sure cosmovisor is running by checking the state of the cosmovisor service:

   * Check the status of the service
      ```
      sudo systemctl status cosmovisor
      ```
   * To view the service logs - to escape, hit CTRL+C
      ```
      sudo journalctl -u cosmovisor -f
      ```
### Verify node status

Note the location of lavad now exists under cosmovisor path:

   ```
   # Check if the node is currently in the process of catching up
   $HOME/.lava/cosmovisor/current/bin/lavad status | jq .SyncInfo.catching_up 
   ```    
   
# Run Validator - Manual setup
### 1. Install node (lavad) & Join network

Running as a validator requires a Lava Node running, Please refer to our guide for joining Testnet for details.

### 2. Prepare an account & Fund it

If you don't have an account (wallet) on Lava yet, Refer to creating new accounts and the faucet.

### 3. Stake & start validating

Once your account is funded, run this to stake and start validating.

  1. Verify that your node has finished synching and it is caught up with the network
      
       ```
       $current_lavad_binary status | jq .SyncInfo.catching_up
       # Wait until you see the output: "false"
       ```
    
  2. Verify that your account has funds in it in order to perform staking
     
      ```
      # Make sure you can see your account name in the keys list
      $current_lavad_binary keys list

      # Make sure you see your account has Lava tokens in it
      YOUR_ADDRESS=$($current_lavad_binary keys show -a $ACCOUNT_NAME)
      $current_lavad_binary query \
         bank balances \
           $YOUR_ADDRESS \
           --denom ulava
     ```
    
  3. Back up your validator's consensus key

       A validator participates in the consensus by sending a message signed by a consensus key which is automatically generated when you first run a node. You must create a backup of this consensus key in case that you migrate your validator to another server or accidentally lose access to your validator.

       A consensus key is stored as a json file in $lavad_home_folder/config/priv_validator_key.json by default, or a custom path specified in the parameter priv_validator_key_file of config.toml.

  4. Stake validator

       Here's an example with Values which starts with a stake of 50000000ulava. Replace <<moniker_node>> With a human readable name you choose for your validator.
   
   ```
   $current_lavad_binary tx staking create-validator \
       --amount="50000000ulava" \
       --pubkey=$($current_lavad_binary tendermint show-validator --home "$HOME/.lava/") \
       --moniker="<<moniker_node>>" \
       --chain-id=lava-testnet-1 \
       --commission-rate="0.10" \
       --commission-max-rate="0.20" \
       --commission-max-change-rate="0.01" \
       --min-self-delegation="10000" \
       --gas="auto" \
       --gas-adjustment "1.5" \
       --gas-prices="0.05ulava" \
       --home="$HOME/.lava/" \
       --from=$ACCOUNT_NAME
   ```
   Once you have finished running the command above, if you see code: 0 in the output, the command was successful

  5. Verify validator setup

      ```
      block_time=60
      # Check that the validator node is registered and staked
      validator_pubkey=$($current_lavad_binary tendermint show-validator | jq .key | tr -d '"')

      $current_lavad_binary q staking validators | grep $validator_pubkey

      # Check the voting power of your validator node - please allow 30-60 seconds for the output to be updated
      sleep $block_time
      $current_lavad_binary status | jq .ValidatorInfo.VotingPower | tr -d '"'
      # Output should be > 0
      ```
 ___________________________________________________
   
 Source: https://docs.lavanet.xyz/testnet-manual-cosmovisor  
        https://docs.lavanet.xyz/validator-manual
 
