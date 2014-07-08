# Whiteflag

This is a demonstration on how to build a self-extracting ansible-playbook.  Could be useful for "installers".


This repo uses submodules, to clone it properly:

    git clone --recursive https://github.com/jsmartin/whiteflag.git

To build the self-extracting role & playbook:

    ./build.sh

The self-extracting playbook will be placed in:

     /tmp/tower-report.sh
     
     
Running the self-extracting playbook would look like this:




	/tmp/tower-report.sh
	Verifying archive integrity... All good.
	Uncompressing Ansible Tower Report  100%
	+ ansible-playbook -v --connection=local -i localhost, report.yml
	
	PLAY [localhost] **************************************************************
	
	GATHERING FACTS ***************************************************************
	ok: [localhost]
	
	TASK: [report | debug var=timestamp] ******************************************
	ok: [localhost] => {
	    "timestamp": "2014-07-08-14-28-29"
	}
	
	TASK: [report | debug var=working_dir] ****************************************
	ok: [localhost] => {
	    "working_dir": "/tmp/tower-report-2014-07-08-14-28-29"
	}
	
	TASK: [report | create working working dir] ***********************************
	changed: [localhost] => {"changed": true, "gid": 0, "group": "root", "mode": "0700", "owner": "root", "path": "/tmp/tower-report-2014-07-08-14-28-29/files", "size": 4096, "state": "directory", "uid": 0}
	
	TASK: [report | dump facts to file] *******************************************
	changed: [localhost] => {"changed": true, "dest": "/tmp/tower-report-2014-07-08-14-28-29/facts.json", "gid": 0, "group": "root", "md5sum": "f5365546f1f8cdaba3860fcb9b370130", "mode": "0611", "owner": "root", "size": 9922, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1404829709.62-149364541783668/source", "state": "file", "uid": 0}
	
	TASK: [report | include_vars {{ansible_os_family}}.yml] ***********************
	ok: [localhost] => {"ansible_facts": {"os_commands": {"apt-get": {"command": "apt-get --version"}}, "os_files": ["/var/log/syslog"]}}
	
	TASK: [report | running common commands] **************************************
	changed: [localhost] => (item={'value': {'command': 'uname -a'}, 'key': 'uname'}) => {"changed": true, "cmd": "uname -a > /tmp/tower-report-2014-07-08-14-28-29/uname  ", "delta": "0:00:00.003675", "end": "2014-07-08 14:28:29.722961", "item": {"key": "uname", "value": {"command": "uname -a"}}, "rc": 0, "start": "2014-07-08 14:28:29.719286", "stderr": "", "stdout": ""}
	changed: [localhost] => (item={'value': {'command': 'who'}, 'key': 'who'}) => {"changed": true, "cmd": "who > /tmp/tower-report-2014-07-08-14-28-29/who  ", "delta": "0:00:00.002545", "end": "2014-07-08 14:28:29.781465", "item": {"key": "who", "value": {"command": "who"}}, "rc": 0, "start": "2014-07-08 14:28:29.778920", "stderr": "", "stdout": ""}
	changed: [localhost] => (item={'value': {'command': 'hostname -f'}, 'key': 'hostname'}) => {"changed": true, "cmd": "hostname -f > /tmp/tower-report-2014-07-08-14-28-29/hostname  ", "delta": "0:00:00.002628", "end": "2014-07-08 14:28:29.832342", "item": {"key": "hostname", "value": {"command": "hostname -f"}}, "rc": 0, "start": "2014-07-08 14:28:29.829714", "stderr": "", "stdout": ""}
	
	TASK: [report | running os commands] ******************************************
	changed: [localhost] => (item={'value': {'command': 'apt-get --version'}, 'key': 'apt-get'}) => {"changed": true, "cmd": "apt-get --version > /tmp/tower-report-2014-07-08-14-28-29/apt-get  ", "delta": "0:00:00.004092", "end": "2014-07-08 14:28:29.901142", "item": {"key": "apt-get", "value": {"command": "apt-get --version"}}, "rc": 0, "start": "2014-07-08 14:28:29.897050", "stderr": "", "stdout": ""}
	
	TASK: [report | collecting common files] **************************************
	changed: [localhost] => (item=/var/log/awx) => {"changed": true, "cmd": "cp --parents -R /var/log/awx /tmp/tower-report-2014-07-08-14-28-29/files ", "delta": "0:00:00.002586", "end": "2014-07-08 14:28:29.967666", "item": "/var/log/awx", "rc": 0, "start": "2014-07-08 14:28:29.965080", "stderr": "", "stdout": ""}
	changed: [localhost] => (item=/etc/awx) => {"changed": true, "cmd": "cp --parents -R /etc/awx /tmp/tower-report-2014-07-08-14-28-29/files ", "delta": "0:00:00.002827", "end": "2014-07-08 14:28:30.026437", "item": "/etc/awx", "rc": 0, "start": "2014-07-08 14:28:30.023610", "stderr": "", "stdout": ""}
	
	TASK: [report | collecting {{ansible_os_family}} files] ***********************
	changed: [localhost] => (item=/var/log/syslog) => {"changed": true, "cmd": "cp --parents -R /var/log/syslog /tmp/tower-report-2014-07-08-14-28-29/files ", "delta": "0:00:00.007113", "end": "2014-07-08 14:28:30.091762", "item": "/var/log/syslog", "rc": 0, "start": "2014-07-08 14:28:30.084649", "stderr": "", "stdout": ""}
	
	PLAY RECAP ********************************************************************
	localhost                  : ok=10   changed=6    unreachable=0    failed=0
	
	
	

In this particular case a report is created like below:

	
	/tmp/tower-report-2014-07-08-14-28-29
	|-- apt-get
	|-- facts.json
	|-- files
	|   |-- etc
	|   |   `-- awx
	|   |       |-- awx.cert
	|   |       |-- awx.key
	|   |       |-- conf.d
	|   |       |   `-- celeryd.py
	|   |       |-- license
	|   |       |-- SECRET_KEY
	|   |       `-- settings.py
	|   `-- var
	|       `-- log
	|           |-- awx
	|           |   |-- setup-2014-06-20-18:02:29.log
	|           |   `-- tower_warnings.log
	|           `-- syslog
	|-- hostname
	|-- uname
	`-- who