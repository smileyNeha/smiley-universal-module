#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}
SCRIPT_DIR="$MODDIR/script"

if [ "$(cat $SCRIPT_DIR/pathinfo.sh | grep "$PATH")" == "" ]; then
    echo "" >> $SCRIPT_DIR/pathinfo.sh
    echo "# prefer to use busybox provided by magisk" >> $SCRIPT_DIR/pathinfo.sh
    echo "PATH=$PATH" >> $SCRIPT_DIR/pathinfo.sh
fi

# not relying on executable permissions
sh $SCRIPT_DIR/mem_opt_main.sh


# Kernel based tweaks that reduces the amount of wasted CPU cycles to maximum and gives back a huge amount of needed performance to both the system and the user;
echo "0" > /proc/sys/kernel/perf_cpu_time_max_percent
echo "0" > /proc/sys/kernel/nmi_watchdog
echo "5" > /proc/sys/kernel/sched_walt_init_task_load_pct
echo "0" > /proc/sys/kernel/sched_tunable_scaling

#eas tweak
chown system system /sys/devices/system/cpu/cpufreq/schedutil/*
chmod 0644 /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
chmod 0644 /sys/devices/system/cpu/cpufreq/policy6/scaling_governor
restorecon -R /sys/devices/system/cpu
chmod 0644 /sys/devices/system/cpu/cpufreq/schedtutil/*
echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy6/scaling_governor
echo "2000000" > /sys/devices/system/cpu/cpufreq/schedutil/hispeed_freq
echo "90" > /sys/devices/system/cpu/cpufreq/schedutil/target_loads 
echo "20000" > /sys/devices/system/cpu/cpufreq/schedutil/above_hispeed_delay
echo "99" > /sys/devices/system/cpu/cpufreq/schedutil/go_hispeed_load 
echo "80000" > /sys/devices/system/cpu/cpufreq/schedutil/min_sample_time 
echo "20000" > /sys/devices/system/cpu/cpufreq/schedutil/timer_rate 
echo "80000" > /sys/devices/system/cpu/cpufreq/schedutil/timer_slack 
echo "80000" > /sys/devices/system/cpu/cpufreq/schedutil/boostpulse_duration 

# cpu boost Tweaks
echo '0' > /sys/devices/system/cpu/isolated
echo '0' > /sys/devices/system/cpu/offline
echo '0' > /sys/devices/system/cpu/uevent
echo '1' > /sys/devices/system/cpu/cpufreq/policy0/schedutil/iowait_boost_enable
echo '1' > /sys/devices/system/cpu/cpufreq/policy6/schedutil/iowait_boost_enable
echo '1' > /sys/devices/system/cpu/sched/cpu_prefer

# scheduler TWEAK
chmod 0644 /sys/block/sda/queue/*
chmod 0644 /sys/block/sdb/queue/*
chmod 0644 /sys/block/sdc/queue/*
echo "deadline" > /sys/block/mmcblk0/queue/scheduler
echo "deadline" > /sys/block/sda/queue/scheduler
echo "deadline" > /sys/block/sdb/queue/scheduler
echo "deadline" > /sys/block/sdc/queue/scheduler
chmod 0444 /dev/stune/foreground/*
chmod 0444 /proc/cpufreq/*
echo '35' > /dev/stune/foreground/schedtune.boost
echo '1' > /proc/cpufreq/cpufreq_cci_mode

# Bring CPUs online
    write /sys/devices/system/cpu/cpu0/online 1
    write /sys/devices/system/cpu/cpu1/online 1
    write /sys/devices/system/cpu/cpu2/online 1
    write /sys/devices/system/cpu/cpu3/online 1
    write /sys/devices/system/cpu/cpu4/online 1
    write /sys/devices/system/cpu/cpu5/online 1
    write /sys/devices/system/cpu/cpu6/online 1
    write /sys/devices/system/cpu/cpu7/online 1
    write /sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us 20000
    write /sys/devices/system/cpu/cpu0/cpufreq/schedutil/iowait_boost_enable 1
    write /sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us 500

# Set up schedtune
    write /dev/stune/foreground/schedtune.prefer_idle 1
    write /dev/stune/top-app/schedtune.boost 10
    write /dev/stune/top-app/schedtune.prefer_idle 1

if [[ -d "/sys/devices/system/cpu/cpufreq/policy0/schedutil" ]]
then
 write "/sys/devices/system/cpu/cpufreq/policy4/schedutil/hispeed_load" "100"
 write "/sys/devices/system/cpu/cpufreq/policy4/schedutil/iowait_boost_enable" "0"
 write "/sys/devices/system/cpu/cpufreq/policy4/schedutil/down_rate_limit_us" "0"
 write "/sys/devices/system/cpu/cpufreq/policy4/schedutil/up_rate_limit_us" "0"
 write "/sys/devices/system/cpu/cpufreq/policy4/schedutil/hispeed_freq" cat /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
fi;

# [LITLE CORES]
#
if [[ -d "/sys/devices/system/cpu/cpufreq/policy0/schedutil" ]]
then
 write "/sys/devices/system/cpu/cpufreq/policy0/schedutil/hispeed_load" "100"
 write "/sys/devices/system/cpu/cpufreq/policy0/schedutil/iowait_boost_enable" "0"
 write "/sys/devices/system/cpu/cpufreq/policy0/schedutil/down_rate_limit_us" "0"
 write "/sys/devices/system/cpu/cpufreq/policy0/schedutil/up_rate_limit_us" "0"
 write "/sys/devices/system/cpu/cpufreq/policy0/schedutil/hispeed_freq" cat /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
fi;

# [GPU TWEAKS]
#
if [[ -d "/sys/devices/soc/1c00000.qcom,kgsl-3d0/kgsl/kgsl-3d0" ]]
then
 write "/sys/devices/soc/1c00000.qcom,kgsl-3d0/kgsl/kgsl-3d0/default_pwrlevel" "0"
 write "/sys/devices/soc/1c00000.qcom,kgsl-3d0/kgsl/kgsl-3d0/thermal_pwrlevel" "0"
 write "/sys/devices/soc/1c00000.qcom,kgsl-3d0/kgsl/kgsl-3d0/force_clk_on" "1"
 write "/sys/devices/soc/1c00000.qcom,kgsl-3d0/kgsl/kgsl-3d0/force_rail_on" "1"
fi;

# [Battery Efficient]
#
write "/sys/module/workqueue/parameters/power_efficient" "N"

# [Adreno Idler]
#
write "/sys/module/adreno_idler/paremeters/adreno_idler_active" "Y"

# [Force Fast CHARGE]
#
write "/sys/kernel/fast_charge/force_fast_charge" "1"

# [Cpu Input BOOST]
#
write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "140"
write "/sys/module/cpu_input_boost/parameters/dynamic_stune_boost_duration" "1200"
write "/sys/module/cpu_input_boost/parameters/dynamic_stune_boost" "1"

# [KGSL-3D0 WITHOUT THROTTLING] 
#
write "/sys/class/kgsl/kgsl-3d0/throttling" "0"

# [SCHEDULER TWEAK]
#
write "/sys/block/sda/queue/scheduler "cfq"
write "/sys/block/sdb/queue/scheduler "cfq"
write "/sys/block/sdc/queue/scheduler "cfq"
write "/sys/block/sdd/queue/scheduler "cfq"
write "/sys/block/sde/queue/scheduler "cfq"
write "/sys/block/sdf/queue/scheduler "cfq"

# [FS]
#
write "/proc/sys/fs/dir-notify-enable" "0"
write "/proc/sys/fs/lease-break-time" "15"
write "/proc/sys/fs/aio-max-nr" "131072"

# [POWER SUSPEND]
#
write "/sys/kernel/power_suspend" "3"

# [CPU-SETS]
#
 write "/dev/cpuset/camera-daemon/cpus" "0-7"
 write "/dev/cpuset/audio-app/cpus" "0-7"
 write "/dev/cpuset/top-app/cpus" "0-7"
 write "/dev/cpuset/foreground/cpus" "7-7"
 write "/dev/cpuset/background/cpus" "0-3"
 write "/dev/cpuset/system-background/cpus" "0-3"
 write "/dev/cpuset/restricted/cpus" "0-7"
 write "/dev/cpuset/cpus" "0-7"

# [Tweaks For MEDIATEK] 
#
if [[ -e "/sys/class/devfreq/10012000.dvfsrc_top/ ]]
 write "/sys/class/devfreq/10012000.dvfsrc_top/governor" "performance"
 write "/sys/class/devfreq/10012000.dvfsrc_top/min_freq" "400"
 write "/sys/class/devfreq/10012000.dvfsrc_top/max_freq" "$(cat $gpu/devfreq/max_freq)"
fi;

# [Snapdragon TWEAKS]
#
 write "/sys/class/devfreq/0.qcom,cpubw/max_freq" " "$(cat $cpu/devfreq/cpuinfo_max_freq)"
 write "/sys/class/devfreq/0.qcom,cpubw/min_freq" "400"
 write "/sys/class/devfreq/0.qcom,cpubw/governor" "performance"
 write "/sys/class/devfreq/0.qcom,cpubw/cur_freq" "4066"

#Vm
stop perfd
rm -rf /data/system/perfd/default_values
if [ -d /proc/sys ]; then
     echo "1" > /proc/sys/vm/drop_caches
     echo "0" > /proc/sys/vm/compact_unevictable_allowed
     echo "70" > /proc/sys/vm/dirty_background_ratio
     echo "1000" > /proc/sys/vm/dirty_expire_centisecs
     echo "0" > /proc/sys/vm/page-cluster
     echo "1" > /proc/sys/vm/reap_mem_on_sigkill
     echo "90" > /proc/sys/vm/dirty_ratio
     echo "0" > /proc/sys/vm/laptop_mode
     echo "0" > /proc/sys/vm/block_dump
     echo "1" > /proc/sys/vm/compact_memory
     echo "0" > /proc/sys/vm/dirty_writeback_centisecs
     echo "750" > /proc/sys/vm/extfrag_threshold
     echo "0" > /proc/sys/vm/oom_dump_tasks
     echo "0" > /proc/sys/vm/oom_kill_allocating_task
     echo "10" > /proc/sys/vm/stat_interval
     echo "0" > /proc/sys/vm/panic_on_oom
     echo "100" > /proc/sys/vm/swappiness
     echo "400" > /proc/sys/vm/vfs_cache_pressure
     echo "100" > /proc/sys/vm/watermark_scale_factor
     echo "80" > /proc/sys/vm/overcommit_ratio
     echo "24300" > /proc/sys/vm/extra_free_kbytes
     echo "128" > /proc/sys/kernel/random/read_wakeup_threshold
     echo "256" > /proc/sys/kernel/random/write_wakeup_threshold     
     echo "4096" > /proc/sys/vm/min_free_kbytes
fi
echo "512" > /sys/block/mmcblk0/queue/read_ahead_kb
echo "0" > /sys/block/mmcblk0/queue/iostats
echo "1" > /sys/block/mmcblk0/queue/add_random
echo "512" > /sys/block/mmcblk1/queue/read_ahead_kb
echo "0" > /sys/block/mmcblk1/queue/iostats
echo "1" > /sys/block/mmcblk1/queue/add_random
if [ -d /sys/module/lowmemorykiller/parameters ]; then
     chmod 0644 sys/module/lowmemorykiller/parameters/*
     echo "1" > /sys/module/lowmemorykiller/parameters/oom_reaper
     echo "0" > /sys/module/lowmemorykiller/parameters/enable_lmk
     echo "0,258,417,676,824,1000" > /sys/module/lowmemorykiller/parameters/adj
     echo "0" > /sys/module/lowmemorykiller/parameters/enable_simple_lmk
     echo "21816,29088,36360,43632,50904,65448" > /sys/module/lowmemorykiller/parameters/minfree
     echo "0" > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
     echo "0" > /sys/module/lowmemorykiller/parameters/lmk_fast_run
fi
echo "0" > /d/tracing/tracing_on;
echo "0" > /sys/module/rmnet_data/parameters/rmnet_data_log_level;

# Network tweaks for slightly reduced battery consumption when being "actively" connected to a network connection;
echo "1" > /proc/sys/net/ipv4/route/flush
echo "1" > /proc/sys/net/ipv4/tcp_mtu_probing;
echo "0" > /proc/sys/net/ipv4/conf/all/rp_filter
echo "0" > /proc/sys/net/ipv4/conf/default/rp_filter
echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_all
echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
echo "1" > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
echo "1" > /proc/sys/net/ipv4/conf/all/log_martians
echo "1" > /proc/sys/kernel/kptr_restrict 
echo "6" > /proc/sys/net/ipv4/tcp_retries2
echo "1" > /proc/sys/net/ipv4/tcp_low_latency
echo "0" > /proc/sys/net/ipv4/tcp_slow_start_after_idle
echo "0" > /proc/sys/net/ipv4/conf/default/secure_redirects
echo "0" > /proc/sys/net/ipv4/conf/default/accept_redirects
echo "0" > /proc/sys/net/ipv4/conf/default/accept_source_route
echo "0" > /proc/sys/net/ipv4/conf/all/secure_redirects
echo "0" > /proc/sys/net/ipv4/conf/all/accept_redirects
echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route
echo "0" > /proc/sys/net/ipv4/ip_forward
echo "0" > /proc/sys/net/ipv4/ip_dynaddr
echo "0" > /proc/sys/net/ipv4/ip_no_pmtu_disc
echo "0" > /proc/sys/net/ipv4/tcp_ecn
echo "1" > /proc/sys/net/ipv4/tcp_timestamps
echo "1" > /proc/sys/net/ipv4/tcp_tw_reuse
echo "1" > /proc/sys/net/ipv4/tcp_fack
echo "1" > /proc/sys/net/ipv4/tcp_sack
echo "1" > /proc/sys/net/ipv4/tcp_dsack
echo "1" > /proc/sys/net/ipv4/tcp_rfc1337
echo "1" > /proc/sys/net/ipv4/tcp_tw_recycle
echo "1" > /proc/sys/net/ipv4/tcp_window_scaling
echo "1" > /proc/sys/net/ipv4/tcp_moderate_rcvbuf
echo "1" > /proc/sys/net/ipv4/tcp_no_metrics_save
echo "2" > /proc/sys/net/ipv4/tcp_synack_retries
echo "2" > /proc/sys/net/ipv4/tcp_syn_retries
echo "5" > /proc/sys/net/ipv4/tcp_keepalive_probes
echo "30" > /proc/sys/net/ipv4/tcp_keepalive_intvl
echo "10" > /proc/sys/net/ipv4/tcp_fin_timeout
echo "1800" > /proc/sys/net/ipv4/tcp_keepalive_time
echo "2097152" > /proc/sys/net/core/rmem_max
echo "2097152" > /proc/sys/net/core/wmem_max
echo "1048576" > /proc/sys/net/core/rmem_default
echo "1048576" > /proc/sys/net/core/wmem_default
echo "300000" > /proc/sys/net/core/netdev_max_backlog
echo "0" > /proc/sys/net/core/netdev_tstamp_prequeue
echo "0" > /proc/sys/net/ipv4/cipso_cache_bucket_size
echo "0" > /proc/sys/net/ipv4/cipso_cache_enable
echo "0" > /proc/sys/net/ipv4/cipso_rbm_strictvalid
echo "0" > /proc/sys/net/ipv4/igmp_link_local_mcast_reports
echo "30" > /proc/sys/net/ipv4/ipfrag_time
echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control
echo "0" > /proc/sys/net/ipv4/tcp_fwmark_accept
echo "600" > /proc/sys/net/ipv4/tcp_probe_interval
echo "60" > /proc/sys/net/ipv6/ip6frag_time

# Google Service Reduce Drain Tweaks Set Config
sleep '0.001'
su -c 'pm enable com.google.android.gms'
sleep '0.001'
su -c 'pm enable com.google.android.gsf'
sleep '0.001'
su -c 'pm enable com.google.android.gms/.update.SystemUpdateActivity'
sleep '0.001'
su -c 'pm enable com.google.android.gms/.update.SystemUpdateService'
sleep '0.001'
su -c 'pm enable com.google.android.gms/.update.SystemUpdateServiceActiveReceiver'
sleep '0.001'
su -c 'pm enable com.google.android.gms/.update.SystemUpdateServiceReceiver'
sleep '0.001'
su -c 'pm enable com.google.android.gms/.update.SystemUpdateServiceSecretCodeReceiver'
sleep '0.001'
su -c 'pm enable com.google.android.gsf/.update.SystemUpdateActivity'
sleep '0.001'
su -c 'pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity'
sleep '0.001'
su -c 'pm enable com.google.android.gsf/.update.SystemUpdateService'
sleep '0.001'
su -c 'pm enable com.google.android.gsf/.update.SystemUpdateServiceReceiver'
sleep '0.001'
su -c 'pm enable com.google.android.gsf/.update.SystemUpdateServiceSecretCodeReceiver'

# Set CF DNS servers address
setprop net.rmnet0.dns1 1.1.1.1
setprop net.rmnet0.dns2 1.0.0.1
setprop net.rmnet1.dns1 1.1.1.1
setprop net.rmnet1.dns2 1.0.0.1
setprop net.dns1 1.1.1.1
setprop net.dns2 1.0.0.1
setprop net.wcdma.dns1 1.1.1.1
setprop net.wcdma.dns2 1.0.0.1
setprop net.hspa.dns1 1.1.1.1
setprop net.hspa.dns2 1.0.0.1
setprop net.lte.dns1 1.1.1.1
setprop net.lte.dns2 1.0.0.1
setprop net.ltea.dns1 1.1.1.1
setprop net.ltea.dns2 1.0.0.1
setprop net.ppp0.dns1 1.1.1.1
setprop net.ppp0.dns2 1.0.0.1
setprop net.pdpbr1.dns1 1.1.1.1
setprop net.pdpbr1.dns2 1.0.0.1
setprop net.wlan0.dns1 1.1.1.1
setprop net.wlan0.dns2 1.0.0.1
setprop 2606:4700:4700::1111
setprop 2606:4700:4700::1001

# Edit the resolv conf file if it exist

if [ -a /system/etc/resolv.conf ]; then
	mkdir -p $MODDIR/system/etc/
	printf "nameserver 1.1.1.1\nameserver 1.0.0.1" >> $MODDIR/system/etc/resolv.conf
	chmod 644 $MODDIR/system/etc/resolv.conf
fi

stop logd
stop thermald
echo always_on > /sys/devices/platform/13040000.mali/power_policy
echo alweys_on > /sys/devices/platform/13040000.mali/gpuinfo
echo <supported> >/sys/devices/system/cpu/cpufreq/policy4/scaling_setspeed
echo <supported> >/sys/devices/system/cpu/cpufreq/policy6/scaling_setspeed
echo '1' > /sys/devices/system/cpu/perf/enable
echo boost > /sys/devices/system/cpu/sched/sched_boost
echo '1' > /sys/devices/system/cpu/eas/enable

# Dt2W Fixed Tweaks Set Config
If [[ -d "/sys/touchpanel/double_tap" ]]
then
  write "/sys/touchpanel/double_tap" 1
fi

done