## Pulumin with Go and Azure

[![Status](https://github.com/MonseGuzman/pulumi-go-learning/actions/workflows/github-pipeline.yml/badge.svg?branch=main)](https://github.com/MonseGuzman/pulumi-go-learning/actions/workflows/github-pipeline.yml)

Concepts

* Pulumi.yaml --> defines current project (runtime to use and determines where to look for the program that should be executed)
* Pulumi.dev.yaml --> configuration of the stacks (in this case, it will be 'dev')

1. Create a new project

``` pulumi new azure-go -n <project_name> -s <stack_name> -y```

2. Configure azure region (Optional)

``` pulumi config set azure-native:location <az region> ```

3. Review the changes

```pulumi preview ```

4. Deploy the application

``` pulumi up --yes ``` 

5. Destroy the application

```pulumi destroy --yes ```

**NOTES:**

To log into Azure, you can use az CLI uing `az login` or set the az env vars

````
    export ARM_CLIENT_ID="xxxx-xxxxx-xxxx"
    export ARM_CLIENT_SECRET="xxxx-xxxxx-xxxx"
    export ARM_TENANT_ID="xxxx-xxxxx-xxxx"
    export ARM_SUBSCRIPTION_ID="xxxx-xxxxx-xxxx"
````

More information: https://www.pulumi.com/docs/get-started/azure/begin/
