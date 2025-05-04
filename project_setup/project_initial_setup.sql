{% macro run_project_setup() -%}{% if execute and flags.WHICH in ('run', 'build', 'run-operation') %}
    {% do log("Run project setup", info=True) %}
    {% do run_query(project_initial_setup__sql()) %}
    {% do log("DONE - Run project setup ", info=True) %}
{% endif %}{%- endmacro %}


{% macro project_initial_setup__sql() -%}{% if execute and flags.WHICH in ('run', 'build', 'run-operation', 'compile') %}

    {# --- MANDATORY CONFIGS --- #}
    {%- set prj_name = var('project_short_name') -%}
    {%- set environments = var('environments') -%}
    {%- set owner_role = var('owner_role') -%}

    {#---- CONFIGS YOU MIGHT WANT TO LIVE WITH THE DEFAULTS #}
    {%- set creator_role = var('creator_role') -%}
    {%- set useradmin_role = var('useradmin_role') -%}

        {# --- IF it does not already exist, create the role to OWN the project resources or use an existing role, like SYSADMIN --- #}
        {{ sf_project_admin.create_role( 
                owner_role,
                comment = 'Sysadmin like role that will own for the resources of the STONKS project.',
                parent_role = 'SYSADMIN',
                useradmin_role = useradmin_role
        ) }}    

    /* == Create ONE WAREHOUSE for ALL envs => pass NO env name or pass/set single_WH to true == */
    {{- sf_project_admin.create_warehouse(prj_name, single_WH = true) }}

    /* == Create ALL environments, one at a time == */
    {%- for env_name in environments %}
        {{ sf_project_admin.create_environment(prj_name, env_name, owner_role, creator_role, useradmin_role, 'SECURITYADMIN', single_WH = true) }}
        {#{ sf_project_admin.grant_shared_wh_to_writer_role(prj_name, env_name, owner_role = 'SYSADMIN' )}#}
    {%- endfor %}


    /* == Setup ORGANIZATIONAL ROLES == */
    {{ sf_project_admin.setup_default_org_roles(prj_name, environments, owner_role, useradmin_role) }}

    /* == TO Create and Setup USERS => go to sample_prj__manage_users and run refresh_user_roles___XXXX_project()  == */

{% endif %}{%- endmacro %}