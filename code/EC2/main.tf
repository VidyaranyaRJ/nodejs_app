terraform {
  backend "s3" {
    bucket         = "vj-test-ecr-79"  # Your newly created S3 bucket
    key            = "terraform.tfstate"  # Path to store the state file in S3
    region         = "us-east-2"  # Update if your bucket is in a different region
    encrypt        = true
  }
}

module "ec2" {
  source                                 = "../../modules/ec2"
  ami = var.ami
  instance_type = var.instance_type
}

