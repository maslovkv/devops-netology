#!/usr/bin/env python3
import time
from os import statvfs as stvfs

cpula = {}
mi = {}
out = {'timestamp': time.time()}

c = open('/proc/loadavg', 'r')
cpu = c.read().split()
c.close()

m = open('/proc/meminfo', 'r')
mil = m.readlines()
m.close()

rootfs = stvfs('/')

out['CPU_la_1'] = cpu[0]
out['CPU_la_5'] = cpu[1]
out['CPU_la_15'] = cpu[2]

for line in mil:
    if len(line) < 2:
        continue
    name = line.split(':')[0]
    var = line.split(':')[1].split()[0]
    mi[name] = int(var)
out['MemTotal'] = mi['MemTotal']
out['MemFree'] = mi['MemFree']
out['MemAvailable'] = mi['MemAvailable']
out['SwapTotal'] = mi['SwapTotal']
out['SwapFree'] = mi['SwapFree']

''' Закомментировано для наглядности скриншота.
out['rootfs_bsize'] = rootfs.f_bsize
out['rootfs_blocks'] = rootfs.f_blocks
out['rootfs_bavail'] = rootfs.f_bavail
out['rootfs_f_files'] = rootfs.f_files
out['rootfs_f_favail'] = rootfs.f_favail
'''

lf = time.strftime("/var/log/%Y-%m-%d-awesome-monitoring.log", time.localtime(out['timestamp']))

l = open(lf, 'a')
l.write(str(out)+"\n")
l.close()


