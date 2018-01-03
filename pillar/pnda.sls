pnda:
  user: 'pnda'
  password_hash: $6$g4LehAEw$gIGXrIXeQBXgytGswU3m1Ovtb7FpGMZpWd5P8wdrbaGXFN.HeJ1UE1Hp/d6jAbEmTuymdcQAhEKQlDxd53Gjn1
  password: pnda
  group: 'pnda'
  homedir: '/opt/pnda'

  master_dataset:
    directory: /user/pnda/PNDA_datasets/datasets
    quarantine_directory: /user/pnda/PNDA_datasets/quarantine
    bulk_directory: /user/pnda/PNDA_datasets/bulk
    staging_directory: /user/pnda/PNDA_datasets/staging
  
  app_packages:
    app_packages_hdfs_path: /pnda/deployment/app_packages
