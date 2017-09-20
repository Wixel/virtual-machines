# Apollo Virtual Machine Configurations

This project contains all the configuration instructions to compile our VirtualBox/Vagrant virtual machine environments for development.

### Prerequisites:

- Vagrant 2.0
- VirtualBox ^5.1.2.8
- Ubuntu-16.04.3

### How this works

Creating the virtual machines is a 3-step process.

1. Create a base virtual machine from an Ubuntu Server image
2. Provision the base VM and install all required components and dependencies
3. Packaging the instance as a reusable vagrant box

### 1. Creating a base VM from an Ubuntu Image

We'll be using Ubuntu 16.04 LTS as our primary operating system since this is what we use in production.

Steps:

1. Open virtual box
2. Create a new linux instance
3. Before launching, change the following settings:
  - Turn off Audio (Uncheck Audio > Enable Audio)
  - Turn off USB (Uncheck Ports > USB > Enable USB Controller)
  - Ensure that network adapter enabled and attached to NAT
4. Launch instance and follow through the Linux installation process
5. When asked for user details, use the following:
  - username: vagrant
  - password: vagrant
6. Once done, log into your instance via the virtual box terminal window with the new username and password `vagrant:vagrant`

### 2. Provision the base VM and install required components & dependencies






# sudo
# ssh key
# freeing up space
# packaging
# running scripts
