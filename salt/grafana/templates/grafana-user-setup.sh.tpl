#!/bin/bash
{% set pnda_user = pillar['pnda']['user'] %}
{% set pnda_password = pillar['pnda']['password'] %}
while ! nc -z localhost 3000; do   
  sleep 1
done
sleep 1
curl -H "Content-Type: application/json" -X POST -d '{"name":"{{ pnda_user }}", "email":"pnda@pnda.com", "login":"{{ pnda_user }}", "password":"{{ pnda_password }}"}' http://admin:admin@localhost:3000/api/admin/users
curl -H "Content-Type: application/json" -X PUT -d '{"IsGrafanaAdmin":true}' http://admin:admin@localhost:3000/api/admin/users/2/permissions
curl -H "Content-Type: application/json" -X PATCH -d '{"orgId": 1, "name": "Main Org.", "role": "Admin"}' http://admin:admin@localhost:3000/api/orgs/1/users/2
curl -X DELETE http://{{ pnda_user }}:{{ pnda_password }}@localhost:3000/api/admin/users/1
