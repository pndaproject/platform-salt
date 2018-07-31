#!/bin/bash
CONTENT='      <quickLinksConfigurations>\
        <quickLinksConfiguration>\
          <fileName>quicklinks.json</fileName>\
          <default>true</default>\
        </quickLinksConfiguration>\
      </quickLinksConfigurations>'

SERVICE_CNT=$(sed -n '/<service>/p' $1 | wc -l)
echo "$SERVICE_CNT"

CONF_CNT=$(sed -n '/<quickLinksConfiguration>/p'  $1 | wc -l)

echo "$CONF_CNT" 

if [[ $SERVICE_CNT -gt 0 && $CONF_CNT -eq 0 ]]; then
  sed -i '/<\/service>/i\'"$CONTENT" $1
fi

CONTENT='      <quickLinksConfigurations-dir>quicklinks-mapred</quickLinksConfigurations-dir>' 
sed -i '/<configuration-dir>configuration-mapred<\/configuration-dir>/a\'"$CONTENT" $1