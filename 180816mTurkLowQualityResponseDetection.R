################################################################
##### Detecting low-quality survey responses for Qualtrics #####
################################################################

# Code by JP Prims - Concept by Matt Motyl 

# This function assigns a score to each response. The higher the score, the higher the probability that the respondant is a bot or survey-farmer. 
# It is best to examine each response with a high score manually. This function cannot replace the human eye- it can only guide it. 

# Function arguments: 
  # Data - your dataset
  # Latitude - A column with latitude coordinates for your respondant. 
  # Longitude - A column with longitude coordinates for your respondant. 
  # Comments - An optional free-response field. 
  # Comments2 - A second, optional free-response field. 
  # Comments3 - A third, optional free-response field. 

# Scoring: 
  # Scores can go as high as 7 if you have three free-resposne fields. 
  # Having a latitude and longitude that appears in more than 1% of responses adds 1 point. (I recommend changing the percentage depending on the size of your dataset.)
  # Comments consisting solely of phrases typically attributed to bots/duplicate responses/survey farmers adds 1 point. (Send new suggestions for phrases to jprims2@uic.edu.)
  # Duplicate comments that other respondants have already made in response to the same question add 1 point. 
    # Max score for only latitude and longitude: 1
    # Max score for latitude, longitude, and one free-response: 3
    # Max score for latitude, longitude, and two free-responses: 5
    # Max score for latitude, longitude, and three free-responses: 7


bot.detector <- function(Data, Latitude, Longitude, Comments, Comments2, Comments3){
  
  
  # This creates a new column to store our bot suspicion score. 
    Data[,"bot.susp"] <- NA
  
  # First, let's work on detecting if there are some coordinates that appear in more than 1% of the Dataa. 
      # With Qualtrics, the columns we want to look at are Latitude and Longitude. 
      
      # Creating an object combining those two into one column 
      latlong <- with(Data, paste(Latitude,Longitude))
      
      # This counts the number of times each coordinate appears in the Dataaset. 
      llcount <- summary(as.factor(latlong))
      
      # This determines if a certain latitude and longitude appears in more than 1% of responses.
      lllots <- llcount > nrow(Data) * .01 # You can change the .01 to change the % of the sample. 
      
      # Pulls out the coordinates that make up more than 1% of the sample.   
      llmany <- names(lllots[lllots == TRUE]) 
      
      # Adds a 1 to the bot suspicion column if the coordinates appear in more than 1% of the sample
      Data$bot.susp <- ifelse(latlong %in% llmany, 1,  0)
  
  # Now, let's check if their free response contains "good" or "NICE!"
    suswords <- c("good","NICE!")
  
  # Check if person specified a free-response. If so, run. 
      if(missing(Comments)) {
        NULL
      } else {
        
        # Adds 1 to the bot suspicion column if suspicous phrases appear in the responses.
        # Putting the arguments in this order makes sure it won't flag comments that contain the word "good," but also have other content.
        Data$bot.susp <- with(Data, ifelse(Comments %in% suswords, Data$bot.susp + 1, Data$bot.susp))
        
        # Now, check if any free responses are 100% matches to other free responses. 
        Data$bot.susp <- with(Data, ifelse(duplicated(Comments), Data$bot.susp + 1, Data$bot.susp))
      }
  
  # Check if person specified second free-response. If so, run. 
      if(missing(Comments2)) {
        NULL
      } else {
        
        # Adds 1 to the bot suspicion column if suspicous phrases appear in the responses.
        # Putting the arguments in this order makes sure it won't flag comments that contain the word "good," but also have other content.
        Data$bot.susp <- with(Data, ifelse(Comments2 %in% suswords, Data$bot.susp + 1, Data$bot.susp))
        
        # Now, check if any free responses are 100% matches to other free responses. 
        Data$bot.susp <- with(Data, ifelse(duplicated(Comments2), Data$bot.susp + 1, Data$bot.susp))
      }
  
  # Check if person specified third free-response. If so, run. 
      if(missing(Comments3)) {
        NULL
      } else {
        
        # Adds 1 to the bot suspicion column if suspicous phrases appear in the responses.
        # Putting the arguments in this order makes sure it won't flag comments that contain the word "good," but also have other content.
        Data$bot.susp <- with(Data, ifelse(Comments3 %in% suswords, Data$bot.susp + 1, Data$bot.susp))
        
        # Now, check if any free responses are 100% matches to other free responses. 
        Data$bot.susp <- with(Data, ifelse(duplicated(Comments3), Data$bot.susp + 1, Data$bot.susp))
      }
  
  # Outputting results
    return(Data$bot.susp)
  
}