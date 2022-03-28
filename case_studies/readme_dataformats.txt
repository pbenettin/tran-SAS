## Data should be formatted as a csv file with the following variables:
- 'date' is a timestamp [yyyy-mm-dd HH:MM] indicating the beginning of each hourly timestep
- J is precipitation flux [length/hour]
- Q is streamflow flux [length/hour]
- ET is evapotranspiration flux [length/hour]
- Cin is the input concentration to the system (e.g. mg/l)
- wi is timeseries including a measure of system wetness. This can be useful when defining time-variant SAS functions. If no time-variant SAS functions are used, the value can be set to 1
- measC_Q is the measured streamflow concentration. Timesteps with no available concentration measurement should be filled with a 'no data' value (NaN).
  
## Columns must include data at hourly timesteps. The columns wi and measC_Q are not necessary for the model to run, but they have to be filled in anyway. In this case, wi can be simply equal to a constant value (for example: 1) and measC_Q should be set to the 'no data' value NaN.



