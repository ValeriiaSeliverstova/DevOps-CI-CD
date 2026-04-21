output "jenkins_namespace" {
  value = module.jenkins.namespace
}

output "argocd_namespace" {
  value = module.argo_cd.namespace
}

output "jenkins_agent_role_arn" {
  value = module.jenkins.agent_role_arn
}

output "jenkins_url" {
  value = module.jenkins.service_url
}

output "jenkins_admin_username" {
  value = module.jenkins.admin_username
}

output "jenkins_admin_password" {
  value     = module.jenkins.admin_password
  sensitive = true
}

output "argocd_url" {
  value = module.argo_cd.server_url
}

output "argocd_initial_admin_password" {
  value     = module.argo_cd.initial_admin_password
  sensitive = true
}
