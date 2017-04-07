k8s-states
#############

Kubernetes on AWS with `Botoform <http://botoform.com>`_ and SaltStack

This project and guide provides automation for standing up a Kubernetes cluster on AWS using `Botoform <http://botoform.com>`_ and SaltStack. 

.. contents::

Example
============

In this example we use `Botoform <http://botoform.com>`_ to spin up AWS resources and provision SaltStack on the instances.

When SaltStack is ready, it will install Kubernetes on the master.

When the Kubernetes master is ready we can spin up one or many Kubernetes minion nodes using AWS Autoscaling.

When these instances report into SaltStack, it will install Kubernetes on the minions and join them to the cluster.

Finally, when all the Kubernetes minion nodes are in the ``Ready`` state, we can use ``kubectl`` to spin up Selenium hub and chrome-nodes.


1. Install and activate Botoform. Reference: (Botoform `Quickstart <https://botoform.readthedocs.io/en/latest/guides/quickstart.html>`_)

.. code-block:: bash
 
  wget -O - https://raw.githubusercontent.com/russellballestrini/botoform/master/botoform-bootstrap.sh | sh
  
  # whenever you want to use the 'bf' tool, you need to activate it.
  source $HOME/botoform/env/bin/activate

2. Download the Botoform template for this project:

.. code-block:: bash

 wget https://raw.githubusercontent.com/russellballestrini/k8s-states/master/botoform-k8s.yml -O $HOME/botoform-k8s.yml

3. Create AWS resources with botoform, this step also provisions SaltStack:

.. code-block:: bash
 
  bf create testk8s -e 'vpc_cidr=192.168.56.0/24' $HOME/botoform-k8s.yml

4. Connect to Salt/Kubernetes Master and verify it has come online properly.

.. code-block:: bash
  
  bf dump testk8s instance_roles
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

5. Scale up the minion autoscaling groups.

.. code-block:: bash
 
  # TODO: add a tool into botoform for adjusting autoscaling group desired counts.

6. Wait for them to come online and report into Salt/Kubernetes master.

.. code-block:: bash
   
   kubectl get nodes 


7. Launch containers (for example we show a Selenium Grid setup).

* pull in notes from selenium blog post
* pull in selenium grid example from kubenetes repo
* show commands to run on master

8. Verify

* show how to use the ELB to access to selenium grid "hub" service
 
Example Teardown
=========================

When you are done with this example, or you just don't want this cluster anymore, you can run to following commands to completely terminate all AWS resources spun up in the previous section.

1. Unlock VPC:

.. code-block:: bash
 
  bf unlock testk8s
  
2. Destroy VPC:

.. code-block:: bash
 
  bf destroy testk8s
