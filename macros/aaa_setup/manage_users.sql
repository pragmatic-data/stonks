{% macro get_STONKS_user_dictionary() %}

/* *** User setup config dictionary *** 
 * This file is used to:
 * - define the name of the DBT executor user to be created
 * - assign SF users to the default roles (Developer or Reader) (the can also be created)
 * - assign SF users to any other existing role
 * - delete SF users that are not needed anymore
 */

{% set users_dict_yaml -%}

dbt_executor: STONKS_DBT_EXECUTOR

developers:
 - ROBERTO_ZAGNI_ADMIN          # high privilege user for interactive access and to run the "Snowflake Admin" project 
 - ROBERTO_ZAGNI_DEVELOPER      # limited privilege user for normal project development tasks
 - USER@COMPANY.COM
 - NAME.SURNAME@COMPANY.COM


readers:
  - POWERBI_READER

users_to_delete:
  - SOME_USER_NAME_TO_DROP
#  - OTHER_USER_NAME_TO_DROP

SOME_ROLE:                      # An EXISTING role to be assigned to the list of users
 - ROBERTO_ZAGNI_DEVELOPER

AI_TEAM_ROLE:
 - AI_GUY@COMPANY.COM
 - AI_TEAM_SERVICE_USER

FINANCE_TEAM_ROLE:
 - FINANCE_GUY@COMPANY.COM

{%- endset %}

{% do return(fromyaml(users_dict_yaml)) %}

{%- endmacro %}

/* == Macro to run the user update as a dbt run-operation == */
{% macro refresh_user_roles___STONKS_project() -%}{% if execute and flags.WHICH in ('run', 'build', 'run-operation') %}
    
    {%- set prj_name = var('project_short_name', 'STONKS') -%}
    {% set useradmin_role = var('useradmin_role', 'USERADMIN') %}
    
    {% do log("Refreshing user roles for "~prj_name~" project ", info=True) %}
    {% do run_query( 
        sf_project_admin.refresh_user_roles( 
            prj_name, 
            get_STONKS_user_dictionary(), 
            useradmin_role
        ) 
    ) %}
    {% do log("Refreshed user roles for "~prj_name~" project ", info=True) %}

{% endif %}{%- endmacro %}

/* == Macro to run the dbt user creation as a dbt run-operation IF you do not run the full user creation == */
{% macro create_dbt_executor_user___STONKS_project() -%}{% if execute and flags.WHICH in ('run', 'build', 'run-operation') %}
    
    {%- set prj_name = var('project_short_name', 'STONKS') -%}
    {%- set useradmin_role = var('useradmin_role', 'USERADMIN') -%}

    {% do log("Refreshing user roles for "~prj_name~" project ", info=True) %}
    /** CREATE dbt Executor User */ 
    {% do run_query( 
        sf_project_admin.create_dbt_executor_user(
            prj_name = prj_name,
            user_name = get_STONKS_user_dictionary().dbt_executor,
            useradmin_role = useradmin_role
        )
    ) %}

    {% do log("Refreshed user roles for "~prj_name~" project ", info=True) %}
{% endif %}{%- endmacro %}

/* == Macro to run the user update as a dbt run-operation == */
{% macro create_users___STONKS_project() -%}{% if execute and flags.WHICH in ('run', 'build', 'run-operation') %}
    
    {%- set prj_name = var('project_short_name', 'STONKS') -%}
    {%- set useradmin_role = var('useradmin_role', 'USERADMIN') -%}

    {% do log("Creating users for "~prj_name~" project ", info=True) %}
    /* Create users listed in the YAML definition */
    {% do run_query(
        sf_project_admin.create_users_from_dictionary(
            prj_name, get_STONKS_user_dictionary(), useradmin_role
        )
    ) %}
    {% do log("Created users for "~prj_name~" project ", info=True) %}

{% endif %}{%- endmacro %}

/* == Macro to run the user CREATION as a dbt run-operation == */
{% macro drop_users___STONKS_project() -%}{% if execute and flags.WHICH in ('run', 'build', 'run-operation') %}

    {%- set useradmin_role = var('useradmin_role', 'USERADMIN') -%}

    /* Drop users listed for deletion  */
    {% do log("Dropping users marked for deletion for "~prj_name~" project ", info=True) %}
    {% do run_query(
        sf_project_admin.drop_users(get_STONKS_user_dictionary().users_to_delete, useradmin_role)
    ) %}
    {% do log("Dropped users marked for deletion for "~prj_name~" project ", info=True) %}

{% endif %}{%- endmacro %}
