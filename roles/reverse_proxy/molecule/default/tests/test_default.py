import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']
).get_hosts('all')


def test_hosts_file(host):
    f = host.file('/etc/hosts')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'

def test_nginx_conf_file(host):
    f = host.file('/var/www/nginx/nginx.conf')
    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'

def test_nginx_running_enabled(host):
    nginx = host.service('nginx')
    assert nginx.is_running

def test_apache_running_enabled(host):
    httpd = host.service('httpd')
    assert httpd.is_running
    