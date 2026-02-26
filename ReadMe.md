```markdown
# Table of Contents
- [1 Prerequisites](#1-prerequisites)
- [2 Requirements](#2-requirements)
- [3 How to run the playbooks](#3-how-to-run-the-playbooks)
  - [3.1 ConfigureVMs.yml](#31-configurevmsyml)
  - [3.2 CleanUpVMs.yml](#32-cleanupvmsyml)
  - [3.3 backup_to_database.yml](#33-backup_to_databaseyml)
  - [3.4 backup_to_loadbalancer.yml](#34-backup_to_loadbalanceryml)
  - [3.5 backup_to_webserver.yml](#35-backup_to_webserveryml)
- [4 How to verify](#4-how-to-verify)
  - [4.1 Verify that all required servers are created](#41-verify-that-all-required-servers-are-created)
  - [4.2 Verify SSH access to all servers from the Master VM](#42-verify-ssh-access-to-all-servers-from-the-master-vm)
  - [4.3 Verify required packages on each server role](#43-verify-required-packages-on-each-server-role)
  - [4.4 Verify users and groups on the required servers](#44-verify-users-and-groups-on-the-required-servers)
  - [4.5 Verify that all servers have been deleted](#45-verify-that-all-servers-have-been-deleted)
```
---

## 1 Prerequisites

You need to have access to OsloMet’s network either using the same Wifi or connect via EduVPN. In order to log in to the Master VM you will need to send your public key via mail/discord/teams or other platforms, so that it can be added to the Master VM’s `authorized_keys`.

> **NB: Do not send your private key**

Once your public key has been added to `authorized_keys`, you can SSH into the Master VM by writing:

```bash
ssh ubuntu@10.196.241.251

```

---

## 2 Requirements

The project has the following requirements:

* One server which will be the loadbalancer. This one should run pound.
* Two database servers, each with a single CPU, running the mysql server.
* Two webservers, each with a single CPU, with apache2, php and php-mysql libraries.
* One backup server.
* The development team will configure their database themselves.
* The users `tom`, `brady` and `janet` should be on all servers except the backup server. They need sudo rights and to be members of the new group «webadmins».

**All the servers have the following configuration:**

* **Image:** Ubuntu-24.04-LTS (Noble Numbat)
* **Flavor:** aem.1c2r.50g
* **Network:** oslomet
* **Key pair:** MasterVMKey

---

## 3 How to run the playbooks

Make sure you are in the `Oblig1` folder. Inside are 2 main playbooks and a folder called `BackupPlaybooks` that contains 3 backup playbooks.

**Main playbooks:**

* `ConfigureVMs.yml`
* `CleanUpVMs.yml`

**Backup playbooks:**

* `backup_to_database.yml`
* `backup_to_loadbalancer.yml`
* `backup_to_webserver.yml`

### 3.1 ConfigureVMs.yml

This command sets up the environment for the web solution. It also includes the commands to initialize terraform within the folder allowing you to run terraform commands. This playbook provisions the 6 servers using terraform and are given their respective roles by the configuration provided by the `ConfigureVMs.yml` file.

You can run this playbook with the following command:

```bash
ansible-playbook ConfigureVMs.yml

```

### 3.2 CleanUpVMs.yml

This command cleans up the environment that was created by the `ConfigureVMs.yml` file. Which means that it also deletes any existing servers.

You can run this playbook with the following command:

```bash
ansible-playbook CleanUpVMs.yml

```

### 3.3 backup_to_database.yml

This playbook configures the backup server to act as a database backupserver by installing the mysql-server package. It also updates the package cache before installation. Make sure you are in `~/Oblig1/BackupPlaybooks/`.

You can run this playbook with the following command:

```bash
ansible-playbook -i ~/Oblig1/inventory/backup_inventory.ini backup_to_database.yml

```

### 3.4 backup_to_loadbalancer.yml

This playbook configures the backup server to act as a load balancer backup server by installing the pound package. It updates the package cache and adds the required repository before installation. Make sure you are in `~/Oblig1/BackupPlaybooks/`.

You can run this playbook with the following command:

```bash
ansible-playbook -i ~/Oblig1/inventory/backup_inventory.ini backup_to_loadbalancer.yml

```

### 3.5 backup_to_webserver.yml

This playbook configures the backup server to act as a web server backup server by installing apache2, php, php-cli, and php-mysql. It also ensures that the Apache2 service is started and enabled. Make sure you are in `~/Oblig1/BackupPlaybooks/`.

You can run this playbook with the following command:

```bash
ansible-playbook -i ~/Oblig1/inventory/backup_inventory.ini backup_to_webserver.yml

```

---

## 4 How to verify

The following subsections explains how you can verify installations, users, groups, ssh logins, etc.

### 4.1 Verify that all required servers are created

Check the Terraform outputs to confirm that all server IPs were created:

```bash
terraform output webserver_ips
terraform output database_ips
terraform output loadbalancer_ip
terraform output backup_ip

```

**Expected result:**

* `webserver_ips` → 2 IP addresses
* `database_ips` → 2 IP addresses
* `loadbalancer_ip` → 1 IP address
* `backup_ip` → 1 IP address

*This confirms a total of 6 servers.*

### 4.2 Verify SSH access to all servers from the Master VM

Use SSH from the Master VM to verify key-based login works to each server. Example commands (replace `<IP>` with the actual IPs from Terraform output):

```bash
ssh ubuntu@<LOADBALANCER_IP> hostname
ssh ubuntu@<WEBSERVER_1_IP> hostname
ssh ubuntu@<WEBSERVER_2_IP> hostname
ssh ubuntu@<DATABASE_1_IP> hostname
ssh ubuntu@<DATABASE_2_IP> hostname
ssh ubuntu@<BACKUP_IP> hostname

```

*If the connection succeeds and returns a hostname, SSH access is working.*

### 4.3 Verify required packages on each server role

**Load balancer server (pound)**

```bash
ssh ubuntu@<LOADBALANCER_IP> "dpkg -l | grep -E '^ii\s+pound\b'"

```

**Database servers (mysql-server)**

```bash
ssh ubuntu@<DATABASE_IP> "dpkg -l | grep -E '^ii\s+mysql-server\b'"

```

**Web servers (apache2, php, php-mysql)**

```bash
ssh ubuntu@<WEBSERVER_IP> "dpkg -l | grep -E '^ii\s+(apache2|php|php-mysql)\b'"

```

### 4.4 Verify users and groups on the required servers

The users `tom`, `brady`, and `janet` and the group `webadmins` must exist on:

* load balancer
* web servers
* database servers

They should **not** be created on the backup server. Run these commands on the load balancer, web servers, and database servers:

```bash
ssh ubuntu@<IP> "id tom; id brady; id janet"

```

### 4.5 Verify that all servers have been deleted

The cleanup playbook runs `terraform destroy -auto-approve`, which removes the Terraform-managed servers.

Run this command:

```bash
terraform state list

```

**Expected result:**
No resources are listed (empty output), or Terraform reports that no state/resources exist.

*This means the Terraform-managed infrastructure has been removed.*
