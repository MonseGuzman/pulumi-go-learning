package main

import (
	"github.com/pulumi/pulumi-azure-native/sdk/go/azure/network"
	"github.com/pulumi/pulumi-azure-native/sdk/go/azure/storage"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func main() {
	var resourceGroup pulumi.String = "monserrat-guzman"

	pulumi.Run(func(ctx *pulumi.Context) error {

		// Create Security Group
		securityGroup, err := network.NewNetworkSecurityGroup(ctx, "securityGroup", &network.NetworkSecurityGroupArgs{
			ResourceGroupName:        resourceGroup,
			Location:                 pulumi.String("centralus"),
			NetworkSecurityGroupName: pulumi.String("sg-pulumi"),
			SecurityRules: network.SecurityRuleTypeArray{
				&network.SecurityRuleTypeArgs{
					Access:    pulumi.String("Allow"),
					Direction: pulumi.String("Inbound"),
					Protocol:  pulumi.String("*"),
					Priority:  pulumi.Int(100), // It seems these paramets are require
					Name:      pulumi.String("rule1"),

					Description:              pulumi.String("Allow SSH port"),
					DestinationPortRange:     pulumi.String("22"),
					DestinationAddressPrefix: pulumi.String("*"),
					SourcePortRanges:         pulumi.StringArray{pulumi.String("0-65535")},
					SourceAddressPrefix:      pulumi.String("*"),
				},
				&network.SecurityRuleTypeArgs{
					Access:    pulumi.String("Allow"),
					Direction: pulumi.String("Outbound"),
					Protocol:  pulumi.String("*"),
					Priority:  pulumi.Int(4096),

					Name:                     pulumi.String("Allow_All_Outbound"),
					SourcePortRanges:         pulumi.StringArray{pulumi.String("0-65535")},
					SourceAddressPrefix:      pulumi.String("*"),
					DestinationPortRanges:    pulumi.StringArray{pulumi.String("0-65535")},
					DestinationAddressPrefix: pulumi.String("*"),
				},
			},
		})
		if err != nil {
			// ctx.Log.Error("ERROR: ", err.Error() )
			return err
		}

		ctx.Log.Info("This is a log message", &pulumi.LogArgs{
			Resource:  securityGroup,
			StreamID:  0,
			Ephemeral: false,
		})

		// Create a Virtual Network
		vnet, err := network.NewVirtualNetwork(ctx, "vnet", &network.VirtualNetworkArgs{
			ResourceGroupName:  resourceGroup,
			Location:           pulumi.String("centralus"),
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
					NetworkSecurityGroup: &network.NetworkSecurityGroupTypeArgs{
						Id: securityGroup.ID(),
					},
				},
			},
		})
		if err != nil {
			return err
		}

		// OUTPUTS -
		ctx.Export("securityGroupId", securityGroup.ID())

		ctx.Export("vnetName", vnet.Name)

		return nil
	})
}

func helloStorageAccount(resourceGroup pulumi.String) {
	pulumi.Run(func(ctx *pulumi.Context) error {
		// Create an Azure resource (Storage Account)
		account, err := storage.NewStorageAccount(ctx, "sa", &storage.StorageAccountArgs{
			ResourceGroupName: resourceGroup,
			Sku: &storage.SkuArgs{
				Name: pulumi.String("Standard_LRS"),
			},
			Kind: pulumi.String("StorageV2"),
		})
		if err != nil {
			return err
		}

		// outputs
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
