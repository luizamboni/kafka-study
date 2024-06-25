TERRAFORM_VERSION=1.8
# GIT_COMMIT_HASH=$(shell git rev-parse --short HEAD)

TERRAFORM_BASE=docker run --rm -it --name terraform \
	-v $(shell pwd)/infra/terraform/:/workspace \
	-w /workspace \
	-e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	-e AWS_REGION=${AWS_REGION} \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	hashicorp/terraform:${TERRAFORM_VERSION}

terraform-generate-certs:
	cd infra/terraform/keys && ./generate.sh

terraform-init:
	${TERRAFORM_BASE} \
	init

terraform-plan: terraform-init
	${TERRAFORM_BASE} \
	plan

terraform-create-all: terraform-init terraform-create-network terraform-create-vpn-endpoint terraform-create-get-vpn-config terraform-create-msk
	echo "All created"


terraform-create-network: 
	${TERRAFORM_BASE} \
	apply --auto-approve \
	--target=module.network

terraform-create-vpn-endpoint: 
	${TERRAFORM_BASE} \
	apply --auto-approve \
	--target=module.vpn_endpoint

terraform-create-get-vpn-config: terraform-init
	${TERRAFORM_BASE} \
	apply --auto-approve \
	--target=null_resource.get_vpn_endpoint_config

terraform-create-data-crawlers: terraform-init
	${TERRAFORM_BASE} \
	apply --auto-approve \
	--target=aws_glue_crawler.root

terraform-create-data-crawlers: terraform-init
	${TERRAFORM_BASE} \
	destroy --auto-approve \
	--target=aws_glue_crawler.root

terraform-create-msk: 
	${TERRAFORM_BASE} \
	apply --auto-approve \
	--target=module.msk_instance \
	--target=module.s3_connect-avro-to-parquet-example

terraform-destroy-all: terraform-init
	${TERRAFORM_BASE} \
	destroy --auto-approve

