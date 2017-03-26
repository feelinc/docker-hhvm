# docker-hhvm
Dockerized HHVM. Installed :  rsyslog, cron, imagemagick, supervisor, and MongoDB extension installed.

## Build

    $ chmod +x ./build.sh
    $ ./build.sh

## Prepare
- A folder where all container configuration data stored, in example "**hhvm-container**".
- "**hhvm-container/cron.d**" folder to provide cron configuration.
- "**hhvm-container/supervisor/conf.d**" folder to provide supervisor configuration.
- "**hhvm-container/conf.d**" folder to provide additional configuration, in example the **config.hdf**, **php.ini**, and **server.ini**.
- "**hhvm-container/www**" folder to provide site files. You can put multiple sites here, just create a subfolder for each site. Make sure your webserver site root configuration having correct value based on this path "**/var/www/...**".

Create "**hhvm-container/supervisor/conf.d/hhvm.conf**" file and put below content.

    [program:hhvm]
    command=hhvm --mode=server --user=www-data --port=9001 --config=/etc/hhvm/conf.d/server.ini --config=/etc/hhvm/conf.d/php.ini --config=/etc/hhvm/conf.d/config.hdf
    autostart=true
    autorestart=false
    redirect_stderr=true
    user=www-data
    
Create "**hhvm-container/conf.d/config.hdf**" file and put below content.

    ResourceLimit {
        CoreFileSize = 0          # in bytes
        MaxSocket = 10000         # must be not 0, otherwise HHVM will not start
        SocketDefaultTimeout = 5  # in seconds
        MaxRSS = 0
        MaxRSSPollingCycle = 0    # in seconds, how often to check max memory
        DropCacheCycle = 0        # in seconds, how often to drop disk cache
    }
    Log {
        Level = Info
        AlwaysLogUnhandledExceptions = true
        RuntimeErrorReportingLevel = 8191
       UseLogFile = true
       UseSyslog = false
       File = /var/log/hhvm/error.log
       Access {
           * {
               File = /var/log/hhvm/access.log
               Format = %h %l %u % t \"%r\" %>s %b
            }
       }
    }
    MySQL {
        ReadOnly = false
       ConnectTimeout = 1000      # in ms
        ReadTimeout = 1000         # in ms
        SlowQueryThreshold = 1000  # in ms, log slow queries as errors
       KillOnTimeout = false
    }
    Mail {
        SendmailPath = /usr/sbin/sendmail -t -i
       ForceExtraParameters =
    }

Create "**hhvm-container/conf.d/php.ini**" file and put below content.

    ; php options
    session.name = mysessionname
    session.save_handler = files
    session.save_path = /var/lib/hhvm/sessions
    session.gc_maxlifetime = 1440
    post_max_size = 20M
    upload_max_filesize = 100M
    set_time_limit = 1800
    log_errors = On
    error_log = /var/log/hhvm/error.log

    ; hhvm specific
    hhvm.log.level = Warning
    hhvm.log.always_log_unhandled_exceptions = true
    hhvm.log.runtime_error_reporting_level = 8191
    hhvm.mysql.typed_results = false

    hhvm.keep_perf_pid_map = 0
    hhvm.perf_pid_map = 0
    hhvm.perf_data_map = 0

    xdebug.enable=0
    ;xdebug.max_nesting_level=65536
    xdebug.profiler_enable=1
    xdebug.profiler_append=1
    xdebug.profiler_enable_trigger=1
    xdebug.profiler_output_dir=/var/log/hhvm
    xdebug.trace_output_dir=/var/log/hhvm
    xdebug.remote_enable=1
    xdebug.remote_host="0.0.0.0"
    xdebug.remote_port=8787

    hhvm.dynamic_extension_path=/usr/lib/x86_64-linux-gnu/hhvm/extensions/20150212
    hhvm.dynamic_extensions[mongodb]=mongodb.so
    
Create "**hhvm-container/conf.d/server.ini**" file and put below content.

    ; hhvm specific
    hhvm.pid_file = "/var/log/hhvm/pid"
    hhvm.server.port = 9001
    hhvm.server.type = fastcgi
    hhvm.server.default_document = index.php
    hhvm.server.graceful_shutdown_wait = 5
    hhvm.server.enable_keep_alive = true
    hhvm.server.apc.enable_apc = true
    hhvm.server.request_timeout_seconds = 300
    hhvm.server.connection_timeout_seconds = 300
    hhvm.server.user = www-data
    
    hhvm.log.level = Notice
    hhvm.log.always_log_unhandled_exceptions = true
    hhvm.log.runtime_error_reporting_level = 8191
    hhvm.log.use_log_file = true
    hhvm.log.use_syslog = false
    hhvm.log.file = /var/log/hhvm/error.log
    hhvm.log.header = true
    hhvm.log.native_stack_trace = true

    hhvm.repo.central.path = /var/run/hhvm/hhvm.hhbc
    
    hhvm.jit = true
    
    [date]
    date.timezone = Asia/Jakarta
    default_socket_timeout = 300
    
    expose_php = Off
    post_max_size = 10M
    upload_max_filesize = 2M
    
    log_errors = On
    error_log = /var/log/hhvm/error.log

## Run

    docker run --interactive --tty --name=hhvm --memory=1024m \
        --hostname=hhvm \
        --volume=/path/to/hhvm-container/cron.d:/etc/cron.d \
        --volume=/path/to/hhvm-container/supervisor/conf.d:/etc/supervisor/conf.d \
        --volume=/path/to/hhvm-container/logs/cron:/var/log/cron \
        --volume=/path/to/hhvm-container/logs/hhvm:/var/log/hhvm \
        --volume=/path/to/hhvm-container/logs/supervisor:/var/log/supervisor \
        --volume=/path/to/hhvm-container/conf.d:/etc/hhvm/conf.d \
        --volume=/path/to/hhvm-container/www:/var/www \
        --publish="9001:9001" \
        --publish="8787:8787" \
        --detach \
        hhvm:3.18
        
## Environment Defaults
    MONGODB_VERSION=1.2.3
    HHVM_VERSION=3.18