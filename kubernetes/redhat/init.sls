/etc/yum.repos.d/kubernetes.repo:
  file.managed:
    - source: salt://kubernetes/redhat/kubernetes.repo
    - mode: 0640
    
