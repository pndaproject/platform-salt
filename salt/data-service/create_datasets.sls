data-service_wait_for_api:
  rest_helper:
    - wait
    - url: http://localhost:7000/api/v1/datasets

data-service_create_testbot:
  http.query:
    - name: 'http://localhost:7000/api/v1/datasets/testbot/'
    - match: 'success'
    - method: 'PUT'
    - header: 'Content-Type: application/json'
    - data: '{"policy":"size","path":"/user/pnda/PNDA_datasets/datasets/source=testbot","mode":"delete","max_size_gigabytes":1}'
