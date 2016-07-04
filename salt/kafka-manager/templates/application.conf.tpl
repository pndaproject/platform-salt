
# Copyright 2015 Yahoo Inc. Licensed under the Apache License, Version 2.0
# See accompanying LICENSE file.  
#
# Some parts Copyright (c) 2016 Cisco and/or its affiliates.

play.crypto.secret="{{ application_secret }}"
play.i18n.langs=["en"]
play.http.requestHandler = "play.http.DefaultHttpRequestHandler"
play.application.loader=loader.KafkaManagerLoader
kafka-manager.zkhosts="{{ zk_servers|join(',') }}"
pinned-dispatcher.type="PinnedDispatcher"
pinned-dispatcher.executor="thread-pool-executor"
application.features=["KMClusterManagerFeature","KMTopicManagerFeature","KMPreferredReplicaElectionFeature","KMReassignPartitionsFeature"]
akka {
  loggers = ["akka.event.slf4j.Slf4jLogger"]
  loglevel = "INFO"
}
