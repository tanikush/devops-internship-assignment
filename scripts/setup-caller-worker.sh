#!/bin/bash
set -e

# Injected by Terraform at runtime - NOT hardcoded
ENGINE_IP="${engine_ip}"

apt-get update
apt-get install -y curl git nodejs npm supervisor

curl -fsSL https://iii.dev/install.sh | bash
export PATH=$PATH:/root/.iii/bin

mkdir -p /opt/hiring
git clone https://github.com/Alchemyst-ai/hiring /opt/hiring
cd /opt/hiring/may-2026/devops/quickstart

mkdir -p /var/log/iii

cat > /etc/supervisor/conf.d/iii-caller.conf << EOF
[program:iii-caller]
command=/root/.iii/bin/iii worker start ./workers/caller-worker --engine ws://${ENGINE_IP}:49134
directory=/opt/hiring/may-2026/devops/quickstart
autostart=true
autorestart=true
user=root
stdout_logfile=/var/log/iii/caller.log
stderr_logfile=/var/log/iii/caller.err
EOF

supervisorctl reread
supervisorctl update
supervisorctl restart iii-caller