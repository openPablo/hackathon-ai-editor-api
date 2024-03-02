data "aws_ecs_cluster" "cluster" {
  cluster_name = var.ecsCluster
}

resource "aws_ecs_service" "service" {
  depends_on = [
    aws_lb_target_group.target
  ]
  name                 = "${var.project}-${var.environment}"
  cluster              = data.aws_ecs_cluster.cluster.id
  task_definition      = aws_ecs_task_definition.task.arn
  desired_count        = var.minContainers
  force_new_deployment = true
  launch_type          = "FARGATE"
  propagate_tags                     = "SERVICE"
  load_balancer {
    container_name   = "${var.project}-${var.environment}"
    container_port   = var.containerPort
    target_group_arn = aws_lb_target_group.target.arn
  }
  network_configuration {
    subnets         = data.aws_subnets.private.ids
    security_groups = [aws_security_group.ecs_sg.id]
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
}
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.maxContainers
  min_capacity       = var.minContainers
  resource_id        = "service/${data.aws_ecs_cluster.cluster.cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "target-track-${var.project}-${var.environment}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    scale_in_cooldown  = 3600
    scale_out_cooldown = 180
    target_value       = 30
    customized_metric_specification {
      metric_name = "CPUUtilization"
      namespace   = "AWS/ECS"
      statistic   = "Maximum"

      dimensions {
        name  = "ClusterName"
        value = data.aws_ecs_cluster.cluster.cluster_name
      }
      dimensions {
        name  = "ServiceName"
        value = aws_ecs_service.service.name
      }
    }
  }
}
resource "aws_cloudwatch_log_group" "service" {
  name              = "${var.project}/${var.environment}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.project}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.execution-role.arn
  task_role_arn            = aws_iam_role.execution-role.arn
  cpu                      = 1024
  memory                   = 2048
  container_definitions    = jsonencode(
    [
      {
        cpu : 1024,
        memory : 2048,
        essential : true,
        image : "${data.aws_caller_identity.current.id}.dkr.ecr.${var.region}.amazonaws.com/${var.project}:${coalesce(var.TAG,data.aws_ssm_parameter.commit-tag.value)}",
        name : "${var.project}-${var.environment}",
        portMappings : [
          {
            "containerPort" : var.containerPort,
            "hostPort" : var.containerPort
          }
        ],
        environment : [
          {
            "name" : "SPRING_PROFILES_ACTIVE",
            "value" : "${var.environment}"
          },
          {
            "name" : "ENVIRONMENT",
            "value" : "${var.environment}"
          },
          {
            "name" : "AWS_REGION",
            "value" : "${var.region}"
          },
          {
            "name" : "PROMETHEUS",
            "value" : "true"
          },
          {
            "name" : "PROMETHEUS_ENDPOINT",
            "value" : "/actuator/prometheus"
          },
          {
            name  = "OTEL_METRICS_EXPORTER"
            value = "none"
          },
          {
            name  = "OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"
            value = data.aws_ssm_parameter.tempo_url.value
          },
          {
            name  = "OTEL_TRACES_SAMPLER"
            value = "parentbased_traceidratio"
          },
          {
            name  = "OTEL_TRACES_SAMPLER_ARG"
            value = "0.0001"
          },
          {
            name  = "OTEL_PROPAGATORS"
            value = "tracecontext,baggage,xray"
          },
          {
              name  = "OPENAI_API_KEY"
              value = jsondecode(data.aws_secretsmanager_secret_version.openai_current.secret_string)["OPENAI_API_KEY"]
          },
          {
              name  = "TAVILY_API_KEY"
              value = jsondecode(data.aws_secretsmanager_secret_version.openai_current.secret_string)["TAVILY_API_KEY"]
          },
          {
            name  = "OTEL_RESOURCE_ATTRIBUTES"
            value = "service_name=${var.project},compose_service=${var.squad},environment=${var.environment}"
          }
        ],
        logConfiguration = {
          logDriver = "awsfirelens",
            options = {
              Name        = "loki"
              Host        = "loki.videobs.local"
              port        = "3100"
              labels      = "environment=${var.environment},service_name=${var.project},compose_service=${var.squad}"
              remove_keys = "container_id,ecs_task_arn,Time,container_name,ecs_cluster,tsNs",
            }
        }
      },
      {
        essential : false,
        image : "${data.aws_caller_identity.current.id}.dkr.ecr.${var.region}.amazonaws.com/fluentbit:multiline",
        name : "log_router",
        firelensConfiguration : {
          "type" : "fluentbit",
          "options": {
            "enable-ecs-log-metadata" : "true"
					  "config-file-type"        : "file",
					  "config-file-value"       : "/extra.conf"
				}
        },
        logConfiguration : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-group" : aws_cloudwatch_log_group.firelens.name,
            "awslogs-region" : var.region,
            "awslogs-stream-prefix" : "ecs"
          }
        }
      }
    ]
  )
}
resource "aws_cloudwatch_log_group" "firelens" {
  name = "${var.project}-${var.environment}-firelens"
  retention_in_days = 14
}

data "aws_secretsmanager_secret" "openai" {
  name = "hackathon/openai"
}
data "aws_secretsmanager_secret_version" "openai_current" {
  secret_id = data.aws_secretsmanager_secret.openai.id
}