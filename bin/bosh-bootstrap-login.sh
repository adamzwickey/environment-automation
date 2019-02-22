bosh alias-env bosh-bootstrap -e $CONTROL_PLANE_FQDNS
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh int ./creds/bosh-bootstrap-creds.yml --path /admin_password)
export BOSH_ENVIRONMENT=bosh-bootstrap
bosh login
