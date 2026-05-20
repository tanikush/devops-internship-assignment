#!/bin/bash
set -e

apt-get update
apt-get install -y curl git nodejs npm supervisor

curl -fsSL https://iii.dev/install.sh | bash
export PATH=$PATH:/root/.iii/bin

mkdir -p /opt/hiring
git clone https://github.com/Alchemyst-ai/hiring /opt/hiring
cd /opt/hiring/may-2026/devops/quickstart

mkdir -p /var/log/iii

cat > /etc/supervisor/conf.d/iii-engine.conf << 'EOF'
[program:iii-engine]
command=/root/.iii/bin/iii --config config.yaml --host 0.0.0.0
directory=/opt/hiring/may-2026/devops/quickstart
autostart=true
autorestart=true
user=root
stdout_logfile=/var/log/iii/engine.log
stderr_logfile=/var/log/iii/engine.err
EOF

supervisorctl reread
supervisorctl update
supervisorctl restart iii-engine