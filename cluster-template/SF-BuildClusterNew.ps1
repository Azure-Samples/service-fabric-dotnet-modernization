New-AzureRmResourceGroup -Name clustnameRg -Location centralus	

$pwd = "pass@word222" | ConvertTo-SecureString -AsPlainText -Force

# build the initial cluster
New-AzureRmServiceFabricCluster  -TemplateFile 'C:\demo\clustertemplate-demo.json' `
    -ParameterFile 'C:\demo\params-demo.json' `
    -KeyVaultResouceGroupName keyvaultRG `
    -KeyVaultName keyvaultname `
    -CertificateSubjectName 'clustname.centralus.cloudapp.azure.com' `
    -CertificateOutputFolder 'C:\Users\zzz\Desktop\demo\' `
    -CertificatePassword $pwd `
    -ResourceGroupName 'clustnameRg'


# Update the cluster with modified template and params
New-AzureRmResourceGroupDeployment -Name 'addSolution' -ResourceGroupName 'clustnameRg' -Mode Incremental `
  -TemplateFile 'C:\demo\template.json' `
  -TemplateParameterFile 'C:\demo\params.json'
