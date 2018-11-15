global_defs {
   router_id LVS_k8s
}

vrrp_script CheckK8sMaster {
    script "/etc/keepalived/keepalived-k8s.sh"
    interval 3
    timeout 2
    fall 2
    rise 2
    weight -30
}

vrrp_instance VI_1 {
    state backup
    interface #interface
    virtual_router_id #ID 
    priority #priority
    advert_int 1
    mcast_src_ip #NodeIP
    authentication {
        auth_type PASS
        auth_pass sqP05dQgMSlzrxHj
    }
    unicast_peer {
        ##CP0_IP
        ##CP1_IP
        ##CP2_IP

        
    }
    virtual_ipaddress {
        LOAD_BALANCER_DNS/24
    }
    track_script {
        CheckK8sMaster
    }

}
