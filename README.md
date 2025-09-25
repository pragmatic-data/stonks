# STONKS! Project

Welcome to the sample project of the book presenting how to build the Pragmatic Data Platform with dbt and Snowflake.

## Sample project overview and analysis 

The [Sample_Project_Analysis](https://raw.githack.com/pragmatic-data/stonks/main/Sample_Project_Analysis.html) page 
provides a good starting point to understand the Stonks project. It provides:
- an introduction to the STONKS project
- a primer on the layers of the project, including their features and goals.
  The layer follow the standard of the Pragmatic Data Platform.
- a detailed folder-by-folder and mode-by-model analysis for the contents of the project

## Setting up the project

We split the process to get the full project setup in a few steps:

1. bootstrapping the dbt project
2. configuring environments and roles
3. creating the first users and granting them the project roles

### 1 - Bootstrapping the dbt project

Once you have all the pre-requisites in place, you can delve into creating the dbt project.

#### Pre-requisites

To get started you need:

- a Snowflake account.  
  Any edition works, and you can create one for free going at http://snowflake.com
  - a Snowflake user with access to at least `SYSADMIN` and `USERADMIN` roles .  
      This is the bare minimum to be able to create the users, roles and DBs for your project.
  - a Snowflake user with access to `SECURITYADMIN` role is needed to provide future grants to reader roles.  
      This could be done later or manually or totally bypassed by granting access to readers when running the dbt project.
  - a Snowflake warehouse accessible by that user, so that the SQL commands to do the setup can be run.
      The `COMPUTE_WH` warehouse used to exist by default, and you can create a new one with the UI
      or by running the commands in the Troubleshooting section at the end of this page.

- an account with a cloud git provider (like GitHub, GitLab, BitBucket or DevOps) where you can:
  - connect dbt Cloud application (you might need to have admin role in the git provider)
  - create a new repository for this new dbt project

- a dbt Cloud account where you can create a new project.  
  You can create a free account at https://www.getdbt.com/

### Creation of the dbt project

The goal of this step is to have a new dbt project set up with the default dbt sample project.  

To achieve that we will create a project, connect to Snowflake, to the empty git repository,
initialize it with the dbt sample project and do our first commit.

This will allow us to verify that the connections to the DB and git repository work,
by testing the ability to query the DB and to make commits from dbt Cloud with our development user.

Let's do the setup

1. **create a new repo** in your git cloud provider and **leave it empty**,  
   i.e. no README, LICENSE .gitignore or any other file.  
   This is needed to allow dbt Cloud to propose to initialise the project with
   the dbt sample project.
2. **setup a new dbt Cloud project** by configuring Snowflake and the git repo.  
   Go to dbt Cloud > Account Home, click the "new project" button and follow the guided steps:  
   1. Enter a project name, then press NEXT
   2. create a new connection (or pick an existing one if you know what you are doing):  
       select Snowflake and enter your correct account, then enter a DB and Warehouse.  
       Please note that the DB does not need to exist (yet).
   3. Enter the credentials to use in the development environment.  
       This is usually the user name and password of the user that you want to develop with,
       but if your development user does not fullfil the pre-requisites temporarily use one that can.  
       You can replace it with your "normal" development user unce the setup is done.  
       Test the connection to verify that the user can connect to Snowflake.
       Once the connection works, save and move to the selection of the git repository.
   4. Select your git provider (GitHub or GitLab) or Git Clone for other providers
       and select the repository from the list (or enter the URL fro Git Clone).
       We use GitHub as you can get a free plan and it has full integration with dbt Cloud.
       If you do not find the git provider user or organization in the drop-down you can go to
       your profile to set up the integration between dbt Cloud and GitHub,
       so that you will see the repository that you want to use.

Congratulations you now have a dbt Cloud project setup that can connect to your Snowflake account
and store your code in the selected git repository.
BUT you do not yet have nor a database nor the roles in place to deploy your project.

### 2 - Configuring environments and roles

In this step you will configure the databases and the roles to be used in your enviroments,
so that at the end you will be able to deploy your project.

In the dbt project creation step you have configured as your the user for your developmen
environemnt a user with a role with enough privileges to run the required commands. See
the Troubleshooting section for more details.

To have the environemnts and roles set up we need to gothrough these next steps:

1. Installl the SF Admin package and
   - duplicate the `project_initial_setup__sql` macro from the SF Admin project
     (in the folder `dbt_packages/sf_project_admin/integration_tests/macros`)
     to the macro folder of your project. We suggest to make a subdirectory with a name
     like `aaa_setup` to keep all the setup scripts together and on top of the list.
   - copy the variables from the package config file
     (`dbt_packages/sf_project_admin/integration_tests/dbt_project.yml`)
     in your project config file (`dbt_project.yml`)
2. Edit the `project_initial_setup__sql` macro and/or the variables in the `dbt_project`
   config file to provide the three mandatory configurations: project name,
   list of enviroment short names and role that will own the project's resources.  
   By editing the variable and script you can alter the desired setup to fit your needs.
3. You can verify the generated SQL by opening a new model, pasting the code to render
   the SQL from the macro `{{ project_initial_setup__sql() }}` and clicking compile.
4. Once you are happy with the generated SQL you can run the SQL as a run operation
   with the command `dbt run-operation run_project_setup`.

At this point you have your project in place with one DB for each environemnt,
one warehouse for all environments or one for each -depending on your config-,
one writer and one reader role for each environment, and the three high level
roles of DBT_EXECUTOR, DEVELOPER and READER that you can assign to users.
All these resources and roles are under the role that you have designated as OWNER
of the project resources and that has potentially been also created by the setup script.

### 3 - Creating the first users and granting them the project roles

In this step we need at minimum to set up the user that dbt will use to execute the code (in all environments,
with one specific writer role for each environment) and define the initial mappings
of users to the other two default high level roles: developers and readers.

1. To get a good head-start duplicate the `manage_users` macro from the SF Admin package
   into your macro folder (we suggest placing it under a `aaa_setup` subfolder or something similar).
   You can find it in `dbt_packages/sf_project_admin/integration_tests/macros/manage_users.sql`

2. Edit the role user mapping in YAML
   - pick a name for the dbt executor user.
     You can use an already existing user
3. Edit the macro to decide what functionalities to enable

// TODO - SF Admin package

1. add PRG and ENVs variables to the CFG
2. set the script vars from the variables
    dbt_packages/sf_project_admin/integration_tests/macros/
    - sample_prj__create_project
    - sample_prj__manage_users
    - sample_prj__mart_access
    - cross_project_access

### Troubleshooting

This section lists a few details that might be needed to plan the details or troubleshoot the setup process.

#### Installing the SF ADmin package

To install a package you add its URL and version/revision to the `packages.yml` config file
in the root of your project. If the file does not exist, you can create it.

To install the SF Admin package in your project the file should contain the following:

```yaml
    packages:        
        # Pragmatic Data Platform - Snowflake Admin package
        - git: "https://github.com/pragmatic-data/sf-admin.git"
            revision: main
```

#### Details of the user to run the setup scripts

For the botstrap phase we need a user able to:

- run `create user` and `create role` commands (`USERADMIN`),
- run `create database` and `create warehouse` commands (`SYSADMIN`) and
- possibly also to grant future grants (`SECURITYADMIN` or a role with `MANAGE GRANTS` privilege)

At point 3, an alternative to setting a user with very powerful role like `SECURITYADMIN` as the
development user of the person that will do the set up, you could create a deployment environment
that executes using such powerful user and run the set up scripts in that environment.
To run the scripts you will need forst to edit them in the development environment and then
release the scripts to the "special" setup environment so that they can be run.
In a way that is cleaner as all run will be audited, but the ability to run scripts as the powerful user
is then available to all developers that can run jobs in such environemnt.
This is the main reason why our suggestion is to set a powerful user for the developer doing the setup
and then replace it with the normal development user. This is akin to impersonating `super user`
or logging into a DB with the `admin` user for some task and then going back to the normal user.

If you want to segregate the setup operations from the FULL pool of developers a valid alternative,
especially in bigger organizations where in bigger teams it makes sense that not all developers
have administrative roles, is to have a specific dbt project dedicated to building up and maintaining
the other dbt projects.
In this way the access to that Admin project can be limited only to the developers with the knowledge
and ability to manage the environments, roles and users.
This setup would still align with the DevOps mantra of ability along with responsibility if every team
has someone with the ability to perform the setup / maintenance needs of the team.

##### Creation of a new warehouse

If you do not have any warehouse, you can create one if you have access to the `SYSADMIN` role.

```sql
        USE ROLE SYSADMIN;      -- or the role used for setup, if it can create warehouses

        CREATE OR REPLACE WAREHOUSE wh_name WITH
            WAREHOUSE_SIZE = XSMALL 
            AUTO_SUSPEND = 120                -- 120 seconds = 2 min (min 1 min)
            AUTO_RESUME = TRUE
            INITIALLY_SUSPENDED = TRUE
            COMMENT = 'Initial warehouse to run interactive and setup commands.'
        ;

        GRANT USAGE ON WAREHOUSE wh_name TO ROLE role_used_for_setup;  -- if the setup role needs it
```

Please make sure that the user that you will configure to do the setup will be able to use the warehouse.
You can do it by granting to the role used for the setup by that user, but because that user will
most probably have access to the `SYSADMIN` role the granting might not be needed.

#### Assigning future grants to reader roles

```sql
USE ROLE {{future_grants_role}};

GRANT USAGE ON FUTURE SCHEMAS IN DATABASE {{db_name}} TO ROLE {{reader_role_name}};
GRANT SELECT ON FUTURE TABLES IN DATABASE {{db_name}} TO ROLE {{reader_role_name}};
GRANT SELECT ON FUTURE VIEWS IN DATABASE {{db_name}} TO ROLE {{reader_role_name}};
```

## Resources

- Snowflake web site (to create a free trial account): <https://www.snowflake.com/>
- dbt-Labs web site (to create a free Developer account): <https://www.getdbt.com/>
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [dbt community](https://getdbt.com/community) to learn from other analytics engineers
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
