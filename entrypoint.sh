#!/bin/sh
set -e

echo "Starting Medusa ECS Entrypoint..."

# Extract DB host from DATABASE_URL
DB_HOST=$(echo $DATABASE_URL | awk -F[@:] '{print $2}')
echo "Waiting for PostgreSQL at $DB_HOST..."

while ! nc -z $DB_HOST 5432; do
  echo "Still waiting for PostgreSQL..."
  sleep 2
done

echo "PostgreSQL is up!"

# Run DB migrations
npx medusa migrations run

# Start Medusa on 0.0.0.0 for ECS
exec medusa start --port=9000 --host=0.0.0.0
