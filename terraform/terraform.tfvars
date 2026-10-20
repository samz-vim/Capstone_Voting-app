aws_region       = "eu-north-1"

# Replace these example values with your real AWS resource IDs.
vpc_id           = "vpc-001161571cbc742c7"
subnet_id        = "subnet-064d809e7fa97457b"
ubuntu_ami_id    = "ami-05bfa4a7765f38076"
key_name         = "devops"

# Replace with your public IPv4 address, ending in /32
ssh_allowed_cidr = "102.89.22.12/32"

# For testing, this allows the website to be accessed publicly.
# Restrict this to your IP if public access is unnecessary.
app_allowed_cidr = "0.0.0.0/0"

instance_type    = "t3.xlarge"
