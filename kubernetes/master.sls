#kubeadm init
master-kubeadm-init:
  cmd.run:
    - name: kubeadm init
    # only try to init the kubernetes master when there are no default bootstrap tokens.
    - unless: kubeadm token list | grep "default bootstrap" 

master-create-bootstrap-token-piller:
  cmd.run:
    - name: |
        mkdir -p /srv/pillar/kubernetes
        kubernetes_bootstrap_token=$(kubeadm token list | grep "default bootstrap" | cut -d ' ' -f 1)
        echo "kubernetes_bootstrap_token: $kubernetes_bootstrap_token" > /srv/pillar/kubernetes/bootstrap-token.sls
    - onchanges:
      - cmd: master-kubeadm-init



 #should we make centos user have the ability to talk to kubernetes cluster?
# should we assume root and configure this to run in bash_rc?:
#
#   export KUBECONFIG=/etc/kubernetes/admin.conf
#  sudo cp /etc/kubernetes/admin.conf $HOME/
#  sudo chown $(id -u):$(id -g) $HOME/admin.conf
#  export KUBECONFIG=$HOME/admin.conf
#
# verify:
# kubectl get pods --namespace=kube-system
