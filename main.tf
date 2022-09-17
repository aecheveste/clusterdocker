
# SELECCIONAR AL PRVOEDOR DE LA NUBE 
provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region     = "us-east-2"


}
#levanta una instancia en aws ubuntu 20.04
resource "aws_instance" "reverse-proxy" {
  instance_type = "t2.micro"
  ami           = "ami-0960ab670c8bb45f3"
  #nombre de la llave que de descargo de aws
  key_name  = "MRSI"
  user_data = filebase64("${path.module}/script/docker.sh")
  vpc_security_group_ids = [aws_security_group.WEB_SG.id]

}
resource "aws_security_group" "WEB_SG" {
  name = "sg_reglas_firewall"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG HTTPs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG SSH "
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {                                  #Reglas de firewall de salida
    cidr_blocks = ["0.0.0.0/0"]             #Se aplicará a todas las direcciones
    description = "SG All Traffic Outbound" #Descripción
    from_port   = 0                         #Del puerto
    to_port     = 0                         #Al puerto
    protocol    = "-1"                      #Protocolo
  }
  }
  
  output "public_ip" {
  value = "${join(",", aws_instance.reverse-proxy.*.public_ip)}"
}
