provider "aws" {
  region = "${var.region}"
}

data "aws_availability_zones" "available" {}

module "jenkins" {
  source      = "git::https://github.com/cloudposse/terraform-aws-jenkins.git?ref=master"
  namespace   = "hero-tw"
  name        = "jenkins"
  stage       = "tools"
  description = "Jenkins server as Docker container running on Elastic Beanstalk"

  master_instance_type         = "t2.medium"
  aws_account_id               = "${var.account_id}"
  aws_region                   = "${var.region}"
  availability_zones           = ["${slice(data.aws_availability_zones.available.names, 0, var.max_availability_zones)}"]
  vpc_id                       = "${module.vpc.vpc_id}"
  zone_id                      = "${aws_route53_zone.zone.zone_id}"
  public_subnets               = "${module.subnets.public_subnet_ids}"
  private_subnets              = "${module.subnets.private_subnet_ids}"
  loadbalancer_certificate_arn = "${module.cert.arn}"
  ssh_key_pair                 = "${var.key_name}"

  github_oauth_token  = ""
  github_organization = "cloudposse"
  github_repo_name    = "jenkins"
  github_branch       = "master"

  datapipeline_config = {
    instance_type = "t2.medium"
    email         = "joe@smith.com"
    period        = "12 hours"
    timeout       = "60 Minutes"
  }

  env_vars = {
    JENKINS_USER          = "${var.jenkins_user}"
    JENKINS_PASS          = "${var.jenkins_pass}"
    JENKINS_NUM_EXECUTORS = 4
  }

  tags = {
    BusinessUnit = "Hero"
    Department   = "TW"
  }
}

module "vpc" {
  source                           = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=master"
  namespace                        = "hero-tw"
  name                             = "jenkins"
  stage                            = "tools"
  cidr_block                       = "10.0.0.0/16"

  tags = {
    BusinessUnit = "Hero"
    Department   = "TW"
  }
}

module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=master"
  availability_zones  = ["${slice(data.aws_availability_zones.available.names, 0, var.max_availability_zones)}"]
  namespace           = "hero-tw"
  name                = "jenkins"
  stage               = "tools"
  region              = "${var.region}"
  vpc_id              = "${module.vpc.vpc_id}"
  igw_id              = "${module.vpc.igw_id}"
  cidr_block          = "${module.vpc.vpc_cidr_block}"
  nat_gateway_enabled = "true"

  tags = {
    BusinessUnit = "Hero"
    Department   = "TW"
  }
}

resource "aws_route53_zone" "zone" {
  name = "${var.custom_domain}"
}

module "cert" {
  source = "github.com/azavea/terraform-aws-acm-certificate?ref=0.1.0"

  domain_name               = "${var.custom_domain}"
  subject_alternative_names = ["*.${var.custom_domain}"]
  hosted_zone_id            = "${aws_route53_zone.zone.zone_id}"
  validation_record_ttl     = "60"
}

terraform {
  backend "s3" {
    bucket = "tf-bootstrap-us-east-1"
    key    = "terraform"
    region = "us-east-1"
  }
}
