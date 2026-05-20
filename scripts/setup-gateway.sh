#!/bin/bash
set -e

apt-get update
apt-get install -y nginx

# Injected by Terraform at runtime - NOT hardcoded
ENGINE_IP="${engine_private_ip}"

cat > /etc/nginx/sites-available/iii << EOF
server {
    listen 80;
    location / {
        proxy_pass http://${ENGINE_IP}:3111;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

ln -sf /etc/nginx/sites-available/iii /etc/nginx/sites-enabled/iii
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx