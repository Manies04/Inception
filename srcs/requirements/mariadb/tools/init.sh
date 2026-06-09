#!/bin/bash

set -e

# Read secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# Create directory for socket and pid
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chmod 777 /run/mysqld

# Initialize database if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    
    chown -R mysql:mysql /var/lib/mysql
    
    # Initialize the database
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db > /dev/null
    
    echo "Database initialized."
fi

# Start MySQL in background to configure it
mysqld --user=mysql --datadir=/var/lib/mysql &
pid="$!"

echo "Waiting for MariaDB to start..."
for i in {30..0}; do
    if mysqladmin ping --silent; then
        break
    fi
    echo "MariaDB is starting..."
    sleep 1
done

if [ "$i" = 0 ]; then
    echo "MariaDB failed to start."
    exit 1
fi

echo "MariaDB started successfully!"

# Configure database if not already configured
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Configuring database..."
    
    mysql -u root << EOF
-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- Create database
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- Create user and grant privileges
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

-- Flush privileges
FLUSH PRIVILEGES;
EOF

    echo "Database configured successfully!"
else
    echo "Database already configured, skipping initialization."
fi

# Shutdown the background MySQL
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Wait for shutdown
wait "$pid"

echo "Starting MariaDB in foreground..."

# Start MariaDB in foreground
exec mysqld --user=mysql --console
