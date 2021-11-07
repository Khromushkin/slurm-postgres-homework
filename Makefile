rebuild_restart_db:
	docker rm -f my_db
	docker build -t my_db .
	docker run --name my_db -p 5433:5432 my_db