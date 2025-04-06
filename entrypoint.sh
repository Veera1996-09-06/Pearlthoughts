#!/bin/sh
set -e

# Wait for dependencies to be ready
while ! nc -z $DB_HOST 5432; do
  echo "Waiting for PostgreSQL..."
  sleep 2
done

while ! nc -z $REDIS_HOST 6379; do
  echo "Waiting for Redis..."
  sleep 2
done

# Run migrations and start
npx medusa migrations run
exec medusa start
