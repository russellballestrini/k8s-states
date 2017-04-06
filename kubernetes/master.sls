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

master-setup-weave-overlay-network:
  cmd.wait:
    - name: |
        export KUBECONFIG=/etc/kubernetes/admin.conf
        kubectl apply -f https://git.io/weave-kube-1.6
    - unless: export KUBECONFIG=/etc/kubernetes/admin.conf && kubectl get pods --namespace=kube-system | grep weave
    - watch:
      - cmd: master-kubeadm-init

# teach root user about cluster certificates for access to kubeapi.
# this allows kubectl to work.
root-bash-profile-kube-certs:
  file.line:
    - name: /root/.bash_profile
    - content: export KUBECONFIG=/etc/kubernetes/admin.conf
    - mode: insert
    - location: end
    - require:
      - pkg: kubernetes-packages
