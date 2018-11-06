.PHONY: up setup vagrant playbook smoketest test clean

up: vagrant playbook

setup:
	@vagrant plugin install vagrant-hostmanager

vagrant:
	@vagrant up
	@vagrant ssh-config > ssh.config

playbook:
	@ansible-playbook -i inventories/vagrant.ini swarm.yml

smoketest:
	@ansible-playbook -i inventories/vagrant.ini swarm.yml --tags test

test:
	@molecule test

clean:
	@vagrant destroy -f
	@[ ! -f ssh.config ] || rm ssh.config
