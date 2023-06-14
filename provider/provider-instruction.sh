rpcprovider.yml должен лежать в домашней директории cd ~

#стейкаем на LAV1

lavad tx pairing stake-provider "LAV1" "50006000000ulava" "123.45.67.890:2221,tendermintrpc,2 123.45.67.890:2221,rest,2 123.45.67.890,grpc,2" 2 --from lighthouse --provider-moniker Lighthouse --keyring-backend "test" --chain-id "lava-testnet-1" --gas="auto" --gas-adjustment "1.5" --fees 6000ulava --node "https://public-rpc.lavanet.xyz:443/rpc/"

// 123.45.67.890:2221 - указывается ip нашего сервера где все это запускаем
// в rpcprovider.yml указваем network-address: 0.0.0.0:2221 - порт который будет прослушиваться
//
//  node-urls:
//      - url: http://123.xx.xx.890:1307   - указывается ip и порт того сервера, где находится сеть которую мы предоставляем
// т.е. если это Lava - то указвыается ip нашего сервера, а если это не Lava а другая сеть - то будет ip того сервера где 
// стоит другая сеть
//


# запускаем провайдера

lavad rpcprovider rpcprovider.yml --from lighthouse --geolocation 2


# информация о провайдере

lavad query pairing account-info \
--from lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp \
--node "https://public-rpc.lavanet.xyz:443/rpc/"

# тест провайдера

lavad test rpcprovider lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp

lavad test rpcprovider --from lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp --endpoints "123.45.67.890:2221,rest,LAV1 123.45.67.890:2221,tendermintrpc,LAV1 123.45.67.890:2221,grpc,LAV1" --node https://public-rpc.lavanet.xyz:443/rpc/


// создаем сервис-демона для провайдера!!!! чтобы всегда работал

echo "[Unit]
Description=Provider LAV1 daemon
After=network-online.target
[Service]
User=$USER
ExecStart=lavad rpcprovider rpcprovider.yml --from lighthouse --geolocation 2 --chain-id lava-testnet-1
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
" >lava-provider-LAV1.service
sudo mv lava-provider-LAV1.service /lib/systemd/system/lava-provider-LAV1.service

sudo systemctl daemon-reload
sudo systemctl enable lava-provider-LAV1.service
sudo systemctl restart systemd-journald
sudo systemctl start lava-provider-LAV1

sudo journalctl -u lava-provider-LAV1 -f


sudo systemctl stop lava-provider-LAV1
sudo systemctl restart lava-provider-LAV1

# unjail

lavad tx slashing unjail --from lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp --chain-id lava-testnet-1 --fees 500ulava -y


////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////   CANTO  ///////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

lavad tx pairing stake-provider "CANTO" \
"50006000000ulava" \
"123.45.67.890:2231,tendermintrpc,2 123.45.67.890:2231,rest,2 123.45.67.890:2231,grpc,2 123.45.67.890:2231,jsonrpc,2" 2 \
--from lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp \
--provider-moniker Lighthouse \
--keyring-backend "test" \
--chain-id "lava-testnet-1" \
--gas="auto" \
--gas-adjustment "1.5" \
--fees 6000ulava \
--node "https://public-rpc.lavanet.xyz:443/rpc/"

# информация о провайдере

lavad query pairing account-info \
--from lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp \
--node "https://public-rpc.lavanet.xyz:443/rpc/"

# запускаем провайдера

lavad rpcprovider rpcprovider-canto.yml --from lighthouse --geolocation 2




# тест провайдера

lavad test rpcprovider lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp



echo "[Unit]
Description=Provider CANTO daemon
After=network-online.target
[Service]
User=$USER
ExecStart=lavad rpcprovider rpcprovider-canto.yml --from lighthouse --geolocation 2 --chain-id lava-testnet-1
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
" >lava-provider-CANTO.service
sudo mv lava-provider-CANTO.service /lib/systemd/system/lava-provider-CANTO.service

sudo systemctl daemon-reload
sudo systemctl enable lava-provider-CANTO.service
sudo systemctl restart systemd-journald
sudo systemctl start lava-provider-CANTO

sudo journalctl -u lava-provider-CANTO -f

sudo systemctl stop lava-provider-CANTO
sudo systemctl restart lava-provider-CANTO


lavad tx pairing unstake-provider CANTO --from lighthouse --account-number 4158 --chain-id "lava-testnet-1"


////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////   ETH  /////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

lavad tx pairing stake-provider "ETH1" \
"100012000000ulava" \
"123.45.67.890:2241,jsonrpc,2" 2 \
--from lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp \
--provider-moniker Lighthouse \
--keyring-backend "test" \
--chain-id "lava-testnet-1" \
--gas="auto" \
--gas-adjustment "1.5" \
--fees 6000ulava \
--node "https://public-rpc.lavanet.xyz:443/rpc/"

# информация о провайдере

lavad query pairing account-info \
--from lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp \
--node "https://public-rpc.lavanet.xyz:443/rpc/"

# запускаем провайдера

lavad rpcprovider rpcprovider-eth.yml --from lighthouse --geolocation 2


# тест провайдера

lavad test rpcprovider lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp



echo "[Unit]
Description=Provider ETH daemon
After=network-online.target
[Service]
User=$USER
ExecStart=lavad rpcprovider rpcprovider-eth.yml --from lighthouse --geolocation 2 --chain-id lava-testnet-1
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
" >lava-provider-ETH.service
sudo mv lava-provider-ETH.service /lib/systemd/system/lava-provider-ETH.service

sudo systemctl daemon-reload
sudo systemctl enable lava-provider-ETH.service
sudo systemctl restart systemd-journald
sudo systemctl start lava-provider-ETH

sudo journalctl -u lava-provider-ETH -f

sudo systemctl stop lava-provider-ETH
sudo systemctl restart lava-provider-ETH


////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////   ARB Mainet ///////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

lavad tx pairing stake-provider "ARB1" \
"50006000000ulava" \
"123.45.67.890:2251,jsonrpc,2" 2 \
--from lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp \
--provider-moniker Lighthouse \
--keyring-backend "test" \
--chain-id "lava-testnet-1" \
--gas="auto" \
--gas-adjustment "1.5" \
--fees 6000ulava \
--node "https://public-rpc.lavanet.xyz:443/rpc/"

# информация о провайдере

lavad query pairing account-info \
--from lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp \
--node "https://public-rpc.lavanet.xyz:443/rpc/"

# запускаем провайдера

lavad rpcprovider rpcprovider-arb.yml --from lighthouse --geolocation 2


# тест провайдера

lavad test rpcprovider lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp
lavad test rpcprovider --from lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp --endpoints "123.45.67.890:2251,jsonrpc,ARB1" --node https://public-rpc.lavanet.xyz:443/rpc/ 


echo "[Unit]
Description=Provider ARB daemon
After=network-online.target
[Service]
User=$USER
ExecStart=lavad rpcprovider rpcprovider-arb.yml --from lighthouse --geolocation 2 --chain-id lava-testnet-1
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
" >lava-provider-ARB.service
sudo mv lava-provider-ARB.service /lib/systemd/system/lava-provider-ARB.service

sudo systemctl daemon-reload
sudo systemctl enable lava-provider-ARB.service
sudo systemctl restart systemd-journald
sudo systemctl start lava-provider-ARB

sudo journalctl -u lava-provider-ARB -f

sudo systemctl stop lava-provider-ARB
sudo systemctl restart lava-provider-ARB


////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////   POLYGON Mainet ///////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

lavad tx pairing stake-provider "POLYGON1" \
"50006000000ulava" \
"123.45.67.890:2231,jsonrpc,2" 2 \
--from lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp \
--provider-moniker Lighthouse \
--keyring-backend "test" \
--chain-id "lava-testnet-1" \
--gas="auto" \
--gas-adjustment "1.5" \
--fees 6000ulava \
--node "https://public-rpc.lavanet.xyz:443/rpc/"

# информация о провайдере

lavad query pairing account-info \
--from lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp \
--node "https://public-rpc.lavanet.xyz:443/rpc/"

# запускаем провайдера

lavad rpcprovider rpcprovider-poly.yml --from lighthouse --geolocation 2


# тест провайдера

lavad test rpcprovider lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp
lavad test rpcprovider --from lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp --endpoints "123.45.67.890:2231,jsonrpc,POLYGON1" --node https://public-rpc.lavanet.xyz:443/rpc/ 


echo "[Unit]
Description=Provider POLYGON daemon
After=network-online.target
[Service]
User=$USER
ExecStart=lavad rpcprovider rpcprovider-poly.yml --from lighthouse --geolocation 2 --chain-id lava-testnet-1
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
" >lava-provider-POLYGON.service
sudo mv lava-provider-POLYGON.service /lib/systemd/system/lava-provider-POLYGON.service

sudo systemctl daemon-reload
sudo systemctl enable lava-provider-POLYGON.service
sudo systemctl restart systemd-journald
sudo systemctl start lava-provider-POLYGON

sudo journalctl -u lava-provider-POLYGON -f

sudo systemctl stop lava-provider-POLYGON
sudo systemctl restart lava-provider-POLYGON


lavad tx pairing unstake-provider POLYGON1 --from lighthouse --account-number 4158 --chain-id "lava-testnet-1"

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////   Aptos Mainet ///////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

lavad tx pairing stake-provider "APT1" \
"50006000000ulava" \
"167.86.82.139:2261,rest,2" 2 \
--from lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp \
--provider-moniker Lighthouse \
--keyring-backend "test" \
--chain-id "lava-testnet-1" \
--gas="auto" \
--gas-adjustment "1.5" \
--fees 6000ulava \
--node "https://public-rpc.lavanet.xyz:443/rpc/"

# информация о провайдере

lavad query pairing account-info \
--from lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp \
--node "https://public-rpc.lavanet.xyz:443/rpc/"

# запускаем провайдера

lavad rpcprovider rpcprovider-apt.yml --from lighthouse --geolocation 2


# тест провайдера

lavad test rpcprovider lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp
lavad test rpcprovider --from lava@1vu3xj8yv8280mx5pt64q4xg37692txwm422ymp --endpoints "123.45.67.890:2261,jsonrpc,APT1" --node https://public-rpc.lavanet.xyz:443/rpc/ 


echo "[Unit]
Description=Provider APT daemon
After=network-online.target
[Service]
User=$USER
ExecStart=lavad rpcprovider rpcprovider-apt.yml --from lighthouse --geolocation 2 --chain-id lava-testnet-1
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
" >lava-provider-APT.service
sudo mv lava-provider-APT.service /lib/systemd/system/lava-provider-APT.service

sudo systemctl daemon-reload
sudo systemctl enable lava-provider-APT.service
sudo systemctl restart systemd-journald
sudo systemctl start lava-provider-APT

sudo journalctl -u lava-provider-APT -f

sudo systemctl stop lava-provider-APT
sudo systemctl restart lava-provider-APT


lavad tx pairing unstake-provider APT1 --from lighthouse --account-number 4158 --chain-id "lava-testnet-1"

