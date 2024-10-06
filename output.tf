# output "vpc_id" {
#   value = aws_vpc.demo_vpc.id
# }

resource "local_file" "ssh_key" {
  filename = "${path.module}/key_pair/${aws_key_pair.my-key-pair.key_name}.pem"
  content  = tls_private_key.private-key.private_key_pem
}

resource "local_file" "server_ip" {
  count    = 2
  filename = "${path.module}/Ansible/inventory.ini"
  content  = join("\n", aws_instance.web.*.public_ip)
}