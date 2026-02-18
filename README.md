Run with:

docker compose up -d


Stop running with:

docker compose down


Check if it's running with:

docker ps


Connect to PostgreSQL Inside Container:

docker exec -it neobank_db psql -U postgres -d neobank


access the postgreSQL through the web:
http://127.0.0.1:5050/login?next=/

Email: admin@neobank.com
Password: admin
