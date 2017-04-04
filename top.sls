base:

  '*':
    - ntp
    - docker
    - kubernetes
    
  # Kubernetes Minion Node.  
  'roles:minion':
    - match: grain
    - blah
    
  # Kubernetes Master Node.  
  'roles:master':
    - match: grain
    - blah
