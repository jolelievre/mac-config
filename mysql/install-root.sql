UPDATE mysql.user SET Password=PASSWORD('') WHERE User='root';
FLUSH PRIVILEGES;
