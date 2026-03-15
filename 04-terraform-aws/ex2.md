# Ejercicio 2 – Creación de una Subnet con acceso a Internet

## Creación de la Subnet

El bloque CIDR `10.0.1.0/24` permite dividir la red de la VPC en una subred más pequeña.

El parámetro `map_public_ip_on_launch = true` permite que las instancias lanzadas dentro de esta subnet reciban automáticamente una **IP pública**.

```hcl
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.pac_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "pac-public-subnet"
  }
}
```

## Creación de la Route Table

Creamos una tabla de rutas para la VPC que hemos creado anteriormente.

```hcl
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.pac_vpc.id

  tags = {
    Name = "pac-public-rt"
  }
}
```

## Creación de la ruta hacia Internet

Se define una ruta que redirige todo el tráfico (`0.0.0.0/0`) hacia el Internet Gateway.

```hcl
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
```

## Asociación de la Route Table con la Subnet

Para que la subnet utilice la tabla de rutas creada anteriormente, se debe asociar la tabla de rutas con la subnet.

```hcl
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
```

## Ejecución de Terraform

Se ejecuta primero el plan para revisar los cambios que Terraform aplicará.

```bash
terraform plan
```
Output recibido:

```
# aws_route.internet_access will be created
  + resource "aws_route" "internet_access" {
      + destination_cidr_block = "0.0.0.0/0"
      + gateway_id             = "igw-0288d8e12ab62e536"
      + id                     = (known after apply)
      + instance_id            = (known after apply)
      + instance_owner_id      = (known after apply)
      + network_interface_id   = (known after apply)
      + origin                 = (known after apply)
      + region                 = "eu-west-3"
      + route_table_id         = (known after apply)
      + state                  = (known after apply)
    }

  # aws_route_table.public_rt will be created
  + resource "aws_route_table" "public_rt" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + region           = "eu-west-3"
      + route            = (known after apply)
      + tags             = {
          + "Name" = "pac-public-rt"
        }
      + tags_all         = {
          + "Name" = "pac-public-rt"
        }
      + vpc_id           = "vpc-0a4269ffa44bca0e2"
    }

  # aws_route_table_association.public_assoc will be created
  + resource "aws_route_table_association" "public_assoc" {
      + id             = (known after apply)
      + region         = "eu-west-3"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # aws_subnet.public_subnet will be created
  + resource "aws_subnet" "public_subnet" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = (known after apply)
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block                                = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "eu-west-3"
      + tags                                           = {
          + "Name" = "pac-public-subnet"
        }
      + tags_all                                       = {
          + "Name" = "pac-public-subnet"
        }
      + vpc_id                                         = "vpc-0a4269ffa44bca0e2"
    }

Plan: 4 to add, 0 to change, 0 to destroy.
```

Posteriormente se aplican los cambios para crear los recursos en AWS.

```bash
terraform apply
```

Output recibido:

```
aws_route_table.public_rt: Creating...
aws_subnet.public_subnet: Creating...
aws_route_table.public_rt: Creation complete after 2s [id=rtb-09e9b5a5ec321d676]
aws_route.internet_access: Creating...
aws_route.internet_access: Creation complete after 2s [id=r-rtb-09e9b5a5ec321d6761080289494]
aws_subnet.public_subnet: Still creating... [00m10s elapsed]
aws_subnet.public_subnet: Creation complete after 13s [id=subnet-02ccd47cb3b018f09]
aws_route_table_association.public_assoc: Creating...
aws_route_table_association.public_assoc: Creation complete after 1s [id=rtbassoc-04c7ed937d5352d0d]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

## Verificación de la creación de la Subnet

Verificamos en la consola de AWS que la Subnet se ha creado correctamente:

![Subnet creada](img/subnet.png)

