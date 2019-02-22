bosh int ./creds/bosh-bootstrap-creds.yml --path /credhub_tls/certificate > state/credhub_ca_cert
export CREDHUB_CA=state/credhub_ca_cert
export CREDHUB_PWD=$(bosh int ./creds/bosh-bootstrap-creds.yml --path /credhub_cli_user_password)
export CREDHUB_USER=credhub_cli_user
export CREDHUB_SERVER=https://$CONTROL_PLANE_FQDNS:8844
credhub api $CREDHUB_SERVER --ca-cert=$CREDHUB_CA
credhub login --ca-cert=$CREDHUB_CA -u $CREDHUB_USER -p $CREDHUB_PWD
