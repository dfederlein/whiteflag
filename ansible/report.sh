#! /bin/bash -ex

ansible-playbook -v --connection=local -i 'localhost,' report.yml
