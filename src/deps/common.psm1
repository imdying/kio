$ErrorActionPreference = 'Stop';

#
$Padding = '   ';

#
# Summary:
# 		Read-Host with some padding.
#	 
# Returns:
#		The input from the cin.
#
function ReadLine {
    return (Read-Host $Padding'Select');
}

#
# Summary:
# 		Displays a text with some padding.
#	 
# Parameters:
#	Message
#		A string representing the text.
#	Color
#		https://docs.microsoft.com/en-us/dotnet/api/system.consolecolor?view=net-6.0
#
function WritePadded {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [string]$Color = 'Gray'
    )
    Write-Host $Padding$Message -ForegroundColor $Color
}

#
# Summary:
# 		-
#	 
# Parameters:
#	Question
#		A string representing the question.
#	Options
#		A string array representing the selectable options.
#	Select
#		If greater than zero, skip the UserInput process and return the value as the result.
#
# Returns:
#		The value of the selected option.
#
function AskUserInput {
    param (
        [Parameter(Mandatory)]
        [string]$Question,
        [Parameter(Mandatory)]
        [String[]] $Options,
        [int] $Select
    )

    Write-Host $Question
    for ($i = 0; $i -lt $Options.Length; $i++) {
        $index = $i + 1;
        $option = $Options[$i];
        WritePadded -Message "$index. $option"
    }

    $Result = $Select;
    Write-Host;

    if ($Select -eq 0) {
        $result = ReadLine;
        Write-Host;
    }

    try {
        # string to unsigned int.
        [UInt32]::TryParse($Result, [ref]$Result) | Out-Null;
    } catch {
        throw $_;
    }
	
    return $Result;
}