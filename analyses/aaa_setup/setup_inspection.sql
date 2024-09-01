{%- set prj_name = var('project_short_name', 'STONKS') -%}
{%- set useradmin_role = var('useradmin_role', 'USERADMIN') -%}

------------
{{ project_initial_setup__sql() }}
------------
{#{ sf_project_admin.create_dbt_executor_user(
        prj_name = prj_name,
        user_name = get_STONKS_user_dictionary().dbt_executor,
        useradmin_role = useradmin_role
) }#}
------------
{{ sf_project_admin.create_users_from_dictionary(
        prj_name, get_STONKS_user_dictionary(), useradmin_role
) }}
------------
{{ sf_project_admin.refresh_user_roles( 
        prj_name, 
        get_STONKS_user_dictionary(), 
        useradmin_role
)  }}
------------
{#{ sf_project_admin.drop_users(
        get_STONKS_user_dictionary().users_to_delete, useradmin_role
) }#}
