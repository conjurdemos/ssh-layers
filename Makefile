.PHONY: all ssh

all: ssh

ssh:
	docker build -t conjur-ssh-layers host
