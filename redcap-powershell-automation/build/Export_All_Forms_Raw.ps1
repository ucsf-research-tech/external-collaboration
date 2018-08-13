#requires -version 3
<#
.SYNOPSIS
  UCSF Graduate Career Outcomes extract from REDCap
.DESCRIPTION
  
.INPUTS
    None - automated process
    Need to update to protect API token with Get-Credential
.OUTPUTS
    Extracted data files dumped to C:\temp.
.NOTES
  Version:        1.2
  Author:         Remi Frazier
  Creation Date:  2018-08-13
  Purpose/Change: Refactored code to improve clarity of flow and commenting
.EXAMPLE
  n/a
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
  #Script parameters go here
  #To add - output directory, and overrides for API parameters
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'Stop'

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Global Declarations of file sources
    $instrumentsPath='c:\temp\instruments.csv' 
    $outputPath='c:\temp\' 

#Project-specific connection strings
    $apiUrl='https://redcap.ucsf.edu/api/' #replace with your institution's API URL
    $apiToken='XXXXXXXXXXXXXXXXXXXXXXXXXXXXX' #replace with your API token

#REDCap project-specific structure information
    $guidLabel='record_id' #replace with your project's unique identifier field


#Project-specific lookup tables
    #No lookups currently used - sample syntax below:
    <#$lu_patientGender = @{
        'Female' = 0
        'Male'   = 1
        'Not Indicated'  = 3
    }#>


#-----------------------------------------------------------[Functions]------------------------------------------------------------

function redcapExportData
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)][String]$apiUrl,
		[Parameter(Mandatory=$true)][String]$apiToken,
		[Parameter(Mandatory=$true)][String]$form,
		[Parameter(Mandatory=$false)][String]$guidLabel='record_id', #Default value for most REDCap projects is [record_id], but some projects may need to override this
		[Parameter(Mandatory=$false)][String]$rawOrLabel='raw'
	)
    $forms = New-Object System.Collections.ArrayList
    $foo=$forms.Add($form)
    $call = @{
        token=$apiToken
        content='record'
        fields=$guidLabel
        forms=$forms
        rawOrLabel=$rawOrLabel
        rawOrLabelHeaders=$rawOrLabel
        format='csv'
        type='flat'
        }
    $body = (ConvertTo-Json $call) 
    $response = Invoke-RestMethod $apiUrl -Method Post -body $call #$body -ContentType 'application/json' #'application/json' #-Body $body -ContentType 'application/json' #-Headers $hdrs 
    Write-Output $response
    }
#-------------------------
function redcapExportForms
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)][String]$apiUrl,
		[Parameter(Mandatory=$true)][String]$apiToken
	)
    $call = @{
        token=$apiToken
        content='instrument'
        format='csv'
        type='flat'
        }
    $body = (ConvertTo-Json $call) 
    $response = Invoke-RestMethod $apiUrl -Method Post -body $call #$body -ContentType 'application/json' #'application/json' #-Body $body -ContentType 'application/json' #-Headers $hdrs 
    Return $response
    }
#-------------------------


function reformatOutput
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)][String]$text,
		[Parameter(Mandatory=$true)][String]$path
	)
    $pathTemp=$path + ".tmp"
    $text | Out-File $pathTemp
    Import-Csv $pathTemp | Export-Csv $path -NoTypeInformation
    Remove-Item $pathTemp
}


#-----------------------------------------------------------[Execution]------------------------------------------------------------
cls


#---
#Get list of instruments from project
$return=redcapExportForms -apiUrl 'https://redcap.ucsf.edu/api/' -apiToken $apiToken

#--
# Reformat output into a somewhat more Excel-friendly CSV
# (not really necessary for the process, but helpful for troubleshooting)
reformatOutput -text $return -path $instrumentsPath

#--
# Load instrument list from file for iteration
# (again, we don't need to write the instrument list to a file - could
#  just load it to memory -- but this method supports troubleshooting)
$instruments=import-csv $instrumentsPath


#--
# Iterate through list of instruments, exporting all data in each instrument
# to a separate file in the output directory.
$instruments | Foreach-Object {
    # Prepare to request data
    $instrument=$_.instrument_name 
    $output = $outputPath+$instrument+".csv"
    Write-Output "Requesting $instrument"

    # Request data for this instrument and reformat output to make more Excel friendly
    $response=redcapExportData -apiUrl 'https://redcap.ucsf.edu/api/' -apiToken $apiToken -form $instrument -guidLabel $guidLabel
    reformatOutput -text $response -path $output

    # Report results
    $outputSize=$response.Length
    Write-Output "$instrument - wrote $outputSize bytes"
}
