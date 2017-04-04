ntp:
  pkg:
    - installed

{% set ntp_service_name = 'ntp' %}
{% if grains.get('os_family', '') == 'RedHat' %}
{% set ntp_service_name = 'ntpd' %}
{% endif %}

ntp-service:
  service:
    - running
    - name: {{ ntp_service_name }}
    - watch:
      - pkg: ntp
