variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  count         = var.instance_count

  tags = {
    Name        = "web-server-${count.index}"
    Environment = var.environment
  }
}

output "instance_ids" {
  value = aws_instance.web[*].id
}
