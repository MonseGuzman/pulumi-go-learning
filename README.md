## Pulumin with Go and Azure

Concepts

* Pulumi.yaml --> defines current project (runtime to use and determines where to look for the program that should be executed)
* Pulumi.dev.yaml --> configuration of the stacks (in this case, it will be 'dev')

1. Create a new project

``` pulumi new <project_name> ```

2. Configure azure region (Optional)

``` pulumi config set azure-native:location <az region> ```

3. Review the changes

```pulumi review ```

4. Deploy the application

``` pulumi up --yes ``` 

5. Destroy the application

```pulumi destroy --yes ```

**NOTES:**

I'm not sure if you need to do a >az login< but do it

Example: https://www.pulumi.com/docs/get-started/azure/begin/

