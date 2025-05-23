/**
 * This file contains the SQL generated by compiling the refresh_user_roles(...) macro.
 *
 * The code to compile is:
{#
    {%- set prj_name = var('project_short_name') -%}
    {% set useradmin_role = var('useradmin_role') %}

    {{ sf_project_admin.refresh_user_roles( 
            prj_name, 
            get_STONKS_user_dictionary(), 
            useradmin_role
    ) }}
#}
*/

/** Set defaults if params not passed */ 
    
        
    /** Collect special role names based on the project name */

    /** ASSIGN the ORG ROLES to the configured USERS **/ 
    USE ROLE USERADMIN;

    GRANT ROLE STONKS_DBT_EXECUTOR_ROLE TO USER "STONKS_DBT_EXECUTOR";

    
      GRANT ROLE STONKS_DEVELOPER TO USER "ROBDBTZAG";
      GRANT ROLE STONKS_DEVELOPER TO USER "ROBERTO_ZAGNI_ADMIN";
      GRANT ROLE STONKS_DEVELOPER TO USER "ROBERTO_ZAGNI_DEVELOPER";

    
      GRANT ROLE STONKS_READER TO USER "STONKS_READER";

    /** ASSIGN all other ROLES to the listed USERS **/ 