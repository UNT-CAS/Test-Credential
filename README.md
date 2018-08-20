Verify Active Directory or Local SAM store credentials.

# Description

This function takes a credential object (user name and password) as input and will verify if the combination is correct.
The function returns a boolean based on the result.
The script defaults to local user accounts, but a remote computername can be specified in the `-ComputerName` parameter.
If a domain is specified with the user name, the domain will be used to validate the supplied credentials.

## Quick Usage

```powershell
# Install and import from PowerShell Gallery before using:
Install-Module Test-Credential
Import-Module Test-Credential

# Test the credential object: $creds
Test-Credential $creds
```

# Parameters

## Credentials

- Type: `[SecureString]`

The credentials obejct to verify.
Credential objects are usually collected from a user:

```powershell
$creds = Get-Credential
```

However, you might need to build the credentials object in the script:

```powershell
$username = 'VertigoRay'
$plainPassword = 'P@$$w0rd'
$securePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePassword
```

If you want to validate agains Active Directory, the user name should include the domain:

```powershell
$username = 'VertigoRay'
```

## ComputerName

- Type: `[String]`
- Default: `$env:ComputerName`

The computer on which the local credentials will be verified.
Only necessary when verifying a Local SAM store on a different machine.

**If a domain is specified with the user name, this parameter will be ignored.**
    
# Examples

## Test Credentials against Local SAM store.
    
```powershell
$creds = Get-Credential
$creds

UserName                         Password
--------                         --------
vertigoray   System.Security.SecureString

Test-Credential -Credentials $creds
```

## Test Unsecure Credentials against Local SAM store.

```powershell
$username = 'VertigoRay'
$plainPassword = 'P@$$w0rd'
$securePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

Test-Credential -Credentials $creds
```
    
## Test Credentials against Remote SAM store.

```powershell
$creds = Get-Credential
$creds

UserName                         Password
--------                         --------
vertigoray   System.Security.SecureString

Test-Credential -Credentials $creds -ComputerName 'MyComputer02'
```

## Test Unsecure Credentials against Remote SAM store.

```powershell
$username = 'VertigoRay'
$plainPassword = 'P@$$w0rd'
$securePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

Test-Credential -Credentials $creds -ComputerName 'MyComputer02'
```

## Test Credentials against Active Directory..

```powershell
$creds = Get-Credential
$creds

UserName                             Password
--------                             --------
DOM\vertigoray   System.Security.SecureString

Test-Credential -Credentials $creds
```

## Test Unsecure Credentials against Active Directory.

```powershell
$username = 'DOM\VertigoRay'
$plainPassword = 'P@$$w0rd'
$securePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

Test-Credential -Credentials $creds
```

# Notes

Inspired by:

- [Test-ADCredential; by Jaap Brasser](https://gallery.technet.microsoft.com/scriptcenter/Verify-the-Active-021eedea)
- [Test-LocalCredential; by Jaap Brasser](https://gallery.technet.microsoft.com/scriptcenter/Verify-the-Local-User-1e365545)

Improvements made because:

- Wanted a single function to rule them all.
- Use a secure Credential Object.
- Improved error messages for function, instead of interior methods.
- Deployable via PSGallery
