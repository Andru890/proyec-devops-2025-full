provider "mysql" {
  endpoint = "172.28.0.2:3307"  # Cambiar a la IP correcta y puerto
  username = "dev_user"
  password = "dev_password"
}

resource "mysql_database" "default" {
  name = "devops_db"
}

resource "mysql_user" "default" {
  user               = "dev_user"
  host               = "%"
  plaintext_password = "dev_password"
}

resource "mysql_grant" "default" {
  user       = mysql_user.default.user
  host       = mysql_user.default.host
  database   = mysql_database.default.name
  privileges = ["ALL"]
}
