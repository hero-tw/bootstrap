.DEFAULT_GOAL := help

AWS_PROFILE=default
PROJECT=bootstrap
REGION=us-east-1

help:
	cat ./Makefile

# setup terraform bucket for aws
one-time:
	aws s3api create-bucket --bucket "tf-${PROJECT}-${REGION}" \
	--acl private --profile ${AWS_PROFILE} --region ${REGION}

init:
	terraform init && terraform get -update

apply: init
	terraform apply -auto-approve --var-file="app.tfvars"

destroy:
    terraform destroy -force --var-file="app.tfvars"

