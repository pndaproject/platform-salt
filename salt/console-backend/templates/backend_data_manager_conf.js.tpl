/* This file was generated from a template */

var hostname = process.env.HOSTNAME || 'localhost';
var whitelist = ['http://{{nodename}}', 'http://' + hostname, 'http://' + hostname + ':8006', 'http://0.0.0.0:8006'];
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
  }
};
