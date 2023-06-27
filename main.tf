#RabiitMQ Instance add as it doesnt support cluster /service implementation.
# Hence we are going to add ec2 instance.

resource "aws_spot_instance_request" "rabbitmq" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  subnet_id = var.subnet_ids[0]
  wait_for_fulfillment = true

  tags = merge(
    var.tags,
    { Name = "${var.env}-rabbitmq" }
  )
}

resource "aws_ec2_tag" "rabitmqtag" {
    resource_id = aws_spot_instance_request.rabbitmq.spot_instance_id
    key = "Name"
    value = "${var.env}-rabbitmq"
  
}