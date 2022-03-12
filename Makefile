up:
	docker-compose up zookeeper kafka kafka-admin


consumer:
	docker-compose run kafka-clients python consumer.py