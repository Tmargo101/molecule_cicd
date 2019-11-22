import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']
).get_hosts('all')


def test_html_file_and_owner(host):
    f = host.file('/var/www/html')
    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'


def test_apache_conf_file(host):
    conf = host.file('/etc/httpd/conf/httpd.conf')
    assert conf.exists
    assert conf.user == 'root'
    assert conf.group == 'root'


def test_apache_running_and_enabled(host):
    httpd = host.service('httpd')
    assert httpd.is_running
