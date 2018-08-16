
function includeOnlyRepeatingInstrumentData
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)][String]$path,
        [Parameter(Mandatory=$false)][String]$output=$path
	)
 
    $data=Import-Csv $path
 
    $headers=$data | Get-member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name' 
    Write-Output ($headers -contains 'redcap_repeat_instrument')
    If ($headers -contains 'redcap_repeat_instrument') 
        {
        Write-Output 'redcap_repeat_instrument found'
        }
    Else
        {
        Write-Output 'redcap_repeat_instrument not found'
        }

#    $data.Where({$PSItem.redcap_repeat_instrument.length -ne 0 -OR $PSItem.redcap_repeat_instrument -ne [String]::Empty}) | Export-Csv $output -NoTypeInformation
    #return $headers
}

cls
$input='c:\temp\job_history.csv'
$output='c:\temp\job_history_truncated.csv'
#$input='c:\temp\trainee_information.csv'
#$output='c:\temp\trainee_information_truncated.csv'

Write-Output "Input file: $input"
Write-Output ("Input file length:  "+(Get-Item $input).Length)
includeOnlyRepeatingInstrumentData -path $input -output $output
Write-Output ("Output file length: "+(Get-Item $output).Length)


