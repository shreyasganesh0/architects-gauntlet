# Terraform Configuration Language

## Syntax
<BLOCK TYPE> "<BLOCK_LABEL>"<"BLOCK_LABEL>" {

    <IDENTIFIER> = <EXPRESSION> //this is an argument
}

- blocks represent config of some object
    - they have a block type
    - optional block labels
    - body with arguments and nested blocks
- arguments value to name
- epxression represent a value 
    - referencing or combing other values
    - can be nested
- declarative describing the goal not the steps
- considers implicit and explicit relationships betwewen resource
  to determine order of operations
- Terraform block
    - usually kept in a seperate terraform.tf file
    - specifies the version of terraform and providers
        - providers are plugins used to manage resoucre
        - used typically for per cloud provider resource parsing
