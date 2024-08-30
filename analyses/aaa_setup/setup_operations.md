## Set up of this project
This file recaps how to do setup and user maintenance operations for the STONKS project

### Initial environemnt creation
To create the dBs for the environemnts and the role structure run:
- `dbt run-operation run_project_setup`

This needs to be done only once, but running it multiple time will not throw exceptions or cause problems.
In the event that config variables (project and environment names) have been changed or added the there might 
be new objects created.

### User and role configuration
To create the users and setup their mapping to the roles run the commands the suit your needs from the following list.

#### User creation from the YAML configuration
- `dbt run-operation create_users___STONKS_project`  
  You run this command if you want to create the users listed in the role mapping config in `manage_users.sql` file.  
  In the STONKS project we have decided to use SF Admin to create the users, so we run this script.

#### Dbt executor user creation from the YAML configuration
- `dbt run-operation create_dbt_executor_user___STONKS_project`  
  You run this command if you want to create ONLY the dbt executor user from the name in the role mapping config in `manage_users.sql` file.  
  In the STONKS project we have decided to use SF Admin to create the users, so we DO NOT run this script,
  even if running it would make no harm as it would try to recreate an existing userd, doing nothing.

#### Grant roles to users according to the YAML configuration
- `dbt run-operation refresh_user_roles___STONKS_project`
  You always run this command to refresh the user to role mapping from the config in `manage_users.sql` file after every change.  
  Please remember that the current implementation is ADDITIVE: it grants the roles to the configured users, 
  it does not revoke any role from any user, so if you remove a user from a role and run this the role she had
  will not be revoked. This might be an improvement for the future.

#### User deletion from the YAML configuration
- `dbt run-operation drop_users___STONKS_project`
  You run this command if you want to drop the the users listed for deletion in the role mapping config in `manage_users.sql` file.  
  In the STONKS project we have decided to use SF Admin to create the users, so we will run this script 
  when we start to have users to delete.

#### User and role configuration refresh
Once the project has been initialized some operations like the creation of the dbt executor are not needded anymore,
so you can chose to run only the commands that make sense according to the changes that you do in the YAML configuration.

### Troubleshooting
You can use the `setup_inspection.sql` file to preview the commands that will be executed by the run operations.
Configure what code you want by commenting and uncommenting the sections.

