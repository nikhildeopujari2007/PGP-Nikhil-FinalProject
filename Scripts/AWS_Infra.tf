terraform {
  required_providers {
    aws = {
           source  = "hashicorp/aws"
           version = "~>4.0"
           }
         }
}
 
provider "aws" {
   region = "us-east-1"
  shared_credentials_files =  ["~/.aws/credentials"]
}
 
resource "aws_vpc" "pgp-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
  Name = "pgp-vpc"
}
}
 
resource "aws_subnet" "subnet-1" {
   vpc_id            = aws_vpc.pgp-vpc.id
   cidr_block        = "10.0.1.0/24"
   map_public_ip_on_launch = true
   depends_on = [aws_vpc.pgp-vpc]
   tags = {
     Name = "pgp-subnet"
   }
}
 
resource "aws_route_table" "pgp-route-table" {
vpc_id = aws_vpc.pgp-vpc.id
tags = {
     Name = "pgp-route-table"
   }
}
 
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.pgp-route-table.id
}
 
resource "aws_internet_gateway" "gw" {
vpc_id = aws_vpc.pgp-vpc.id
depends_on = [aws_vpc.pgp-vpc]
}
 
resource "aws_route" "pgp-route" {
route_table_id = aws_route_table.pgp-route-table.id
destination_cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.gw.id
}
resource "aws_security_group" "allow_web" {
   name        = "allow_web_traffic"
   description = "Allow Web inbound traffic"
     vpc_id      = aws_vpc.pgp-vpc.id
ingress {
     description = "HTTPS"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
}
ingress {
     description = "HTTP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }
   egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }
 
   tags = {
     Name = "allow_web"
   }
}
# create a private key that will be used to loginto website
 
resource "tls_private_key" "web-key" {
algorithm = "RSA"
}
 
resource "aws_key_pair" "web-key-pair" {
 
key_name = "web-key"
public_key = tls_private_key.web-key.public_key_openssh
 
provisioner "local-exec" {
command = "echo '${tls_private_key.web-key.private_key_openssh}' > ./web-key.pem"
}
 
}
 
# save the key to local
 
#resource local_file "web-key" {
 
# content = tls_private_key.web-key.private_key_pem
# filename = "web-key.pem"
#}
 
resource "aws_instance" "jenkin-master" {
  ami           = "ami-0e2c8caa4b6378d8c"
  instance_type = "t2.micro"
  count = 1
  tags = {
    Name = "Jenkin-Master"
  }
  subnet_id = aws_subnet.subnet-1.id
  key_name = "web-key"
  security_groups = [aws_security_group.allow_web.id]
 
  connection {
     type = "ssh"
     user = "ubuntu"
     private_key = tls_private_key.web-key.private_key_pem
     host = self.public_ip
  }
 
  # copy the install_softwares.sh file from your computer to the ec2 instance
  provisioner "file" {
    source      = "install_softwares.sh"
    destination = "/tmp/install_softwares.sh"
  }
  
  

  # set permissions and run the install_softwares.sh file

  provisioner "remote-exec" {

    inline = [

      "sudo chmod +x /tmp/install_softwares.sh",

      "sh /tmp/install_softwares.sh Jenkin-Master",

    ]

  }

}
 
resource "aws_instance" "PGP-Agents-Tools" {

  ami           = "ami-0e2c8caa4b6378d8c"

  instance_type = "t2.micro"

  count = 1

  tags = {

    Name = "PGP-Agents-Tools"

  }

  subnet_id = aws_subnet.subnet-1.id

  key_name = "web-key"

  security_groups = [aws_security_group.allow_web.id]
 
  connection {

     type = "ssh"

     user = "ubuntu"

     private_key = tls_private_key.web-key.private_key_pem

     host = self.public_ip

  }
 
  # copy the install_softwares.sh file from your computer to the ec2 instance

  provisioner "file" {

    source      = "install_softwares.sh"

    destination = "/tmp/install_softwares.sh"

  }
 
  # set permissions and run the install_softwares.sh file

  provisioner "remote-exec" {

    inline = [

      "sudo chmod +x /tmp/install_softwares.sh",

      "sh /tmp/install_softwares.sh PGP-Agents-Tools",

    ]

  }

}
 resource "aws_instance" "PGP-Monitoring" {
  ami           = "ami-0e2c8caa4b6378d8c"
  instance_type = "t2.micro"
  count = 1
  tags = {
    Name = "PGP-Monitoring"
  }
  subnet_id = aws_subnet.subnet-1.id
  key_name = "web-key"
  security_groups = [aws_security_group.allow_web.id]
 
  connection {
     type = "ssh"
     user = "ubuntu"
     private_key = tls_private_key.web-key.private_key_pem
     host = self.public_ip
  }
 
  # copy the install_softwares.sh file from your computer to the ec2 instance
  provisioner "file" {
    source      = "install_softwares.sh"
    destination = "/tmp/install_softwares.sh"
  }
 
  # set permissions and run the install_softwares.sh file
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/install_softwares.sh",
      "sh /tmp/install_softwares.sh PGP-Monitoring",
    ]
  }
}