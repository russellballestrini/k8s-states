---

# enable ip forwarding and redirects.
sysctl-nat:
  file.managed:
    - name: /etc/sysctl.d/10-nat.conf
    - source: salt://nat/10-nat.conf
    - user: root
    - group: root
    - mode: 0644
    - watch_in:
      - cmd: sysctl-nat

  cmd.wait:
    - name: sysctl --system

manage /etc/sysconfig/iptables:
  file.managed:
    - name: /etc/sysconfig/iptables
    - source: salt://nat/iptables.conf
    - user: root
    - group: root
    - mode: 0600

iptables service:
  file.managed:
    - name: /etc/systemd/system/iptables.service
    - source: salt://nat/iptables.service
    - owner: root
    - group: root
    - mode: 0644

  service.running:
    - name: iptables
    - enabled: True
    - watch:
      - file: /etc/systemd/system/iptables.service
      - file: /etc/sysconfig/iptables
      - file: /etc/sysctl.d/10-nat.conf 
