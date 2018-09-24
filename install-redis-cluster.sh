#!/bin/bash

# Stop redis
service redis stop

# download end extract redis
[[ ! -d /store/apps ]] && mkdir /store/apps
cd /store/apps
curl http://download.redis.io/releases/redis-3.2.12.tar.gz | tar -zxvf -
ln -s redis-3.2.12 redis

# compile redis
cd /store/apps/redis
make
#make test

# install ruby and gems
yum install -y ruby22
alternatives --set ruby /usr/bin/ruby2.2
gem install redis

# update cluster script
cd /store/apps/redis/utils/create-cluster
sed -i 's/^PORT=.*/PORT=6378/g' create-cluster
sed -i 's/^TIMEOUT=.*/TIMEOUT=2000/g' create-cluster
sed -i 's/^NODES=.*/NODES=3/g' create-cluster
sed -i 's/^REPLICAS=.*/REPLICAS=0/g' create-cluster

# manually start and configure cluster
./create-cluster start
echo "yes" | ./create-cluster create
./create-cluster stop

# create /etc/init.d/redis-cluster
cat >/etc/init.d/redis-cluster << 'EOF'
#!/bin/sh
#
# redis-cluster         Start/Stop Redis Cluster Server
#
# chkconfig: 2345 90 60
# description: redis is an in memory key/value database
#
#
#
# Simple Redis init.d script conceived to work on Linux systems
# as it does use of the /proc filesystem.

REDISDIR=/store/apps/redis/utils/create-cluster
EXEC=$REDISDIR/create-cluster
PIDFILE=/var/run/redis.pid

case "$1" in
    start)
        if [ -f $PIDFILE ]
        then
                echo "$PIDFILE exists, process is already running or crashed"
        else
                echo "Starting Redis cluster server..."
		cd $REDISDIR
                $EXEC start
        fi
        ;;
    stop)
        if [ ! -f $PIDFILE ]
        then
                echo "$PIDFILE does not exist, process is not running"
        else
                PID=$(cat $PIDFILE)
                echo "Stopping ..."
		cd $REDISDIR
                $EXEC stop
                while [ -x /proc/${PID} ]
                do
                    echo "Waiting for Redis to shutdown ..."
                    sleep 1
                done
                echo "Redis stopped"
        fi
        ;;
    restart)
                        if [ ! -f $PIDFILE ]
        then
                echo "$PIDFILE does not exist, process is not running"
        else
                PID=$(cat $PIDFILE)
                echo "Stopping ..."
		cd $REDISDIR
                $EXEC stop
                while [ -x /proc/${PID} ]
                do
                    echo "Waiting for Redis to shutdown ..."
                    sleep 1
                done
                echo "Redis stopped"
        fi
        if [ -f $PIDFILE ]
        then
                echo "$PIDFILE exists, process is already running or crashed"
        else
                echo "Starting Redis server..."
                $EXEC start
        fi

        ;;

    *)
        echo "Please use start or stop as first argument"
        ;;
esac

EOF

chmod +x /etc/init.d/redis-cluster

chkconfig --add redis-cluster
chkconfig redis off
service redis-cluster start
