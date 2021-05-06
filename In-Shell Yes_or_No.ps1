# In Shell Yes or No Prompt
# Prompts user in shell for a yes or no response and proceeds with that action.
# Juan Parra
# 4/12/21

function Ask-YesorNo {
    Bump
    $title = "Prompt Statement / Title"
    $message = "Ask your question"

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "Explain actions of yes response"
    
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "Explain actions of no response"
    
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

# this will set a default answer, which is when you only push enter without a response. 0 for yes default, 1 for no default.
    $result = $host.ui.PromptForChoice($title, $message, $options, 1) 
    switch ($result)
        {
            0 { "action for yes response" }
            1 { "action for no response"}
        }
}
