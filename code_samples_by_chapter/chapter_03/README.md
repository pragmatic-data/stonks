# Materials for Chapter 3

This folder contains code samples and other materials for Chapter 3 of the book 
"Building a Pragmatic Data Platform with dbt and Snowflake" by Roberto Zagni and Jakob Brandel.

## Code samples
In this folder and its sub folders you find code samples related to the contents of the Chapter.

Under the `sample_project` folder you find the relevant files from the sample project 
as discussed during this chapter and organized as if that folder was the project root folder.

Notable contents of `code_samples_by_chapter/chapter_03/` folder:

* sample_project/models/example__v1
  In this folder there is the sample dbt project at its starting point.
  You can use this at the beginning of the section `The release process` in chapter_03. 

* sample_project/dbt_project.yml
  Changes in the macro-paths config.

## Useful links
The following links are related to the contents of this Chapter.

### dbt
* dbt_project configuration file:
  https://docs.getdbt.com/reference/dbt_project.yml

* Custom schemas:  
  https://docs.getdbt.com/docs/build/custom-schemas  
  https://docs.getdbt.com/reference/resource-configs/schema

* Model specific configurations: 
  https://docs.getdbt.com/reference/model-configs

* Using a Custom branch in development or deployment environemnts
  https://docs.getdbt.com/faqs/Environments/custom-branch-settings

* Environemnts and Staging setup
  https://docs.getdbt.com/docs/deploy/deploy-environments#staging-environment
  
* Ref() and relation object
  -	https://docs.getdbt.com/reference/dbt-jinja-functions/ref
  -	https://docs.getdbt.com/reference/dbt-classes#relation

* Node selection syntax
  https://docs.getdbt.com/reference/node-selection/syntax

* Run-operation
  https://docs.getdbt.com/reference/commands/run-operation

----
### &#169;  Copyright 2025 Roberto Zagni, Jakob Brandel.
   All right reserved.
