#cython: language_level=3
from sys import exit
import subprocess
import os

si = subprocess.STARTUPINFO()
si.dwFlags |= subprocess.STARTF_USESHOWWINDOW

def adbcall(command, serial, adbpath='adb'):
    args = [adbpath]
    args.append('-s')
    args.append(serial)
    args.append('shell')
    args.append(command)
    subprocess.call(args,startupinfo=si)
    # subprocess.call(args)

def tap(device, coordx, coordy, serial, adbpath='adb'):
    adbcall('S="sendevent {}";$S 3 53 {};$S 3 54 {};$S 3 48 5;$S 1 330 1;$S 0 0 0;'.format(device, coordx, coordy), serial, adbpath)
    adbcall('S="sendevent {}";$S 3 48 0;$S 1 330 0;$S 0 0 0;'.format(device), serial, adbpath)

def adbshell(command, serial=None, adbpath='adb'):
    args = [adbpath]
    if serial is not None:
        args.append('-s')
        args.append(serial)
    args.append('shell')
    args.append(command)
    return os.linesep.join(str(subprocess.check_output(args, startupinfo=si)).split(r'\r\n')[0:-1])

def adbdevices(adbpath='adb'):
    for dev in subprocess.check_output([adbpath, 'devices'], startupinfo=si).splitlines():
        dev = str(dev)
        if dev.endswith(r"\tdevice'"):
            return dev.split(r'\t')[0][2:]
        elif dev.endswith(r"b''"):
            return 0

def multiadbdevices(adbpath='adb'):
    multi = []
    for dev in subprocess.check_output([adbpath, 'devices'], startupinfo=si).splitlines():
        dev = str(dev)
        if dev.endswith(r"\tdevice'"):
            multi.append(dev.split(r'\t')[0][2:])
    if len(multi) > 0:
        return multi
    else:
        return 0

def touchscreen_devices(serial=None, adbpath='adb'):
    print(f'Connect to {serial}')
    for dev in adbshell('getevent -il', serial, adbpath).split('add device '):
        if dev.find('ABS_MT_POSITION_X') > -1:
            return [dev.splitlines()[0].split()[-1]]