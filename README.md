# ThesisJannekeBlok

Everything is split into two parts:

1. Data processing: the data is pre-processed and the correct data segments are selected for each child.
2. Data analysis: the outcome metrics are determined

First: dataSelection.m should be run with the correct settings:

  
  isAutomatic   = 1;
  
  isOverlap     = true;
  
  timeframe     = 30;


Running the file with these inputs will save a .mat file with the correct name. Recreating the other parts can be done by running it again with: timeframe = [30 30 30]; overlap = false (for 3 separate segments without overlap) or with timeframe = 5:40; overlap = true (for segments with lengths ranging from 5 seconds to 40 seconds).


If all these datasets are saved, use main.m in the data analysis folder to create the plots.
