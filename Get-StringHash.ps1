#!/usr/bin/env powershell
<#
.SYNOPSIS

Compute the hash value for a string by using a specific hash algorithm.

.DESCRIPTION

The Get-StringHash script computes the hash value for a string by using a specified hash algorithm. A hash value is a unique value that corresponds to the content of the string.

By default, the Get-StringHash script uses the SHA256 algorithm, although any hash algorithm that is supported by the target operating system can be used.

.PARAMETER Algorithm

Specifies the cryptographic hash function to use for computing the hash value of the contents of the specified file. A cryptographic hash function includes the property that it is not possible to find two distinct inputs that generate the same hash values. Hash functions are commonly used with digital signatures and for data integrity. The acceptable values for this parameter are:

        -- SHA1
        -- SHA256
        -- SHA384
        -- SHA512
        -- MD5

If no value is specified, or if the parameter is omitted, the default value is SHA256.

.PARAMETER String

Specifies the string that is to be hashed.

.OUTPUTS
StringHashInfo

Get-StringHash returns an object that represents the string that was hashed, the value of the computed hash, and the algorithm used to compute the hash.

.EXAMPLE
Get-StringHash.ps1 -String "HashThisString" | Format-List

Hash         : BE767EABA134CB2F01E8D1755A8DD3B18BC8B063049CFF5E6228F5F7143FF777
Algorithm    : SHA256
SourceString : HashThisString

.EXAMPLE
"PipelineString" | Get-StringHash.ps1 | Format-List

Hash         : 26F5E3BDA4FED8F257BD76B4653CB3D49FE572031891DE74E532E6AE088FE892
Algorithm    : SHA256
SourceString : PipelineString

.EXAMPLE
Get-StringHash.ps1 -String "UseMD5" -Algorithm MD5 | Format-List

Hash         : 1634763BFA8CFCB2C795A05B894554CA
Algorithm    : MD5
SourceString : UseMD5

#>


param (
    [Parameter(Position=0,mandatory=$true, ValueFromPipeline=$true)]
    [String] $String,
    [ValidateSet("SHA1","SHA256","SHA384","SHA512","MD5")]
    [Parameter(Position=1,mandatory=$false)]
    [String] $Algorithm = "SHA256"
)

# The StringHashInfo Class is used to make the return data similar to FileHashInfo for consistency.
class StringHashInfo {
    [String] $Hash;
    [String] $Algorithm; 
    [String] $SourceString;
    hidden [int] $HashCode;

    StringHashInfo([Microsoft.PowerShell.Commands.FileHashInfo] $FileHashInfo, [String] $StringInput) {
        $this.Algorithm = $FileHashInfo.Algorithm;
        $this.Hash = $FileHashInfo.Hash;
        $this.HashCode = $FileHashInfo.GetHashCode();
        $this.SourceString = $StringInput
    }

    [int] GetHashCode() {
        return $this.HashCode
    }
}

$byteArray = [System.Text.Encoding]::UTF8.GetBytes($String)
$stream = [System.IO.MemoryStream]::new($byteArray)
$hash = Get-FileHash -InputStream $stream -Algorithm $Algorithm
$stream.Close()

[StringHashInfo]::new($hash, $String)
