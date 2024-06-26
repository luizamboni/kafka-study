module "ec2_test_instances" {
    source = "./modules/ec2_test_instances"

    subnet_ids = module.network.subnet_ids
    security_group_id = module.network.sg_id
    name = "endpoint connectivity test instance"
}