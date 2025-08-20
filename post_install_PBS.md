## PBS post-installation steps

How to setup PBS queues

### GPU setup

```bash
qmgr -c "create resource ngpus type=long flag=nh"

#adjust /var/spool/pbs/server_priv/hooks/pbs_cgroups.CF
nano /var/spool/pbs/server_priv/hooks/pbs_cgroups.CF

# add device and enable devices and cpuset
["nvidiactl", "rwm"] # should be added after "c *:* rwm",

# import the hook
qmgr -c "import hook pbs_cgroups application/x-config default /var/spool/pbs/server_priv/hooks/pbs_cgroups.CF"

# add ngpus to /var/spool/pbs/sched_priv/sched_config after ncpus, mem, etc.

qmgr -c "set node HOSTNAME resources_available.ngpus=1"

systemctl restart pbs
```

### workq - the default queue
```bash
qmgr -c "set queue workq priority=50"
qmgr -c "set queue workq resources_default.walltime=01:00:00"
qmgr -c "set queue workq resources_max.walltime=12:00:00"
qmgr -c "set queue workq resources_default.ncpus=1"
qmgr -c "set queue workq resources_max.ncpus=8"
qmgr -c "set queue workq queue_type=execution"
qmgr -c "set queue workq max_running=1"
qmgr -c "set queue workq resources_default.ngpus=1"
qmgr -c "set queue workq resources_max.ngpus=1"
qmgr -c "set queue workq resources_default.mem=1gb"
qmgr -c "set queue workq resources_max.mem=64gb"
```


### staffq - the staff queue
This queue has a higher priority, possibly longer jobs, and access only for specified users.
```bash
qmgr -c "create queue staffq"
qmgr -c "set queue staffq priority=80"
qmgr -c "set queue staffq resources_default.walltime=01:00:00"
qmgr -c "set queue staffq resources_max.walltime=24:00:00"
qmgr -c "set queue staffq resources_default.ncpus=1"
qmgr -c "set queue staffq resources_max.ncpus=8"
qmgr -c "set queue staffq queue_type=execution"
qmgr -c "set queue staffq max_running=1"
qmgr -c "set queue staffq resources_default.ngpus=1"
qmgr -c "set queue staffq resources_max.ngpus=1"
qmgr -c "set queue staffq resources_default.mem=1gb"
qmgr -c "set queue staffq resources_max.mem=64gb"
qmgr -c "set queue staffq acl_user_enable=True"
qmgr -c "set queue staffq acl_users+=username"
qmgr -c "set queue staffq enabled=True"
qmgr -c "set queue staffq started=True"
```


### cpuq - the CPU only queue
This queue has a higher priority, possibly longer jobs, but should be CPU only.
```bash
qmgr -c "create queue cpuq"
qmgr -c "set queue cpuq priority=80"
qmgr -c "set queue cpuq resources_default.walltime=01:00:00"
qmgr -c "set queue cpuq resources_max.walltime=48:00:00"
qmgr -c "set queue cpuq resources_default.ncpus=1"
qmgr -c "set queue cpuq resources_max.ncpus=8"
qmgr -c "set queue cpuq resources_default.ngpus=0"
qmgr -c "set queue cpuq resources_max.ngpus=0"
qmgr -c "set queue cpuq queue_type=execution"
qmgr -c "set queue cpuq resources_default.mem=1gb"
qmgr -c "set queue cpuq resources_max.mem=64gb"
qmgr -c "set queue cpuq enabled=True"
qmgr -c "set queue cpuq started=True"
```

### other usefull PBS commands
```bash
# enable history
qmgr -c "set server job_history_enable=true"
qmgr -c "set server job_history_duration=720:00:00"
qstat -fx

# check current resource usage (available and assigned)
pbsnodes -av

# check status of jobs in queues
qstat -Q
```

## cgroups tweaks

It is also possible to use cgroups to further limit user resources (in certain scenarios).

### limit ssh user resources
```bash
mkdir -p /etc/systemd/system/user-.slice.d
tee /etc/systemd/system/user-.slice.d/limits.conf > /dev/null <<'EOF'
[Slice]
CPUQuota=50%
MemoryMax=1G
EOF

sudo systemctl daemon-reexec or systemctl daemon-reload
```
The above limits each user that logs in via SSH to 1G of RAM and 50% of one CPU core. If the user wants more, he/she has to submit a PBS job.
