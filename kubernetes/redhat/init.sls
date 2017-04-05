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

