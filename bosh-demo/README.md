# BOSH Demo

- Deploy Zookeeper
```bash
bosh upload-stemcell https://s3.amazonaws.com/bosh-gce-light-stemcells/light-bosh-stemcell-3586.79-google-kvm-ubuntu-trusty-go_agent.tgz
bosh deploy -d zookeeper zookeeper.yml
bosh -d zookeeper run-errand smoke-tests
```

- Update Zookeeper
```bash
bosh upload-stemcell https://s3.amazonaws.com/bosh-gce-light-stemcells/light-bosh-stemcell-250.9-google-kvm-ubuntu-xenial-go_agent.tgz
bosh deploy -d zookeeper zookeeper-latest.yml
bosh -d zookeeper run-errand smoke-tests
```
