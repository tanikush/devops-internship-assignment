#!/bin/bash
set -e

# Injected by Terraform at runtime - NOT hardcoded
ENGINE_IP="${engine_ip}"

apt-get update
apt-get install -y curl git python3 python3-pip supervisor

curl -fsSL https://iii.dev/install.sh | bash
export PATH=$PATH:/root/.iii/bin

mkdir -p /opt/hiring
git clone https://github.com/Alchemyst-ai/hiring /opt/hiring
cd /opt/hiring/may-2026/devops/quickstart

pip3 install transformers torch --break-system-packages

mkdir -p /var/log/iii

cat > /etc/supervisor/conf.d/iii-inference.conf << EOF
[program:iii-inference]
command=/root/.iii/bin/iii worker start ./workers/inference-worker --engine ws://${ENGINE_IP}:49134
directory=/opt/hiring/may-2026/devops/quickstart
autostart=true
autorestart=true
user=root
stdout_logfile=/var/log/iii/inference.log
stderr_logfile=/var/log/iii/inference.err
EOF

supervisorctl reread
supervisorctl update
supervisorctl restart iii-inference