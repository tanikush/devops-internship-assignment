output "gateway_public_ip" {
  description = "Public IP of the gateway VM"
  value       = aws_instance.gateway.public_ip
}

output "engine_private_ip" {
  description = "Private IP of the engine VM"
  value       = aws_instance.engine.private_ip
}

output "inference_private_ip" {
  description = "Private IP of the inference VM"
  value       = aws_instance.inference.private_ip
}