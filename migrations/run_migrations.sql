-- Adding a migration macro:
-- {#% do run_migration('V003_drop_table', database, schema_prefix) %#}
-- !! Remove the # from the above lines and change the string with the macro name!!

-- How to report there are no migrations to run
-- {#% do log("No migrations to run.", info=True) %#}

{% macro run_migrations(
        database = target.database,
        schema_prefix = target.schema
) -%}

{#
{% do run_migration('V004_alter_storage_ib_schema', database, schema_prefix) %}
#}
{% do log("No migrations to run.", info=True) %}


{%- endmacro %}


/**
 * == Helper macro ==
 * It that takes the name of the macro to be run, db and schema and runs it with logs.
 * It uses the context to get the function object from its name
 */
{% macro run_migration(
        migration_name, 
        database = target.database,
        schema_prefix = target.schema
    ) %}
{% if execute %}    
    {% do log(" * Running " ~ migration_name ~ " migration with database = " 
            ~ database ~ ", schema_prefix = " ~ schema_prefix, info=True) %}

    {% set migration_macro = context.get(migration_name, none) %}
    {% do run_query(migration_macro(database, schema_prefix)) if migration_macro 
          else log("!! Macro " ~ migration_name ~ " not found. Skipping call.", info=True) %}
{% endif %}    
{% endmacro %}
