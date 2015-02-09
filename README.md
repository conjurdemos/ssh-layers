# Conjur Secondary Groups Demo

This demo shows how to manage SSH access to machines using Conjur layers.

## Groups

* **admin**
* **developers**

## Users

* **alice** is a member of group `admin`.
* **donna** is a member of group `developers`.
* **claire** is not a member of any groups.

# Running the Demo

## Setup

Build the images:

    $ make

Load the policy:

    $ conjur policy load -c policy.json policy.rb

Create the hosts:

Prepare host conjurization scripts:

    $ ./conjurize.sh
    Generating conjurize for dev-0
    Generating conjurize for prod-0
    
## Run the target machines    

Run the dev-0 container:

    $ docker run --name dev-0 \
      -d \
      -v $PWD/hosts/conjurize-dev-0.sh:/conjurize.sh \
      -p 2300:22 \
      conjur-ssh-layers

Run the prod-0 container:

    $ docker run --name prod-0 \
      -d \
      -v $PWD/hosts/conjurize-prod-0.sh:/conjurize.sh \
      -p 2400:22 \
      conjur-ssh-layers

## Login to dev-0 as alice

    $ cd users/alice*
    $ login=`basename "$PWD"`
    $ ssh -p 2300 -i ./id_rsa $login@$(boot2docker ip)
    alice@kgilpin-spudling-docker-ssh-layers-1-0@e42980012176:/$ id
    uid=1165(alice@kgilpin-spudling-docker-ssh-layers-1-0) gid=50000(conjurers) groups=50000(conjurers)
    
Demonstrate that alice has passwordless sudo:

    alice@kgilpin-spudling-docker-ssh-layers-1-0@e42980012176:/$ sudo -i
    root@e42980012176:~# 
        
## Login to prod-0 as alice

    $ ssh -p 2400 -i ./id_rsa $login@$(boot2docker ip)
    alice@kgilpin-spudling-docker-ssh-layers-1-0@b6ddf2001dd7:/$ id
    uid=1165(alice@kgilpin-spudling-docker-ssh-layers-1-0) gid=50000(conjurers) groups=50000(conjurers)

Demonstrate that alice has passwordless sudo:

    alice@kgilpin-spudling-docker-ssh-layers-1-0@e42980012176:/$ sudo -i
    root@b6ddf2001dd7:~# 

## Login to dev-0 as donna

    $ cd ../donna*
    $ login=`basename "$PWD"`
    $ ssh -p 2300 -i ./id_rsa $login@$(boot2docker ip)
    donna@kgilpin-spudling-docker-ssh-layers-1-0@e42980012176:/$ id
    uid=1166(donna@kgilpin-spudling-docker-ssh-layers-1-0) gid=5000(users) groups=5000(users)
    
Demonstrate that donna can't sudo:

    donna@kgilpin-spudling-docker-ssh-layers-1-0@e42980012176:/$ sudo -i
    [sudo] password for donna@kgilpin-spudling-docker-ssh-layers-1-0: 

## Login to prod-0 as donna

Permission is denied:

    $ ssh -p 2400 -i ./id_rsa $login@$(boot2docker ip)
    donna@kgilpin-spudling-docker-@192.168.59.103's password: 

## Login to dev-0 as claire

    $ cd ../claire*
    
Permission is denied:

    $ ssh -p 2300 -i ./id_rsa $login@$(boot2docker ip)
    claire@kgilpin-spudling-docker@192.168.59.103's password:
    
    