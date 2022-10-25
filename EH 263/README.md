# MINI PROJECT 3



## NOTES

### Load and clean data

  HOBO DATA 
  
      The final HOBO measurement dataframe is called hobo_long. This version is 
      different from the raw data in a few ways: 
      
      1) clean column names: column names are all lower case and do not have spaces
      2) time columns: time columns were converted to date objects using the lubridate:: 
      package; additional time columns were added for the month, day, hour, and minute 
      to make merging with activity and weather data easier later. 
      3) filtered measurements: only measurements made between 10/5/22 06:40 and 
      10/11/22 12:00 were included. 
      4) long data: the cleaned HOBO data are made "long" to make table/figure 
      creation iterative
    

  ACTIVITY LOG

      The activity log was modified to capture uses of the tea kettle and showering 
      in addition to cooking events. This log was read in and further adjusted as 
      follows: 
      
      1) time interval: a new column (intrvl) was created to capture the interval 
      of time during which cooking events too place (start -> end). 
      
      The HOBO data was joined with the activity log by date. I couldn't think of 
      an efficient way to join based on the interval, so instead I did the join by 
      date of the cooking event. This join caused data to be duplicated (# of 
      observations = number of HOBO measurements on the day of a cooking event 
      * number of cooking events on that day). The following steps rectify this 
      duplication: 
      
      1) create activity_status column: create a column that flags whether a HOBO
      measurement occurred during an activity/event (Y/N)
      2) create hobo_act_events dataframe: create a new dataframe that is only HOBO
      measurements taken during activity/event (activity_status == "Y")
      3) drop measurements during activities/events: remove all measurements that 
      were made during an activity/event (activity_status != "Y")
      4) drop the activity columns 
      5) drop duplicated rows: use unique() to get rid of the duplications that 
      were created during the join
      6) bind measurements during activities/events: add the measurements taken 
      during an activity/event back in. The activity columns are now empty for the 
      measurements that did not correspond with an activity/event. 
      
      QA Checks: 
      - do the number of observations in the final dataframe with HOBO 
      measurements and activities/events match the number of expected observations 
      in the HOBO measurements (hobo_long) dataframe? Yes! 
      - spot checks: does the measurement fall within the interval? Yes!

  WEATHER DATA 

      Weather data was sourced from Wunderground. I used the historical weather 
      data for each of the days the HOBO was logging. Data was extracted by manually
      copying and pasting out of the website and into an .xlsx file. I did a bit 
      of manipulating the time columns to ensure that the matching would work properly. 
      I dropped the degrees and percent text from the temperature and humidity columns
      to make them numericals rather than characters. The data was then made "long"
      to match up with the hobo_long data. The columns that hold the temperature and 
      humidity data is called "outdoor_value", as opposed to "indoor_value" which is 
      used for the hobo_long dataframe.
      
      The HOBO measurements and the weather data were merged into a dataframe called
      indoor_outdoor. Because the weather data is hourly and the HOBO data is 
      minute-by-minute, I averaged the HOBO data into an hourly measurement. I opted 
      to do this rather than have the same hourly temperature and relative humidity 
      matched to minute-level HOBO measurements. 
      
      
      

  CLASS HOBO

      The classroom HOBO was treated the same as my personal HOBO. 


### Data exploration

      I checked for gaps in the log by creating a column that pulls the time 
      stamp of the subsequent measurement (rec_after). Another column creates an 
      interval between the timestamp of the measurement and the timestamp of the 
      subsequent measurement (intrvl). A quick summary shows that the duration of 
      these intervals is all 1 minute,verifying that there are no gaps. Other 
      steps in this stage included plotting all the HOBO measurements from my 
      HOBO and generating density plots for temperature and humidity.
      
      
      
### Data Dictionary

      number == a unique ID for each HOBO measurement
      
      date_time == a date/time variable for each observation
      
      date == the date the measurement was taken
      
      month == the number of the month the measurement was taken in
      
      day == the number of the day of the month the measurement was taken in
      
      hour == the hour that the measurement was taken in
      
      minute == the minute that the measurement was taken in
      
      metric == either Temperature (F) or Relative Humitidy (%)
      
      indoor_value == the measurement provided by the HOBO for that specific 
      metric at that date_time
      
      outdoor_value == the measurement retreived from wunderground for outdoor 
      ambient temperature and RH
      
      activity_status == a flag indiciating whether or not a logged activity 
      took place when the HOBO measurement was recorded
      
      event_no == a unique ID for each activity/event
      
      cooking == a binary indicator of whether or not a cooking event was 
      taking place 
      
      kettle == a binary indicator of whether or not the kettle was on
      
      shower == a binary indicator of whether or not someone was showering while 
      an event was occurring
      
      occupants == the number of occupants during an activity/event 
      
      other == field notes during activity logging
      
      intrvl == a interval variable that is bounded by the start and end time 
      of the event/activity  
