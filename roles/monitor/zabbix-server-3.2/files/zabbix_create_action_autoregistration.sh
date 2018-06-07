#!/bin/bash

actionname="Auto registration"
zabbix_api_host="10.5.252.57"
zabbix_api_url="http://${zabbix_api_host}/zabbix/api_jsonrpc.php"

token=$(curl -s -X POST -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
        "user": "admin",
        "password": "zabbix"
    },
    "id": 1,
    "auth": null
}' "$zabbix_api_url" | jq -r .result)


curl -s -X POST -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{
    "jsonrpc": "2.0",
    "method": "action.get",
    "params": {
        "filter": {
            "eventsource": 2
        }
    },
    "auth": "'"$token"'",
    "id": 1
}' "$zabbix_api_url" | jq -r .result[].name | grep -sq "$actionname"

if [[ $? -eq 0 ]]; then
  actionid=$(curl -s -X POST -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{
    "jsonrpc": "2.0",
    "method": "action.get",
    "params": {
        "filter": {
            "eventsource": 2
        }
    },
    "auth": "'"$token"'",
    "id": 1
}' "$zabbix_api_url" | jq -r '.result[] | select (.name=="'"$actionname"'") | .actionid')

 curl -X POST -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{
    "jsonrpc": "2.0",
    "method": "action.delete",
    "params": [
        '"$actionid"'
    ],
    "auth": "'"$token"'",
    "id": 1
}' "$zabbix_api_url"
fi

curl -X POST -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{
  "jsonrpc": "2.0",
  "method": "action.create",
  "params": {
      "name": "'"$actionname"'",
      "eventsource": "2",
      "status": "0",
      "esc_period": "0",
      "def_shortdata": "Auto registration: {HOST.HOST} - {HOST.IP}",
      "def_longdata": "Host name: {HOST.HOST}\r\nHost IP: {HOST.IP}\r\nAgent port: {HOST.PORT}",
      "recovery_msg": "0",
      "r_shortdata": "",
      "r_longdata": "",
      "filter": {
        "evaltype": "0",
        "formula": "",
        "conditions": []
      },
      "operations": [
        {
          "operationtype": "2",
          "esc_period": "0",
          "esc_step_from": "1",
          "esc_step_to": "1",
          "evaltype": "0",
          "opconditions": []
        },
        {
          "operationtype": "4",
          "esc_period": "0",
          "esc_step_from": "1",
          "esc_step_to": "1",
          "evaltype": "0",
          "opconditions": [],
          "opgroup": [
            {
              "groupid": "2"
            },
            {
              "groupid": "5"
            }
          ]
        },
        {
          "operationtype": "6",
          "esc_period": "0",
          "esc_step_from": "1",
          "esc_step_to": "1",
          "evaltype": "0",
          "opconditions": [],
          "optemplate": [
            {
              "templateid": "10001"
            }
          ]
        }
      ]
    },
  "auth": "'"$token"'",
  "id": 1
}' "$zabbix_api_url"
