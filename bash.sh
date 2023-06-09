#!/bin/bash
ami_id="ami-092b51d9008adea15"
key_name="laptop"
vpc_name="vpc-group-2"
vpc_cidr="10.0.0.0/16"
subnet_cidr1="10.0.1.0/24"
subnet_cidr2="10.0.2.0/24"
subnet_cidr3="10.0.3.0/24"
a_z1="us-east-2a"
a_z2="us-east-2b"
a_z3="us-east-2c"
security_group_name="group-2"
instance_name="ec2-group-2"

# Create VPC
vpc_id=$(aws ec2 create-vpc --cidr-block $vpc_cidr --output text --query 'Vpc.VpcId')
aws ec2 create-tags --resources $vpc_id --tags Key=Name,Value=$vpc_name

# Create security group
security_group_id=$(aws ec2 create-security-group --group-name $security_group_name --description "Security Group for $security_group_name" --vpc-id $vpc_id --output text --query 'GroupId')

# Open inbound ports
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 443 --cidr 0.0.0.0/0

# Create Subnets
subnet1=$(aws ec2 create-subnet --vpc-id $vpc_id --availability-zone $a_z1 --cidr-block $subnet_cidr1 --output text --query 'Subnet.SubnetId')
subnet2=$(aws ec2 create-subnet --vpc-id $vpc_id --availability-zone $a_z2 --cidr-block $subnet_cidr2 --output text --query 'Subnet.SubnetId')
subnet3=$(aws ec2 create-subnet --vpc-id $vpc_id --availability-zone $a_z3 --cidr-block $subnet_cidr3 --output text --query 'Subnet.SubnetId')

# Create Internet Gateway
gateway_id=$(aws ec2 create-internet-gateway --output text --query 'InternetGateway.InternetGatewayId')

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway --vpc-id $vpc_id --internet-gateway-id $gateway_id

# Create EC2 Instance
instance_id=$(aws ec2 run-instances --image-id $ami_id --count 1 --instance-type t2.micro --key-name $key_name --security-group-ids $security_group_id --subnet-id $subnet1 --output text --query 'Instances[0].InstanceId')
aws ec2 create-tags --resources $instance_id --tags Key=Name,Value=$instance_name

# Wait for instance to be running
aws ec2 wait instance-running --instance-ids $instance_id

# Install Jenkins
public_ip=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations [0]. Instances [0].PublicIpAddress' _-output text)
ssh -i $key_name ec2-user@$public_ip 'sudo yum install -y jenkins'












