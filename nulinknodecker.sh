#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/Nulink.sh"

# 自动设置快捷键的功能
function check_and_set_alias() {
    local alias_name="nulink"
    local shell_rc="$HOME/.bashrc"

    # 对于Zsh用户，使用.zshrc
    if [ -n "$ZSH_VERSION" ]; then
        shell_rc="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        shell_rc="$HOME/.bashrc"
    fi

    # 检查快捷键是否已经设置
    if ! grep -q "$alias_name" "$shell_rc"; then
        echo "设置快捷键 '$alias_name' 到 $shell_rc"
        echo "alias $alias_name='bash $SCRIPT_PATH'" >> "$shell_rc"
        # 添加提醒用户激活快捷键的信息
        echo "快捷键 '$alias_name' 已设置。请运行 'source $shell_rc' 来激活快捷键，或重新打开终端。"
    else
        # 如果快捷键已经设置，提供一个提示信息
        echo "快捷键 '$alias_name' 已经设置在 $shell_rc。"
        echo "如果快捷键不起作用，请尝试运行 'source $shell_rc' 或重新打开终端。"
    fi
}

# 节点安装功能
function install_node() {

exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
echo ''
else
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi

# Generate Geth Account
wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.23-d901d853.tar.gz

tar -xvzf geth-linux-amd64-1.10.23-d901d853.tar.gz

cd geth-linux-amd64-1.10.23-d901d853/

./geth account new --keystore ./keystore
sleep 5
echo -e "\e[1;32m \e[0m\e[1;36m${CYAN} 保存好你的地址和密码 ${NC}\e[0m"
echo -e "\e[1;32m \e[0m\e[1;36m${CYAN} 保存好你的秘钥和路径 ${NC}\e[0m"
sleep 5



# Pull the latest NuLink image

docker pull nulink/nulink:latest
cd /root
mkdir nulink
cp /root/geth-linux-amd64-1.10.23-d901d853/keystore/* /root/nulink
chmod -R 777 /root/nulink

# Initiate Worker
read -r -p "您的NULINK存储密码.请务必记住此密码以供将来访问 : " NULINK_KEYSTORE_PASSWORD
sleep 0.5
export NULINK_KEYSTORE_PASSWORD=$NULINK_KEYSTORE_PASSWORD
sleep 0.5
read -r -p "您的员工帐户密码.请务必记住此密码以供将来访问 : " NULINK_OPERATOR_ETH_PASSWORD
sleep 0.5
export NULINK_OPERATOR_ETH_PASSWORD=$NULINK_OPERATOR_ETH_PASSWORD
sleep 0.5
echo " 您的密钥库路径 "
filename=$(basename ~/geth-linux-amd64-1.10.23-d901d853/keystore/*)
export filename1=$filename
sleep 1
echo "复制您的密钥库 "
evm=$(grep -oP '(?<="address":")[^"]+' ~/geth-linux-amd64-1.10.23-d901d853/keystore/*)
wallet='0x'$evm
export wallet1=$wallet
sleep 10

read -p "按Enter键继续..."   # 添加这一行，等待用户按下Enter键
# 节点配置部署

docker run -it --rm \
-p 9151:9151 \
-v /root/nulink:/code \
-v /root/nulink:/home/circleci/.local/share/nulink \
-e NULINK_KEYSTORE_PASSWORD \
nulink/nulink nulink ursula init \
--signer keystore:///code/$filename1 \
--eth-provider https://data-seed-prebsc-2-s2.binance.org:8545 \
--network horus \
--payment-provider https://data-seed-prebsc-2-s2.binance.org:8545 \
--payment-network bsc_testnet \
--operator-address $wallet1 \
--max-gas-price 10000000000

#加载节点
read -p "按Enter键继续..."   # 添加这一行，等待用户按下Enter键

docker run --restart on-failure -d \
--name ursula \
-p 9151:9151 \
-v /root/nulink:/code \
-v /root/nulink:/home/circleci/.local/share/nulink \
-e NULINK_KEYSTORE_PASSWORD \
-e NULINK_OPERATOR_ETH_PASSWORD \
nulink/nulink nulink ursula run --no-block-until-ready

echo '=============================== 安装完成 ==============================='
echo 启动节点: docker restart ursula
echo 检查日志 :docker logs -f ursula

}

# 查看节点日志
function check_service_status() {
    docker logs -f ursula
}



# 主菜单
function main_menu() {
    clear    
    echo "================================================================"
    echo "请选择要执行的操作:"
    echo "1. 安装节点"
    echo "2. 查看节点日志"
    echo "3. 设置快捷键的功能"
    read -p "请输入选项（1-2）: " OPTION

    case $OPTION in
    1) install_node ;;
    2) check_service_status ;;
    3) check_and_set_alias ;; 
    *) echo "无效选项。" ;;
    esac
}

# 显示主菜单
main_menu