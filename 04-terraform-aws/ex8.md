# Ejercicio 8 – Refactorizacion con modulo VPC

## Objetivo de la refactorizacion

En este ultimo ejercicio refactorizo la infraestructura pasando de un enfoque totalmente manual (`main.tf`) a un enfoque basado en modulos(`main2.tf`).

- [main.tf](code/main.tf): version inicial con toda la definicion de red manual.
- [main2.tf](code/main2.tf): version refactorizada con el modulo VPC.

## Que se ha refactorizado

En `main.tf` la red se creaba recurso a recurso:

- `aws_vpc`
- `aws_internet_gateway`
- `aws_subnet`
- `aws_route_table`
- `aws_route`
- `aws_route_table_association`

En `main2.tf` toda esa parte se sustituye por el modulo oficial:

```hcl
module "vpc" {
	source  = "terraform-aws-modules/vpc/aws"
	version = "5.8.1"

	name = "pac-vpc"
	cidr = "10.0.0.0/16"

	azs            = ["eu-west-3a"]
	public_subnets = ["10.0.1.0/24"]

	enable_dns_hostnames = true
	enable_nat_gateway   = false
	single_nat_gateway   = false
}
```

El resto de recursos se mantiene con la misma finalidad:

- Security Group (`aws_security_group.web_sg`)
- Key Pair (`aws_key_pair.pac_key`)
- AMI (`data.aws_ami.amazon_linux_2`)
- EC2 (`aws_instance.web_instance`)
- Output de IP publica (`output.web_instance_public_ip`)

## Ventajas obtenidas

1. Menos codigo que mantener: se elimina gran parte de la definicion manual de red.
2. Mejor legibilidad: el foco queda en la intencion (crear VPC publica) y no en tanto detalle repetitivo.
3. Estandarizacion: uso de un modulo ampliamente utilizado y probado en Terraform.
4. Escalabilidad: ampliar a varias subnets o AZs es mas directo modificando variables del modulo.
5. Mantenibilidad: cambios de red futuros se aplican en un bloque centralizado.

## Impacto funcional

A nivel funcional no cambia el objetivo final de la practica:

- Sigo desplegando una EC2 publica.
- Sigo accediendo por SSH con mi key pair.
- Sigo exponiendo HTTP en el puerto 80 para publicar NGINX.

Lo que cambia es la forma de definir la infraestructura, que pasa a ser mas limpia y facil de escalar.
