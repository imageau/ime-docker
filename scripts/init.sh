#!/bin/bash

ENV=$(grep '^ENV=' .env | cut -d '=' -f2)

BACK_REPO=$(grep '^BACK_REPO=' .env | cut -d '=' -f2)
BACK_PATH=$(grep '^BACK_PATH=' .env | cut -d '=' -f2)

FRONT_REPO=$(grep '^FRONT_REPO=' .env | cut -d '=' -f2)
FRONT_PATH=$(grep '^FRONT_PATH=' .env | cut -d '=' -f2)

# Define sed in-place command depending on the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  SED_CMD="sed -i ''"
else
  # Linux and others
  SED_CMD="sed -i"
fi

git clone $BACK_REPO $BACK_PATH
cp $BACK_PATH/.env.example $BACK_PATH/.env 
$SED_CMD '/^DB_CONNECTION/d' $BACK_PATH/.env
$SED_CMD '/^DB_HOST/d' $BACK_PATH/.env
$SED_CMD '/^DB_PORT/d' $BACK_PATH/.env
$SED_CMD '/^DB_DATABASE/d' $BACK_PATH/.env
$SED_CMD '/^DB_USERNAME/d' $BACK_PATH/.env
$SED_CMD '/^DB_PASSWORD/d' $BACK_PATH/.env
$SED_CMD '/^REDIS_HOST/d' $BACK_PATH/.env
$SED_CMD '/^APP_URL/d' $BACK_PATH/.env
$SED_CMD '/^JWT_DOMAIN/d' $BACK_PATH/.env
$SED_CMD '/^FRONTEND_URL/d' $BACK_PATH/.env

git clone $FRONT_REPO $FRONT_PATH
cp $FRONT_PATH/.env.example $FRONT_PATH/.env
$SED_CMD '/^NEXT_PUBLIC_API_URL/d' $FRONT_PATH/.env
$SED_CMD '/^PROXY_URL/d' $FRONT_PATH/.env

if [ "$ENV" != "production" ]; then
    docker compose up --build -d

    sh ./scripts/trust-cert.sh

    # Wait for containers to become healthy
    echo "Waiting for back service to be fully up and running..."
    while ! docker compose ps | grep back | grep -q "healthy"; do
        echo -n "."
        sleep 10
    done
    echo "Back service is up and running."

    ./composer install
    ./artisan init --seed
    docker compose restart front
else
    $SED_CMD '/^NODE_TLS_REJECT_UNAUTHORIZED/d' $FRONT_PATH/.env

    docker compose -f docker-compose.yml up --build -d
fi

echo "Waiting for front service to be fully up and running..."
while ! docker compose ps | grep front | grep -q "healthy"; do
    echo -n "."
    sleep 10
done
echo "Front service is up and running."