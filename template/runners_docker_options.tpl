%{ if allowed_images != null } allowed_images = [${allowed_images}] %{endif}
%{ if allowed_pull_policies != null } allowed_pull_policies = [${allowed_pull_policies}] %{endif}
%{ if allowed_services != null } allowed_services = [${allowed_services}] %{endif}
%{ if cache_dir != null } cache_dir = "${cache_dir}" %{endif}
%{ if cap_add != null } cap_add = [${cap_add}] %{endif}
%{ if cap_drop != null } cap_drop = [${cap_drop}] %{endif}
%{ if container_labels != null } container_labels = [${container_labels}] %{endif}
%{ if cpuset_cpus != null } cpuset_cpus = "${cpuset_cpus}" %{endif}
%{ if cpu_shares != null } cpu_shares = ${cpu_shares} %{endif}
%{ if cpus != null } cpus = "${cpus}" %{endif}
%{ if devices != null } devices = [${devices}] %{endif}
%{ if device_cgroup_rules != null } device_cgroup_rules = [${device_cgroup_rules}] %{endif}
%{ if disable_cache != null} disable_cache = ${disable_cache} %{endif}
%{ if disable_entrypoint_overwrite != null } disable_entrypoint_overwrite = ${disable_entrypoint_overwrite} %{endif}
%{ if dns != null } dns = [${dns}] %{endif}
%{ if dns_search != null } dns_search = [${dns_search}] %{endif}
%{ if extra_hosts != null } extra_hosts = [${extra_hosts}] %{endif}
%{ if gpus != null } gpus = "${gpus}" %{endif}
%{ if helper_image != null } helper_image = "${helper_image}" %{endif}
%{ if helper_image_flavor != null } helper_image_flavor = "${helper_image_flavor}" %{endif}
%{ if host != null } host = "${host}" %{endif}
%{ if hostname != null } hostname = "${hostname}" %{endif}
%{ if image != null} iamge = "${image}" %{endif}
%{ if links != null } links = [${links}] %{endif}
%{ if memory != null } memory = "${memory}" %{endif}
%{ if memory_reservation != null } memory_reservation = "${memory_reservation}" %{endif}
%{ if memory_swap != null } memory_swap = "${memory_swap}" %{endif}
%{ if network_mode != null } network_mode = "${network_mode}" %{endif}
%{ if oom_kill_disable != null } oom_kill_disable = ${oom_kill_disable} %{endif}
%{ if oom_score_adjust != null } oom_score_adjust = ${oom_score_adjust} %{endif}
%{ if privileged != null} privileged = ${privileged} %{endif}
%{ if pull_policy != null} pull_policy = "${pull_policy}" %{endif}
%{ if runtime != null } runtime = "${runtime}" %{endif}
%{ if security_opt != null } security_opt = [${security_opt}] %{endif}
%{ if shm_size != null} shm_size = ${shm_size} %{endif}
%{ if sysctls != null } sysctls = [${sysctls}] %{endif}
%{ if tls_cert_path != null } tls_cert_path = "${tls_cert_path}" %{endif}
%{ if tls_verify != null} tls_verify = ${tls_verify} %{endif}
%{ if userns_mode != null } userns_mode = "${userns_mode}" %{endif}
%{ if volumes != null} volumes = [${volumes}] %{endif}
%{ if volumes_from != null } volumes_from = [${volumes_from}] %{endif}
%{ if volume_driver != null } volume_driver = "${volume_driver}" %{endif}
%{ if wait_for_services_timeout != null } wait_for_services_timeout = ${wait_for_services_timeout} %{endif}