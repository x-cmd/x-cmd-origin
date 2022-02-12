bash test.param/param.test.1 --org hi  --access private --sort time,repo --show repo,time


org=hi access=private bash test.param/param.test.1  --sort time,repo --show repo,time

org=hi sort=time,repo access=private bash test.param/param.test.1 --show repo,time

org=hi ACCESS=private bash test.param/param.test.1 --sort time,repo --show repo,time


org=hi sort=time,repo ACCESS=private bash test.param/param.test.1 --show repo,time

# show help document
bash test.param/param.test.1 --org hi --access private --sort time,repo --show repo,time 12 2 -h
