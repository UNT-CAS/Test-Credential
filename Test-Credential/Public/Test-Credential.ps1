<#
.Synopsis

    Verify Active Directory or Local SAM store credentials.

.DESCRIPTION

    This function takes a user name and a password as input and will verify if the combination is correct. The function returns a boolean based on the result. The script defaults to local user accounts, but a remote computername can be specified in the -ComputerName parameter.
    
.PARAMETER Credentials
    
    The credentials obejct to verify.
	
.PARAMETER ComputerName
    
    The computer on which the local credentials will be verified. Only necessary when verifying a Local SAM store on a different machine.
    
.EXAMPLE
    
    # Test Credentials against Local SAM store.
    
    $creds = Get-Credential
    $creds

    UserName                         Password
    --------                         --------
    vertigoray   System.Security.SecureString

    Test-Credential -Credentials $creds

.EXAMPLE

    # Test Unsecure Credentials against Local SAM store.
    
    $username = 'VertigoRay'
    $plainPassword = 'P@$$w0rd'
    $securePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

    Test-Credential -Credentials $creds
    
.EXAMPLE
    
    # Test Credentials against Remote SAM store.
    
    $creds = Get-Credential
    $creds

    UserName                         Password
    --------                         --------
    vertigoray   System.Security.SecureString

    Test-Credential -Credentials $creds -ComputerName 'MyComputer02'

.EXAMPLE

    # Test Unsecure Credentials against Remote SAM store.
    
    $username = 'VertigoRay'
    $plainPassword = 'P@$$w0rd'
    $securePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

    Test-Credential -Credentials $creds -ComputerName 'MyComputer02'

.EXAMPLE
    
    # Test Credentials against Active Directory..
    
    $creds = Get-Credential
    $creds

    UserName                             Password
    --------                             --------
    DOM\vertigoray   System.Security.SecureString

    Test-Credential -Credentials $creds

.EXAMPLE

    # Test Unsecure Credentials against Active Directory.
    
    $username = 'DOM\VertigoRay'
    $plainPassword = 'P@$$w0rd'
    $securePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

    Test-Credential -Credentials $creds

.NOTES

    Inspired by:
    - Name: Test-ADCredential
      Author: Jaap Brasser
      Version: 1.0
      DateUpdated: 2013-05-10
      Url: https://gallery.technet.microsoft.com/scriptcenter/Verify-the-Active-021eedea
    - Name: Test-Credential
      Author: Jaap Brasser
      Version: 1.0
      DateUpdated: 2013-05-20

    Improvements made because:
    - Wanted a single function to rule them all.
    - Use a secure Credential Object.
    - Improved error messages for function, instead of interior methods.
    - Deployable via PSGallery
#>
function Test-Credential {
    [CmdletBinding()]
    [OutputType([boolean])]
    param (
        [Parameter(Mandatory = $true)]
        [SecureString]
        $Credentials,
        
        [Parameter()]
        [string]
        $ComputerName = $env:COMPUTERNAME
    )
    
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement

    $domain = $Credentials.GetNetworkCredential().Domain
    if ($domain) {
        Write-Verbose "[Test-Credential] Validating Against Domain: ${domain}"
        try {
            $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain', $domain)
        } catch {
            $errorMessage = $Error[0].Exception.InnerException.Message
            Throw [System.DirectoryServices.AccountManagement.PrincipalServerDownException] "Error setting Domain to ${domain}. ${errorMessage}"
        }
    } else {
        Write-Verbose "[Test-Credential] Validating Against Machine: ${ComputerName}"
        $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine', $ComputerName)
    }

    try {
        return $DS.ValidateCredentials($Credentials.UserName, $Credentials.GetNetworkCredential().Password)
    } catch {
        $server = if ($domain) { "domain: ${domain}" } else { "machine: ${ComputerName}" }
        $errorMessage = $Error[0].Exception.InnerException.Message
        Throw [System.DirectoryServices.AccountManagement.PrincipalServerDownException] "Error communicating with ${server}. ${errorMessage}"
    }
}
