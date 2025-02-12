#cython: language_level=3
from sys import exit
import time
import pyautogui
from configparser import ConfigParser
import requests
from tkinter import *
from tkinter import messagebox
import threading
from PIL import Image,ImageTk
import webbrowser
from tkinter import ttk
import pyximport; pyximport.install()
from image import *
from adb_tap import *
import codecs
import base64

def checkTool():
    count = 0
    emuList = get_Emu_Name()
    for val in emuList:
        if val == 'Bổ củi 2-FishShadow':
            count += 1
    return count

def checkKeyTime(key):
    raw = codecs.encode(key, 'rot_13')
    raw = raw.encode('ascii')
    raw = base64.b64decode(raw)
    raw = raw.decode('ascii')
    raw = raw.encode('ascii')
    raw = base64.b64decode(raw)
    raw = raw.decode('ascii')
    datas = raw.split("#")
    timeE = datas[0]
    remainTime = int(timeE) - int(time.time())
    if remainTime > 0:
        return round((remainTime/3600), 2)
    else:
        return 0

lastVal = [0]*9
def dataOnl(name, soCaCau, tenCa, tenCaVM, brokenRope, fixCount, skipCount, modeAuto):
    global lastVal
    if modeAuto == 3:
        text = str(soCaCau-lastVal[0]) + '-' + str(skipCount-lastVal[1]) + '-' + str(brokenRope-lastVal[2]) + '-' + str(tenCa[0]-lastVal[3]) + '-' + str(tenCa[1]+tenCaVM[1]-lastVal[4]) + '-' + str(tenCa[2]+tenCaVM[2]-lastVal[5]) + '-' + str(tenCa[3]+tenCaVM[3]-lastVal[6]) + '-' + str(tenCa[4]+tenCaVM[4]-lastVal[7]) + '-' + str(fixCount-lastVal[8])
        lastVal = [soCaCau, skipCount, brokenRope, tenCa[0], (tenCa[1]+tenCaVM[1]), (tenCa[2]+tenCaVM[2]), (tenCa[3]+tenCaVM[3]), (tenCa[4]+tenCaVM[4]), fixCount]
        url = f'https://autocaucaserver.tk/thongke/addData.php?name={name}&data={text}'
        requests.get(url)

cdef int checkCrack = 0
wurl = 'https://autoplaytogether.tk/'
def openweb():
    webbrowser.open(wurl, new=1)

oversion = '3.0.2'

def update():
    process = subprocess.Popen("UpdateTool.exe", shell=True, stdin=subprocess.PIPE)
    root.destroy()

def chat():
    press(7)
    time.sleep(1)

def processCapt():
    url = f'https://{captchahost}uploader'
    failCapt = 1
    while failCapt == 1:
        checkSend = 0
        time.sleep(1)
        while checkSend == 0:
            time.sleep(1)
            cap_capt()
            files = {'file': open('captcha.png', 'rb')}
            r = requests.post(url, files=files)
            if r:
                if r.text != 'busy':
                    idCap = r.text
                    checkSend = 1

        time.sleep(6)
        result = '0'
        prev = time.time()
        while result == '0':
            if time.time() - prev > 300:
                break
            r2 = requests.get(f'https://{captchahost}passcap?id={idCap}')
            if r2.text == '0' or not r2:
                time.sleep(2)
            else:
                result = r2.text
        if result != '0':
            for i in range(len(result)):
                press2(int(result[i]))
            press(8)
        time.sleep(1.3)
        if checkCapt() == 0:
            failCapt = 0
    press(5)

isConnect = 0
def connectEmu():
    global isConnect
    time.sleep(3)
    # print(EmuName.get())
    try:
        emuConnectName = init_Emu(EmuName.get())
        messagebox.showinfo("FishShadow", f'Đã kết nối với {emuConnectName}')
        connectB.config(bg='#60d394')
        isConnect = 1
    except:
        messagebox.showwarning("FishShadow", "Không tìm thấy giả lập!")

def handlSetUp():
    global screenPos
    if isConnect == 1:
        screenPos = setUp()
        if screenPos != -1:
            config.set("Fishing_Area_Position", "Top_left_X", str(screenPos[0][0]))
            config.set("Fishing_Area_Position", "Top_left_Y", str(screenPos[0][1]))
            config.set("Fishing_Area_Position", "Bottom_right_X", str(screenPos[1][0]))
            config.set("Fishing_Area_Position", "Bottom_right_Y", str(screenPos[1][1]))
            config.set("Exclamation_Mark_Position", "Center_X", str(screenPos[2][0]))
            config.set("Exclamation_Mark_Position", "Center_Y", str(screenPos[2][1]))
            with open('setup.ini', 'w') as configfile:
                config.write(configfile)
    else:
        messagebox.showwarning("FishShadow", "Kết nối với giả lập trước!")

# def threadSetup():
#     t1 = threading.Thread(target=handlSetUp)
#     t1.start()
exit_event = threading.Event()
end_vid_event = threading.Event()
def threadPlay():
    if isConnect == 1:
        exit_event.clear()
        playButton.config(text='Pause', bg='#ee6055', command=stopPlay)
        t2 = threading.Thread(target=playMode)
        t2.start()
    else:
        messagebox.showwarning("FishShadow", "Vui lòng kết nối với giả lập trước!")
def stopPlay():
    exit_event.set()
    playButton.config(text='PlayMode', bg='#60d394', command=threadPlay)

# hotTime1 = [9, 10, 11, 12, 17, 18, 19, 20]
# hotTime2 = [10, 11, 12, 17, 18, 19]
# hotTime3 = []
cdef int modeAuto = 0
# hotTime = hotTime1

url1 = "https://nhat05027.github.io/webauto/"
rep1 = requests.get(url1)
host = rep1.text

# def checkTime():
#     now = datetime.now()
#     hour = int(now.strftime('%H'))
#     for h in hotTime:
#         if hour == h:
#             messagebox.showwarning("Cảnh Báo", f'Bây giờ là giờ cao điểm {h}h nên sẽ khóa tool. Giờ cao điểm: {hotTime}. Nâng cấp lên key Platium để không giới hạn giờ cao điểm!!')
#             return 1
#     return 0
def logOut(key):
    url = host + key + "&state=0"
    raw = requests.get(url)
    rep = raw.text
    if rep == "Offline":
        messagebox.showinfo("Key", "Đã Đăng xuất Key khỏi máy tính khác. Vui lòng khởi động lại tool!!")
def checkMode(key, mess = 0):
    global modeAuto, checkCrack
    url = host + key
    try:
        raw = requests.get(url)
        rep = raw.text
        if rep == "Free":
            if mess == 1:
                messagebox.showinfo("Key", "Tài Khoản FREE KHÔNG tự động skip cá và các tính năng khác!")
            # hotTime = hotTime1
            modeAuto = 1
            checkCrack = 0
            License_key.config(text="Loại key: Free", fg='white', bg='green',font='Helvetica 8 bold')
        elif rep == "Preminium":
            if mess == 1:
                messagebox.showinfo("Key", "Tài Khoản GOLD tự động skip cá + Giới hạn giờ cao điểm 10h-13h và 17h-20h")
            # hotTime = hotTime2
            modeAuto = 0
            checkCrack = 0
            License_key.config(text="Loại key: Gold", fg='black', bg='yellow', font='Helvetica 8 bold')
        elif rep == "PreminiumVIP":
            if mess == 1:
                messagebox.showinfo("Key", "Tài Khoản Platium tự động skip cá + Không Giới hạn giờ cao điểm")
            # hotTime = hotTime3
            modeAuto = 3
            checkCrack = 0
            License_key.config(text="Loại key: Platium", fg='black', bg='cyan', font='Helvetica 8 bold')
        elif rep == "Error":
            messagebox.showwarning("Key", "Key bị lỗi vui lòng check lại key!")
            # hotTime = hotTime1
            modeAuto = 0
            noneKey()
            License_key.config(text="Lỗi key!!", fg='red')
        elif rep == "Expried":
            messagebox.showwarning("Key", "Key hết hạn vui lòng check lại key!")
            # hotTime = hotTime1
            modeAuto = 0
            noneKey()
            License_key.config(text="Key hết hạn!!", fg='red')
        elif rep == "Online":
            cfff = messagebox.askyesno("Key", "Key đang được người khác sử dụng.Có chắc đây là key của bạn! ")
            # hotTime = hotTime1
            modeAuto = 0
            License_key.config(text="Key đã có người khác đăng nhập!!", fg='red')
            if cfff == 1:
                logOut(key)
        else:
            messagebox.showwarning("Key", "Key bị lỗi vui lòng check lại key!")
            # hotTime = hotTime1
            modeAuto = 0
            noneKey()
            License_key.config(text="Key bị lỗi!!", fg='red')
    except:
        checkCrack += 1
        if checkCrack > 5:
            messagebox.showwarning("Key", "Key bị lỗi vui lòng check lại key!")
            # hotTime = hotTime1
            modeAuto = 0
            noneKey()
            License_key.config(text="Key bị lỗi!!", fg='red')

# config
config = ConfigParser()
config.read("setup.ini")

# if not config.has_option('Key_Map', 'rodpos'):
#     config.set('Key_Map', 'rodpos', '1')
#     config.set('Key_Map', 'Open_Bag', '0')
#     config.set('Setting', 'threshold_fish', '3')
#     with open('setup.ini', 'w') as configfile:
#         config.write(configfile)

key = config['License_Key']['key']
tai_khoan = config['User_Name']['username']


settingName = ["Đỗ trễ giữa mỗi lần bấm (s)","Đỗ trễ quét hồ câu","Độ nhạy giật cần (1-10)","Vật thể nhỏ nhất","Vật thể lớn nhất", "Độ nhạy nhận biết môi trường MagicNum", "Độ nhạy nhận biết màu sắc MagicNum", "Độ nhạy bảo quản cá"]
delay = float(config['Setting']['delay'])
delayFishing = float(config['Setting']['delayFishing'])
thresholdFish = int(config['Setting']['Threshold_Fish'])
lowArea = int(config['Setting']['Low_Area'])
highArea = int(config['Setting']['High_Area'])
magicNumThresh = int(config['Setting']['thresholdMagicNum'])
magicNumThreshColor = int(config['Setting']['thresholdcolorMagic'])
thresholdStoreFish = int(config['Setting']['thresholdStoreFish'])
thresholdfixRod = int(config['Setting']['thresholdFix'])
valueSetting = [delay,delayFishing,thresholdFish,lowArea,highArea, magicNumThresh, magicNumThreshColor, thresholdStoreFish]

screenPos = [
             (int(config['Fishing_Area_Position']['Top_left_X']),int(config['Fishing_Area_Position']['Top_left_Y'])),
             (int(config['Fishing_Area_Position']['bottom_right_X']),int(config['Fishing_Area_Position']['bottom_right_Y'])),
             (int(config['Exclamation_Mark_Position']['Center_X']),int(config['Exclamation_Mark_Position']['Center_Y'])),
             None]

fishShadowSizeArr = ["Size1", "Size2", "Size3", "Size4", "Size5"]
fishShadowSize = [0]
for val in fishShadowSizeArr:
    fishShadowSize.append(int(config['Shadow_Size_Fish'][val]))

rodPos = int(config['Key_Map']['rodPos'])
settingLabelKey = ["Nút Mở Túi", "Nút Chọn ô chứa cần câu", "Nút Chọn cần câu", "Nút Câu", "Nút Bảo quản cá", "Nút Xác nhận", "Nút nhảy", "Nút Chat Nhanh"]
keyBoarNameC = ["Open_Bag", "Tab_Rod", "Rod", "Fishing", "Store_Fish", "Confirm", "jump", "chat"]
adbTapkey = ["bagx", "bagy", "toolx", "tooly", "rod1x", "rod1y", "fishx", "fishy", "storex", "storey", "confirmx", "confirmy", "jumpx", "jumpy", "chatx", "chaty"]
keyBoard = []
adbKeyBoard = []
for i, button in enumerate(keyBoarNameC):
    keyBoard.append(config['Key_Map'][button])
keyBoard.append('6')
for i in range(8):
    adbKeyBoard.append([int(config['adb'][adbTapkey[i*2]]), int(config['adb'][adbTapkey[i*2+1]])])
adbKeyBoard.append([640, 620])


skipList = [1, 1, 1, 1, 1]

touchdev = ''
serial = ''
isADB = 0
with open('gate.txt', 'r') as fp:
    gates = fp.readlines()
for i, gate in enumerate(gates):
    gates[i] = gate.replace('\n', '')
# print(gates)
def stopADB():
    global isADB
    isADB = 0
    playAdb.config(bg='#ee6055', fg='white', text="ADB OFF", command=adb_start)
def adb_start():
    global touchdev, serial, isADB
    messagebox.showwarning("FishShadow", "Hạn chế sử dụng ADB để treo lâu dài nhe bạn, treo máy không dùng nên xài bàn phím!!")
    messagebox.showinfo("ADB", "Đang quét host giả lập của bạn vui lòng chờ!!")
    if serialEntry.get() != "None":
        serial = serialEntry.get()
    try:
        if serial == '' or serial == 0 or serial == 'None':
            serial = adbdevices()
            if serial == 0:
                for gate in gates:
                    subprocess.check_output(f'adb connect {gate}', startupinfo=si)
                    serial = adbdevices()
                    if serial != 0:
                        break
        touchdev = touchscreen_devices(serial)[0]
        playAdb.config(bg='#60d394', fg='black', text="ADB ON", command=stopADB)
        messagebox.showinfo("ADB", "Kết nối ADB thành công!")
        isADB = 1
    except:
        messagebox.showerror("Lỗi","Không thể kết nối ADB!!")
# def adb_thread():
#     t3 = threading.Thread(target=adb_start)
#     t3.start()
def press(i):
    if isADB == 0:
        pyautogui.press(keyBoard[i])
        time.sleep(delay)
    else:
        tap(touchdev, adbKeyBoard[i][0], adbKeyBoard[i][1], serial)
        time.sleep(delay)
def press2(i):
    if isADB == 0:
        capKey = ['r', 't', 'y', 'f', 'g', 'h', 'v', 'b', 'n']
        pyautogui.press(capKey[i-1])
        time.sleep(delay)
    else:
        if i < 4:
            x = 630 + 124*i
            y = 213
        elif i < 7:
            x = 630 + 124*(i-3)
            y = 339
        elif i < 10:
            x = 630 + 124*(i-6)
            y = 465
        tap(touchdev, x, y, serial)
        time.sleep(delay)       
def choseNfix():
    time.sleep(delay*2)
    press(0)
    time.sleep(delay)
    press(1)
    time.sleep(delay)
    x = time.time()
    while time.time() - x < delay:
        chckbro = checkBroken(rodPos)
        if chckbro == 1:
            press(2)
            time.sleep(delay)
            press(5)
            time.sleep(2*delay)
            press(5)
            time.sleep(2*delay)
            break
    press(5)
    time.sleep(2*delay)
    return chckbro

def inPutKey():
    global key
    key = keyI.get()
    config.set("License_Key", "key", key)
    with open('setup.ini', 'w') as configfile:
        config.write(configfile)
    checkMode(key, 1)
def noneKey():
    config.set("License_Key", "key", "None")
    with open('setup.ini', 'w') as configfile:
        config.write(configfile)

def changeSetting():
    global keyBoard, adbKeyBoard, delay, thresholdFish, delayFishing, lowArea, highArea, magicNumThresh, magicNumThreshColor, valueSetting, rodPos
    for i in range(8):
        keyBoard[i] = keyEntry[i].get()
        config.set("Key_Map", keyBoarNameC[i], str(keyBoard[i]))
        adbKeyBoard[i][0] = int(adbxEntry[i].get())
        config.set("adb", adbTapkey[i*2], str(adbKeyBoard[i][0]))
        adbKeyBoard[i][1] = int(adbyEntry[i].get())
        config.set("adb", adbTapkey[i*2+1], str(adbKeyBoard[i][1]))
    delay = float(valueSEntry[0].get())
    config.set("Setting", "delay", str(delay))
    delayFishing = float(valueSEntry[1].get())
    config.set("Setting", "delayFishing", str(delayFishing))
    thresholdFish = int(valueSEntry[2].get())
    config.set("Setting", "Threshold_Fish", str(thresholdFish))
    lowArea = int(valueSEntry[3].get())
    config.set("Setting", "Low_Area", str(lowArea))
    highArea = int(valueSEntry[4].get())
    config.set("Setting", "High_Area", str(highArea))
    magicNumThresh = int(valueSEntry[5].get())
    config.set("Setting", "thresholdMagicNum", str(magicNumThresh))
    magicNumThreshColor = int(valueSEntry[6].get())
    config.set("Setting", "thresholdcolorMagic", str(magicNumThreshColor))
    thresholdStoreFish = int(valueSEntry[7].get())
    config.set("Setting", "thresholdStoreFish", str(thresholdStoreFish))
    valueSetting = [delay, delayFishing, thresholdFish, lowArea, highArea, magicNumThresh,
                    magicNumThreshColor, thresholdStoreFish]
    rodPos = rodPoss.get()
    with open('setup.ini', 'w') as configfile:
        config.write(configfile)

def updateDevices(mserial):
    w4.children['menu'].delete(0, END)
    mserial.insert(0, 'None')
    for m in mserial:
        w4.children['menu'].add_command(label=m, command=lambda mm=m:serialEntry.set(mm))
    serialEntry.set("None")

# def updateEmu():
#     findEmu()
#     w3.children['menu'].delete(0, END)
#     for m in Emu_list:
#         w3.children['menu'].add_command(label=m, command=lambda mm=m:EmuName.set(mm))
#     EmuName.set("None")

mserial = 0
def multiADB():
    global mserial
    if hostEntry.get() == '' or hostEntry.get() == 'localhost':
        messagebox.showinfo("ADB", "Đang quét host giả lập của bạn vui lòng chờ!!")
        try:
            mserial = multiadbdevices()
            # print(mserial)
            if mserial == 0:
                for gate in gates:
                    subprocess.check_output(f'adb connect {gate}', startupinfo=si)
                    mserial = multiadbdevices()
                    if mserial != 0:
                        messagebox.showinfo("ADB", "Tìm ADB thành công!")
                        updateDevices(mserial)
                        hostEntry.delete(0, END)
                        hostEntry.insert(0, gate)
                        break
                if mserial == 0:
                    messagebox.showerror("Lỗi","Không tìm thấy host ADB!!")
            else:
                messagebox.showinfo("ADB", "Tìm ADB thành công!")
                updateDevices(mserial)
        except:
            messagebox.showerror("Lỗi","Không tìm thấy host ADB!!")
    else:
        mainGate = hostEntry.get()
        try:
            subprocess.check_output(f'adb connect {mainGate}', startupinfo=si)
            mserial = multiadbdevices()
            if mserial == 0:
                messagebox.showerror("Lỗi","Không tìm thấy host ADB!!")
            else:
                messagebox.showinfo("ADB", "Tìm ADB thành công!")
                updateDevices(mserial)
        except:
            messagebox.showerror("Lỗi","Không tìm thấy host ADB!!")


def adbRodUpdate(*args):
    global rodPos;
    rodPos = rodPoss.get()
    if rodPos < 4:
        adbKeyBoard[2][0] = 580+200*rodPos
        adbKeyBoard[2][1] = 350
    else:
        adbKeyBoard[2][0] = 580+200*(rodPos-3)
        adbKeyBoard[2][1] = 600

    config.set("Key_Map", "rodPos", str(rodPos))
    config.set("adb", "rod1x", str(adbKeyBoard[2][0]))
    config.set("adb", "rod1y", str(adbKeyBoard[2][1]))
    with open('setup.ini', 'w') as configfile:
        config.write(configfile)


def sizeSave():
    for i in range(5):
        config.set("Shadow_Size_Fish", fishShadowSizeArr[i], str(fishShadowSize[i+1]))
    with open('setup.ini', 'w') as configfile:
        config.write(configfile)

def updateMN():
    global soMT
    newMT = updateMagicNum()
    if newMT-soMT != 0:
        messagebox.showinfo("MagicNumber", f'Đã cập nhật thêm {newMT-soMT} màu hồ nước!')
        soMT = newMT
    else:
        messagebox.showinfo("MagicNumber", "Dữ liệu MagicNumber của bạn đang là mới nhất!")

noRecordMode = 0
def doBongM():
    global noRecordMode
    noRecordMode = 0
    kodoBong.config(bg='#ee6055', fg='white', text="Không Đo", command=koDoBongM)
def koDoBongM():
    global noRecordMode
    noRecordMode = 1
    kodoBong.config(bg='#60d394', fg='black', text="Đo Bóng", command=doBongM)

def reset():
    chc = messagebox.askyesno("Reset", "Bạn có muốn khôi phục về cài đặt mặc định, mọi thông số setting sẽ khôi phục lại như lúc đầu ?")
    if chc == 1:
        f = open("factorySetup.ini", "r")
        factory = f.read()
        f.close()
        f1 = open("setup.ini", "w")
        f1.write(factory)
        f1.close()
        messagebox.showinfo("Reset", "Đã khôi phục về cài đặt gốc! Vui lòng khởi động lại.")

def chiDan():
    f = codecs.open("fishData.txt", "r", "utf-8")
    raw = f.read()
    f.close()
    raww = raw.split('\r\n')
    fishData = []
    for line in raww:
        dad = line.split('-')
        fishData.append(dad)
    if modeAuto == 0 or modeAuto == 1:
        messagebox.showinfo("FishShadow", "Vui lòng nâng cấp để sử dụng tính năng này!!")
    else:
        now = datetime.now()
        minutes = int(now.strftime('%M'))
        K0['text'] = f'Bây giờ là phút thứ: {minutes}'
        i = 0
        for d in fishData:
            if minutes >= int(d[0]) and minutes <= int(d[1]):
                KLabel[i]['text'] = f'{d[0]}-{d[1]}| {d[2]}| {d[3]}| {d[4]}'
                i+=1
        for k in range(i, 7, 1):
            KLabel[k]['text'] = ''

def keyProtection():
    t = messagebox.askyesno("Key", "Bạn có muốn coi mã key ?")
    if t == 1:
        keyI.config(show='')
        hien.config(text='Ẩn', command=hideKey)
def hideKey():
    keyI.config(show='*')
    hien.config(text='Hiện', command=keyProtection)

# UI
root = Tk()
root.title("FishShadow 3")
root.iconbitmap('icon.ico')
root.configure(background='white')

keyEntry = [0]*8
adbxEntry = [0]*8
adbyEntry = [0]*8
valueSEntry = [0]*8
hostEntry = StringVar()
serialEntry = StringVar()
serialEntry.set("None")
keyI = StringVar()
ra = IntVar()
ra.set(1)
autoChat = IntVar()
autoChat.set(0)
sizeEntry = [0]*5
place = StringVar()
place.set("All")
rodPoss = IntVar()
rodPoss.set(rodPos)
EmuName = StringVar()
EmuName.set('LD Player')
thongkeName = StringVar()
# thongkeName.set('None')
def settingWindow():
    global valueSetting,keyBoard, keyI, ra, hostEntry, serialEntry, hien
    newWindow = Toplevel(root)
    newWindow.title("Cài đặt")
    newWindow.iconbitmap('settingicon.ico')
    newWindow.configure(background='white')

    try:
        remainingTime = checkKeyTime(key)
    except:
        remainingTime = -1

    myNoteBook = ttk.Notebook(newWindow)
    myNoteBook.grid(row=1, column=0, columnspan=2, sticky=E + W)

    frameKey = LabelFrame(newWindow, text='Key', padx=10, pady=10)
    frameKey.grid(row=0, column=0, columnspan=2, sticky=E + W)
    if remainingTime == -1:
        Label(frameKey, text=f'Key không hợp lệ!', font='Helvetica 9 bold', fg='red').grid(row=0, column=0, sticky=W)
    else:
        Label(frameKey, text=f'Hết hạn sau: {remainingTime} giờ', font='Helvetica 9 bold', fg='red').grid(row=0, column=0, sticky=W)
    keyI = Entry(frameKey, show="*", width=55)
    keyI.grid(row=1, column=0, columnspan=2)
    keyI.insert(0, key)
    hien = Button(frameKey, text="Hiện", command=keyProtection, width=5)
    hien.grid(row=1, column=2, sticky=E)
    keyButton = Button(frameKey, text="OK", width=20, bg='white', command=lambda: [inPutKey(), newWindow.destroy()])
    keyButton.grid(row=2, column=1, columnspan=2, padx=5,pady =5, sticky=E)
    Button(frameKey, text="Mua Key", bg='yellow', command=openweb).grid(row=2, column=0, padx=5,pady =5, sticky=W)

    frameKeyBoard = Frame(myNoteBook, padx=10, pady=10)
    frameKeyBoard.pack()
    Label(frameKeyBoard,text="Bàn Phím").grid(row=0, column=1)
    Label(frameKeyBoard, text="Tọa độ X (ADB)").grid(row=0, column=2)
    Label(frameKeyBoard, text="Tọa độ Y (ADB)").grid(row=0, column=3)
    for i, name in enumerate(settingLabelKey):
        Label(frameKeyBoard,text=name).grid(row=i+1, column=0, sticky=W)
        keyEntry[i] = Entry(frameKeyBoard, width=10)
        keyEntry[i].grid(row=i+1, column=1, padx=5)
        keyEntry[i].insert(0, keyBoard[i])
        adbxEntry[i] = Entry(frameKeyBoard, width=13)
        adbxEntry[i].grid(row=i+1, column=2, padx=5)
        adbxEntry[i].insert(0, adbKeyBoard[i][0])
        adbyEntry[i] = Entry(frameKeyBoard, width=13)
        adbyEntry[i].grid(row=i+1, column=3, padx=5)
        adbyEntry[i].insert(0, adbKeyBoard[i][1])
    

    frameSoCa = Frame(myNoteBook, padx=10, pady=10)
    frameSoCa.pack()
    for i, name in enumerate(settingName):
        Label(frameSoCa, text=name).grid(row=i+2, column=0, sticky=W)
        valueSEntry[i] = Entry(frameSoCa)
        valueSEntry[i].grid(row=i+2, column=1, columnspan=3)
        valueSEntry[i].insert(0, valueSetting[i])
    Label(frameSoCa, text="Auto Chat khi bị làm phiền:").grid(row=11, column=0, sticky=W)
    Radiobutton(frameSoCa, text="Bật", variable=autoChat, value=1).grid(row=11, column=2, sticky=W)
    Radiobutton(frameSoCa, text="Tắt", variable=autoChat, value=0).grid(row=11, column=1, sticky=W)

    frameModeCa = Frame(myNoteBook, padx=10, pady=10)
    frameSoCa.pack()
    Label(frameModeCa, text="Chế độ nhận diện cá").grid(row=0, column=0, sticky=W)
    Radiobutton(frameModeCa, text="Magic Number", variable=ra, value=1).grid(row=1, column=0, sticky=W)
    Button(frameModeCa, text="Update MagicNumber", bg='yellow', command=lambda: [updateMN(),newWindow.destroy()]).grid(row=1, column=1, sticky=W)
    Radiobutton(frameModeCa, text="Mode Thời gian game", variable=ra, value=2).grid(row=2, column=0, sticky=W)
    w = OptionMenu(frameModeCa, place, "All", "Home Town", "Camp", "Biển")
    w.config(width=10)
    w.grid(row=2, column=1, sticky=W)

    Button(newWindow, bg='white', width=20,text="OK",command=lambda: [changeSetting(), newWindow.destroy()]).grid(row=3, column=1, sticky=E, padx=10, pady=10)
    Button(newWindow, width=8, text="Reset", fg='black', bg='yellow', command=reset).grid(row=3, column=0, padx=5, pady=5, sticky=W)

    myNoteBook.add(frameSoCa, text="Thông số")
    myNoteBook.add(frameModeCa, text="Mode Câu")
    myNoteBook.add(frameKeyBoard, text="Phím tắt")


frameControl = LabelFrame(root, text='Bảng điều khiển', padx=10, pady=10, font='Helvetica 8 bold')
frameControl.grid(row=2, column=0, columnspan=2, sticky=E + W)
frameControl.configure(background='white')


Button(frameControl, width=8, text="Setting", bg='cyan', command= settingWindow).grid(row=0, column=0, columnspan=2, padx=5, pady=5)

Button(frameControl, width=8, text="SetUP", bg='orange', command= handlSetUp).grid(row=0, column=2, padx=5, pady=5)

kodoBong = Button(frameControl, width=8, bg='#ee6055', fg='white', text="Không Đo", command=koDoBongM)
kodoBong.grid(row=0, column=3, padx=5, pady=5)

playAdb = Button(frameControl, width=8, bg='#ee6055', fg='white', text="ADB OFF", command=adb_start)
playAdb.grid(row=0, column=4, padx=5, pady=5)

playButton = Button(frameControl, width=8, text="PlayMode", fg='black', bg='#60d394', command=threadPlay)
playButton.grid(row=0, column=5, padx=5, pady=5)


lablescale = [0]*5
slide = [0]*5
checkBox = [0]*5
sizeShadowScale = []
sizeShadowScale1 = []

def updateSlideUI(*args):
    for i in range(5):
        fishShadowSize[i+1] = sizeShadowScale[i].get() + fishShadowSize[i]
        sizeShadowScale1[i].set(fishShadowSize[i+1])

def updateSlideUI1(event):
    for i in range(5):
        if sizeShadowScale1[i].get() == '':
            sizeShadowScale1[i].set(0)
        fishShadowSize[i+1] = sizeShadowScale1[i].get()
        sizeShadowScale[i].set(fishShadowSize[i+1]-fishShadowSize[i])
    for i in range(5):
        fishShadowSize[i+1] = sizeShadowScale[i].get() + fishShadowSize[i]
        sizeShadowScale1[i].set(fishShadowSize[i+1])

def updateSkipList():
    for i in range(5):
        skipList[i] = cvars[i].get()
cvars = []

frameGame = LabelFrame(root, text='Game',font='Helvetica 8 bold')
frameGame.grid(row=3, column=0, columnspan=2, sticky=E + W)
frameGame.configure(background='white')
myNoteBook1 = ttk.Notebook(frameGame)
myNoteBook1.grid(row=0, column=0, columnspan=2, sticky=E + W)

frameWin = Frame(myNoteBook1, padx=10, pady=10)
frameWin.pack()
frameWin.configure(background='white')
Label(frameWin, text='Loại giả lập:', font='Helvetica 9 bold', bg='white').grid(row=0, column=0, sticky=W)
Emu_list = ['LD Player', 'MEmu', 'BlueStack 5']
w3 = OptionMenu(frameWin, EmuName, *Emu_list)
w3.config(width=15, bg='white', padx=5)
w3.grid(row=0, column=1, sticky=W)
connectB = Button(frameWin, width=8, text="Kết nối", bg='#ee6055', command=connectEmu)
connectB.grid(row=0, column=2, padx=15, pady=5, sticky=E)
def submitName():
    global tai_khoan
    tai_khoan = thongkeName.get()
    config.set("User_Name", "username", tai_khoan)
    with open('setup.ini', 'w') as configfile:
        config.write(configfile)
Label(frameWin, text="Tài khoản thống kê: ", font='Helvetica 9 bold', bg='white').grid(row=1, column=0, sticky=W)
thongkeName = Entry(frameWin, width=20)
thongkeName.grid(row=1, column=1, sticky=W, padx=5)
thongkeName.insert(0, tai_khoan)
Button(frameWin, width=8, text="OK", bg='yellow', command=submitName).grid(row=1, column=2, padx=15, pady=5, sticky=E)

Label(frameWin, text="Treo nhiều giả lập thì cài nhe!", fg='red', font='Helvetica 9 bold', bg='white').grid(row=2, column=0, columnspan=3, sticky=W)
Label(frameWin, text="Host ADB", font='Helvetica 9 bold', bg='white').grid(row=3, column=0, sticky=W)
hostEntry = Entry(frameWin, width=20)
hostEntry.grid(row=3, column=1, sticky=W, padx=5)
Button(frameWin, width=8, text="Find", bg='yellow', command=multiADB).grid(row=3, column=2, padx=15, pady=5, sticky=E)
Label(frameWin, text="Tên thiết bị", font='Helvetica 9 bold', bg='white').grid(row=4, column=0, sticky=W)
if mserial == 0:
    mserial = ["None"]
w4 = OptionMenu(frameWin, serialEntry, *mserial)
w4.config(width=15, bg='white', padx=5)
w4.grid(row=4, column=1, sticky=W)

frameSize = Frame(myNoteBook1, padx=10, pady=10)
frameSize.pack()
frameSize.configure(background='white')
Label(frameSize, text='Chỉnh size cá:', font='Helvetica 9 bold', fg='red', bg='white').grid(row=0, column=0, columnspan=3, sticky=W)
Label(frameSize, text='Câu', font='Helvetica 9 bold', fg='red', bg='white').grid(row=0, column=6)
for i in range(5):
    lablescale[i] = Label(frameSize, text=f'Size {i+1} < ', bg='white', font='Helvetica 9 bold')
    lablescale[i].grid(row=1+i, column=0, sticky=W)

    sizeShadowScale.append(IntVar())
    sizeShadowScale1.append(IntVar())
    sizeShadowScale[i].set(fishShadowSize[i+1]-fishShadowSize[i])
    sizeShadowScale1[i].set(fishShadowSize[i+1])
    
    sizeEntry[i] = Entry(frameSize, width=4, textvariable=str(sizeShadowScale1[i]), selectforeground='white', font='Helvetica 9 bold')
    sizeEntry[i].grid(row=1+i, column=1, sticky=W)
    sizeEntry[i].bind('<Return>', updateSlideUI1)
    slide[i] = Scale(frameSize, from_=0, to=1000, variable=sizeShadowScale[i], showvalue=0, command=updateSlideUI, length=350, orient=HORIZONTAL, bg='white', troughcolor='yellow', activebackground='red')
    slide[i].grid(row=1+i, column=2, columnspan=4, padx=5)

    cvars.append(IntVar())
    checkBox[i] = Checkbutton(frameSize, bg='white', activebackground='yellow', variable=cvars[i], onvalue=1, offvalue=0, command=updateSkipList)
    checkBox[i].grid(row=1+i, column=6, padx=5)
Button(frameSize, width=8, text='Lưu Size', bg='pink', command=sizeSave).grid(row=6, column=0, columnspan=2)
Label(frameSize, bg='white', text="Vị trí cần câu:", font='Helvetica 9 bold').grid(row=6, column=3, sticky=E)
w1 = OptionMenu(frameSize, rodPoss, 1, 2, 3, 4, 5, 6, command=adbRodUpdate)
w1.config(bg='white')
w1.grid(row=6, column=4, sticky=W)

frameVideo = Frame(myNoteBook1, padx=10, pady=10)
frameVideo.pack()
frameVideo.configure(background='white')
LL = Label(frameVideo, text="Thời gian:", bg='white', font='Helvetica 8 bold')
LL.grid(row=0, column=0, sticky=W)

def vidEvent():
    end_vid_event.set()
    vidButton.config(text="Bật video", bg='cyan', command= lambda: [end_vid_event.clear(), vidButton.config(text="Tắt video", bg='pink',command=vidEvent)])
vidButton = Button(frameVideo, width=8, text="Tắt video", bg='pink', command=vidEvent)
vidButton.grid(row=0, column=2, padx=5, pady=5)

L1 = Label(frameVideo, bg='white')
L1.grid(row=1, column=0, columnspan=2, sticky=W)
L1c = Label(frameVideo, text="Diện tích:     Loại Size:", bg='white', font='Helvetica 8 bold')
L1c.grid(row=2, column=0)
L2 = Label(frameVideo, bg='white')
L2.grid(row=1, column=2, sticky=E)
L2c = Label(frameVideo, text="Đợi cá", bg='white', font='Helvetica 8 bold')
L2c.grid(row=2, column=2)
L3 = Label(frameVideo, bg='white')
L3.grid(row=3, column=0, columnspan=2, sticky=W)
L3c = Label(frameVideo, text="", bg='white', font='Helvetica 9 bold')
L3c.grid(row=4, column=0, sticky=W)

frameChart = Frame(myNoteBook1, padx=10, pady=10)
frameChart.pack()
frameChart.configure(background='white')
Z1 = Label(frameChart, text="Tổng số cá câu được: ", bg='white', fg='#ee6055', font='Helvetica 10 bold')
Z1.grid(row=0, column=0, sticky=W)
Z2 = Label(frameChart, text="Số cá xám câu được: ", bg='white', fg='grey', font='Helvetica 9 bold')
Z2.grid(row=1, column=0, sticky=W)
Z3 = Label(frameChart, text="Số cá xanh lá câu được: ", bg='white', fg='#60d394', font='Helvetica 9 bold')
Z3.grid(row=2, column=0, sticky=W)
Z4 = Label(frameChart, text="Số cá xanh biển câu được: ", bg='white', fg='#5cc9ed', font='Helvetica 9 bold')
Z4.grid(row=3, column=0, sticky=W)
Z5 = Label(frameChart, text="Số cá tím câu được: ", bg='white', fg='#ab87ff', font='Helvetica 9 bold')
Z5.grid(row=4, column=0, sticky=W)
Z6 = Label(frameChart, text="Rác + Không biết: ", bg='white', fg='black', font='Helvetica 9 bold')
Z6.grid(row=5, column=0, sticky=W)
Z7 = Label(frameChart, text="Số lần đứt dây: ", bg='white', fg='orange', font='Helvetica 9 bold')
Z7.grid(row=6, column=0, sticky=W)
Z8 = Label(frameChart, text="Số lần sửa cần câu: ", bg='white', fg='green', font='Helvetica 9 bold')
Z8.grid(row=7, column=0, sticky=W)
Z9 = Label(frameChart, text="Số lần skip cá: ", bg='white', fg='green', font='Helvetica 9 bold')
Z9.grid(row=8, column=0, sticky=W)


frameTip = Frame(myNoteBook1, padx=10, pady=10)
frameTip.pack()
frameTip.configure(background='white')
biKip = Button(frameTip, text="Hãy dẫn lối cho tôi!!", bg="#5cc9ed", font='Helvetica 9 bold', command=chiDan)
biKip.grid(row=0, column=0, sticky=W)
K0 = Label(frameTip, text="Bây giờ là phút thứ: ", bg='white', fg='black', font='Helvetica 10 bold')
K0.grid(row=1, column=0, sticky=W)
KLabel = [0]*7
for i in range(7):
    KLabel[i] = Label(frameTip, bg='white', fg='#ee6055', font='Helvetica 9 bold')
    KLabel[i].grid(row=2+i, column=0, sticky=W)

myNoteBook1.add(frameWin, text="Giả lập")
myNoteBook1.add(frameSize, text="Size Cá")
myNoteBook1.add(frameVideo, text="Game")
myNoteBook1.add(frameChart, text="Thống kê")
myNoteBook1.add(frameTip, text="Săn Cá")

License_key = Label(root)
License_key.grid(row=0, column=0, sticky=W, padx=5, pady=5)
Label(root, text=f'FishShadow ver {oversion}', fg='purple', bg='white', font='Helvetica 8 bold').grid(row=4, column=1, sticky=E)
Label(root, text='https://autoplaytogether.tk/', fg='orange', bg='white', font='Helvetica 8 bold').grid(row=4, column=0, sticky=W)

def updateFish(soCaCau, tenCa, tenCaVM, broken, fix, skip, mode):
    if mode == 1 or mode == 0:
        Z1['text'] = 'Nâng cấp Platium để mở khóa'
    else:
        Z1['text'] = f'Tổng số cá câu được: {soCaCau}'
        Z2['text'] = f'Số cá xám câu được: {tenCa[1]}, Vương miện: {tenCaVM[1]}'
        Z3['text'] = f'Số cá xanh lá câu được: {tenCa[2]}, Vương miện: {tenCaVM[2]}'
        Z4['text'] = f'Số cá xanh biển câu được: {tenCa[3]}, Vương miện: {tenCaVM[3]}'
        Z5['text'] = f'Số cá tím câu được: {tenCa[4]}, Vương miện: {tenCaVM[4]}'
        Z6['text'] = f'Rác + Không biết: {tenCa[0]}'
        Z7['text'] = f'Số lần đứt dây: {broken}'
        Z8['text'] = f'Số lần sửa cần câu: {fix}'
        Z9['text'] = f'Số lần skip cá: {skip}'

if key == "None":
    messagebox.showwarning("Key", "Chưa có key, vào Setting nhập key")
    License_key.config(text="Chưa có key!!", fg='red', bg='white', font='Helvetica 8 bold')
else:
    checkMode(key)


url3 = "https://nhat05027.github.io/webauto/version3.txt"
rep3 = requests.get(url3)
nversion = rep3.text
nversion = nversion.replace('\n', '')
if nversion != oversion:
    ff = messagebox.askyesno("Cập Nhật", f'Đã có phiên bản mới {nversion}, bạn có muốn cập nhật?')
    if ff == 1:
        update()

url4 = "https://nhat05027.github.io/webauto/captcha.txt"
rep4 = requests.get(url4)
captchahost = rep4.text
captchahost = captchahost.replace('\n', '')

cdef int soCaCau = 0
cdef int fixCount = 0
cdef int brokenRope = 0
cdef int skipCount = 0
tenCa = [0]*5
tenCaVM = [0]*5
def playMode():
    global tenCa, tenCaVM, soCaCau, brokenRope, skipCount, fixCount
    # try:
    #     if EmuName.get() == "None":
    #         init_Emu(None)
    #     else:
    #         init_Emu(EmuName.get())
    # except:
    #     messagebox.showwarning("FishShadow", "Không tìm thấy giả lập!")
    if checkTool() > 3:
        messagebox.showwarning("FishShadow", "Bạn đã xài tối đa số giả lập cho phép")

    if key == "None":
        messagebox.showwarning("Key", "Chưa có key, vào Setting nhập key")
        License_key.config(text="Chưa có key!!", fg='red')
    else:
        checkMode(key)
    # denyTime = checkTime()
    cdef int c = 0
    cdef int gg = 0
    cdef int sizee = 0
    cdef int skipCountMax = 5
    cdef int newMode = 0
    cdef int fCaRun = 0

    start = time.time()

    if isADB == 0: time.sleep(4)
    updateFish(soCaCau, tenCa, tenCaVM, brokenRope, fixCount, skipCount, modeAuto)
    initRealTime(place.get())
    playTime = time.time()
    while True:
        if time.time() - playTime > 300:
            # denyTime = checkTime()
            checkMode(key)
            playTime= time.time()
            if tai_khoan != 'None':
                dataOnl(tai_khoan, soCaCau, tenCa, tenCaVM, brokenRope, fixCount, skipCount, modeAuto)

        if exit_event.is_set():
            break

        if modeAuto != 0:
            if gg == 0:
                ttt = time.time()
                while time.time() - ttt < 2*delay:
                    chckfix = quickFix(thresholdfixRod)
                    if chckfix == 1:
                        tit = choseNfix()
                        fixCount += tit
                        break
                time.sleep(delay)
                if checkCapt() == 1:
                    processCapt()
                updateFish(soCaCau, tenCa, tenCaVM, brokenRope, fixCount, skipCount, modeAuto)
                kk = 0
                fCaRun = 1
                press(3)
                if modeAuto == 1 or noRecordMode == 1:
                    gg = 3
                else:
                    gg = 1
                start = time.time()
                time.sleep(delayFishing)
            elif gg == 1:
                if ra.get() == 1:
                    day = calculateDayMagicNumber(screenPos[0], screenPos[1], magicNumThreshColor, magicNumThresh)
                    newMode = 0
                elif ra.get() == 2:
                    day = realTimeMode()
                    newMode = 1
                if day == 0:
                    LL['text'] = "Thời gian: Không biết"
                    L1c['text'] = f'Diện tích: ??? Loại Size: ???'
                    sizee = 0
                    gg = 3
                    L2c['text'] = "Đợi cá cắn !!"
                else:
                    if day == 1: LL['text'] = "Thời gian: Ban ngày"
                    elif day == 2: LL['text'] = "Thời gian: Ban đêm"
                    elif day == 3: LL['text'] = "Thời gian: Hoàng hôn"
                    elif day == 4: LL['text'] = "Địa điểm: Trong nhà"
                    elif day == 5:LL['text'] = "Thời gian: Sáng sớm"
                    gg = 2
                    L1c['text'] = "Diện tích:     Loại Size:"
                    L2c['text'] = "Đợi cá"
            elif gg == 2:
                sizeList = []
                size, img2 = calculateFish(screenPos[0], screenPos[1], lowArea, highArea, newMode)
                if not end_vid_event.is_set():
                    img2 = cv2.cvtColor(img2, cv2.COLOR_BGR2RGB)
                    img2 = ImageTk.PhotoImage(Image.fromarray(img2))
                    L1['image'] = img2
                if size > 0 and c == 0:
                    time.sleep(0.5)
                    c += 1
                elif size > 0 and c != 0:
                    sizeList.append(size)
                    c += 1
                    if c > 6:
                        sizee = round(sum(sizeList) / 6)
                        L1c['text'] = f'Diện tích: {sizee} Loại Size:'
                        if sizee > fishShadowSize[0] and sizee <= fishShadowSize[1]:
                            L1c['text'] = f'Diện tích: {sizee} Loại Size: 1'
                            if skipList[0] == 0:
                                L2c['text'] = "Skip Size 1"
                                gg = 4
                            else:
                                gg = 3
                                L2c['text'] = "Đợi cá cắn !!"
                        elif sizee > fishShadowSize[1] and sizee <= fishShadowSize[2]:
                            L1c['text'] = f'Diện tích: {sizee} Loại Size: 2'
                            if skipList[1] == 0:
                                L2c['text'] = "Skip Size 2"
                                gg = 4
                            else:
                                gg = 3
                                L2c['text'] = "Đợi cá cắn !!"
                        elif sizee > fishShadowSize[2] and sizee <= fishShadowSize[3]:
                            L1c['text'] = f'Diện tích: {sizee} Loại Size: 3'
                            if skipList[2] == 0:
                                L2c['text'] = "Skip Size 3"
                                gg = 4
                            else:
                                gg = 3
                                L2c['text'] = "Đợi cá cắn !!"
                        elif sizee > fishShadowSize[3] and sizee <= fishShadowSize[4]:
                            L1c['text'] = f'Diện tích: {sizee} Loại Size: 4'
                            if skipList[3] == 0:
                                L2c['text'] = "Skip Size 4"
                                gg = 4
                            else:
                                gg = 3
                                L2c['text'] = "Đợi cá cắn !!"
                        elif sizee > fishShadowSize[4] and sizee <= fishShadowSize[5]:
                            L1c['text'] = f'Diện tích: {sizee} Loại Size: 5'
                            if skipList[4] == 0:
                                L2c['text'] = "Skip Size 5"
                                gg = 4
                            else:
                                gg = 3
                                L2c['text'] = "Đợi cá cắn !!"
                        else:
                            L1c['text'] = f'Diện tích: {sizee} Loại Size: Chưa set'
                            gg = 3
                            L2c['text'] = "Đợi cá cắn !!"
                        c = 0
                elif time.time() - start > 15:
                    L1c['text'] = f'Diện tích: ??? Loại Size: ???'
                    gg = 3
            elif gg == 3:
                if kk == 0:
                    if fCaRun == 1:
                        imgg = isFishEat(screenPos[2], thresholdFish, fCaRun)
                        fCaRun = 0
                        imgg = cv2.cvtColor(imgg, cv2.COLOR_BGR2RGB)
                        imgg = ImageTk.PhotoImage(Image.fromarray(imgg))
                        L2['image'] = imgg
                    else:
                        isEat, img3 = isFishEat(screenPos[2], thresholdFish)
                        if isEat == 0:
                            if time.time() - start > 90:
                                chck, _ = dutday(thresholdStoreFish)
                                if chck == 1:                           
                                    press(4)
                                    time.sleep(delay)
                                gg = 0
                                tit = choseNfix()
                                fixCount += tit
                        elif isEat == 1:
                            L2c['text'] = "Cá cắn !!"
                            press(6)
                            img3 = cv2.cvtColor(img3, cv2.COLOR_BGR2RGB)
                            img3 = ImageTk.PhotoImage(Image.fromarray(img3))
                            L2['image'] = img3
                            kk = 1
                            waitStore = time.time()

                elif kk == 1:
                    chck, img4 = dutday(thresholdStoreFish)
                    if chck == 1:
                        time.sleep(delay)
                        ca, caCrow = checkRFish()
                        if caCrow == 0:
                            tenCa[ca] += 1
                        else:
                            tenCaVM[ca] += 1
                        time.sleep(delay)
                        press(4)
                        gg = 0
                        soCaCau += 1
                        skipCountMax = 0
                        if not end_vid_event.is_set():
                            img4 = cv2.cvtColor(img4, cv2.COLOR_BGR2RGB)
                            img4 = ImageTk.PhotoImage(Image.fromarray(img4))
                            L3['image'] = img4
                            if sizee == 0: L3c['text'] = f'Diện tích: ??? Số cá câu được: {soCaCau}'
                            else: L3c['text'] = f'Diện tích: {sizee} Số cá câu được: {soCaCau}'
                    elif chck == 0:
                        if time.time() - waitStore > 8:
                            brokenRope += 1
                            gg = 0
            elif gg == 4:
                press(6)
                skipCountMax += 1
                skipCount += 1
                if autoChat.get() == 1 and skipCountMax > 5:
                    chat()
                    skipCountMax = 0
                gg = 0

root.mainloop()