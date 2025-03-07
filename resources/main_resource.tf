resource "kubernetes_manifest" "namespace" {
  manifest = {
    apiVersion = "v1",
    kind = "Namespace",
    metadata = {
      name = var.namespace
    }
  }
}

resource "kubernetes_manifest" "token_config" {
  manifest = {
    apiVersion = "v1",
    kind = "ConfigMap",
    metadata = {
      name = "token-config"
      namespace = var.namespace
    },
    data = {
      "REDIS_HOST" = var.redis_cluster_endpoint
      "REDIS_PORT" = var.redis_cluster_port
      "IMAGE" = var.ecr_token_uri
    }
  }
}

resource "kubernetes_manifest" "deploy_token" {
  for_each = fileset("${path.module}/manifest", "*_token.yaml")

  manifest = yamldecode(
    replace(
      replace(file("${path.module}/manifest/${each.value}"), "$(NAMESPACE)", var.namespace),
      "$(IMAGE_TOKEN)", var.ecr_token_uri
    )
  )

  depends_on = [
    kubernetes_manifest.token_config
  ]
}

resource "kubernetes_manifest" "user_secret" {
  manifest = {
    apiVersion = "v1"
    kind = "Secret"
    metadata = {
      name = "user-secret"
      namespace = var.namespace
    }
    type = "Opaque"
    data = {
      "MONGODB_USERNAME" = base64encode(var.mongodb_username)
      "MONGODB_PASSWORD" = base64encode(var.mongodb_password)
    }
  }

  depends_on = [kubernetes_manifest.deploy_token]
}


resource "kubernetes_manifest" "user_config" {
  manifest = {
    apiVersion = "v1",
    kind = "ConfigMap",
    metadata = {
      name = "user-config"
      namespace = var.namespace
    },
    data = {
      "MONGODB_HOST" = var.mongodb_cluster_endpoint
      "MONGODB_PORT" = var.mongodb_cluster_port
      "IMAGE" = var.ecr_user_uri
      "AWS_REGION" = var.region
      "AWS_SECRET_NAME" = var.secret_manager_name
    }
  }

  depends_on = [ kubernetes_manifest.user_secret ]
}

resource "kubernetes_service_account" "sa_user" {
  
  metadata {
    name = "user"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.user-app-irsa-role.iam_role_arn
    }
  }

  depends_on = [
    kubernetes_manifest.user_config,
    module.user-app-irsa-role
  ]
}

resource "kubernetes_manifest" "deploy_user" {
  for_each = fileset("${path.module}/manifest", "*_user.yaml")

  manifest = yamldecode(
    replace(
      replace(
        replace(
          replace( 
            replace(
                file(
          "${path.module}/manifest/${each.value}"), 
          "$(NAMESPACE)", var.namespace),
          "$(NODEGROUP_NAME)", split(":", var.app_nodegroup_name)[1]), 
          "$(IMAGE_USER)", var.ecr_user_uri),
          "$(ALB_NAME)", var.alb_name),
          "$(SERVICE_NAME)", var.service_name),
  )

  depends_on = [
    kubernetes_service_account.sa_user
  ]
}

resource "kubernetes_manifest" "deploy_cluster_autoscaler_sa" {
  for_each = fileset("${path.module}/manifest", "cluster-autoscaler-sa.yaml")

  manifest = yamldecode(
    replace(
      file("${path.module}/manifest/${each.value}"),
      "$(CLUSTER_AUTOSCALER_ROLE_ARN)", module.cluster-autoscaler-irsa-role.iam_role_arn
    )
  )

  depends_on = [
    kubernetes_manifest.deploy_user,
    module.cluster-autoscaler-irsa-role
  ]
}

resource "kubernetes_manifest" "deploy_cluster_autoscaler_role" {
  for_each = fileset("${path.module}/manifest", "cluster-autoscaler-role-*.yaml")

  manifest = yamldecode(
    file("${path.module}/manifest/${each.value}")
  )

  depends_on = [
    kubernetes_manifest.deploy_cluster_autoscaler_sa
  ]
}

resource "kubernetes_manifest" "deploy_cluster_autoscaler_rolebinding" {
  for_each = fileset("${path.module}/manifest", "cluster-autoscaler-rb-*.yaml")

  manifest = yamldecode(
    file("${path.module}/manifest/${each.value}")
  )

  depends_on = [
    kubernetes_manifest.deploy_cluster_autoscaler_role
  ]
}

resource "kubernetes_manifest" "deploy_cluster_autoscaler_deployment" {
  for_each = fileset("${path.module}/manifest", "cluster-autoscaler-dp-*.yaml")

  manifest = yamldecode(
    file("${path.module}/manifest/${each.value}")
  )

  depends_on = [
    kubernetes_manifest.deploy_cluster_autoscaler_rolebinding
  ]
}

resource "kubernetes_manifest" "amazon_cloudwatch_namespace" {
  manifest = {
    apiVersion = "v1",
    kind = "Namespace",
    metadata = {
      name = var.fluent_bit_ns
    }
  }

  depends_on = [ kubernetes_manifest.deploy_cluster_autoscaler_deployment ]
}

resource "kubernetes_manifest" "fluent_bit_cluster_info" {
  manifest = {
    apiVersion = "v1",
    kind = "ConfigMap",
    metadata = {
      name = "fluent-bit-cluster-info"
      namespace = var.fluent_bit_ns
    },
    data = {
      "cluster.name" = var.cluster_name
      "http.server" = "On"
      "http.port" = "2020"
      "read.head" = "Off"
      "read.tail" = "On"
      "logs.region" = var.region
    }
  }

  depends_on = [ kubernetes_manifest.amazon_cloudwatch_namespace ]
}

resource "kubernetes_service_account" "sa_fluent_bit" {
  
  metadata {
    name = "fluent-bit"
    namespace = var.fluent_bit_ns
    annotations = {
      "eks.amazonaws.com/role-arn" = module.fluent-bit-irsa-role.iam_role_arn
    }
  }

  depends_on = [
    kubernetes_manifest.fluent_bit_cluster_info,
    module.fluent-bit-irsa-role
  ]
}

resource "kubernetes_manifest" "fluent_bit_role" {
  for_each = fileset("${path.module}/manifest", "fluent-bit-role-*.yaml")

  manifest = yamldecode(
    file("${path.module}/manifest/${each.value}")
  )

  depends_on = [
    kubernetes_manifest.fluent_bit_cluster_info,
    module.fluent-bit-irsa-role
  ]
}

resource "kubernetes_manifest" "fluent_bit_role_binding" {
  for_each = fileset("${path.module}/manifest", "fluent-bit-rb-*.yaml")

  manifest = yamldecode(
    replace(
      file("${path.module}/manifest/${each.value}"),
      "$(NAMESPACE)", var.fluent_bit_ns
    )
  )

  depends_on = [
    kubernetes_manifest.fluent_bit_role
  ]
}

resource "kubernetes_manifest" "fluent_bit_cm" {
  for_each = fileset("${path.module}/manifest", "fluent-bit-cm*.yaml")

  manifest = yamldecode(
    replace(
      replace(
        file("${path.module}/manifest/${each.value}"),
        "$(NAMESPACE)", var.fluent_bit_ns),
        "$(LOG_GROUP_NAME)", var.user_log_group_name
    )
  )

  depends_on = [
    kubernetes_manifest.fluent_bit_role_binding
  ]
}

resource "kubernetes_manifest" "fluent_bit_daemonset" {
  for_each = fileset("${path.module}/manifest", "fluent-bit-daemonset.yaml")

  manifest = yamldecode(
    replace(
        file("${path.module}/manifest/${each.value}"),
        "$(NAMESPACE)", var.fluent_bit_ns
    )
  )

  depends_on = [
    kubernetes_manifest.fluent_bit_cm
  ]
}

resource "kubernetes_manifest" "fluent_bit_fargate_ns" {
  manifest = {
    apiVersion = "v1",
    kind = "Namespace"
    metadata = {
      name = var.fluent_bit_fargate_ns
      labels = {
        aws-observability = "enabled"
      }
    }
  }

  depends_on = [ kubernetes_manifest.fluent_bit_daemonset ]
}

resource "kubernetes_manifest" "fluent_bit_fargate_cm" {
  for_each = fileset("${path.module}/manifest", "fluent-bit-fargate-cm.yaml")

  manifest = yamldecode(
    replace(
        file("${path.module}/manifest/${each.value}"),
        "$(NAMESPACE)", var.fluent_bit_fargate_ns
    )
  )

  depends_on = [
    kubernetes_manifest.fluent_bit_fargate_ns
  ]
}