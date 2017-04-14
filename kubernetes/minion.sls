# make shorter, easier to use vars from pillar.
{% set bootstrap_token = pillar.get('kubernetes_bootstrap_token', 'missing') %}
{% set master_address = pillar.get('kubernetes_master_address', 'master') %}

{% if bootstrap_token != 'missing' %}
minion-kubeadm-join:
  cmd.run:
    - name: kubeadm join --token {{ bootstrap_token }} {{ master_address }}:6443
    # don't try to join if kubeadm is already joined.
    - unless: netstat -nap  | grep kubelet | grep 10250
{% endif %}
