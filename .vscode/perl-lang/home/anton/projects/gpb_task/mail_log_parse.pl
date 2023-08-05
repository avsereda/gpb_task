{"version":5,"vars":[{"kind":2,"line":2,"name":"lib","containerName":""},{"kind":2,"name":"strict","line":3,"containerName":""},{"containerName":"","name":"warnings","line":4,"kind":2},{"line":6,"name":"utf8","containerName":"","kind":2},{"name":"SQLStore","line":7,"containerName":"Local","kind":2},{"kind":2,"containerName":"Local::Mail","name":"LogFileParser","line":8},{"kind":2,"containerName":"Data","line":9,"name":"Dumper"},{"definition":"my","containerName":null,"kind":13,"name":"$LOG_FILE","line":11,"localvar":"my"},{"line":12,"name":"$DB_DSN","localvar":"my","containerName":null,"definition":"my","kind":13},{"name":"$DB_USER","line":13,"localvar":"my","containerName":null,"definition":"my","kind":13},{"localvar":"my","line":14,"name":"$DB_PASSWORD","kind":13,"definition":"my","containerName":null},{"localvar":"my","line":16,"name":"@messages","kind":13,"containerName":null,"definition":"my"},{"kind":13,"definition":"my","containerName":null,"localvar":"my","name":"@logs","line":17},{"localvar":"my","name":"$parser","line":18,"kind":13,"definition":"my","containerName":null},{"localvar":"my","line":19,"name":"$error","kind":13,"definition":"my","containerName":null},{"localvar":"my","line":21,"name":"%id_set","kind":13,"definition":"my","containerName":null},{"containerName":null,"name":"$parser","line":22,"kind":13},{"containerName":null,"line":22,"name":"$error","kind":13},{"containerName":"Mail::LogFileParser","name":"Local","line":22,"kind":12},{"name":"new","line":22,"containerName":"main::","signature":{"documentation":"","label":"new($msg_id,$log_entry)","parameters":[{"label":"$msg_id"},{"label":"$log_entry"}]},"detail":"($msg_id,$log_entry)","kind":12,"range":{"start":{}}},{"kind":13,"containerName":null,"name":"$LOG_FILE","line":22},{"kind":12,"name":"process","line":23},{"kind":13,"definition":"my","containerName":null,"localvar":"my","line":24,"name":"$msg_id"},{"name":"$log_entry","line":24,"containerName":null,"kind":13},{"localvar":"my","name":"%msg","line":26,"kind":13,"containerName":null,"definition":"my"},{"name":"status","line":26,"kind":12},{"kind":13,"containerName":null,"definition":"my","localvar":"my","name":"$part","line":27},{"kind":13,"containerName":null,"name":"%log_entry","line":27},{"name":"parts","line":27,"kind":12},{"containerName":null,"name":"%part","line":28,"kind":13},{"name":"flag","line":28,"kind":12},{"containerName":null,"name":"%msg","line":29,"kind":13},{"kind":12,"line":29,"name":"created"},{"kind":13,"line":29,"name":"%part","containerName":null},{"line":29,"name":"datetime","kind":12},{"containerName":null,"line":29,"name":"%msg","kind":13},{"line":29,"name":"created","kind":12},{"kind":13,"containerName":null,"name":"%msg","line":30},{"kind":12,"line":30,"name":"id"},{"kind":13,"line":30,"name":"%part","containerName":null},{"line":30,"name":"id","kind":12},{"kind":13,"name":"%msg","line":31,"containerName":null},{"name":"int_id","line":31,"kind":12},{"kind":13,"containerName":null,"line":31,"name":"$msg_id"},{"name":"%msg","line":32,"containerName":null,"kind":13},{"kind":12,"line":32,"name":"str"},{"line":32,"name":"%part","containerName":null,"kind":13},{"name":"text","line":32,"kind":12},{"containerName":null,"line":34,"name":"%part","kind":13},{"line":34,"name":"flag","kind":12},{"name":"%msg","line":35,"containerName":null,"kind":13},{"line":35,"name":"status","kind":12},{"containerName":null,"line":37,"name":"%part","kind":13},{"kind":12,"name":"to_address","line":37},{"containerName":null,"line":38,"name":"%logs","kind":13},{"kind":12,"name":"created","line":40},{"kind":13,"containerName":null,"name":"%part","line":40},{"kind":12,"name":"datetime","line":40},{"line":41,"name":"int_id","kind":12},{"kind":13,"containerName":null,"line":41,"name":"$msg_id"},{"kind":12,"line":42,"name":"str"},{"kind":13,"containerName":null,"line":42,"name":"%part"},{"name":"text","line":42,"kind":12},{"kind":12,"line":43,"name":"address"},{"kind":13,"containerName":null,"name":"%part","line":43},{"kind":12,"line":43,"name":"to_address"},{"name":"%msg","line":48,"containerName":null,"kind":13},{"line":48,"name":"id","kind":12},{"containerName":null,"name":"%id_set","line":49,"kind":13},{"containerName":null,"line":49,"name":"%msg","kind":13},{"kind":12,"name":"id","line":49},{"kind":13,"line":50,"name":"%id_set","containerName":null},{"kind":13,"line":50,"name":"%msg","containerName":null},{"kind":12,"line":50,"name":"id"},{"containerName":null,"line":51,"name":"$messages","kind":13},{"containerName":null,"name":"%msg","line":51,"kind":13},{"name":"%msg","line":53,"containerName":null,"kind":13},{"kind":12,"name":"id","line":53},{"kind":13,"containerName":null,"line":54,"name":"%msg"},{"kind":12,"name":"int_id","line":54},{"kind":13,"containerName":null,"name":"%parser","line":59},{"name":"$db","line":63,"localvar":"my","containerName":null,"definition":"my","kind":13},{"kind":13,"containerName":null,"name":"$db","line":63},{"kind":13,"name":"$error","line":63,"containerName":null},{"containerName":"SQLStore","name":"Local","line":63,"kind":12},{"containerName":"main::","line":63,"name":"new","kind":12},{"kind":13,"containerName":null,"name":"$DB_DSN","line":63},{"kind":12,"name":"user","line":64},{"containerName":null,"name":"$DB_USER","line":64,"kind":13},{"kind":12,"name":"password","line":65},{"containerName":null,"name":"$DB_PASSWORD","line":65,"kind":13},{"kind":13,"containerName":null,"name":"$db","line":67},{"name":"$db","line":69,"containerName":null,"kind":13},{"kind":12,"line":69,"name":"create_messages","containerName":"main::"},{"kind":13,"line":69,"name":"$messages","containerName":null},{"line":70,"name":"$db","containerName":null,"kind":13},{"kind":12,"line":70,"name":"error_message","containerName":"main::"},{"containerName":null,"line":71,"name":"$db","kind":13},{"kind":12,"containerName":"main::","name":"error_message","line":71},{"kind":13,"containerName":null,"line":73,"name":"$db"},{"containerName":"main::","line":73,"name":"create_logs","kind":12},{"kind":13,"containerName":null,"line":73,"name":"$logs"},{"kind":13,"containerName":null,"name":"$db","line":74},{"kind":12,"containerName":"main::","name":"error_message","line":74},{"kind":13,"line":75,"name":"$db","containerName":null},{"name":"error_message","line":75,"containerName":"main::","kind":12},{"kind":13,"containerName":null,"line":77,"name":"$db"},{"kind":12,"line":77,"name":"close","containerName":"main::"}]}