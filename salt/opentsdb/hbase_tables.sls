opentsdb-create_opentsdb_hbase_tables:
  cmd.script:
    - name: salt://opentsdb/files/create_table.sh
    - unless: echo "exists 'tsdb'" | hbase shell | grep 'Table tsdb does exist'
    - env:
      - HBASE_HOME: /usr
      - COMPRESSION: snappy
    - use_vt: True

opentsdb-verify:
  cmd.run:
    - name: echo "exists 'tsdb'" | hbase shell | grep 'Table tsdb does exist'
