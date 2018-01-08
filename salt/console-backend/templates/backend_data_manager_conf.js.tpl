/* This file was generated from a template */

var hosts = '{{ console_frontend_hosts_csv }}';
var port = '{{ console_frontend_port }}';
var whitelist = hosts.split(',');
whitelist.forEach(function(p, i, a) {
  a[i] = "http://"+a[i]+ ((port=='None')?'':':'+port);
});
module.exports = {
  whitelist: whitelist,
  deployment_manager: {
    host: "{{dm_endpoint}}",
    API: {
      endpoints: "/environment/endpoints",
      packages_available: "/repository/packages?recency=999",
      packages: "/packages",
      applications: "/applications"
    }
  },
  dataset_manager: {
    host: "{{data_service_url}}",
    API: {
     datasets: "/api/v1/datasets"
    }
  },
  session: {
    secret: "data-manager-secret",
    max_age: 60000
  }
};
