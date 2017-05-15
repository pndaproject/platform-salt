# Cloud Formation Templates for PNDA

This readme describes the elements found in the cloud formation templates and their purpose in the cloud formatation stack

## Overview
The AWS Cloud Formation templates for PNDA create a VPC with Private and Public IP subnets, with access to most instances via a single public bastion node.

This arrangement is based on the AWS guide "Scenario 2: VPC with Public and Private Subnets (NAT): http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Scenario2.html"

## cf-common.json
cf-common.json contains the elements of the PNDA stack that are common to all flavors.

The flavor specific file `<flavor>/cf-clavor.json` is merged over the top of this file by pnda-cli.py before submitting it to AWS.

### Parameters
The parameters can all be set in pnda_env.yaml under cloud_formation_parameters section.

Some useful parameters include:

  - imageId should be the latest AWS default Ubuntu 14.04, or RHEL 7 image
  - whitelistSshAccess can be set to a restricted range to further secure cluster access
  - instancetypeCdhDn can be set to an instance type with more resources to vertically scale the cluster compute resources

### Resources
#### VPC
A new VPC is created for every PNDA. It would be possible to re-use an existing VPC by removing the AWS::EC2::VPC resource definition and passing in a VPC ID to use as a parameter.

#### Internet Gateway
The internet gateway connects the VPC to the Internet and to other AWS services.

#### Public Subnet
A public subnet is created to allow access from the outside world via ssh connections to a bastion instance, which is the only instance on this subnet.

The route table for the public subnet contains an entry that enables instances in the subnet to communicate directly with the Internet. AWS automatically adds a rule that keeps local traffic on the subnet.

#### ACL
The ACL is an extra layer of firewall security group for the public route table.
 - TCP port 22 is opened for SSH
 - UDP port 123 is opened for NTP
 - Unlike a security group, ACL's are stateless so require the return paths for outbound connections to be open
 - There are no restrictions on outbound connections through the ACL

#### Private subnet
A private subnet is created to host the main instances. These instances cannot be directly accessed from the Internet.

The NAT gateway with an Elastic IP address enables instances in the private subnet to send requests to the Internet (for example, for software updates).

The route table for the private subnet contains an entry that enables instances in the subnet to communicate with the Internet through the NAT gateway. AWS automatically adds a rule that keeps local traffic on the subnet.

#### Security Groups
Security groups are used to restrict which ports are open to the outside world and to open all ports for internal communication.

The only port opened to external traffic is 22 on the bastion for ssh access the whitelistSshAccess parameter can be used to restrict who can access this.

Internally, all ports are opened between the bastion and the other instances, and between the other instances themselves.

There are no restrictions on outgoing traffic

## cf-flavor.json

The cloud instances are defined in a flavor specific config file `<flavor>/cf-flavor.json`, which is merged over the top of cf-common.json by pnda-cli.py before sumbitting it to AWS.

These files contain the instance definitions for each machine in PNDA.

To re-organise the instances in a given flavor:
  1. Add or remove instances definitions
  2. Set the node_type tag to match the name of the bootstrap script that should run on it.
  3. Edit the bootstrap scripts to assign roles that you want each instance to have. The instances are then targetted by roles by platform-salt scripts which install software on the right instances.

### Standard

The standard flavor is intended for PoC systems handling reasonable quantities of data.

The main hadoop management services are run in HA.

It consists of the following instances:
  - bastion:     ssh access into the other instances on the private subnet
  - kafka:       the kafka databus, can be horizontally scaled using the -k parameter to pnda-cli.py
  - zookeeper:   zookeeper used by kafka, can be horizontally scaled using the -z parameter to pnda-cli.py
  - tools        hosts kafka manager and other tools for administering the databus
  - hadoop-dn:      the hadoop worker nodes, can be horizontally scaled using the -n parameter to pnda-cli.py
  - hadoop-edge:    an instance to access the hadoop services from, also hosts the pnda console
  - hadoop-mgr:     the hadoop management services node, there are 4 of these and they run the main services in HA mode
  - logserver:   runs ELK and aggregates logs from across the cluster
  - opentsdb:    runs the opentsdb daemon, can be horizontally scaled using the -o parameter to pnda-cli.py
  - jupyter:     the Jupyter notebook server for data exploration
  - saltmaster:  the saltmaster runs the scripts for installing software on the other instances
  - hadoop-cm:      the hadoop manager cluster manager

### Pico

The pico flavor is intended for development and learning only.

The main hadoop management services are *not* run in HA.

It consists of the following instances:
  - bastion:  ssh access into the other instances on the private subnet
  - kafka:    the kafka databus, can be horizontally scaled using the -k parameter to pnda-cli.py
  - hadoop-dn:   the hadoop worker nodes, can be horizontally scaled using the -n parameter to pnda-cli.py
  - hadoop-edge: an instance to access the hadoop services from, also hosts the pnda console, the saltmaster and hadoop manager
  - hadoop-mgr1: the hadoop management services node, also hosts opentsdb
