time awk -v color=1 -f json_walk -v op=prepend -v opv1=.c1 -v opv2=New-Inserted test-data/aa.json 

time awk -v color=1 -f json_walk -v op=append -v opv1=.c2 -v opv2=New-Inserted -v dbg=1 test-data/aa.json 

time awk -v color=1 -f json_walk -v op=put -v opv1=.e.a -v opv2=New-Inserted -v dbg=1 test-data/aa.json
time awk -v color=1 -f json_walk -v op=replace -v opv1=.d.[0].member -v opv2=New-Inserted -v dbg=1 test-data/aa.json 


time awk -v color=1 -f json_walk -v op=extract -v opv1=.d.[0].member -v dbg=1 test-data/aa.json
