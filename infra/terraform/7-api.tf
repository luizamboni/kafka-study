resource "aws_ecs_cluster" "fargate_cluster" {
    name = local.name
    tags = local.tags
}


module "api_registry" {
    source = "./modules/ecr_repo"
    name = "seeds"
}

module "api" {
    source = "./modules/ecs_service"

    name = "event_receiver"
    image = var.event_receive_image
    cluster_id = aws_ecs_cluster.fargate_cluster.id
    subnet_ids = module.network.subnet_ids
    security_group_id = module.network.sg_id
    vpc_id = module.network.vpc_id
    internal = true
    container_port = 5000
    region = local.region
    environment_variables = {
       	AWS_REGION = local.region
		GLUE_SCHEMA_REGISTRY_NAME = local.registry_name
		KAFKA_BOOTSTRAP_URL = module.msk_instance.bootstrap_brokers_tls
		SECURITY_PROTOCOL =  "SSL"
		SCHEMA_REGISTRY_TYPE = "GLUE"
    }

    tags = local.tags

    depends_on = [
        module.api_registry
    ]
}