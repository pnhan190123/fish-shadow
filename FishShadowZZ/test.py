from ReadWriteMemory import ReadWriteMemory
import pyautogui
import time

keyBoard = ['0', '1', '2', '3', '4', '5', 'space']
def press(i):
    pyautogui.press(keyBoard[i])

def initProcess(name):
    global process
    rwm = ReadWriteMemory()
    process = rwm.get_process_by_name(name)
    process.open()

baseAddr = 0x11621DE88
baseAddr2 = 0x114209BAC
gioA = baseAddr
canA = baseAddr + 0x00000004
tthA = baseAddr + 0x0000002c
fixA = baseAddr + 0x000000e4
typA = baseAddr2 + 0x000000ac

toc = 1
loc = 1
dem = 0
day = 0
def cau():
    global dem, day
    gio = process.read(gioA)
    can = process.read(canA)
    tth = process.read(tthA)
    fix = process.read(fixA)
    typ = process.read(typA)

    if can == 1:
        press(0)
        time.sleep(0.5)
        press(1)
        time.sleep(0.5)
        press(2)
        time.sleep(0.5)
    elif can > 103:
        press(2)

    if tth == 0:
        if can == 103:
            press(3)
            time.sleep(0.1)
            if gio == 300:
                time.sleep(2)
                press(5)
        else:
            time.sleep(2)
    if tth == 3:
        if toc == 1:
            sp = 0.05
        elif toc == 2:
            sp = 5
        elif toc == 3:
            sp = 10

        if loc == 1:
            if typ == 1 or typ == 7 or typ == 13:
                time.sleep(sp)
                press(6)
        elif loc == 2:
            if typ == 1 or typ == 7 or typ == 10 or typ == 13 or typ == 15:
                time.sleep(sp)
                press(6)
        elif loc == 3:
            if typ < 16:
                time.sleep(sp)
                press(6)
        elif loc == 4:
            if typ < 20:
                time.sleep(sp)
                press(6)
        elif loc == 5:
            if typ < 25:
                time.sleep(sp)
                press(6)
    if tth == 4:
        bat = 50 + 1
        if bat > 85:
            bat = 50
        time.sleep(bat/1000)
        press(6)
    if tth == 6:
        dem = dem + 1
        print(f'Cau: {dem}')
        time.sleep(2)
    if tth == 8:
        time.sleep(0.5)
        press(4)
        time.sleep(1)
    if tth == 10:
        if fix == 6:
            time.sleep(0.5)
            press(0)
            time.sleep(1)
            press(1)
            time.sleep(1)
            press(2)
            time.sleep(1)
            press(5)
            time.sleep(1)
            press(5)
            time.sleep(1)
            press(5)
            time.sleep(0.5)
        else:
            time.sleep(2)
    if tth == 11:
        day = day + 1
        print(f'Dut day: {day}')
        time.sleep(2)

initProcess('MEmuHeadless.exe')
while True:
    cau()

