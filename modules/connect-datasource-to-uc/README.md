# Connect Datasource to Universal Connector Module

This module connects a datasource to Guardium Universal Connector by uploading CSV configuration files to the Guardium server.

## Features


- **Secure File Transfer**: Uses SSH to securely transfer configuration files to Guardium server
- **Automatic Cleanup**: Removes CSV files on destroy
- **Profile Import**: Automatically imports profiles to Guardium
- **Connector Installation**: Installs and configures the Universal Connector

## Usage

```hcl
module "connect_datasource" {
  source = "../../modules/connect-datasource-to-uc"
  
  # Universal Connector Configuration
  udc_name       = "my-datasource-connector"
  udc_csv_parsed = local.csv_content
  
  # Log Directory (optional, defaults to /var/log/guardium)
  log_directory = "/var/log/guardium"  # or leave empty for default
  
  # Guardium Server Configuration
  gdp_server             = "guardium.example.com"
  gdp_port               = "8443"
  gdp_username           = "admin"
  gdp_password           = var.gdp_password
  gdp_ssh_username       = "root"
  gdp_ssh_privatekeypath = "/path/to/private/key"
  gdp_mu_host            = "default"
  
  # OAuth Configuration
  client_id     = "client1"
  client_secret = var.client_secret
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| udc_name | Universal Data Collector name | string | "" | yes |
| udc_csv_parsed | The parsed CSV profile content | string | n/a | yes |
| log_directory | Directory path for CSV files on Guardium server | string | "" | no |
| gdp_server | Guardium server hostname or IP | string | n/a | yes |
| gdp_port | Guardium server port | string | "8443" | no |
| gdp_username | Guardium username | string | n/a | yes |
| gdp_password | Guardium password | string | n/a | yes |
| gdp_ssh_username | SSH username for Guardium server | string | n/a | yes |
| gdp_ssh_privatekeypath | Path to SSH private key | string | n/a | yes |
| gdp_mu_host | Comma-separated list of Managed Units | string | "" | no |
| client_id | OAuth client ID | string | n/a | yes |
| client_secret | OAuth client secret | string | n/a | yes |

## Log Directory Behavior

- If `log_directory` is not specified or is empty, defaults to `/var/log/guardium`
- The directory must exist on the Guardium server and be writable by the SSH user
- Common options:
  - `/var/log/guardium` - Default, typically accessible to customers
  - `/opt/guardium/logs` - Alternative location
  - Custom path as needed for your environment
