k8s-states
#############

Kubernetes on AWS with `Botoform <http://botoform.com>`_ and SaltStack

This project and guide provides automation for standing up a Kubernetes cluster on AWS using `Botoform <http://botoform.com>`_ and SaltStack. Once the Kubernetes cluster is online, we will use it to deploy a Selenium Grid cluster.

.. contents::

Diagram of infra
===================

.. image:: selenium-grid-in-aws-on-kubernetes.png
 :width: 600
 :alt: Selenium Grid in AWS on Kubernetes

Example
============

In this example we use `Botoform <http://botoform.com>`_ to spin up resources on AWS and bootstrap SaltStack on instances. When SaltStack is ready, it will automatically install Kubernetes on the master.

When the Kubernetes master is ready we can spin up one or many Kubernetes minion nodes using AWS Autoscaling.
The minion instances will automatically report to the Salt master, install Kubernetes, and join the to the Kubernetes cluster.

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
 
  bf create testk8s $HOME/botoform-k8s.yml
  bf dump testk8s instances

  # add the newly created SSH private key to your ssh-agent.
  ssh-add testk8s-*


4. In another terminal, you may optionally connect to Salt/Kubernetes Master and verify it has come online properly.

.. code-block:: bash
  
  ssh -A centos@<bastion-eip>
  ssh <master-private-ip>
  
  # you can watch cloud-init as it works.
  tail -f /var/log/cloud-init.log

  # when master is in "Ready" state, scale up minions.
  export KUBECONFIG=/etc/kubernetes/admin.conf
  kubectl get nodes

5. Back to the first terminal, scale up the minion autoscaling group.

.. code-block:: bash
 
  # TODO: create botoform tool for scaling ASG desired counts.
  bf shell testk8s
  
.. code-block:: python

  >>> as_name = evpc.autoscaling.get_related_autoscaling_group_names()[0]
  >>> len(evpc.instances)
  2
  >>> evpc.autoscaling.scale_related_autoscaling_group(as_name, 5)
  >>> len(evpc.instances)
  7

6. Tag newly autoscaled instances:

.. code-block:: bash

 bf refresh testk8s instance_roles $HOME/botoform-k8s.yml


7. Wait for them to come online and report into Salt/Kubernetes master as ``Ready``.

.. code-block:: bash

   # watch salt key for new minions.
   watch 'salt-key -L'
   
   # watch kubectl for new kubernetes nodes.
   watch 'kubectl get nodes'

Congratulations! You have built a fully functional Kubernetes cluster!

Launch Containers
=======================

Now it is time to schedule some containers to run on our Kubernetes cluster.  In this guide we will create Selenium grid with an Internet accessible hub and private selenium chrome-nodes. 

In this example we pin Selenium to version ``2.53.1`` when we specify the official community supported docker image. Both the Selenium hub and nodes must be pinned to the same Selenium version to ensure proper communication. We pin the Chrome nodes in the kubernetes spec file located in ``kubernetes/specs/selenium-node-chrome.yaml``.

These commands should be run on the Kubernetes master as the root user. To get to the Kubernetes master connect to the bastion and then hop to the master.

1. Launch the selenium hub (and expose hub service for external access):

.. code-block:: bash

 kubectl get pods
 kubectl get services
 kubectl create -f /srv/salt/kubernetes/specs/selenium-hub.yaml
 kubectl get pods
 kubectl get services

2. Launch a selenium chrome-node:

.. code-block:: bash

 kubectl get pods
 kubectl create -f /srv/salt/kubernetes/specs/selenium-node-chrome.yaml
 kubectl get pods

3. Scale up the chrome node deployment:

.. code-block:: bash

 kubectl get pods
 kubectl scale deployment selenium-node-chrome --replicas=4
 kubectl get pods

5. Use the ELB (Elastic Load Balancer) to access to selenium grid "hub" service. You should be able to access the hub by pointing your web browser to the ELB DNS record.
 
Example Teardown
=========================

When you are done with this example, or you just don't want this cluster anymore, you can run to following commands to completely terminate all AWS resources spun up in the previous section.

1. Unlock VPC:

.. code-block:: bash
 
  bf unlock testk8s
  
2. Destroy VPC:

.. code-block:: bash
 
  bf destroy testk8s

Appendix
===========================

China Region
---------------------

The ``botoform-k8s.yml`` template supports a few extra arguments which customize the deployment.

For example the China (cn-north-1) region does not have access to Route53 and only has 2 availaibilty zones.
We can deal with this by passing extra arguments to the ``bf create`` command:

.. code-block:: bash

 bf create testk8s -e "private_zone=false, azone_count=2" $HOME/botoform-k8s.yml


