{% if {% if grains.get('os_family', '') == 'RedHat' %}
include kubernetes.redhat
{% elif {% if grains.get('os_family', '') == 'Debian' %}
include kubernetes.debian
{% endif %}
