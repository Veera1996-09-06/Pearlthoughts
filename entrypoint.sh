#!/bin/sh
set -e

# Extract DB host from full DATABASE_URL (if needed)
export DB_HOST=$(echo "$DATABASE_URL" | sed -E 's/.*@([^:]+):.*/\1/')

# Wait for PostgreSQL to be available
echo "🔄 Waiting for PostgreSQL at $DB_HOST..."
while ! nc -z "$DB_HOST" 5432; do
  sleep 2
done
echo "✅ PostgreSQL is ready"

# Run Medusa migrations
echo "📦 Running Medusa migrations..."
npx medusa migrations run

# Start the Medusa server on all interfaces
echo "🚀 Starting Medusa on 0.0.0.0:9000..."
exec medusa start --port=9000 --host=0.0.0.0
