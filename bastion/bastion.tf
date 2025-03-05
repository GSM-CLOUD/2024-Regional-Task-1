resource "aws_instance" "bastion" {
  ami = var.aws_ami
  instance_type = "t4g.large"

  subnet_id = var.public_subnets[0]
  vpc_security_group_ids = [var.cluster_security_group_id, var.node_security_group_id, aws_security_group.bastion-sg.id]
  key_name = aws_key_pair.bastion-key-pair.key_name
  iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name

  user_data = <<-EOF
#!/bin/bash
sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config
systemctl restart sshd
sudo su
yum install -y docker
systemctl enable docker
systemctl restart docker
aws s3 cp s3://"${var.bucket_name}"/user.zip .
unzip ./user.zip -d .
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin "${var.account_id}".dkr.ecr.ap-northeast-2.amazonaws.com
docker build -t user .
docker tag user:latest "${var.account_id}".dkr.ecr.ap-northeast-2.amazonaws.com/user:latest
docker push "${var.account_id}".dkr.ecr.ap-northeast-2.amazonaws.com/user:latest
EOF

  tags = {
    "Name" = "${var.prefix}-bastion-ec2"
  }
}

resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
  
  tags = {
    Name = "${var.prefix}-bastion-eip"
  }
}