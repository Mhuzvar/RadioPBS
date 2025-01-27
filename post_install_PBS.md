## Possible post-installation steps

Usefull commands to setup PBS queues

### add new queue with lower priority and more walltime
```
create queue longq
set queue longq priority=50
set queue longq resources_default.walltime=08:00:00
set queue longq resources_max.walltime=72:00:00
set queue longq resources_default.ncpus=10
set queue longq resources_max.ncpus=12
set queue longq resources_available.ncpus=12
set queue longq queue_type=execution
set queue longq enabled=True
set queue longq started=True
```

### limit the number of running jobs on the server/in the queue
```
set server max_running=1
set queue workq max_running=1
set queue longq max_running=1
```

### run as FIFO
```
set queue workq queue_type=execution
```

### limit the number of cpus cores available
```
set queue workq resources_default.ncpus=10
set queue workq resources_max.ncpus=12
set queue workq resources_available.ncpus=12
```

### limit walltime
```
set queue workq resources_default.walltime=01:00:00
set queue workq resources_max.walltime=01:00:00
```

### users access control
```
set queue workq acl_user_enable = True
```

### to add a user to the queue
```
set queue workq acl_users += username
```

### set priority
```
set queue workq priority=90
```
