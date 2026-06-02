my-vpc-project/
├── provider.tf      # Holds the terraform{} and provider{} blocks
├── vpc.tf           # Holds the VPC and Subnets
├── routing.tf       # Holds the IGW, NAT Gateway, Route Tables, and Associations
├── security.tf      # Holds the Security Groups and network ACLs
├── variables.tf     # (Optional) For input variables if you want to parameterize it
└── outputs.tf       # (Optional) To output IDs like the VPC ID or Subnet IDs