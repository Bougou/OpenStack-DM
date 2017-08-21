listen <srv_name>
    bind <srv_frontend_binds_#1>:<srv_port>
    bind <srv_frontend_binds_#2>:<srv_port>
    mode <srv_mode>
    balance <srv_balance>
    <srv_options_#1>
    <srv_options_#2>
    server <srv_backend_role_#node1_hostname> <srv_backend_ip_fact_name->ip>:<srv_port>
    server <srv_backend_role_#node2_hostname> <srv_backend_ip_fact_name->ip>:<srv_port>