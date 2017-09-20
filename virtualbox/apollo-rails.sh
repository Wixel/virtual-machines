PASSWD="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"

echo "# -------------------------------- #"
echo "#      Apollo Ruby VM Install      #"
echo "# -------------------------------- #"
echo "# + Ruby 2.4.1                     #"
echo "# + PostgreSQL 9.6                 #"
echo "# + PostGIS 2.3                    #"
echo "# + Redis Latest                   #"
echo "# + Phusion Passenger 5            #"
echo "# -------------------------------- #"

sudo apt-get update -y
sudo apt-get upgrade -y

echo "\n\n"
echo "# -------------------------------- #"
echo "#          Installing Ruby         #"
echo "# -------------------------------- #"
echo "\n\n"

sudo apt-get -y install gcc make python-software-properties git-core curl build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev libcurl4-openssl-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libffi-dev libpq-dev tcl8.5 libexpat1-dev gettext unzip  libmagick++-dev libv8-dev libffi-dev libpulse0
echo "gem: --no-ri --no-rdoc" > ~/.gemrc
mkdir ~/downloads
cd ~/downloads && wget http://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.1.tar.gz -O ruby.tar.gz
cd ~/downloads && tar xzf ruby.tar.gz
cd ~/downloads/ruby-2.4.1 && ./configure -prefix=$HOME
cd ~/downloads/ruby-2.4.1 && make
cd ~/downloads/ruby-2.4.1 && make install
gem install bundler
RUBY_PATH="$(which ruby)"
GEM_PATH="$(which gem)"

echo "\n\n"
echo "# -------------------------------- #"
echo "#         Installing Redis         #"
echo "# -------------------------------- #"
echo "\n\n"

cd ~/downloads && wget http://download.redis.io/releases/redis-stable.tar.gz -O redis.tar.gz
cd ~/downloads && tar xzf redis.tar.gz
cd ~/downloads/redis-stable && make
cd ~/downloads/redis-stable && sudo make install
cd ~/downloads/redis-stable/utils && sudo ./install_server.sh

echo "\n\n"
echo "# -------------------------------- #"
echo "#       Installing PostgreSQL      #"
echo "# -------------------------------- #"
echo "\n\n"

sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update -y
sudo apt install -y postgresql-9.6 postgresql-contrib-9.6

echo "\n\n"
echo "# -------------------------------- #"
echo "#         Setting up DB User       #"
echo "# -------------------------------- #"
echo "\n\n"

sudo -u postgres psql -c "CREATE USER app_user WITH PASSWORD 'password';"
sudo -u postgres createdb -O app_user app_db

echo "\n\n"
echo "# -------------------------------- #"
echo "#         Setting up PostGIS       #"
echo "# -------------------------------- #"
echo "\n\n"

sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
sudo apt update -y
sudo apt install -y postgis postgresql-9.6-postgis-2.3
sudo -u postgres psql -c "CREATE EXTENSION postgis; CREATE EXTENSION postgis_topology;" app_db

echo "\n\n"
echo "# -------------------------------- #"
echo "#          Setting ENV Vars        #"
echo "# -------------------------------- #"
echo "\n\n"

echo 'RAILS_ENV="production"' | sudo tee --append /etc/environment > /dev/null
echo 'DATABASE_URL="postgresql://app_user:password@127.0.0.1:5432/app_db"' | sudo tee --append /etc/environment > /dev/null
echo 'REDIS_URL="redis://localhost:637"' | sudo tee --append /etc/environment > /dev/null

echo "\n\n"
echo "# -------------------------------- #"
echo "#         Installing Apache2       #"
echo "# -------------------------------- #"
echo "\n\n"

sudo apt-get -y install apache2

echo "\n\n"
echo "# -------------------------------- #"
echo "#   Installing Phusion Passenger   #"
echo "# -------------------------------- #"
echo "\n\n"

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' | sudo tee --append /etc/apt/sources.list.d/passenger.list > /dev/null
sudo chown root: /etc/apt/sources.list.d/passenger.list
sudo chmod 600 /etc/apt/sources.list.d/passenger.list
sudo apt-get update -y
sudo apt-get -y install libapache2-mod-passenger
sudo a2enmod passenger
sudo service apache2 restart
sudo rm /usr/bin/ruby
sudo ln -s "${RUBY_PATH}" /usr/bin/ruby
sudo rm /usr/bin/gem
sudo ln -s "${GEM_PATH}" /usr/bin/gem
sudo service apache2 restart

echo "\n\n"
echo "# -------------------------------- #"
echo "#            Cleaning Up           #"
echo "# -------------------------------- #"
echo "\n\n"

rm -rf ~/downloads
sudo apt-get clean
