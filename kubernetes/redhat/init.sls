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

redhat-kubernetes-tools:
  pkg.installed:
    - names:
      - docker
      - kubelet
      - kubeadm
      - kubectl
      - kubernetes-cni

docker:
  service.running:
    - enable: True
    - watch:
      - pkg: redhat-kubernetes-tools

kubelet:
  service.running:
    - enable: True
    - watch:
      - pkg: redhat-kubernetes-tools
