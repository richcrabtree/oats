module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  # Autoscaling group
  name = "example-asg"

  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets

  initial_lifecycle_hooks = [
    {
      name                  = "ExampleStartupLifeCycleHook"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 60
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
      notification_metadata = jsonencode({ "hello" = "world" })
    },
    {
      name                  = "ExampleTerminationLifeCycleHook"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 180
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_TERMINATING"
      notification_metadata = jsonencode({ "goodbye" = "world" })
    }
  ]

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 300
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  target_group_arns = module.alb.target_group_arns
  user_data_base64 = "IyEvYmluL3NoCnl1bSBpbnN0YWxsIC15IGdpdCBqcQphbWF6b24tbGludXgtZXh0cmFzIGluc3RhbGwgLXkgbmdpbngxCnBpcDMgaW5zdGFsbCBwaXBlbnYKCmNkIH5lYzItdXNlci8KY2F0ID4gfi8uc3NoL2NvbmZpZyA8PCBFT0YKSG9zdCAqCiAgICBTdHJpY3RIb3N0S2V5Q2hlY2tpbmcgbm8KRU9GCmNobW9kIDYwMCB+Ly5zc2gvY29uZmlnCmdpdCBjbG9uZSBodHRwczovL2dpdGh1Yi5jb20vZGlhbmVwaGFuL2ZsYXNrLWF3cy1zdG9yYWdlLmdpdApjZCBmbGFzay1hd3Mtc3RvcmFnZQpta2RpciB1cGxvYWRzCmNob3duIC1SIGVjMi11c2VyOmVjMi11c2VyIC4KY2F0ID4gcnVuLnNoIDw8IEVPRgojIS9iaW4vc2gKcGlwZW52IGluc3RhbGwKcGlwZW52IHJ1biBwaXAzIGluc3RhbGwgLXIgcmVxdWlyZW1lbnRzLnR4dApSRUdJT049XCQoY3VybCBodHRwOi8vMTY5LjI1NC4xNjkuMjU0L2xhdGVzdC9tZXRhLWRhdGEvcGxhY2VtZW50L3JlZ2lvbikKSUlEPVwkKGN1cmwgaHR0cDovLzE2OS4yNTQuMTY5LjI1NC9sYXRlc3QvbWV0YS1kYXRhL2luc3RhbmNlLWlkKQpFTlY9XCQoYXdzIC0tcmVnaW9uIFwkUkVHSU9OIGVjMiBkZXNjcmliZS10YWdzIC0tZmlsdGVycyBOYW1lPXJlc291cmNlLWlkLFZhbHVlcz1cJElJRCB8IGpxIC1yICcuVGFnc1tdfHNlbGVjdCguS2V5ID09ICJlbnZpcm9ubWVudCIpfC5WYWx1ZScpCkZMQVNLX0VOVj1cJEVOViBwaXBlbnYgcnVuIGZsYXNrIHJ1bgpFT0YKY2htb2QgNzU1IHJ1bi5zaAoKY2F0ID4gL2V0Yy9zeXN0ZW1kL3N5c3RlbS9pbWdtZ3Iuc2VydmljZSA8PCBFT0YKW1VuaXRdCkRlc2NyaXB0aW9uPUltYWdlIG1hbmFnZXIgYXBwCkFmdGVyPW5ldHdvcmsudGFyZ2V0CgpbU2VydmljZV0KVXNlcj1lYzItdXNlcgpXb3JraW5nRGlyZWN0b3J5PS9ob21lL2VjMi11c2VyL2ZsYXNrLWF3cy1zdG9yYWdlCkV4ZWNTdGFydD0vaG9tZS9lYzItdXNlci9mbGFzay1hd3Mtc3RvcmFnZS9ydW4uc2gKUmVzdGFydD1hbHdheXMKCltJbnN0YWxsXQpXYW50ZWRCeT1tdWx0aS11c2VyLnRhcmdldApFT0YKCnN5c3RlbWN0bCBkYWVtb24tcmVsb2FkCnN5c3RlbWN0bCBzdGFydCBpbWdtZ3IKCmNhdCA+IC9ldGMvbmdpbngvY29uZi5kL215YXBwLmNvbmYgPDwgRU9GCnNlcnZlciB7CiAgIGxpc3RlbiA4MDsKICAgc2VydmVyX25hbWUgbG9jYWxob3N0OwogICBsb2NhdGlvbiAvIHsKICAgICAgICBwcm94eV9zZXRfaGVhZGVyIEhvc3QgXCRodHRwX2hvc3Q7CiAgICAgICAgcHJveHlfcGFzcyBodHRwOi8vMTI3LjAuMC4xOjUwMDA7CiAgICB9Cn0KRU9GCnN5c3RlbWN0bCByZXN0YXJ0IG5naW54LnNlcnZpY2UKCgpjYXQgPiAvYmluL3NzaF9tb25pdG9yLnNoIDw8IEVPRgpJRD1cJChlYzItbWV0YWRhdGEgLS1pbnN0YW5jZS1pZCB8IGN1dCAtZCAiICIgLWYgMikKUE9SVF8yMj1cJChuZXRzdGF0IHwgZ3JlcCBzc2ggfCB3YyAtbCkKZWNobyBcJElEIFwkUE9SVF8yMgphd3MgY2xvdWR3YXRjaCAtLXJlZ2lvbiB1cy13ZXN0LTIgcHV0LW1ldHJpYy1kYXRhIC0tbWV0cmljLW5hbWUgUE9SVF8yMl9BVkFJTEFCSUxJVFkgLS1kaW1lbnNpb25zIEluc3RhbmNlPVwkSUQgLS1uYW1lc3BhY2UgInBvcnQyMiIgLS12YWx1ZSBcJFBPUlRfMjIKRU9GCmNobW9kICt4IC9iaW4vc3NoX21vbml0b3Iuc2gKCmNhdCA+IC9ldGMvc3lzdGVtZC9zeXN0ZW0vc3NoX21vbml0b3Iuc2VydmljZSA8PCBFT0YKW1VuaXRdCkRlc2NyaXB0aW9uPVNTSCBNb25pdG9yIGFwcApBZnRlcj1uZXR3b3JrLnRhcmdldAoKW1NlcnZpY2VdClR5cGU9b25lc2hvdApFeGVjU3RhcnQ9L2Jpbi9zc2hfbW9uaXRvci5zaAoKW0luc3RhbGxdCldhbnRlZEJ5PW11bHRpLXVzZXIudGFyZ2V0CkVPRgoKY2F0ID4gL2V0Yy9zeXN0ZW1kL3N5c3RlbS9zc2hfbW9uaXRvci50aW1lciA8PCBFT0YKW1VuaXRdCkRlc2NyaXB0aW9uPWV2ZXJ5IG1pbnV0ZSBzZW5kIHNzaCBtZXRyaWNzCgpbVGltZXJdCk9uQ2FsZW5kYXI9KjoqOjAwClVuaXQ9c3NoX21vbml0b3Iuc2VydmljZQpQZXJzaXN0ZW50PXRydWUKCltJbnN0YWxsXQpXYW50ZWRCeT10aW1lcnMudGFyZ2V0CkVPRgoKc3lzdGVtY3RsIGVuYWJsZSAtLW5vdyBzc2hfbW9uaXRvci50aW1lcg=="
  iam_instance_profile_arn = aws_iam_instance_profile.server_profile.arn

  depends_on = [
    aws_iam_instance_profile.server_profile,
  ]


  # Launch template
  lt_name                = "example-asg"
  description            = "Launch template example"
  update_default_version = true

  use_lt    = true
  create_lt = true

  image_id          = var.image_id
  instance_type     = "t3.micro"
  ebs_optimized     = true
  enable_monitoring = true

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp2"
      }
      }, {
      device_name = "/dev/sda1"
      no_device   = 1
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 30
        volume_type           = "gp2"
      }
    }
  ]

  capacity_reservation_specification = {
    capacity_reservation_preference = "open"
  }

  cpu_options = {
    core_count       = 1
    threads_per_core = 1
  }

  credit_specification = {
    cpu_credits = "standard"
  }

  # instance_market_options = {
  #   market_type = "spot"
  #   spot_options = {
  #     block_duration_minutes = 60
  #   }
  # }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 32
  }

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [module.sg_web.security_group_id,module.sg_ssh.security_group_id]
    },
    {
      delete_on_termination = true
      description           = "eth1"
      device_index          = 1
      security_groups       = [module.sg_web.security_group_id]
    }
  ]

  # placement = {
  #   availability_zone = "us-west-2b"
  # }

  tag_specifications = [
    {
      resource_type = "instance"
      tags          = { WhatAmI = "Instance" }
    },
    {
      resource_type = "volume"
      tags          = { WhatAmI = "Volume" }
    },
    # {
    #   resource_type = "spot-instances-request"
    #   tags          = { WhatAmI = "SpotInstanceRequest" }
    # }
  ]

  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "megasecret"
      propagate_at_launch = true
    },
  ]

  tags_as_map = {
    extra_tag1 = "extra_value1"
    extra_tag2 = "extra_value2"
  }
}