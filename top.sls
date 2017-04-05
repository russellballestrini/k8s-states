base:

  '*':
    - ntp
    - kubernetes
    
  # Kubernetes Minion Node.  
  'role:minion':
    - match: grain
    - kubernetes.minion
    
  # Kubernetes Master Node.  
  'role:master':
    - match: grain
    - kubernetes.master
