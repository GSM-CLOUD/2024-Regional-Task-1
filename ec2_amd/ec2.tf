resource "aws_instance" "bastion" {
    ami = "${var.ami_id}"
    instance_type = "${var.instance_type}"
    key_name = var.key_name
    subnet_id = var.public_subnets[0]
    iam_instance_profile = var.instance_profile
    vpc_security_group_ids = [aws_security_group.ec2-amd-sg.id]

    user_data = <<-EOF
#!/bin/bash
sudo su
yum install -y docker
systemctl enable docker
systemctl restart docker
aws s3 cp s3://"${var.bucket_name}"/token.zip .
unzip ./token.zip -d .
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin "${var.account_id}".dkr.ecr.ap-northeast-2.amazonaws.com
docker build -t token .
docker tag token:latest "${var.account_id}".dkr.ecr.ap-northeast-2.amazonaws.com/token:latest
docker push "${var.account_id}".dkr.ecr.ap-northeast-2.amazonaws.com/token:latest
EOF

    tags = {
      Name = "${var.prefix}-amd-64"
    }
}

