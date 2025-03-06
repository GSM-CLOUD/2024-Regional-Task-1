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
    name = var.service_account_name
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