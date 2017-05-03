base:

  '*':
    - ntp
    
   # Kubernetes Instances.  
  'role:k8s-*':
    - match: grain   
    - kubernetes
    
  # Kubernetes Minion Node.  
  'role:k8s-minion':
    - match: grain
    - kubernetes.minion
    
  # Kubernetes Master Node.  
  'role:k8s-master':
    - match: grain
    - kubernetes.master

  # NAT Node.  
  'role:nat':
    - match: grain
    - nat
