opentsdb-create_opentsdb_hbase_tables:
  cmd.script:
    - name: salt://opentsdb/files/create_table.sh
    - onlyif: echo "exists 'tsdb'" | hbase shell | grep 'Table tsdb does not exist'
    - env:
      - HBASE_HOME: /usr
      - COMPRESSION: snappy
    - use_vt: True
