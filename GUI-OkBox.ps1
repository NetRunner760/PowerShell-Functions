# GUI-OkBox
# Shows an Ok box to the user after the previous action is complete.
# Juan Parra
# 4/29/21


[void] [System.Windows.MessageBox]::Show( "Unable to contact $Computer. Please verify hostname / network connectivity and try again.", "Network Error", "OK", "Information" )