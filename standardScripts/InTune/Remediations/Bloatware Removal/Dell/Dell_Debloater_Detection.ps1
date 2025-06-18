$UninstallPrograms = @(
    "Dell Optimizer"
    "Dell Power Manager"
    "DellOptimizerUI"
    "Dell SupportAssist OS Recovery"
    "Dell SupportAssist"
    "Dell Optimizer Service"
    "Dell Optimizer Core"
    "DellInc.PartnerPromo"
    "DellInc.DellOptimizer"
    "DellInc.DellPowerManager"
    "DellInc.DellDigitalDelivery"
    "DellInc.DellSupportAssistforPCs"
    "DellInc.PartnerPromo"
    "Dell Digital Delivery Service"
    "Dell Digital Delivery"
    "Dell Peripheral Manager"
    "Dell Power Manager Service"
    "Dell SupportAssist Remediation"
    "SupportAssist Recovery Assistant"
    "Dell SupportAssist OS Recovery Plugin for Dell Update"
    "Dell SupportAssistAgent"
    "Dell Update - SupportAssist Update Plugin"
    "Dell Core Services"
    "Dell Pair"
    "Dell Display Manager 2.0"
    "Dell Display Manager 2.1"
    "Dell Display Manager 2.2"
    "Dell SupportAssist Remediation"
    "Dell Update - SupportAssist Update Plugin"
    "DellInc.PartnerPromo"
)

$badDells = Get-CimInstance -class Win32_product | Where-Object {($_.Name -in $UninstallPrograms)}

If ($badDells.Count -ge 1)
{
    Exit 1
}
Else{
    Exit 0
}
# SIG # Begin signature block#Script Signature# SIG # End signature block





