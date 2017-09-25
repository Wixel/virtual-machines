# Apollo Virtual Machines

This project contains all the configuration and set up instructions to compile our VirtualBox/Vagrant virtual machine environments for development.

## Table of contents

- [Environment](#environments)
  - [Dependencies](#dependencies)
  - [Vagrant Boxes](#vagrant-boxes)
- [Building Base Boxes](#building-base-boxes)
    - [Creating Ubuntu Image](#creating-ubuntu-image)
    - [Provisioning Base Box](#provisioning-base-box)
    - [Packaging](#packaging)
- [Components](#components)    
- [Accounts](#accounts)    
- [Global Variables](#global-variables)    
- [License](#license)
- [Links](#links)

## Environment

We use specific environments for the kinds of development work we do, these include:

* [apollo-ruby](https://github.com/apollo-black/virtual-machines/blob/master/virtualbox/apollo-ruby.sh) for Ruby on Rails specific development
* [apollo-go](https://github.com/apollo-black/virtual-machines/blob/master/virtualbox/apollo-go.sh) for Golang specific development
* [apollo-java](https://github.com/apollo-black/virtual-machines/blob/master/virtualbox/apollo-java.sh) for Java specific development

### Vagrant Boxes

The live version of the Vagrant boxes can be found on Vagrant:

* **apolloblack/ruby**
* **apolloblack/go**
* **apolloblack/java**

To use any of these, simply add them to your `Vagrantfile` like this:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "apolloblack/ruby"
  config.vm.box_version = "0.0.5"
end
```

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "apolloblack/go"
  config.vm.box_version = "0.0.5"
end
```

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "apolloblack/java"
  config.vm.box_version = "0.0.5"
end
```

## Building Base Boxes

Creating the virtual machines is a 3-step process.

1. Create a base virtual machine instance from an Ubuntu Server image
2. Provision the base VM and install all required components and dependencies
3. Packaging the instance as a reusable vagrant box

### Creating Ubuntu Image

1. Open virtual box
2. Create a new linux instance
3. Before launching, change the settings listed below
4. Launch instance and follow through the Linux installation process, using the same value for the server hostname as the name of the virtual machine instance.
5. When asked for user details, use `vagrant` for both username and password
6. Do not encrypt the home directory
7. Once done, log into your instance via the virtual box terminal window with the new username and password `vagrant:vagrant`

VBox Setting Changes:

- Turn off Audio (Uncheck Audio > Enable Audio)
- Turn off USB (Uncheck Ports > USB > Enable USB Controller)
- Ensure that network adapter enabled and attached to NAT

### Provisioning Base Box

It's important to ensure that you download and add the default Vagrant insecure SSH key before packaging the box otherwise authentication won't work correctly when you create boxes from it.

Ensure that the vagrant user can use `sudo` without a password:

```
sudo nano /etc/sudoers.d/vagrant
```

Add the following to the file:

```
vagrant ALL=(ALL) NOPASSWD:ALL
```

Change the root password to `vagrant`:

```
sudo passwd root
```

Download vagrant key:

```
mkdir -p /home/vagrant/.ssh
chmod 0700 /home/vagrant/.ssh
wget --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh
```

Enable the local SSH Server:

```
sudo apt-get install -y openssh-server
sudo nano /etc/ssh/sshd_config
# Uncomment AuthorizedKeysFile %h/.ssh/authorized_keys
sudo service ssh restart
```

Lastly, run the installer script for the kind of server this should be (this can take a while):

Example to install the Rails server:

```
cd ~ && wget https://raw.githubusercontent.com/apollo-black/virtual-machines/master/virtualbox/apollo-ruby.sh -O setup.sh
chmod a+x setup.sh
./setup.sh
```

It's important to monitor the output from the set up scripts because it might require manual input or report errors.

### Packaging

Once the above process has completed, it's time to cleanup and package the box.

First, while still logged in, let's clean the box up:

```
rm ~/setup.sh
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY
cat /dev/null > ~/.bash_history && history -c && exit
```

Head back to your host machine terminal and run the following:

```
vagrant package --base <box name> --output apollo-<BOX NAME>.box
```

Replace `<box name>` with the name of the Virtual Box instance (ie: `apollo-ruby`). Once done, the box will be packaged in the same directory that you are currently in.

### Components

Each box is configured with specific components needed for development:

#### apolloblack/ruby:

* Apache 2
* Java 8
* Ruby 2.4.1
* Phusion Passenger
* PostgreSQL 9.6
* PostGIS 2.3
* Redis (Latest Stable)
* Neo4j

#### apolloblack/go:

* Apache 2
* Java 8
* Go 1.9
* PostgreSQL 9.6
* PostGIS 2.3
* Redis (Latest Stable)
* Neo4j

#### apolloblack/java:

* Apache 2
* Java 8
* PostgreSQL 9.6
* PostGIS 2.3
* Redis (Latest Stable)
* Neo4j

### Accounts

We aim to use standard user account credentials throughout the instances of the virtual machines, please follow the same guideline:

*Operating System Users:*

Username: root
Password: vagrant

Username: vagrant
Password: vagrant

*Database User:*

Username: app_user
Password: password
Database: app_db

### Global Variables

As part of the installation process, we create global environment variables that would be expected on a production server. This is simply to keep configuration simple between dev and production.

Variables injected into `/etc/environment` are:

* `DATABASE_URL` The url pointing to the local database
* `RAILS_ENV` The Rails environment setting (default to `development`)
* `REDIS_URL` The url for Redis

## Links

- [Vagrant 2.0.0](https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_x86_64.dmg?_ga=2.175497765.666050554.1506000715-1387584540.1505460054)
- [VirtualBox ^5.1.2.8](http://download.virtualbox.org/virtualbox/5.1.28/VirtualBox-5.1.28-117968-OSX.dmg)
- [Ubuntu-16.04.3](http://releases.ubuntu.com/16.04/ubuntu-16.04.3-server-amd64.iso.torrent?_ga=2.185470314.2120170685.1506000760-822906382.1505464433)

## License

MIT License

Copyright (c) 2017 Apollo Black

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
