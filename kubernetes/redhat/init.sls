# reference - https://kubernetes.io/docs/getting-started-guides/kubeadm/

/etc/yum.repos.d/kubernetes.repo:
  file.managed:
    - source: salt://kubernetes/redhat/kubernetes.repo
    - mode: 0640

disable-selinux:
  cmd.run:
    - name: setenforce 0
    - check_cmd:
      - /bin/true

kubernetes-packages:
  pkg.installed:
    - names:
      - docker
      - kubelet
      - kubeadm
      - kubectl
      - kubernetes-cni
    - requires:
      - file: /etc/yum.repos.d/kubernetes.repo

# reference: https://github.com/kubernetes/kubernetes/issues/43805
hotifx-kubernetes-github-issue-43805:
  file.line:
    - name: /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
    - content: Environment="KUBELET_NETWORK_ARGS=--cgroup-driver=systemd --network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"
    - match: Environment="KUBELET_NETWORK_ARGS=
    - mode: replace
    - require:
      - pkg: kubernetes-packages
    - require_in:
      - service: kubelet 
  cmd.wait:
    - name: systemctl daemon-reload
    - watch:
      - file: hotifx-kubernetes-github-issue-43805

# TODO: setup centos user to have access to kubectl?
#
#  sudo cp /etc/kubernetes/admin.conf $HOME/
#  sudo chown $(id -u):$(id -g) $HOME/admin.conf
#  export KUBECONFIG=$HOME/admin.conf
