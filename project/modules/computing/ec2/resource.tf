# EC2 keypair
resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = file("ec2-keypair.pub")
}

# EC2 instance
resource "aws_instance" "main" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  key_name                    = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "${var.tag_name_prefix}-ec2"
    # Project = var.project
    # Env     = var.environment
  }
}
