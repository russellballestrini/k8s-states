k8s-states
#############

Kubernetes on AWS with Botoform and SaltStack

This project and guide provides automation for standing up a Kubernetes cluster on AWS using Botoform and SaltStack. As an example we will stand up a Selnium Grid cluster on top of Kubernetes.

#. Install botoform (botoform.com)

#. Create AWS resources with botoform, this step also provisions SaltStack.

#. Connect to Salt/Kubernetes Master and verify it has come online properly.

#. Scale up the minion autoscaling groups.

#. Wait for them to come online and report into Salt/Kubernetes master.

#. Launch containers (for example we show a Selenium Grid setup).

#. Verify
