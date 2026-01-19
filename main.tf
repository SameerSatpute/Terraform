resource "aws_key_pair" "home-linux" {
  key_name   = "my-key"
  public_key = file(terra-key.pub)
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "sg" {
    name        = "allow_tls"
    description = "Allow TLS inbound traffic and all outbound traffic"
    vpc_id      = aws_default_vpc.default.id
    
   egress {
    description = " allow all outgoing traffic "
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    
     tags = {
    Name = "allow_tls"
  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_tls_443" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = aws_default_vpc.default.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_ingress_rule" "allow_tls_80" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = aws_default_vpc.default.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  }
  resource "aws_vpc_security_group_ingress_rule" "allow_tls_22" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = aws_default_vpc.default.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_instance" "instance" {  
  ami                     = "ami-0d176f79571d18a8f"
  instance_type           = "t2.micro"
  key_name = aws_key_pair.home-linux.key_name
  security_groups = [aws_security_group.sg.name]

  maintenance_options {
    auto_recovery = "default"
  }
   tags = {
    Name = "web-instance"
  }
  root_block_device {
    volume_size = 10
    volume_type = gp3
  }
  ebs_block_device {
    device_name = "/dev/sdb1"
    volume_size = 10
    volume_type = "gp3"
    delete_on_termination = false
  }
  provisioner "remote-exec" {
   connection {
    type        = "ssh"
    user        = "ec2-user"          
    private_key = file("terra-key")
    host        = self.public_ip
  }

  inline = [
    "echo 'Welcome to EC2 instance' >> ~/.bashrc"
  ]
}
}

