#!/bin/bash

RG_NAME="monserrat-guzman"
STORAGE_NAME="sa$(date "+%m%d%Y")"
CONTAINER_NAME="pulumi-terraform-states"
ACCOUNT_KEY=""

function createStorageAccount(){
  echo "##[debug]Getting storage account '$STORAGE_NAME'"
  storageAccount=$(az storage account list --resource-group $RG_NAME | jq -r '.[] | select(.name == "$STORAGE_NAME") | .id')
  if [ -z "$storageAccount" ]; then
    echo "##[debug]Storage account $STORAGE_NAME does not exist. Creating $STORAGE_NAME..."
    storageAccount=$(az storage account create --resource-group $RG_NAME --name $STORAGE_NAME --sku Standard_LRS --encryption-services blob | jq ".id" -r)
    echo "##[debug]Storage account created"
  fi
}

function deleteStorageAccount(){
  echo "##[debug]Getting storage account '$STORAGE_NAME'"
  storageAccount=$(az storage account list --resource-group $RG_NAME | jq -r '.[] | select(.name == "$STORAGE_NAME") | .id')
  if [ -z "$storageAccount" ]; then
    echo "##[debug]Storage account $STORAGE_NAME was found. Deleting $STORAGE_NAME..."
    az storage account delete --resource-group $RG_NAME --name $STORAGE_NAME -y
    echo "##[debug]Storage account deleted"
  fi
}

function createContainer(){
  echo "##[debug]Get storage account key..."
  ACCOUNT_KEY=$(az storage account keys list --resource-group $RG_NAME --account-name $STORAGE_NAME --query '[0].value' -o tsv)

  echo "##[debug]Checking to see if storage container exists"
  storageContainerExists=$(az storage container exists --name $CONTAINER_NAME --account-name $STORAGE_NAME --account-key $ACCOUNT_KEY | jq -r .exists)
  if [ "$storageContainerExists" = true ]; then
    echo "##[debug] Storage container $CONTAINER_NAME already exists"
    exit 0
  fi

  echo "##[debug]Creating blob container $CONTAINER_NAME..."
  az storage container create --name $CONTAINER_NAME --account-name $STORAGE_NAME --account-key $ACCOUNT_KEY
}

function deleteContainer(){
  echo "##[debug]Get storage account key..."
  ACCOUNT_KEY=$(az storage account keys list --resource-group $RG_NAME --account-name $STORAGE_NAME --query '[0].value' -o tsv)

  echo "##[debug]Checking to see if storage container exists"
  storageContainerExists=$(az storage container exists --name $CONTAINER_NAME --account-name $STORAGE_NAME --account-key $ACCOUNT_KEY | jq -r .exists)
  if [ "$storageContainerExists" = false ]; then
    echo "##[debug] Storage container $CONTAINER_NAME does not exist"
    exit 0
  fi

  echo "##[debug]Deleting blob container $CONTAINER_NAME..."
  az storage container delete --name $CONTAINER_NAME --account-name $STORAGE_NAME --account-key $ACCOUNT_KEY
}

echo "##[debug]Select the action"
echo "##[debug]1. Create the storage account and blob container"
echo "##[debug]2. Delete the storage account and blob container"
read option

case $option in
  1)
    createStorageAccount
    createContainer

    echo "Copy and page these env variables on your console"
    echo "export AZURE_STORAGE_ACCOUNT=$STORAGE_NAME"
    echo "export AZURE_STORAGE_KEY=$ACCOUNT_KEY"
    echo "export PULUMI_CONFIG_PASSPHRASE=$ACCOUNT_KEY"

    echo "In the end, run this command: "
    echo "pulumi new <azure-go> -n <project_name> -s <stack_name> -y or pulumi stack init -s <stack_name>"
  ;;
  2)
    deleteContainer
    deleteStorageAccount
  ;;
  *)
    echo "##[debug]Invalid option. Run it again"
  ;;
esac