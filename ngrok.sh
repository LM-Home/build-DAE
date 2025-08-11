#!/bin/bash

# 检查必要的环境变量
if [[ -z "$NGROK_TOKEN" ]]; then
	echo "Please set 'NGROK_TOKEN'"
	exit 2
fi

if [[ -z "$USER_PASS" ]]; then
	echo "Please set 'USER_PASS' for user: $USER"
	exit 3
fi

# 安装 ngrok
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com bookworm main" | sudo tee /etc/apt/sources.list.d/ngrok.list >/dev/null
sudo apt update -y
sudo apt install ngrok -y

# 配置 ngrok 并启动
rm -f .ngrok.log
ngrok authtoken "$NGROK_TOKEN"
ngrok tcp 22 --log ".ngrok.log" &

# 等待 ngrok 启动
sleep 10

# 检查是否有错误
HAS_ERRORS=$(grep "command failed" <.ngrok.log)

if [[ -z "$HAS_ERRORS" ]]; then
	echo ""
	echo "=========================================="
	echo '连接: '"$(grep -o -E 'tcp://(.+)' < .ngrok.log | head -n 1 | sed 's/tcp:\/\//ssh '"$(whoami)"'@/' | sed 's/:/ -p /')"
	echo "=========================================="
else
	echo "$HAS_ERRORS"
	exit 4
fi
