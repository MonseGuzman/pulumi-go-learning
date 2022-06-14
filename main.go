package main

import (
	"github.com/pulumi/pulumi-azure-native/sdk/go/azure/network"
	"github.com/pulumi/pulumi-azure-native/sdk/go/azure/storage"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {
		resourceGroup := "monserrat-guzman"

		// Create an Azure resource (Storage Account)
		account, err := storage.NewStorageAccount(ctx, "sapulumi", &storage.StorageAccountArgs{
			ResourceGroupName: pulumi.String(resourceGroup),
			Sku: &storage.SkuArgs{
				Name: pulumi.String("Standard_LRS"),
			},
			Kind: pulumi.String("StorageV2"),
		})
		if err != nil {
			return err
		}

		// Create a Virtual Network
		vnet, err := network.NewVirtualNetwork(ctx, "vnet", &network.VirtualNetworkArgs{
			ResourceGroupName: pulumi.String(resourceGroup),

			VirtualNetworkName: pulumi.String("example-network-pulumi"),

			AddressSpace: &network.AddressSpaceArgs{
				AddressPrefixes: pulumi.StringArray{pulumi.String("10.0.0.0/16")},
			},

			DhcpOptions: &network.DhcpOptionsArgs{
				DnsServers: pulumi.StringArray{
					pulumi.String("10.0.0.4"),
					pulumi.String("10.0.0.5"),
				},
			},

			Subnets: network.SubnetTypeArray{
				&network.SubnetTypeArgs{
					Name:          pulumi.String("subnet1"),
					AddressPrefix: pulumi.String("10.0.1.0/24"),
				},
				&network.SubnetTypeArgs{
					Name:          pulumi.String("subnet2"),
					AddressPrefix: pulumi.String("10.0.2.0/24"),
				},
			},
		})
		if err != nil {
			return err
		}

		ctx.Export("vnetName", vnet.Name)

		// OUTPUTS - the primary key of the Storage Account
		ctx.Export("primaryStorageKey", pulumi.All(resourceGroup, account.Name).ApplyT(
			func(args []interface{}) (string, error) {
				resourceGroupName := args[0].(string)
				accountName := args[1].(string)
				accountKeys, err := storage.ListStorageAccountKeys(ctx, &storage.ListStorageAccountKeysArgs{
					ResourceGroupName: resourceGroupName,
					AccountName:       accountName,
				})
				if err != nil {
					return "", err
				}

				return accountKeys.Keys[0].Value, nil
			},
		))

		return nil
	})
}
