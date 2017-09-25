PASSWD="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"

echo "# -------------------------------- #"
echo "#      Apollo Java VM Install      #"
echo "# -------------------------------- #"
echo "# + PostgreSQL 9.6                 #"
echo "# + PostGIS 2.3                    #"
echo "# + Redis Latest                   #"
echo "# + Java 8                         #"
echo "# + Neo4j                          #"
echo "# -------------------------------- #"

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get -y install gcc make python-software-properties git-core curl build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev libcurl4-openssl-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libffi-dev libpq-dev tcl8.5 libexpat1-dev gettext unzip  libmagick++-dev libv8-dev libffi-dev libpulse0
mkdir ~/downloads

echo "# -------------------------------- #"
echo "#         Installing Redis         #"
echo "# -------------------------------- #"

cd ~/downloads && wget http://download.redis.io/releases/redis-stable.tar.gz -O redis.tar.gz
cd ~/downloads && tar xzf redis.tar.gz
cd ~/downloads/redis-stable && make
cd ~/downloads/redis-stable && sudo make install
cd ~/downloads/redis-stable/utils && sudo ./install_server.sh

echo "# -------------------------------- #"
echo "#       Installing PostgreSQL      #"
echo "# -------------------------------- #"

sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update -y
sudo apt install -y postgresql-9.6 postgresql-contrib-9.6

echo "# -------------------------------- #"
echo "#         Setting up DB User       #"
echo "# -------------------------------- #"

sudo -u postgres psql -c "CREATE USER app_user WITH PASSWORD 'password';"
sudo -u postgres createdb -O app_user app_db

echo "# -------------------------------- #"
echo "#         Setting up PostGIS       #"
echo "# -------------------------------- #"

sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
sudo apt update -y
sudo apt install -y postgis postgresql-9.6-postgis-2.3
sudo -u postgres psql -c "CREATE EXTENSION postgis; CREATE EXTENSION postgis_topology;" app_db

echo "# -------------------------------- #"
echo "#         Installing Apache2       #"
echo "# -------------------------------- #"

sudo apt-get -y install apache2

echo "# -------------------------------- #"
echo "#        Installing Java 8         #"
echo "# -------------------------------- #"

sudo apt install default-jre default-jre-headless

echo "# -------------------------------- #"
echo "#        Installing Neo4j          #"
echo "# -------------------------------- #"

wget --no-check-certificate -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add -
echo 'deb http://debian.neo4j.org/repo stable/' | sudo tee /etc/apt/sources.list.d/neo4j.list
sudo apt update
sudo apt install neo4j
sudo service neo4j stop
sudo service neo4j start

echo "# -------------------------------- #"
echo "#          Setting ENV Vars        #"
echo "# -------------------------------- #"

echo 'DATABASE_URL="postgresql://app_user:password@127.0.0.1:5432/app_db"' | sudo tee --append /etc/environment > /dev/null
echo 'REDIS_URL="redis://localhost:6379"' | sudo tee --append /etc/environment > /dev/null

echo "# -------------------------------- #"
echo "#            Cleaning Up           #"
echo "# -------------------------------- #"

rm -rf ~/downloads
sudo apt-get clean
