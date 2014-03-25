sudo passwd root
apt-get install openssh-server
sudo apt-get -y install curl
\curl -L https://get.rvm.io | bash -s stable
exit and login
apt-get -y install  vim
apt-get -y install git
gem install heroku
rvm install ruby -v 2.1.1
gem install --no-rdoc --no-ri rails -v 4.0.3
apt-get install -y postgresql postgresql-contrib libpq-dev

postgres
sudo su postgres -c  "createuser root --pwprompt"  
sudo -u postgres dropdb   $dbname
sudo -u postgres createdb $dbname

 /etc/init.d/postgresql status
 
 psql -l

 psql TCM_production
SELECT version();
\dt
\q
