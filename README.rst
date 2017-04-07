k8s-states
#############

Kubernetes on AWS with Botoform and SaltStack

This project and guide provides automation for standing up a Kubernetes cluster on AWS using Botoform and SaltStack. As an example we will stand up a Selnium Grid cluster on top of Kubernetes.


#. Install botoform (`Quickstart <https://botoform.readthedocs.io/en/latest/guides/quickstart.html>`)

 * clone botoform repo
 * create virtual env
 * install dependencies
 * configure ``~/.aws/config``

#. Clone this repo:

 .. code-block:: bash
 
  git clone https://github.com/russellballestrini/k8s-states.git

#. Create AWS resources with botoform, this step also provisions SaltStack:

 .. code-block:: bash
 
  bf create testk8s -e 'vpc_cidr=192.168.56.0/24' k8s-states/botoform-k8s.yml

#. Connect to Salt/Kubernetes Master and verify it has come online properly.

 .. code-block:: bash
  
  bf dump testk8s instance_roles``
  ssh-add testk8s-*
  ssh -A centos@<bastion-eip>
  ssh <master-private-ip>
  sudo su -
  tail -f /var/log/cloud-init.log
  # wait a bit, then test Salt, the master should join automatically.
  salt-key -L
  # wait a bit, then test Kubernetes.
  kubectl get nodes 
  # when master is in "Ready" state, scale up minions.

#. Scale up the minion autoscaling groups.

 .. code-block:: bash
 
  # TODO: add a tool into botoform for adjusting autoscaling group desired counts.

#. Wait for them to come online and report into Salt/Kubernetes master.

  .. code-block:: bash
   
   kubectl get nodes 


#. Launch containers (for example we show a Selenium Grid setup).

 * pull in notes from selenium blog post
 * pull in selenium grid example from kubenetes repo
 * show commands to run on master

#. Verify

 * show how to use the ELB to access to selenium grid "hub" service
