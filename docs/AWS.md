# AWS CLI

## Status
AWS CLI is required by the AWS Toolkit.

## Verify
```powershell
aws --version
```

## Configure
```powershell
aws configure
```

## Notes
- The CLI path is set to `C:\Program Files\Amazon\AWSCLIV2`.
- If profiles are missing, create them with `aws configure`.
- Set a default region to avoid Toolkit fallback to `us-east-1`.

## Repo Automation
This repo includes `scripts/aws-cli-check.ps1` which verifies the default install path.

- Safe check only (no system changes):
```powershell
powershell -ExecutionPolicy Bypass -File scripts\aws-cli-check.ps1
```

- Add AWS CLI to *user* PATH (writes to user environment):
```powershell
powershell -ExecutionPolicy Bypass -File scripts\aws-cli-check.ps1 -SetPath
```
