{% if pillar.get('kubernetes_bootstrap_token', 'missing') != 'missing' %}
minion-kubeadm-join:
  cmd.run:
    - name: kubeadm join --token {{ pillar['kubernetes_bootstrap_token'] }} master:6443
    # don't try to join if kubeadm is already joined.
    - unless: netstat -nap  | grep kubelet | grep 10250
{% endif %}
