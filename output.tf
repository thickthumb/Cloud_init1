output "ec2_public_ip" {
  description = "The public address of the instance2 is "
  value = aws_instance.ec2_instance.public_ip
}

output "ami_id" {
  description = "Select ami value"
  value = aws_instance.ec2_instance.ami
}