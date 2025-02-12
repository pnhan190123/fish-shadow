#cython: language_level=3
from sys import exit
import time
import pyautogui
from configparser import ConfigParser
import requests
from tkinter import *
from tkinter import messagebox
from ReadWriteMemory import ReadWriteMemory
import threading
import webbrowser
from tkinter import ttk
from datetime import datetime
import pyximport; pyximport.install()
from adb_tap import *
from image import *
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
    usname = datas[2]
    r = requests.get(f'https://autocaucaserver.tk/getTime.php?nm={usname}')
    remainTime = int(r.text) - int(time.time())
    if remainTime > 0:
        return round((remainTime/3600), 2)
    else:
        return 0
def getNameKey(key):
    raw = codecs.encode(key, 'rot_13')
    raw = raw.encode('ascii')
    raw = base64.b64decode(raw)
    raw = raw.decode('ascii')
    raw = raw.encode('ascii')
    raw = base64.b64decode(raw)
    raw = raw.decode('ascii')
    datas = raw.split("#")
    return datas[2]


cdef int checkCrack = 0
wurl = 'https://autoplaytogether.tk/'
def openweb():
    webbrowser.open(wurl, new=1)

oversion = '2.5'

def update():
    process = subprocess.Popen("UpdateTool.exe", shell=True, stdin=subprocess.PIPE)
    root.destroy()

isConnect = 0
exit_event = threading.Event()
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

cdef int modeAuto = 0

url1 = "https://nhat05027.github.io/webauto/"
rep1 = requests.get(url1)
host = rep1.text

def logOut(key):
    url = host + key + "&state=0"
    raw = requests.get(url)
    rep = raw.text
    if rep == "Offline":
        messagebox.showinfo("Key", "Đã Đăng xuất Key khỏi máy tính khác. Vui lòng khởi động lại tool!!")
def checkMode(key, mess = 0):
    global modeAuto, checkCrack, nameKey
    nameKey = getNameKey(key)
    url = host + key
    try:
        raw = requests.get(url)
        rep = raw.text
        if rep == "Preminium":
            if mess == 1:
                messagebox.showinfo("Key", "Tài Khoản Platium tự động skip cá")
            modeAuto = 3
            checkCrack = 0
            License_key.config(text="Loại key: Platium-Bổ củi", fg='black', bg='cyan', font='Helvetica 8 bold')
        elif rep == "Error":
            messagebox.showwarning("Key", "Key bị lỗi vui lòng check lại key!")
            modeAuto = 0
            noneKey()
            License_key.config(text="Lỗi key!!", fg='red')
        elif rep == "Expried":
            messagebox.showwarning("Key", "Key hết hạn vui lòng check lại key!")
            modeAuto = 0
            noneKey()
            License_key.config(text="Key hết hạn!!", fg='red')
        elif rep == "Online":
            cfff = messagebox.askyesno("Key", "Key đang được người khác sử dụng.Có chắc đây là key của bạn! ")
            modeAuto = 0
            License_key.config(text="Key đã có người khác đăng nhập!!", fg='red')
            if cfff == 1:
                logOut(key)
        else:
            messagebox.showwarning("Key", "Key bị lỗi vui lòng check lại key!")
            modeAuto = 0
            noneKey()
            License_key.config(text="Key bị lỗi!!", fg='red')
    except:
        checkCrack += 1
        if checkCrack > 5:
            messagebox.showwarning("Key", "Key bị lỗi vui lòng check lại key!")
            modeAuto = 0
            noneKey()
            License_key.config(text="Key bị lỗi!!", fg='red')

# config
config = ConfigParser()
config.read("setup.ini")

if not config.has_option('User_Name', 'username'):
    config.add_section('User_Name')
    config.set('User_Name', 'username', 'None')
    with open('setup.ini', 'w') as configfile:
        config.write(configfile)

key = config['License_Key']['key']
tai_khoan = config['User_Name']['username']

rodPos = int(config['Key_Map']['rodPos'])
settingLabelKey = ["Nút Mở Túi", "Nút Chọn ô chứa cần câu", "Nút Chọn cần câu", "Nút Câu", "Nút Bảo quản cá", "Nút Xác nhận", "Nút nhảy"]
keyBoarNameC = ["Open_Bag", "Tab_Rod", "Rod", "Fishing", "Store_Fish", "Confirm", "jump"]
adbTapkey = ["bagx", "bagy", "toolx", "tooly", "rod1x", "rod1y", "fishx", "fishy", "storex", "storey", "confirmx", "confirmy", "jumpx", "jumpy"]
keyBoard = []
adbKeyBoard = []
for i, button in enumerate(keyBoarNameC):
    keyBoard.append(config['Key_Map'][button])
keyBoard.append('6')
for i in range(7):
    adbKeyBoard.append([int(config['adb'][adbTapkey[i*2]]), int(config['adb'][adbTapkey[i*2+1]])])
adbKeyBoard.append([640, 620])


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

def press(i):
    if isADB == 0:
        pyautogui.press(keyBoard[i])
    else:
        tap(touchdev, adbKeyBoard[i][0], adbKeyBoard[i][1], serial)
def press2(i):
    if isADB == 0:
        capKey = ['r', 't', 'y', 'f', 'g', 'h', 'v', 'b', 'n']
        pyautogui.press(capKey[i-1])
        time.sleep(0.5)
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
        time.sleep(0.5)       

def processCapt():
    url = f'https://{captchahost}uploader'
    failCapt = 1
    while failCapt == 1:
        checkSend = 0
        while checkSend == 0:
            time.sleep(3)
            cap_capt()
            files = {'file': open('captcha.png', 'rb')}
            myobj = {'user': nameKey}
            r = requests.post(url, files=files, data=myobj)
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
                time.sleep(3)
            else:
                result = r2.text
        if result != '0':
            if result == '999':
                messagebox.showwarning("Lỗi", "Máy bạn chưa cài phím hoặc 1 số phím cài ko đúng !")
                return 0
            else:
                for i in range(len(result)):
                    press2(int(result[i]))
                press(7)
        time.sleep(2)
        if checkCapt() == 0:
            failCapt = 0
    press(5)
    return 1

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
    global keyBoard, adbKeyBoard
    for i in range(7):
        keyBoard[i] = keyEntry[i].get()
        config.set("Key_Map", keyBoarNameC[i], str(keyBoard[i]))
        adbKeyBoard[i][0] = int(adbxEntry[i].get())
        config.set("adb", adbTapkey[i*2], str(adbKeyBoard[i][0]))
        adbKeyBoard[i][1] = int(adbyEntry[i].get())
        config.set("adb", adbTapkey[i*2+1], str(adbKeyBoard[i][1]))
    with open('setup.ini', 'w') as configfile:
        config.write(configfile)

def updateDevices(mserial):
    w4.children['menu'].delete(0, END)
    mserial.insert(0, 'None')
    for m in mserial:
        w4.children['menu'].add_command(label=m, command=lambda mm=m:serialEntry.set(mm))
    serialEntry.set("None")


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

def initProcess():
    global process, isConnect
    kk = 0
    if procesIDEntry.get() != "":
        try:
            pid = int(procesIDEntry.get(), 16)
            rwm = ReadWriteMemory()
            process = rwm.get_process_by_id(pid)
            process.open()  
            kk = 1
        except:
            kk = 0

    else:
        fdf = ['LdVBoxHeadless.exe', 'MEmuHeadless.exe', 'HD-Player.exe']
        emuName = EmuName.get()
        for i, v in enumerate(Emu_list):
            if emuName == v:
                name = fdf[i]
                break
        try:
            rwm = ReadWriteMemory()
            process = rwm.get_process_by_name(name)
            process.open()  
            kk = 1
        except:
            kk = 0

    time.sleep(3)
    try:
        emuConnectName = init_Emu(EmuName.get())
        kk += 1
    except:
        kk = 0
    if kk == 2:
        messagebox.showinfo("FishShadow", f'Đã kết nối với {emuConnectName}')
        connectB.config(bg='#60d394')
        isConnect = 1
    else:
        messagebox.showwarning("FishShadow", "Không tìm thấy giả lập!")

lastVal = [0]*4
def dataOnl(name, soCaCau, brokenRope, fixCount, skipCount, modeAuto):
    global lastVal
    if modeAuto == 3:
        text = str(soCaCau-lastVal[0]) + '-' + str(skipCount-lastVal[1]) + '-' + str(brokenRope-lastVal[2]) + '-0-0-0-0-0-' + str(fixCount-lastVal[3])
        lastVal = [soCaCau, skipCount, brokenRope, fixCount]
        url = f'https://autocaucaserver.tk/thongke/addData.php?name={name}&data={text}'
        requests.get(url)

# UI
root = Tk()
root.title("Bổ củi 2-FishShadow")
root.iconbitmap('icon.ico')
root.configure(background='white')

bong = []
for i in range(5):
    bong.append(IntVar())
    bong[i].set(1)
mauCa = []
for i in range(4):
    mauCa.append(IntVar())
    mauCa[i].set(1)
keyEntry = [0]*7
adbxEntry = [0]*7
adbyEntry = [0]*7
hostEntry = StringVar()
serialEntry = StringVar()
procesIDEntry = StringVar()
serialEntry.set("None")
keyI = StringVar()
rodPoss = IntVar()
rodPoss.set(rodPos)
skipMode = StringVar()
skipMode.set('Cày tiền')
speedC = StringVar()
speedC.set("0.05")
addr1 = StringVar()
addr2 = StringVar()
EmuName = StringVar()
EmuName.set('LD Player')
mau = ['xám', 'xanh lá', 'xanh biển', 'tím']
def settingWindow():
    global keyBoard, keyI, hostEntry, serialEntry, hien
    newWindow = Toplevel(root)
    newWindow.title("Cài đặt")
    newWindow.iconbitmap('settingicon.ico')
    newWindow.configure(background='white')

    try:
        remainingTime = checkKeyTime(key)
    except:
        remainingTime = -1

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

    myNoteBook = ttk.Notebook(newWindow)
    myNoteBook.grid(row=1, column=0, columnspan=2, sticky=E + W)
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

    frameCustom = Frame(myNoteBook, padx=10, pady=10)
    frameCustom.pack()
    Label(frameCustom, text="Cỡ Bóng", font='Helvetica 9 bold').grid(row=0, column=0, sticky=W)
    for i in range(5):
        Checkbutton(frameCustom, text=f'Bóng {i+1}', activebackground='yellow', variable=bong[i], onvalue=1, offvalue=0).grid(row=1+i, column=0, padx=5, sticky=W)
    Label(frameCustom, text="Loại màu cá", font='Helvetica 9 bold').grid(row=0, column=1, sticky=W)
    for i in range(4):
        Checkbutton(frameCustom, text=mau[i], activebackground='yellow', variable=mauCa[i], onvalue=1, offvalue=0).grid(row=1+i, column=1, padx=5, sticky=W)

    myNoteBook.add(frameKeyBoard, text="Cài Phím")
    myNoteBook.add(frameCustom, text="Custom")
    
    Button(newWindow, bg='white', width=20,text="OK",command=lambda: [changeSetting(), newWindow.destroy()]).grid(row=2, column=1, sticky=E, padx=10, pady=10)
    Button(newWindow, width=8, text="Reset", fg='black', bg='yellow', command=reset).grid(row=2, column=0, padx=5, pady=5, sticky=W)


frameControl = LabelFrame(root, text='Bảng điều khiển', padx=10, pady=10, font='Helvetica 8 bold')
frameControl.grid(row=2, column=0, columnspan=2, sticky=E + W)
frameControl.configure(background='white')


Button(frameControl, width=8, text="Setting", bg='cyan', command= settingWindow).grid(row=0, column=0, columnspan=2, padx=5, pady=5)

playAdb = Button(frameControl, width=8, bg='#ee6055', fg='white', text="ADB OFF", command=adb_start)
playAdb.grid(row=0, column=4, padx=5, pady=5)

playButton = Button(frameControl, width=8, text="PlayMode", fg='black', bg='#60d394', command=threadPlay)
playButton.grid(row=0, column=5, padx=5, pady=5)


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
connectB = Button(frameWin, width=8, text="Kết nối", bg='#ee6055', command=initProcess)
connectB.grid(row=0, column=2, padx=15, pady=5, sticky=E)

Label(frameWin, text="Địa chỉ 1: ", font='Helvetica 9 bold', bg='white').grid(row=1, column=0, sticky=W)
EE1 = Entry(frameWin, textvariable=addr1, width=20)
EE1.grid(row=1, column=1, sticky=W, padx=5)
Label(frameWin, text="Địa chỉ 2: ", font='Helvetica 9 bold', bg='white').grid(row=2, column=0, sticky=W)
EE2 = Entry(frameWin, textvariable=addr2, width=20)
EE2.grid(row=2, column=1, sticky=W, padx=5)

def submitName():
    global tai_khoan
    tai_khoan = thongkeName.get()
    config.set("User_Name", "username", tai_khoan)
    with open('setup.ini', 'w') as configfile:
        config.write(configfile)
Label(frameWin, text="Tài khoản thống kê: ", font='Helvetica 9 bold', bg='white').grid(row=3, column=0, sticky=W)
thongkeName = Entry(frameWin, width=20)
thongkeName.grid(row=3, column=1, sticky=W, padx=5)
thongkeName.insert(0, tai_khoan)
Button(frameWin, width=8, text="OK", bg='yellow', command=submitName).grid(row=3, column=2, padx=15, pady=5, sticky=E)

Label(frameWin, text="Treo nhiều giả lập thì cài nhe!", fg='red', font='Helvetica 9 bold', bg='white').grid(row=4, column=0, columnspan=3, sticky=W)
Label(frameWin, text="ID Process", font='Helvetica 9 bold', bg='white').grid(row=5, column=0, sticky=W)
procesIDEntry = Entry(frameWin, width=20)
procesIDEntry.grid(row=5, column=1, sticky=W, padx=5)
Label(frameWin, text="Host ADB", font='Helvetica 9 bold', bg='white').grid(row=6, column=0, sticky=W)
hostEntry = Entry(frameWin, width=20)
hostEntry.grid(row=6, column=1, sticky=W, padx=5)
Button(frameWin, width=8, text="Find", bg='yellow', command=multiADB).grid(row=6, column=2, padx=15, pady=5, sticky=E)
Label(frameWin, text="Tên thiết bị", font='Helvetica 9 bold', bg='white').grid(row=7, column=0, sticky=W)
if mserial == 0:
    mserial = ["None"]
w4 = OptionMenu(frameWin, serialEntry, *mserial)
w4.config(width=15, bg='white', padx=5)
w4.grid(row=7, column=1, sticky=W)



frameChart = Frame(myNoteBook1, padx=10, pady=10)
frameChart.pack()
frameChart.configure(background='white')
Z1 = Label(frameChart, text="Tổng số cá câu được: ", bg='white', fg='#ee6055', font='Helvetica 10 bold')
Z1.grid(row=0, column=0, sticky=W)
Z2 = Label(frameChart, text="Số lần đứt dây: ", bg='white', fg='orange', font='Helvetica 9 bold')
Z2.grid(row=1, column=0, sticky=W)
Z3 = Label(frameChart, text="Số lần sửa cần câu: ", bg='white', fg='green', font='Helvetica 9 bold')
Z3.grid(row=2, column=0, sticky=W)
Z4 = Label(frameChart, text="Số lần skip cá: ", bg='white', fg='green', font='Helvetica 9 bold')
Z4.grid(row=3, column=0, sticky=W)

Label(frameChart, bg='white', text="Vị trí cần câu (ADB):", font='Helvetica 9 bold').grid(row=4, column=0, sticky=W)
w1 = OptionMenu(frameChart, rodPoss, 1, 2, 3, 4, 5, 6, command=adbRodUpdate)
w1.config(bg='white')
w1.grid(row=4, column=1, sticky=W)
Label(frameChart, bg='white', text="Chế độ câu:", font='Helvetica 9 bold').grid(row=5, column=0, sticky=W)
w11 = OptionMenu(frameChart, skipMode, 'Custom', 'Cày tiền')
w11.config(bg='white')
w11.grid(row=5, column=1, sticky=W)
Label(frameChart, text="Tốc độ: ", font='Helvetica 9 bold', bg='white').grid(row=6, column=0, sticky=W)
speedCC = Entry(frameChart, textvariable=speedC, width=7)
speedCC.grid(row=6, column=1, sticky=W, padx=5)
levelCa = Label(frameChart, text="Dự đoán: ", font='Helvetica 9 bold', bg='white')
levelCa.grid(row=7, column=0, columnspan=3, sticky=W)


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
myNoteBook1.add(frameChart, text="Thống kê")
myNoteBook1.add(frameTip, text="Săn Cá")

License_key = Label(root)
License_key.grid(row=0, column=0, sticky=W, padx=5, pady=5)
Label(root, text=f'Bổ củi-FishShadow {oversion}', fg='purple', bg='white', font='Helvetica 8 bold').grid(row=4, column=1, sticky=E)
Label(root, text='https://autoplaytogether.tk/', fg='orange', bg='white', font='Helvetica 8 bold').grid(row=4, column=0, sticky=W)

def updateFish(soCaCau, broken, fix, skip, mode):
    if mode == 1 or mode == 0:
        Z1['text'] = 'Nâng cấp Platium để mở khóa'
    else:
        Z1['text'] = f'Tổng số cá câu được: {soCaCau}'
        Z2['text'] = f'Số lần đứt dây: {broken}'
        Z3['text'] = f'Số lần sửa cần câu: {fix}'
        Z4['text'] = f'Số lần skip cá: {skip}'

if key == "None":
    messagebox.showwarning("Key", "Chưa có key, vào Setting nhập key")
    License_key.config(text="Chưa có key!!", fg='red', bg='white', font='Helvetica 8 bold')
else:
    checkMode(key)

nameKey = 'None'

url3 = "https://nhat05027.github.io/webauto/version4.txt"
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

def tienTri(level):
    cdef int a = 0
    cdef int b = 0
    if level == 0:
        levelCa["text"] = f'Dự đoán: Không có'
    else:
        a = (level-1) // 6
        b = level % 6
        if b < 3:
            levelCa["text"] = f'Dự đoán: Bóng {a+1} {mau[b-1]}'
        elif b < 5:
            levelCa["text"] = f'Dự đoán: Bóng {a+1} {mau[b-3]} vương miện hoặc {mau[b-1]}'
        else:
            levelCa["text"] = f'Dự đoán: Bóng {a+1} {mau[b-3]} vương miện'

cdef int soCaCau = 0
cdef int fixCount = 0
cdef int brokenRope = 0
cdef int skipCount = 0
def playMode():
    global soCaCau, brokenRope, skipCount, fixCount

    if checkTool() > 3:
        messagebox.showwarning("FishShadow", "Bạn đã xài tối đa số giả lập cho phép")

    cdef int gio = 0
    cdef int can = 0
    cdef int tth = 0
    cdef int fix = 0
    cdef int typ = 0
    cdef int loc = 0

    baseAddr = int(addr1.get(), 16)
    baseAddr2 = int(addr2.get(), 16)
    if process.read(baseAddr2 - 0x00000010) != 0:
       baseAddr2 = int(addr1.get(), 16) 
       baseAddr = int(addr2.get(), 16)

    gioA = baseAddr
    canA = baseAddr + 0x00000004
    tthA = baseAddr + 0x00000038
    fixA = baseAddr + 0x000000ec
    typA = baseAddr2 - 0x00000010

    if key == "None":
        messagebox.showwarning("Key", "Chưa có key, vào Setting nhập key")
        License_key.config(text="Chưa có key!!", fg='red')
    else:
        checkMode(key)

    if skipMode.get() == 'Cày tiền':
        loc = 1
    else:
        loc = 0
    sp = float(speedC.get())
    # if sp < 1:
    #     sp = 1
    acceptB = [0]
    if loc == 0:
        for i in range(5):
            if bong[i].get() == 1:
                for j in range(4):
                    if mauCa[j].get() == 1:
                        acceptB.append(1+i*6+j)
                        acceptB.append(1+i*6+j+2)

    # print(acceptB)
    time.sleep(2)
    playTime = time.time()
    while True:
        if time.time() - playTime > 300:
            checkMode(key)
            playTime= time.time()
            if tai_khoan != 'None':
                dataOnl(tai_khoan, soCaCau, brokenRope, fixCount, skipCount, modeAuto)

        if exit_event.is_set():
            break

        if modeAuto != 0:
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
                updateFish(soCaCau, brokenRope, fixCount, skipCount, modeAuto)
                if checkCapt() == 1:
                    ka = processCapt()
                    if ka == 0:
                        break
                if can == 103:
                    press(3)
                    time.sleep(0.1)
                    if gio == 300:
                        time.sleep(2)
                        press(5)
                else:
                    time.sleep(2)
            if tth == 3:
                tienTri(typ)
                if loc == 0:
                    if typ in acceptB:
                        pass
                    else:
                        time.sleep(sp)
                        skipCount += 1
                        press(6)
                elif loc == 1:
                    if typ == 1 or typ == 7 or typ == 13:
                        time.sleep(sp)
                        skipCount += 1
                        press(6)

            if tth == 4:
                bat = 50 + 1
                if bat > 85:
                    bat = 50
                time.sleep(bat/1000)
                press(6)
            if tth == 6:
                soCaCau += 1
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
                    fixCount += 1
                else:
                    time.sleep(2)
            if tth == 11:
                brokenRope += 1
                time.sleep(2)

root.mainloop()