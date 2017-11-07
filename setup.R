token <- Auth("Your_ClientID", "ClientSecret") # first Client ID, then Client Secret

save(token,file="./token_file") # This will save the token on your computer so you do not need to authenticate everytime

ValidateToken(token) # Checks if the token is valid
