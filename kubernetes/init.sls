{% if grains.get('os_family', '') == 'RedHat' %}
include:
  - kubernetes.redhat
{% elif grains.get('os_family', '') == 'Debian' %}
include:
  - kubernetes.debian
{% endif %}

/etc/sysctl.d/kube-sysctl.conf:
  file.managed:
    - source: salt://kubernetes/kube-sysctl.conf
    - mode: 0640
  cmd.wait:
    - name: sysctl --system
    - watch: 
      - file: /etc/sysctl.d/kube-sysctl.conf

docker:
  service.running:
    - enable: True
    - watch:
      - pkg: kubernetes-packages

kubelet:
  service.running:
    - enable: True
    - watch:
      - pkg: kubernetes-packages
