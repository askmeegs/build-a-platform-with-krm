#!/bin/bash 

config-connector export "//sqladmin.googleapis.com/sql/v1beta4/projects/$PROJECT_ID/instances/cymbal-dev" \
    --output cloudsql/

config-connector export \
    "//sqladmin.googleapis.com/sql/v1beta4/projects/$PROJECT_ID/instances/cymbal-dev/databases/accounts-db" \
    --output cloudsql/

config-connector export \
    "//sqladmin.googleapis.com/sql/v1beta4/projects/$PROJECT_ID/instances/cymbal-dev/databases/ledger-db" \
    --output cloudsql/