#!/bin/bash

REPO_DIR="$HOME/202408/docker"
IMAGE_NAME="web3_ri2024-valenciano"
CONTAINER_PORT=8081

cd "$REPO_DIR" || { echo "Error: no existe $REPO_DIR"; exit 1; }


MODEL_CPU=$(lscpu | grep "Model name:" | sed 's/Model name:\s*//')
FREQ_CPU=$(lscpu | grep "CPU MHz:" | awk '{print $3/1000 " GHz"}')

cat > web/file/info.txt <<EOF
Modelo CPU: $MODEL_CPU
Frecuencia: $FREQ_CPU
EOF

if [ ! -f Dockerfile ]; then
cat > Dockerfile <<'EOF'
FROM nginx:latest
COPY index.html /usr/share/nginx/html/index.html
COPY file /usr/share/nginx/html/file
EOF
echo "Dockerfile creado."
else
echo "Dockerfile ya existe."
fi

docker build -t "$IMAGE_NAME" .

cat > docker-compose.yml <<EOF
version: "3.8"
services:
  web:
    image: $IMAGE_NAME
    ports:
      - "$CONTAINER_PORT:80"
    volumes:
      - ./file:/usr/share/nginx/html/file
EOF
echo "docker-compose.yml creado"

docker compose up -d

