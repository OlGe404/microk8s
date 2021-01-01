#!/bin/bash

grafana_host="https://grafana.microk8s.local"
grafana_creds="admin:aHQEu6PMGfg85Nn"
grafana_datasource="prometheus"
dashboard_ids=(9524);

for dashboard in "${dashboard_ids[@]}"; do
  echo -n "Processing dashboard_id $dashboard: "
  dashboard_json=$(curl --silent --user "$grafana_creds" $grafana_host/api/gnet/dashboards/$dashboard | jq .json)
  echo $dashboard_json
  curl --silent --user "$grafana_creds" -X POST -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{\"dashboard\":$dashboard_json,\"overwrite\":true}]}" \
    $grafana_host/api/dashboards/import; echo ""
done