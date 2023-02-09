output "ebs_csi_iam_policy" {
  value = data.http.ebs_csi_driver_policy.body
}
