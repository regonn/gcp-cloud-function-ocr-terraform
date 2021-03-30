## Terraform

```
$ cd [This project directory]/terraform
```

Put `account.json` file from [GCP service account keys](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#iam-service-account-keys-create-console)

```
$ terraform init
$ terraform plan -var 'gcp_project_id=YOUR_PROJECT_ID'
$ terraform apply -var 'gcp_project_id=YOUR_PROJECT_ID'
```