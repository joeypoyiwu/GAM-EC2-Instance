# GAM-EC2-Instance

This repo will spin up an EC2 instance with Terraform, and then configure it with Ansible.

The Ansible Playbook will update the system to the latest version, install the latest git version, and can also install gam.

First, make sure to download the GAM install BASH script from here: https://raw.githubusercontent.com/jay0lee/GAM/master/src/gam-install.sh

Place it in any directory, and within the Ansible Playbook file, specify the location of the file, and move it over to the EC2 instance. Example:

```
- name: moves a file to destination
  copy:
    src: #~/path/to/gam install
    dest: #~/path/to/any directory
```
