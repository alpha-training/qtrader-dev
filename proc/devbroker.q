Order:`sym xkey .schema.t.Order

simfills:{
  if[not count o:select from Order where filled<size;:()];
  
 }

.cron.add[`simfills;0Np;00:00:01]