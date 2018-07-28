resource "google_sql_database_instance" "mysql-master" {
  database_version = "MYSQL_5_7"
  region           = "us-central1"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
    ip_configuration {
      authorized_networks = [
        {
          name = "concourse"
          value = "104.196.254.104"
        },
        {
          name = "pivotal"
          value = "209.234.137.222/32"
        }
      ]
    }
  }
}

resource "google_sql_database" "mysql" {
  instance  = "${google_sql_database_instance.mysql-master.name}"
  name      = "bosh_director"
}

resource "google_sql_user" "mysql" {
  instance = "${google_sql_database_instance.mysql-master.name}"
  name     = "root"
  password = "${random_string.password.result}"
}

output "gcp_mysql_endpoint" {
  value = "${google_sql_database_instance.mysql-master.first_ip_address}"
}

output "gcp_mysql_instance_name" {
  value = "${google_sql_database_instance.mysql-master.name}"
}
