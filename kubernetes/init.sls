{% if grains.get('os_family', '') == 'RedHat' %}
include kubernetes.redhat
{% elif grains.get('os_family', '') == 'Debian' %}
include kubernetes.debian
{% endif %}
