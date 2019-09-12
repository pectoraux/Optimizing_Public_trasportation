echo 'schema.registry.url=http://localhost:8081' >> /etc/kafka/connect-distributed.properties
systemctl start confluent-zookeeper
systemctl start confluent-kafka
systemctl start confluent-schema-registry
systemctl start confluent-kafka-rest
systemctl start confluent-kafka-connect
systemctl start confluent-ksql
sed -i 's/md5/trust/g' /etc/postgresql/10/main/pg_hba.conf
/etc/init.d/postgresql start
su postgres -c "createuser root -s"
createdb classroom
psql -d classroom -c "DROP TABLE IF EXISTS purchases; CREATE TABLE purchases(id INT PRIMARY KEY, username VARCHAR(100), currency VARCHAR(10), amount INT);"
psql -d classroom -c "DROP TABLE IF EXISTS clicks; CREATE TABLE clicks(id INT PRIMARY KEY, email VARCHAR(100), timestamp VARCHAR(100), uri VARCHAR(512), number INT);"
psql -d classroom -c "DROP TABLE IF EXISTS connect_purchases; CREATE TABLE connect_purchases(id INT PRIMARY KEY, username VARCHAR(100), currency VARCHAR(10), amount INT);"
psql -d classroom -c "DROP TABLE IF EXISTS connect_clicks; CREATE TABLE connect_clicks(id INT PRIMARY KEY, email VARCHAR(100), timestamp VARCHAR(100), uri VARCHAR(512), number INT);"
psql -d classroom -c "COPY purchases(id,username,currency,amount)  FROM '/home/workspace/utilities/purchases.csv' DELIMITER ',' CSV HEADER;"
psql -d classroom -c "COPY clicks(id,email,timestamp,uri,number)  FROM '/home/workspace/utilities/clicks.csv' DELIMITER ',' CSV HEADER;"

su postgres -c "createuser cta_admin -s"
createdb cta
psql -d cta -c "ALTER USER cta_admin WITH PASSWORD 'chicago'"
psql -d cta -c "CREATE TABLE stations (stop_id INTEGER PRIMARY KEY, direction_id VARCHAR(1) NOT NULL, stop_name VARCHAR(70) NOT NULL, station_name VARCHAR(70) NOT NULL, station_descriptive_name VARCHAR(200) NOT NULL, station_id INTEGER NOT NULL, \"order\" INTEGER, red BOOLEAN NOT NULL, blue BOOLEAN NOT NULL, green BOOLEAN NOT NULL);"

psql -d cta -c "COPY stations(stop_id, direction_id,stop_name,station_name,station_descriptive_name,station_id,\"order\",red,blue,green) FROM '/home/workspace/utilities/cta_stations.csv' DELIMITER ',' CSV HEADER;"

# Configure lesson 6 and 7 streams
# kafka-topics --delete --zookeeper localhost:2181 --topic com.udacity.streams.users
# kafka-topics --delete --zookeeper localhost:2181 --topic com.udacity.streams.purchases
# kafka-topics --create --zookeeper localhost:2181 --topic com.udacity.streams.users --replication-factor 1 --partitions 10
# kafka-topics --create --zookeeper localhost:2181 --topic com.udacity.streams.purchases --replication-factor 1 --partitions 10

# Configure the directory structure for KSQL
mkdir -p /var/lib/kafka-streams
chmod g+rwx /var/lib/kafka-streams
chgrp -R confluent /var/lib/kafka-streams

#python stream.py