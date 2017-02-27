output {
  elasticsearch { hosts => {{list_of_ingest|string}} }
}
input {
  file {
    path => "{{input_dir|string}}"
  }
}
