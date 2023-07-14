#RabiitMQ Instance add as it doesnt support cluster /service implementation.
# Hence we are going to add ec2 instance.

resource "aws_instance" "rabbitmq" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  subnet_id = var.subnet_ids[0]
  /* wait_for_fulfillment = true */

  vpc_security_group_ids = [aws_security_group.main.id]
  iam_instance_profile   = aws_iam_instance_profile.main.name

    # OPITON - B other approch is
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    component = var.component
    env = var.env
  } ))

  tags = merge(
    var.tags,
    { Name = "${var.env}-rabbitmq" }
  )
}

/* resource "aws_ec2_tag" "rabitmqtag" {
    resource_id = aws_spot_instance_request.rabbitmq.spot_instance_id
    key = "Name"
    value = "${var.env}-rabbitmq"
  
} */

resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "rabbitmq-${var.env}.${var.dns_domain}"
  type    = "A"
  ttl     = 30
  records = [aws_instance.rabbitmq.private_ip]
}

resource "aws_security_group" "main" {
  name        = "rabbitmq-${var.env}"
  description = "rabbitmq-${var.env}"
  vpc_id      = var.vpc_id

  ingress {
    description = "RABBITMQ"
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = var.allow_subnets
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    var.tags,
    { Name = "rabbitmq-${var.env}" }
  )
}
