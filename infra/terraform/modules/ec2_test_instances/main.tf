data "aws_ami" "this" {
    most_recent = true
    owners = ["amazon"]
}

resource "aws_instance" "instances" {
    count         = length(var.subnet_ids)
    ami           = data.aws_ami.this.id
    instance_type = "t2.micro"

    subnet_id = element(var.subnet_ids, count.index)

    vpc_security_group_ids = [var.security_group_id]
    tags = {
        Name = "${var.name}-${count.index}"
    }
}