aws_region       = "eu-north-1"

# Replace these example values with your real AWS resource IDs.
vpc_id           = "vpc-REPLACE_ME"
subnet_id        = "subnet-REPLACE_ME"
ubuntu_ami_id    = "ami-REPLACE_ME"
key_name         = "YOUR_EXISTING_KEY_PAIR_NAME"

# Replace with your public IPv4 address, ending in /32.
ssh_allowed_cidr = "YOUR_PUBLIC_IP/32"

# For testing, this allows the website to be accessed publicly.
# Restrict this to your IP if public access is unnecessary.
app_allowed_cidr = "0.0.0.0/0"

instance_type    = "t3.xlarge"
