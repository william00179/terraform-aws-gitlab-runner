/*
 * Global variables
 */
variable "vpc_id" {
  description = "The target VPC for the agent and executors (e.g. docker-machine) instances."
  type        = string
}

variable "subnet_id" {
  description = "Subnet id used for the agent and executors. Must belong to the `vpc_id`."
  type        = string
}

variable "kms_key_id" {
  description = "KMS key id to encrypt the resources. Ensure CloudWatch and Agent/Executors have access to the provided KMS key."
  type        = string
  default     = ""
}

variable "enable_managed_kms_key" {
  description = "Let the module manage a KMS key. Be-aware of the costs of an custom key. Do not specify a `kms_key_id` when `enable_kms` is set to `true`."
  type        = bool
  default     = false
}

variable "kms_managed_alias_name" {
  description = "Alias added to the created KMS key."
  type        = string
  default     = ""
}

variable "kms_managed_deletion_rotation_window_in_days" {
  description = "Key deletion/rotation window for the created KMS key. Set to 0 for no rotation/deletion window."
  type        = number
  default     = 7
}

variable "iam_permissions_boundary" {
  description = "Name of permissions boundary policy to attach to AWS IAM roles"
  type        = string
  default     = ""
}

variable "environment" {
  description = "A name that identifies the environment, used as prefix and for tagging."
  type        = string
}

variable "tags" {
  description = "Map of tags that will be added to created resources. By default resources will be tagged with name and environment."
  type        = map(string)
  default     = {}
}

variable "suppressed_tags" {
  description = "List of tag keys which are removed from `tags`, `agent_tags`  and `executor_tags` and never added as default tag by the module."
  type        = list(string)
  default     = []
}

variable "security_group_prefix" {
  description = "Set the name prefix and overwrite the `Name` tag for all security groups."
  type        = string
  default     = ""
}

variable "iam_object_prefix" {
  description = "Set the name prefix of all AWS IAM resources."
  type        = string
  default     = ""
}

/*
 * Runner Manager: A type of runner that can create multiple runners for autoscaling. Specific to the type of executor used.
 */
variable "runner_manager" {
  description = <<-EOT
    gitlab_check_interval = Number of seconds between checking for available jobs.
    maximum_concurrent_jobs = The maximum number of jobs which can be processed by all executors at the same time.
    prometheus_listen_address = Defines an address (<host>:<port>) the Prometheus metrics HTTP server should listen on.
    sentry_dsn = Sentry DSN of the project for the Agent to use (uses legacy DSN format)
  EOT
  type = object({
    gitlab_check_interval = optional(number, 3)
    maximum_concurrent_jobs = optional(number, 10)
    prometheus_listen_address = optional(string, "")
    sentry_dsn = optional(string, "__SENTRY_DSN_REPLACED_BY_USER_DATA__")
  })
  default = {}
}

/*
 * Runner: The agent that runs the code on the host platform and displays in the UI.
 */
variable "runner_instance" {
  description = <<-EOT
    additional_tags = Map of tags that will be added to the Agent instance.
    ebs_optimized = Enable EBS optimization for the Agent instance.
    monitoring = Enable the detailed monitoring on the Agent instance.
    name = Name of the Runner instance.
    name_prefix = Set the name prefix and override the `Name` tag for the Agent instance.
    private_address_only = Restrict the Agent to the use of a private IP address. If this is set to `false` it will override the `runners_use_private_address` for the agent.
    root_device_config = The Agent's root block device configuration. Takes the following keys: `device_name`, `delete_on_termination`, `volume_type`, `volume_size`, `encrypted`, `iops`, `throughput`, `kms_key_id`
    spot_price = By setting a spot price bid price the runner agent will be created via a spot request. Be aware that spot instances can be stopped by AWS. Choose \"on-demand-price\" to pay up to the current on demand price for the instance type chosen.
    ssm_access = Allows to connect to the Agent via SSM.
    type = EC2 instance type used.
  EOT
  type = object({
    additional_tags = optional(map(string))
    ebs_optimized = optional(bool, true)
    monitoring = optional(bool, true)
    name = string
    name_prefix = optional(string)
    private_address_only = optional(bool, true)
    root_device_config = optional(map(string))
    spot_price = optional(string, null)
    ssm_access = optional(bool, false)
    type = optional(string, "t3.micro")
  })
  default = {
    name = "gitlab-runner"
  }
}

variable "runner_ami_filter" {
  description = "List of maps used to create the AMI filter for the Agent AMI. Must resolve to an Amazon Linux 1 or 2 image."
  type        = map(list(string))

  default = {
    name = ["amzn2-ami-hvm-2.*-x86_64-ebs"]
  }
}

variable "runner_ami_owners" {
  description = "The list of owners used to select the AMI of the Agent instance."
  type        = list(string)
  default     = ["amazon"]
}

variable "runner_collect_autoscaling_metrics" {
  description = "A list of metrics to collect. The allowed values are GroupDesiredCapacity, GroupInServiceCapacity, GroupPendingCapacity, GroupMinSize, GroupMaxSize, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupStandbyCapacity, GroupTerminatingCapacity, GroupTerminatingInstances, GroupTotalCapacity, GroupTotalInstances."
  type        = list(string)
  default     = null
}

variable "runner_ping_enable" {
  description = "Allow ICMP Ping to the Agent. Specify `agent_ping_allowed_from_security_groups` too!"
  type        = bool
  default     = false
}

variable "runner_ping_allow_from_security_groups" {
  description = "A list of security group ids that are allowed to access the gitlab runner agent"
  type        = list(string)
  default     = []
}

variable "runner_security_group_description" {
  description = "A description for the Agents security group"
  type        = string
  default     = "A security group containing gitlab-runner agent instances"
}

variable "runner_extra_security_group_ids" {
  description = "IDs of security groups to add to the Agent."
  type        = list(string)
  default     = []
}

variable "runner_extra_egress_rules" {
  description = "List of egress rules for the Agent."
  type = list(object({
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    from_port        = number
    protocol         = string
    security_groups  = list(string)
    self             = bool
    to_port          = number
    description      = string
  }))
  default = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      from_port        = 0
      protocol         = "-1"
      security_groups  = null
      self             = null
      to_port          = 0
      description      = null
    }
  ]
}

variable "runner_role" {
    description = <<-EOT
        additional_tags = Map of tags that will be added to the role created. Useful for tag based authorization.
        allow_iam_service_linked_role_creation = Boolean used to control attaching the policy to the Agent to create service linked roles.
        assume_role_policy_json = The assume role policy for the Agent.
        create_role_profile = Whether to create the IAM role/profile for the Agent. If you provide your own role, make sure that it has the required permissions.
        policy_arns = List of policy ARNs to be added to the instance profile of the Agent.
        role_profile_name = IAM role/profile name for the Agent. If unspecified then `$${var.iam_object_prefix}-instance` is used.
    EOT
    type = object({
      additional_tags = optional(map(string))
      allow_iam_service_linked_role_creation = optional(bool, true)
      assume_role_policy_json = optional(string, "")
      create_role_profile = optional(bool, true)
      policy_arns = optional(list(string), [])
      role_profile_name = optional(string)
    })
    default = {}
}

variable "runner_enable_eip" {
  description = "Assigns an EIP to the Agent."
  type        = bool
  default     = false
}

variable "runner_metadata_options" {
  description = "Enable the Gitlab runner agent instance metadata service. IMDSv2 is enabled by default."
  type = object({
    http_endpoint               = string
    http_tokens                 = string
    http_put_response_hop_limit = number
    instance_metadata_tags      = string
  })
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }
}

variable "runner_schedule_enable" {
  description = "Set to `true` to enable the auto scaling group schedule for the Agent."
  type        = bool
  default     = false
}

variable "runner_max_instance_lifetime_seconds" {
  description = "The maximum time an Agent should live before it is killed."
  default     = null
  type        = number
}

variable "runner_enable_asg_recreation" {
  description = "Enable automatic redeployment of the Agent ASG when the Launch Configs change."
  default     = true
  type        = bool
}

variable "runner_schedule_config" {
  description = "Map containing the configuration of the ASG scale-out and scale-in for the Agent. Will only be used if `agent_schedule_enable` is set to `true`. "
  type        = map(any)
  default = {
    # Configure optional scale_out scheduled action
    scale_out_recurrence = "0 8 * * 1-5"
    scale_out_count      = 1 # Default for min_size, desired_capacity and max_size
    scale_out_time_zone  = "Etc/UTC"
    # Override using: scale_out_min_size, scale_out_desired_capacity, scale_out_max_size

    # Configure optional scale_in scheduled action
    scale_in_recurrence = "0 18 * * 1-5"
    scale_in_count      = 0 # Default for min_size, desired_capacity and max_size
    scale_in_time_zone  = "Etc/UTC"
    # Override using: scale_out_min_size, scale_out_desired_capacity, scale_out_max_size
  }
}

variable "runner_install" {
  description = <<-EOT
    amazon_ecr_credentials_helper = Install amazon-ecr-credential-helper inside `userdata_pre_install` script
    docker_machine_download_url = URL to download docker machine binary. If not set, the docker machine version will be used to download the binary.
    docker_machine_version = By default docker_machine_download_url is used to set the docker machine version. This version will be ignored once `docker_machine_download_url` is set. The version number is maintained by the CKI project. Check out at https://gitlab.com/cki-project/docker-machine/-/releases
    pre_install_script = Script to run before installing the runner
    post_install_script = Script to run after installing the runner
    start_script = Script to run after starting the runner
    yum_update = Update the yum packages before installing the runner
  EOT
  type = object({
    amazon_ecr_credential_helper = optional(bool, false)
    docker_machine_download_url = optional(string, "")
    docker_machine_version = optional(string, "0.16.2-gitlab.19-cki.2")
    pre_install_script = optional(string, "")
    post_install_script = optional(string, "")
    start_script = optional(string, "")
    yum_update = optional(bool, true)
  })
  default = {}
}

variable "runner_cloudwatch" {
  description = <<-EOT
    enable = Boolean used to enable or disable the CloudWatch logging.
    log_group_name = Option to override the default name (`environment`) of the log group. Requires `enable = true`.
    retention_days = Retention for cloudwatch logs. Defaults to unlimited. Requires `enable = true`.
  EOT
  type = object({
    enable = optional(bool, true)
    log_group_name = optional(string, null)
    retention_days = optional(number, 0)
  })
  default = {}
}

variable "runner_gitlab_registration_config" {
  description = "Configuration used to register the Agent. See the README for an example, or reference the examples in the examples directory of this repo."
  type        = object({
    registration_token = optional(string, "")
    tag_list           = optional(string, "")
    description        = optional(string, "")
    locked_to_project  = optional(string, "")
    run_untagged       = optional(string, "")
    maximum_timeout    = optional(string, "")
    access_level       = optional(string, "")
  })

  default = {}
}

variable "runner_gitlab" {
  description = <<-EOT
    ca_certificate = Trusted CA certificate bundle (PEM format).
    certificate = Certificate of the GitLab instance to connect to (PEM format).
    registration_token = Registration token to use to register the runner. Do not use. This is replaced by the `registration_token` in `runner_gitlab_registration_config`.
    runner_version = Version of the [GitLab runner](https://gitlab.com/gitlab-org/gitlab-runner/-/releases).
    url = URL of the GitLab instance to connect to.
    url_clone = URL of the GitLab instance to clone from. Use only if the agent can’t connect to the GitLab URL.
  EOT
  type = object({
    ca_certificate = optional(string, "")
    certificate = optional(string, "")
    registration_token = optional(string, "__REPLACED_BY_USER_DATA__")
    runner_version = optional(string, "15.8.2")
    url = optional(string)
    url_clone = optional(string)
  })
}

variable "runner_gitlab_token_secure_parameter_store" {
  description = "Name of the Secure Parameter Store entry to hold the GitLab Runner token."
  type        = string
  default     = "runner-token"
}

variable "runner_sentry_secure_parameter_store_name" {
  description = "The Sentry DSN name used to store the Sentry DSN in Secure Parameter Store"
  type        = string
  default     = "sentry-dsn"
}

variable "runner_terminate_ec2_lifecycle_hook_name" {
  description = "Specifies a custom name for the ASG terminate lifecycle hook and related resources."
  type        = string
  default     = null
}

variable "runner_terraform_timeout_delete_asg" {
  description = "Timeout when trying to delete the Agent ASG."
  default     = "10m"
  type        = string
}

/*
 * Runner Worker: The process created by the runner on the host computing platform to run jobs.
 */
variable "runner_worker" {
  description = <<-EOT
    environment_variables = List of environment variables to add to the runner.
    idle_count = Number of idle Executor instances.
    idle_time = Idle time of the runners before they are destroyed.
    max_jobs = Number of jobs which can be processed in parallel by the executor.
    output_limit = Sets the maximum build log size in kilobytes. Default is 4MB
    request_concurrency = Limit number of concurrent requests for new jobs from GitLab (default 1).
    ssm_access = Allows to connect to the Executor via SSM.
    type = The executor type to use. Currently supports `docker+machine` or `docker`.
  EOT
  type = object({
    environment_variables = optional(list(string), [])
    idle_count = optional(number, 0)
    idle_time = optional(number, 600)
    max_jobs = optional(number, 0)
    output_limit = optional(number, 4096)
    request_concurrency = optional(number, 1)
    ssm_access = optional(bool, false)
    type = optional(string, "docker+machine")
  })
  default = {}

  validation {
    condition     = contains(["docker+machine", "docker"], var.runner_worker.executor_type)
    error_message = "The executor currently supports `docker+machine` and `docker`."
  }
}

variable "runner_worker_cache" {
  description = <<-EOT
    Configuration to control the creation of the cache bucket. By default the bucket will be created and used as shared
    cache. To use the same cache across multiple runners disable the creation of the cache and provide a policy and
    bucket name. See the public runner example for more details."

    access_log_bucker_id = The ID of the bucket where the access logs are stored.
    access_log_bucket_prefix = The bucket prefix for the access logs.
    authentication_type = A string that declares the AuthenticationType for [runners.cache.s3]. Can either be 'iam' or 'credentials'
    bucket = Name of the cache bucket. Requires `create = false`.
    bucket_prefix = Prefix for s3 cache bucket name. Requires `create = true`.
    create = Boolean used to enable or disable the creation of the cache bucket.
    expiration_days = Number of days before cache objects expire. Requires `create = true`.
    include_account_id = Boolean used to include the account id in the cache bucket name. Requires `create = true`.
    policy = Policy to use for the cache bucket. Requires `create = false`.
    random_suffix = Boolean used to enable or disable the use of a random string suffix on the cache bucket name. Requires `create = true`.
    shared = Boolean used to enable or disable the use of the cache bucket as shared cache.
    versioning = Boolean used to enable versioning on the cache bucket. Requires `create = true`.
  EOT
  type        = object({
    access_log_bucket_id = optional(string, null)
    access_log_bucket_prefix = optional(string, null)
    authentication_type = optional(string, "iam")
    bucket = optional(string, "")
    bucket_prefix = optional(string, "")
    create = bool
    expiration_days = optional(number, 1)
    include_account_id = optional(bool, true)
    policy = optional(string, "")
    random_suffix = optional(bool, false)
    shared = optional(bool, false)
    versioning = optional(bool, false)
  })
  default = {
    create = true
  }
}

variable "runner_worker_pre_clone_script" {
  description = "Script to execute in the pipeline before cloning the Git repository. this can be used to adjust the Git client configuration first, for example."
  type        = string
  default     = "\"\""
}

variable "runner_worker_pre_build_script" {
  description = "Script to execute in the pipeline just before the build."
  type        = string
  default     = "\"\""
}

variable "runner_worker_post_build_script" {
  description = "Script to execute in the pipeline just after the build, but before executing after_script."
  type        = string
  default     = "\"\""
}

/*
 * Docker Executor variables.
 */
variable "runner_worker_docker_volumes_tmpfs" {
  description = "Mount a tmpfs in Executor container. https://docs.gitlab.com/runner/executors/docker.html#mounting-a-directory-in-ram"
  type = list(object({
    volume  = string
    options = string
  }))
  default = []
}

variable "runner_worker_docker_services" {
  description = "Starts additional services with the Docker container. All fields must be set (examine the Dockerfile of the service image for the entrypoint - see ./examples/runner-default/main.tf)"
  type = list(object({
    name       = string
    alias      = string
    entrypoint = list(string)
    command    = list(string)
  }))
  default = []
}

variable "runner_worker_docker_services_volumes_tmpfs" {
  description = "Mount a tmpfs in gitlab service container. https://docs.gitlab.com/runner/executors/docker.html#mounting-a-directory-in-ram"
  type = list(object({
    volume  = string
    options = string
  }))
  default = []
}

variable "runner_worker_docker_add_dind_volumes" {
  description = "Add certificates and docker.sock to the volumes to support docker-in-docker (dind)"
  type        = bool
  default     = false
}

variable "runner_worker_docker_options" {
  description = <<EOT
    Options added to the [runners.docker] section of config.toml to configure the Docker container of the Executors. For
    details check https://docs.gitlab.com/runner/configuration/advanced-configuration.html

    Default values if the option is not given:
      disable_cache = "false"
      image         = "docker:18.03.1-ce"
      privileged    = "true"
      pull_policy   = "always"
      shm_size      = 0
      tls_verify    = "false"
      volumes       = "/cache"
  EOT

  type = object({
    allowed_images               = optional(list(string))
    allowed_pull_policies        = optional(list(string))
    allowed_services             = optional(list(string))
    cache_dir                    = optional(string)
    cap_add                      = optional(list(string))
    cap_drop                     = optional(list(string))
    container_labels             = optional(list(string))
    cpuset_cpus                  = optional(string)
    cpu_shares                   = optional(number)
    cpus                         = optional(string)
    devices                      = optional(list(string))
    device_cgroup_rules          = optional(list(string))
    disable_cache                = optional(bool, false)
    disable_entrypoint_overwrite = optional(bool)
    dns                          = optional(list(string))
    dns_search                   = optional(list(string))
    extra_hosts                  = optional(list(string))
    gpus                         = optional(string)
    helper_image                 = optional(string)
    helper_image_flavor          = optional(string)
    host                         = optional(string)
    hostname                     = optional(string)
    image                        = optional(string, "docker:18.03.1-ce")
    isolation                    = optional(string)
    links                        = optional(list(string))
    mac_address                  = optional(string)
    memory                       = optional(string)
    memory_swap                  = optional(string)
    memory_reservation           = optional(string)
    network_mode                 = optional(string)
    oom_kill_disable             = optional(bool)
    oom_score_adjust             = optional(number)
    privileged                   = optional(bool, true)
    pull_policies                = optional(list(string), ["always"])
    runtime                      = optional(string)
    security_opt                 = optional(list(string))
    shm_size                     = optional(number, 0)
    sysctls                      = optional(list(string))
    tls_cert_path                = optional(string)
    tls_verify                   = optional(bool, false)
    user                         = optional(string)
    userns_mode                  = optional(string)
    volumes                      = optional(list(string), ["/cache"])
    volumes_from                 = optional(list(string))
    volume_driver                = optional(string)
    wait_for_services_timeout    = optional(number)
  })

  default = {
    disable_cache = "false"
    image         = "docker:18.03.1-ce"
    privileged    = "true"
    pull_policy   = "always"
    shm_size      = 0
    tls_verify    = "false"
    volumes       = ["/cache"]
  }
}

/*
 * docker+machine Executor variables. The executor is the actual machine that runs the job. Please specify the
 * `executor_docker_*` variables as well as Docker is used on the docker+machine executor.
 */
variable "runner_worker_docker_machine_instance_type" {
  description = "Instance type used for the instances hosting docker-machine."
  type        = string
  default     = "m5.large"
}

variable "runner_worker_docker_machine_extra_role_tags" {
  description = "Map of tags that will be added to runner EC2 instances."
  type        = map(string)
  default     = {}
}

variable "runner_worker_docker_machine_extra_egress_rules" {
  description = "List of egress rules for the docker-machine instance(s)."
  type = list(object({
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    from_port        = number
    protocol         = string
    security_groups  = list(string)
    self             = bool
    to_port          = number
    description      = string
  }))
  default = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      from_port        = 0
      protocol         = "-1"
      security_groups  = null
      self             = null
      to_port          = 0
      description      = "Allow all egress traffic for docker machine build runners"
    }
  ]
}

variable "runner_worker_docker_machine_iam_instance_profile_name" {
  description = "IAM instance profile name of the Executors."
  type        = string
  default     = ""
}

variable "runner_worker_docker_machine_assume_role_json" {
  description = "Assume role policy for the docker+machine Executor."
  type        = string
  default     = ""
}

# executor
variable "runner_worker_docker_machine_extra_iam_policy_arns" {
  type        = list(string)
  description = "List of policy ARNs to be added to the instance profile of the docker+machine Executor."
  default     = []
}

variable "runner_worker_docker_machine_security_group_description" {
  description = "A description for the docker+machine Executor security group"
  type        = string
  default     = "A security group containing docker-machine instances"
}

variable "runner_worker_docker_machine_ami_filter" {
  description = "List of maps used to create the AMI filter for the docker+machine Executor."
  type        = map(list(string))

  default = {
    name = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

variable "runner_worker_docker_machine_ami_owners" {
  description = "The list of owners used to select the AMI of the docker+machine Executor."
  type        = list(string)

  # Canonical
  default = ["099720109477"]
}

variable "runner_worker_docker_machine_instance" {
  description = <<-EOT
    ebs_optimized = Enable EBS optimization for the GitLab Runner Executor instances.
    monitoring = Enable detailed monitoring for the GitLab Runner Executor instances.
    name_prefix = Set the name prefix and override the `Name` tag for the GitLab Runner Executor instances.
    private_address_only = Restrict Executors to the use of a private IP address. If `agent_use_private_address` is set to `true` (default), `executor_docker_machine_use_private_address` will also apply for the agent.
    root_size = The size of the root volume for the GitLab Runner Executor instances.
    start_script = Cloud-init user data that will be passed to the Executor EC2 instance. Should not be base64 encrypted.
    volume_type = The type of volume to use for the GitLab Runner Executor instances.
  EOT
  type = object({
    ebs_optimized = optional(bool, true)
    monitoring = optional(bool, false)
    name_prefix = optional(string, "")
    private_address_only = optional(bool, true)
    root_size = optional(number, 8)
    start_script = optional(string, "")
    volume_type = optional(string, "gp2")
  })
  default = {
  }

  validation {
    condition     = length(var.runner_worker_docker_machine_instance.name_prefix) <= 28
    error_message = "Maximum length for docker+machine executor name is 28 characters!"
  }

  validation {
    condition     = var.runner_worker_docker_machine_instance.name_prefix == "" || can(regex("^[a-zA-Z0-9\\.-]+$", var.runner_worker_docker_machine_instance_prefix))
    error_message = "Valid characters for the docker+machine executor name are: [a-zA-Z0-9\\.-]."
  }
}

variable "runner_worker_docker_machine_ec2_spot_price_bid" {
  description = "Spot price bid. The maximum price willing to pay. By default the price is limited by the current on demand price for the instance type chosen."
  type        = string
  default     = "on-demand-price"
}

variable "runner_worker_docker_machine_request_spot_instances" {
  description = "Whether or not to request spot instances via docker-machine"
  type        = bool
  default     = true
}

variable "runner_worker_docker_machine_ec2_options" {
  # cspell:ignore amazonec
  description = "List of additional options for the docker+machine config. Each element of this list must be a key=value pair. E.g. '[\"amazonec2-zone=a\"]'"
  type        = list(string)
  default     = []
}

variable "runner_worker_docker_machine_ec2_metadata_options" {
  description = "Enable the docker machine instances metadata service. Requires you use GitLab maintained docker machines."
  type = object({
    http_tokens                 = string
    http_put_response_hop_limit = number
  })
  default = {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
}

variable "runner_worker_docker_machine_autoscaling_options" {
  description = "Set autoscaling parameters based on periods, see https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnersmachine-section"
  type = list(object({
    periods           = list(string)
    idle_count        = optional(number)
    idle_scale_factor = optional(number)
    idle_count_min    = optional(number)
    idle_time         = optional(number)
    timezone          = optional(string, "UTC")
  }))
  default = []

}

variable "runner_worker_docker_machine_max_builds" {
  description = "Destroys the executor after processing this many jobs. Set to `0` to disable this feature."
  type        = number
  default     = 0
}

variable "runner_worker_docker_machine_docker_registry_mirror_url" {
  description = "The docker registry mirror to use to avoid rate limiting by hub.docker.com"
  type        = string
  default     = ""
}

variable "debug" {
  description = <<-EOT
    trace_runner_user_data: Enable bash trace for the user data script on the Agent. Be aware this could log sensitive data such as you GitLab runner token.
    write_runner_config_to_file: Outputs the user data script and `config.toml` to the local file system.
  EOT
  type = object({
    trace_runner_user_data = optional(bool, false)
    write_runner_config_to_file = optional(bool, false)
  })
  default = {}
}
