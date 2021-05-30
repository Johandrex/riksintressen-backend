# riksintressen-backend

Backend delen består utav postgresql databasen som går att komma åt via pgadmin4. Databasen har pluginet PostGIS vars uppgift är att lagra spatial data av riksintressen, den spatiala datan visas i frontend genom geoservern vars uppgift är att fungera som en länk mellan databasen och frontend. I backend finns även vår REST API som är skapad i node.js, men den finns inte här, utan i det separata repositoryt "riksintressen-node". I detta projekt finns alltså docker-compose.yml, konfigurationsfiler från pgadmin4 och geoservern, ERD över databasen, samt en backup av databasen.

pgadmin4, postgresql och geoservern installeras automatiskt via docker-compose.yml. Så det enda som behöver installeras är docker applikationen, när det är installerat går det att starta docker-compose.yml via kommandot "docker-compose up" via terminalen när man befinner sig i mappen där filen finns.

När docker-compose.yml har startat startas applikationerna, kan andra datorer komma åt tjänsterna så länge det inte finns någon brandvägg som stör uppkopplingen. De sidor som går att komma åt finns listade nedanför. Localhost ska bytas ut mot användarens IP-addressen för att andra ska komma åt tjänsten.
* localhost:5432 - databasen "database" som går att komma åt via lösenordet i konfigurationsfilen och användaren "root".
* http://localhost:5050/ - webbapplikation som hanterar databaser, här kan databasen läggas till för att hantera den via SQL-queries.
* http://localhost:8080/geoserver/web/ - geoservern, fungerar som en länk mellan databasens spatiala data och webbsidan.

## information

riksintressen-backend körs i docker. Docker ansvarar för PostgreSQL, GeoServer och PgAdmin4.

Skapare: Johannes Seldevall, Sebastian Sjöberg och Wibke Du Rietz.

## installation

1. installera docker från sajten "https://docs.docker.com/get-docker/"
2. klona repository med kommandot "git clone https://Johandrex@bitbucket.org/Johandrex/riksintressen-backend.git"
3. gå in i repository mappen "cd riksintressen-backend"
4. starta applikationen med "docker-compose up"
5. Ifall det är första gången applikationen körs följ stegen i nästkommande avsnitt.

### PostgreSQL database
importera databasen
* docker exec -i database /bin/bash -c "PGPASSWORD=QG3QhfJtwdjMBb3NoKnq6BsgN8g2wOM0NaEe6S3GO0D5Rl psql --username root database" < backup.sql

exportering av databasen görs med kommandot nedanför
* docker exec -i database /bin/bash -c "PGPASSWORD=QG3QhfJtwdjMBb3NoKnq6BsgN8g2wOM0NaEe6S3GO0D5Rl pg_dump --username root database" > backup.sql

### PgAdmin4
1. Logga in med användaruppgifterna som finns i "docker-compose.yml"
2. Tryck på "Add New Server"
3. Fyll i PostgreSQL uppgifterna som finns i "docker-compose.yml"

### GeoServer
importering av geoserverns data (host till container)
* docker cp geoserver geoserver:/usr/local/tomcat/data

exportering geoserverns data (container till host)
* docker cp geoserver:/usr/local/tomcat/data geoserver