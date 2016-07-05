# TODOs

* Ansible for post-boot setup, rather than janky shell-scripts on FAT32 volume of SD cards.
    * SSH key
    * Default password
    * Cluster state can come up wrong, need to coordinate this better.
        * If `consul` is failing to come up on one or more nodes, turn off ALL nodes EXCEPT one, let it come up, then proceed with next node...
        * Need to investigate if this is a known issue in Consul, ClusterLab, etc.
* Workflow, for now:
    ```bash
    docker-swarm list consul://pi2-n01.local:8500/
    docker -H tcp://pi2-n01:2378/ ps
    ```
* Workloads, for now:
    ```bash
    # Or: hypriot/rpi-dockerui, but that's a bit behind last I checked:
    docker run --name=docker_ui -d -p 9000:9000 mrjoy/rpi-ui-for-docker:v0.11.0-beta -e http://$(ip addr list | grep eth0 | grep inet | grep eth0.200 | awk '{ print $2 }' | cut -d/ -f1):2378
    ```
* Script power management:
    ```bash
    curl --cookie AIROS_SESSIONID=<cookie> http://utopiaplanitia.local/sensors | jsonpp
    ```
