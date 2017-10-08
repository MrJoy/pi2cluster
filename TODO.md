# TODOs

* Ansible for post-boot setup, rather than janky shell-scripts on FAT32 volume of SD cards.
    * SSH key
    * Default password
    * Cluster state can come up wrong, need to coordinate this better.
        * If `consul` is failing to come up on one or more nodes, turn off ALL nodes EXCEPT one, let it come up, then proceed with next node...
        * Need to investigate if this is a known issue in Consul, ClusterLab, etc.
* Workloads, for now:
    ```bash
    # Docker UI, running on pi2-n01:
    docker run --name=docker_ui -d -p 9000:9000 mrjoy/rpi-ui-for-docker:v0.11.0-beta -e http://$(ip addr list | grep eth0 | grep inet | awk '{ print $2 }' | cut -d/ -f1):2378
    # (Or: hypriot/rpi-dockerui, but that's a bit behind last I checked...)

    # This works on Hypriot 1.0.0, except for some wonkiness around `pi2-nXX.local` getting resolved to an IPv6 address and traffic sometimes (apparently) getting routed to /dev/null.  Use the IPv4 address of the node to hit the UI.  Also, this doesn't show the whole Swarm, as the Docker-API-compatible-whole-cluster-API is apparently a feature of the standalone Swarm product only.
    # Not sure the endpoint-mode flag is needed here...
    docker service create --endpoint-mode=vip --restart-condition=on-failure --mode=global --mount=type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock --name=docker_ui --publish=9000:9000 mrjoy/rpi-ui-for-docker:v0.11.0-beta


    # MySQL, running on pi2-n02:
    docker run --name mysql_shared -v /mnt/external/mysql_shared:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=ddkjhkjh23he2hd289hd -d hypriot/rpi-mysql:5.5

    # Hypriot 1.0.0, service is bound to the node and data is stored on external drive so you need to do this by hand from the relevant node:
    sudo mkdir /mnt/external/mysql_shared
    docker service create --constraint=node.id==$(docker node ls | fgrep '*' | cut -d' ' -f1) --restart-condition=on-failure --mount=type=bind,source=/mnt/external/mysql_shared,target=/var/lib/mysql --name=mysql_shared --publish=3306:3306 --env=MYSQL_ROOT_PASSWORD=ddkjhkjh23he2hd289hd hypriot/rpi-mysql:5.5
    # We might want to set the user to `pirate`, or something, as the user ID in use by default seems to be 999.


    # MySQL CLI:
    docker run --rm -it --link mysql_shared:mysql hypriot/rpi-mysql:5.5 sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"ddkjhkjh23he2hd289hd" test'
    # Or from your laptop:
    mysql -h <node>.domain -u root -pddkjhkjh23he2hd289hd
    ```
* Script power management:
    ```bash
    curl --cookie AIROS_SESSIONID=<cookie> http://utopiaplanitia.local/sensors | jsonpp
    ```
* Containers to look into:
    * https://hub.docker.com/r/hypriot/rpi-ruby/
    * https://hub.docker.com/r/hypriot/rpi-gogs-raspbian/
    * https://hub.docker.com/r/hypriot/rpi-gogs-alpine/
* Benchmarking:
    ```bash
    apt-get update && apt-get install -y sysbench linux-cpupower

    cpupower frequency-set -f 900000 # CPU speed isn't auto-scaling properly!
    sysbench --num-threads=8 --test=cpu --cpu-max-prime=10000000000 run
    while [ 1 ]; do clear; uptime; sudo cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq; sleep 2; done
    while true; do vcgencmd measure_temp && vcgencmd measure_clock arm; sleep 1; done
    ```
* Other Fun Things:
    * https://www.cockroachlabs.com/blog/run-cockroachdb-on-a-raspberry-pi/
