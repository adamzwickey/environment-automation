bosh int ./creds/bosh-bootstrap-creds.yml --path /director_ssl/ca > state/bosh-bootstrap-ca
bosh alias-env bosh-bootstrap -e $BOSH_BOOTSTRAP_PUBLIC_IP --ca-cert state/bosh-bootstrap-ca
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh int ./creds/bosh-bootstrap-creds.yml --path /admin_password)
export BOSH_ENVIRONMENT=bosh-bootstrap
bosh login
