TERRAFORM_VERSION=1.8
ECR_REGISTRY=${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
GIT_COMMIT_HASH=$(shell git rev-parse --short HEAD)
TF_VAR_event_receive_image=${ECR_REGISTRY}/seeds:${GIT_COMMIT_HASH}
TF_VAR_metabase_image=${ECR_REGISTRY}/metabase:${GIT_COMMIT_HASH}

TERRAFORM_BASE=docker run --rm -it --name terraform \
	-v $(shell pwd)/infra/terraform/:/workspace \
	-w /workspace \
	-e TF_VAR_event_receive_image=${TF_VAR_event_receive_image} \
	-e TF_VAR_metabase_image=${TF_VAR_metabase_image} \
	-e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	-e AWS_REGION=${AWS_REGION} \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	hashicorp/terraform:${TERRAFORM_VERSION}


ecr-docker-build:
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
	docker buildx build --platform linux/amd64,linux/arm64 -t ${TF_VAR_event_receive_image} -f event-receiver/Dockerfile event-receiver --push
	docker buildx build --platform linux/amd64,linux/arm64 -t ${TF_VAR_metabase_image} -f metabase/Dockerfile event-receiver --push


terraform-generate-certs:
	cd infra/terraform/keys && ./generate.sh

terraform-init:
	${TERRAFORM_BASE} \
	init

terraform-plan: terraform-init
	${TERRAFORM_BASE} \
	plan


terraform-create-dev: terraform-init terraform-create-network terraform-create-vpn-endpoint terraform-create-get-vpn-config terraform-create-ecr terraform-create-dataviz

terraform-create-all: terraform-init terraform-create-network terraform-create-vpn-endpoint terraform-create-msk terraform-create-data-crawlers terraform-write-outputs
	echo "All created"


terraform-create-network: terraform-init
	${TERRAFORM_BASE} \
	apply --auto-approve \
	--target=module.network

terraform-destroy-network: 
	${TERRAFORM_BASE} \
	destroy --auto-approve \
	--target=module.network

terraform-create-vpn-endpoint: terraform-init
	${TERRAFORM_BASE} \
	apply --auto-approve \
	--target=module.vpn_endpoint \
	--target=null_resource.get_vpn_endpoint_config

terraform-destroy-vpn-endpoint: 
	${TERRAFORM_BASE} \
	destroy --auto-approve \
	--target=module.vpn_endpoint \
	--target=null_resource.get_vpn_endpoint_config


terraform-create-get-vpn-config: terraform-init
	${TERRAFORM_BASE} \
	apply --auto-approve \
	--target=null_resource.get_vpn_endpoint_config

terraform-create-data-crawlers: terraform-init
	${TERRAFORM_BASE} \
	apply --auto-approve \
	--target=aws_glue_crawler.root

terraform-destroy-data-crawlers: terraform-init
	${TERRAFORM_BASE} \
	destroy --auto-approve \
	--target=aws_glue_crawler.root


terraform-create-msk: 
	${TERRAFORM_BASE} \
	apply --auto-approve \
	--target=module.msk_instance \
	--target=module.s3_connect-avro-to-parquet-example \
	--target=aws_glue_registry.example

terraform-create-msk-connect: 
	${TERRAFORM_BASE} \
	apply --auto-approve \
	--target=module.s3_connect-avro-to-parquet-example

terraform-create-ecr: terraform-init
	${TERRAFORM_BASE} \
	apply --auto-approve \
	--target=module.metabase_registry \
	--target=module.api_registry

terraform-destroy-ecr:
	${TERRAFORM_BASE} \
	destroy --auto-approve \
	--target=module.metabase_registry \
	--target=module.api_registry

terraform-create-api: terraform-init ecr-docker-build
	${TERRAFORM_BASE} \
	apply --auto-approve \
	--target=module.api

terraform-destroy-api:
	${TERRAFORM_BASE} \
	destroy --auto-approve \
	--target=module.api_registry

terraform-create-dataviz: terraform-init ecr-docker-build
	${TERRAFORM_BASE} \
	apply --auto-approve \
	--target=module.metabase

terraform-destroy-dataviz:
	${TERRAFORM_BASE} \
	destroy --auto-approve \
	--target=module.metabase

terraform-destroy-msk-connect: 
	${TERRAFORM_BASE} \
	destroy --auto-approve \
	--target=module.s3_connect-avro-to-parquet-example

terraform-create-ec2-test-instances:
	${TERRAFORM_BASE} \
	apply --auto-approve \
	--target=module.ec2_test_instances

terraform-destroy-all: terraform-init
	${TERRAFORM_BASE} \
	destroy --auto-approve

terraform-write-outputs:
	${TERRAFORM_BASE} \
		apply --auto-approve \
		--target=null_resource.write_outputs_to_file
	mv infra/terraform/env.cloud env.cloud