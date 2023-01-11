output "interface_endpoints" {
  description = "The interface endpoints provisioned"
  value       = { for i in sort(keys(var.interface_endpoints)) : i => aws_vpc_endpoint.interface[i].id }
}
