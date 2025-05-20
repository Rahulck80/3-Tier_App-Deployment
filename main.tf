resource "aws_instance" "Ansible" {
  for_each = var.instances
  ami                    = "ami-09c813fb71547fc4f"
  instance_type          = each.value
  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  root_block_device {
    volume_size = 50  # Set root volume size to 50GB
    volume_type = "gp3"  # Use gp3 for better performance (optional)
  }
  #user_data = file("docker.sh")
  provisioner "remote-exec" {
    inline = [
      "sudo growpart /dev/nvme0n1 4",
      "sudo lvextend -l +50%FREE /dev/RootVG/rootVol",
      "sudo lvextend -l +50%FREE /dev/RootVG/varVol",
      "sudo xfs_growfs /",
      "sudo xfs_growfs /var"
    ]
  }
  
  connection {
    type        = "ssh"
    user        = "ec2-user"
    password    = "DevOps321"
    host        = self.public_ip
  }
  
  tags = {
    Name = each.key
    
  }

}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }

}

resource "aws_route53_record" "www" {
  for_each = aws_instance.Ansible
  zone_id = var.zone_id
  name    = each.key == "Ansible" ? var.domain_name : "${each.key}.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = each.key == "Ansible" ? [each.value.public_ip] : [each.value.private_ip]
}
