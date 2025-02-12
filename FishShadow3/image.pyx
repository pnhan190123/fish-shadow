#cython: language_level=3
from sys import exit
import pygame
import cv2
import requests
import numpy as np
from datetime import datetime
import pyximport; pyximport.install()
from screen_cap import WindowCapture

def get_Emu_Name():
    ListName = WindowCapture.list_window_names()
    return ListName

def init_Emu(name):
    global wincap, alpha
    wincap = WindowCapture(name)
    WI, HI = wincap.calculateScreen()
    alpha = (WI*HI / 921600)
    return wincap.emuConnectName

GREEN = (0, 255 ,0)
magic_num = []
realTimedat = []
# print(alpha)

# Magic Number
def dynamicMagicNum(raw):
    magicNumq = []
    raw = raw.replace('\r', '')
    raw1 = raw.split('\n')
    for r in raw1:
        if r != '':
            x = r.split(',')
            y = []
            for i in x:
                y.append(int(i))
            magicNumq.append(y)
    return magicNumq
def updateMagicNum():
    global magic_num
    url = "https://nhat05027.github.io/webauto/magicNum.txt"
    rep = requests.get(url)
    raw = rep.text
    magicNumU = dynamicMagicNum(raw)
    magic_num = magicNumU
    f = open("magicNum.txt", "w")
    for t in magicNumU:
        t = str(t).replace('[', '')
        f.write(t.replace(']','') + "\n")
    f.close()
    return len(magic_num)
f = open("magicNum.txt", "r")
raw = f.read()
f.close()
if raw != '':
    magic_num = dynamicMagicNum(raw)
soMT = len(magic_num)

# Realtime data
def getRealTimeData(raw):
    realq = []
    raw = raw.replace('\r', '')
    raw1 = raw.split('\n')
    for r in raw1:
        if r != '':
            x = r.split(',')
            y = []
            for i in x:
                y.append(int(i))
            realq.append(y)
    return realq
f = open("realTimeDat.txt", "r")
raw2 = f.read()
f.close()
if raw2 != '':
    realTimedat = getRealTimeData(raw2)

def setUp():
    screenPos = []
    screenPos1 = []
    img = wincap.get_screenshot()
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)
    cv2.imwrite('screen.png', img)
    WIDTH, HEIGHT = img.shape[1::-1]
    # print(WIDTH, HEIGHT)
    pygame.font.init()
    font = pygame.font.SysFont('Comic Sans MS', 30)
    pygame.display.set_caption("Set Up")
    screen = pygame.display.set_mode((1280, 720))
    programIcon = pygame.image.load('logo.png')
    pygame.display.set_icon(programIcon)
    material = pygame.image.load('screen.png')
    x = 1280/WIDTH
    material = pygame.transform.scale(material, (int(WIDTH*x), int(HEIGHT*x)))
    isSetup = True
    click = 0
    while isSetup:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                return -1
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    pygame.quit()
                    return -1
            if event.type == pygame.MOUSEBUTTONDOWN:
                pos = pygame.mouse.get_pos()
                screenPos1.append(pos)
                screenPos.append((int(pos[0]/x), int(pos[1]/x)))
                click += 1
        screen.blit(material, (0, 0))
        if click == 0:
            text = font.render('SetUp quanh khu cau', False, (255, 0, 0))
        elif click == 1:
            x1 = screenPos1[0][0]
            y1 = screenPos1[0][1]
            pygame.draw.rect(screen, GREEN, pygame.Rect(x1, y1, pygame.mouse.get_pos()[0]-x1, pygame.mouse.get_pos()[1]-y1), 2)
        elif click == 2:
            text = font.render('SetUp dau cham thang', False, (255, 0, 0))
        elif click == 3:
            x1 = screenPos1[2][0]
            y1 = screenPos1[2][1]
            pygame.draw.rect(screen, GREEN, pygame.Rect(x1, y1, pygame.mouse.get_pos()[0]-x1, pygame.mouse.get_pos()[1]-y1), 2)
        else:
            isSetup = False
        screen.blit(text, (30, 30))
        pygame.display.update()
    pygame.quit()
    x_c = int((screenPos[2][0] + screenPos[3][0]) / 2)
    y_c = int((screenPos[2][1] + screenPos[3][1]) / 2)
    screenPos[2] = (x_c, y_c)
    screenPos[3] = None
    return screenPos

def checkCapt():
    cdef int a1 = 0
    cdef int b1 = 0
    cdef int a2 = 0
    cdef int b2 = 0
    cdef int w = 0
    cdef int h = 0
    cdef int b = 0
    cdef int r = 0
    cdef int g = 0
    cdef int t = 0

    img = wincap.get_screenshot()
    h, w = img.shape[:2]
    a = w / 206
    bb = h / 119
    a1 = int(86*a)
    b1 = int(102*bb)
    a2 = a1 + int(29 * a)
    b2 = b1 + int(5 * bb)
    # cv2.imwrite('checkcap.png', img[b1:b2, a1:a2])
    for x in range(a1, a2, 1):
        for y in range(b1, b2, 1):
            pixel = (img[y, x])
            b, g, r = pixel[0], pixel[1], pixel[2]
            if r == 65 and g == 197 and b == 243:
                t += 1
                if t > 2000 * alpha:
                    return 1
    return 0

def cap_capt():
    img = wincap.get_screenshot()
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)
    cv2.imwrite('captcha.png', img)

lower = np.array([95, 134, 68])
upper = np.array([113, 255, 154])
def calculateDayMagicNumber(pos, pos1, threshMagic, threshMagicNum):
    global lower, upper
    cdef int b = 0
    cdef int r = 0
    cdef int g = 0
    cdef int x = 0
    cdef int y = 0
    cdef int x1 = 0
    cdef int y1 = 0
    cdef int x2 = 0
    cdef int y2 = 0
    x1, y1 = pos
    x2, y2 = pos1
    img = wincap.get_screenshot()
    img = img[y1:y2, x1:x2]
    h, w = img.shape[:2]
    checkNum = np.array([0]*len(magic_num))
    for x in range(0, w, 1):
        for y in range(0, h, 1):
            pixel = (img[y, x])
            b, g, r = pixel[0], pixel[1], pixel[2]
            for i in range(len(magic_num)):
                if (r > magic_num[i][1]-threshMagic and r < magic_num[i][1]+threshMagic) and (g > magic_num[i][2]-threshMagic and g < magic_num[i][2]+threshMagic) and (b > magic_num[i][3]-threshMagic and b < magic_num[i][3]+threshMagic):
                    checkNum[i] += 1
                    if checkNum[i] > threshMagicNum*alpha:
                        lower = np.array([magic_num[i][4], magic_num[i][5], magic_num[i][6]])
                        upper = np.array([magic_num[i][7], magic_num[i][8], magic_num[i][9]])
                        return magic_num[i][0]
    return 0

placeId = 0
def initRealTime(place):
    global placeId
    if place == 'Home Town':
        placeId = 1
    elif place == 'Camp':
        placeId = 2
    elif place == 'Biển':
        placeId = 3


def realTimeMode():
    global lower,  upper
    now = datetime.now()
    cdef int minutes = 0
    cdef int seconds = 0
    cdef int tifo = 0
    rangee = realTimedat[placeId]
    minutes = int(now.strftime('%M'))
    seconds = int(now.strftime('%S'))
    tifo = minutes*60 + seconds
    if tifo >= 1800:
        tifo = tifo-1800
    if (tifo >= 0 and tifo < 230) or (tifo >= 1500 and tifo < 1800):  # nửa đêm
        lower = np.array([rangee[0], rangee[1], rangee[2]])
        upper = np.array([rangee[3], rangee[4], rangee[5]])
        return 2
    elif tifo >= 230 and tifo < 450: # nữa đêm 2
        lower = np.array([rangee[6], rangee[7], rangee[8]])
        upper = np.array([rangee[9], rangee[10], rangee[11]])
        return 2
    elif tifo >= 450 and tifo < 490:  #ani đổi ngày
        lower = np.array([rangee[12], rangee[13], rangee[14]])
        upper = np.array([rangee[15], rangee[16], rangee[17]])
        return 5
    elif tifo >= 490 and tifo < 1350:  # ban ngày
        lower = np.array([rangee[18], rangee[19], rangee[20]])
        upper = np.array([rangee[21], rangee[22], rangee[23]])
        return 1
    elif tifo >= 1350 and tifo < 1500:  # hoàng hôn
        lower = np.array([rangee[24], rangee[25], rangee[26]])
        upper = np.array([rangee[27], rangee[28], rangee[29]])
        return 3


def calculateFish(pos, pos1, lowArea, highArea, mode):
    cdef int x1 = 0
    cdef int y1 = 0
    cdef int x2 = 0
    cdef int y2 = 0
    cdef int w = 0
    cdef int h = 0
    if mode == 1:
        realTimeMode()
    lowArea = lowArea * alpha
    highArea = highArea * alpha
    x1, y1 = pos
    x2, y2 = pos1
    img1 = wincap.get_screenshot()
    img1 = img1[y1:y2, x1:x2]
    img1 = cv2.cvtColor(img1, cv2.COLOR_BGR2RGB)
    img1 = cv2.cvtColor(img1, cv2.COLOR_RGB2BGR)
    mask = cv2.inRange(img1, lower, upper)
    _, threshold = cv2.threshold(mask, 127, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(threshold, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)[-2:]
    contours = sorted(contours, key=lambda x: cv2.contourArea(x))
    for contour in reversed(contours):
        area = cv2.contourArea(contour)
        if area > lowArea and area < highArea:
            epsilon = 0.02 * cv2.arcLength(contour, True)
            approx = cv2.approxPolyDP(contour, epsilon, True)
            rectF = cv2.minAreaRect(approx)
            (_,_),(w,h),_ = rectF
            boxF = cv2.boxPoints(rectF)
            boxF = np.int0(boxF)
            if w != 0 and h != 0:
                if w/h > 1.8 or h/w > 1.8:
                    cv2.drawContours(img1, [boxF], 0, (255,255,255), 2)
                    sizeFish = (w * h) / alpha
                    img1 = cv2.resize(img1, (300, 200)) 
                    return sizeFish, img1
    img1 = cv2.resize(img1, (300, 200)) 
    return 0, img1

lb = 0
lr = 0
lg = 0
def isFishEat(pos, thresholdFish, firstrun=0):
    global lb, lr, lg
    cdef int b = 0
    cdef int r = 0
    cdef int g = 0
    cdef int x = 0
    cdef int y = 0
    cdef int hh = 0

    aveB = 0
    aveG = 0
    aveR = 0
    hh = 0

    img = wincap.get_screenshot()
    img = img[(pos[1]-50):(pos[1]+50), (pos[0]-50):(pos[0]+50)]
    for x in range(50 - thresholdFish, 50 + thresholdFish, 1):
        for y in range(50 - thresholdFish, 50 + thresholdFish, 1):
            pixel = (img[y, x])
            b, g, r = pixel[0], pixel[1], pixel[2]
            aveB += b
            aveG += g
            aveR += r
            hh += 1
    if hh != 0:
        aveR = aveR/hh
        aveG = aveG/hh
        aveB = aveB/hh
        if firstrun == 1:
            lb = aveB
            lg = aveG
            lr = aveR
            img = cv2.rectangle(img, (50 - thresholdFish, 50 - thresholdFish), (50 + thresholdFish, 50 + thresholdFish), (0, 255, 0), 1)
            return img
        else:
            if abs(aveR-lr) > 50 or abs(aveB-lb) > 50 or abs(aveG-lg) > 50:
                img = cv2.rectangle(img, (50 - thresholdFish, 50 - thresholdFish), (50 + thresholdFish, 50 + thresholdFish), (0, 255, 0), 1)
                return 1, img
            else:
                lb = aveB
                lg = aveG
                lr = aveR
                return 0, None
    else:
        img = cv2.rectangle(img, (50 - thresholdFish, 50 - thresholdFish), (50 + thresholdFish, 50 + thresholdFish), (0, 255, 0), 1)
        return 0, img

def dutday(threshold):
    cdef int a1 = 0
    cdef int b1 = 0
    cdef int a2 = 0
    cdef int b2 = 0
    cdef int w = 0
    cdef int h = 0
    cdef int b = 0
    cdef int r = 0
    cdef int g = 0
    cdef int t = 0

    img = wincap.get_screenshot()
    h, w = img.shape[:2]
    a = w/206
    bb = h/116
    a1 = int(135*a)
    b1 = int(7*bb)
    a2 = a1 + int(60 * a)
    b2 = b1 + int(14 * bb)
    img = img[b1:b2, a1:a2]
    # cv2.imwrite('baoquan.png', img)
    for x in range(0, (a2-a1), 1):
        for y in range(0, (b2-b1), 1):
            pixel = (img[y, x])
            b, g, r = pixel[0], pixel[1], pixel[2]
            if b > 250 and g > 250 and r > 250:
                t += 1
                if t > threshold*alpha:
                    img = cv2.resize(img, (300, 60))
                    return 1, img
    return 0, None

col = [
    (221, 237, 238),
    (228, 224, 197),
    (163, 228, 103),
    (89, 198, 217),
    (231, 147, 232),]
crowded = (248, 214, 56)
def checkRFish():
    cdef int a1 = 0
    cdef int b1 = 0
    cdef int a2 = 0
    cdef int b2 = 0
    cdef int w = 0
    cdef int h = 0
    cdef int b = 0
    cdef int r = 0
    cdef int g = 0
    cdef int crowCount = 0
    cdef int k = 0

    img = wincap.get_screenshot()
    h, w = img.shape[:2]
    a = w / 206
    bb = h / 119
    a1 = int(155*a)
    b1 = int(29*bb)
    a2 = a1 + int(20 * a)
    b2 = b1 + int(20 * bb)
    # cv2.imwrite('ca.png', img[b1:b2, a1:a2])
    t = [0,0,0,0,0]
    for x in range(a1, a2, 1):
        for y in range(b1, b2, 1):
            pixel = (img[y, x])
            b, g, r = pixel[0], pixel[1], pixel[2]
            if (b >= crowded[2]-2 and b <= crowded[2]+2) and (g >= crowded[1]-2 and g <= crowded[1]+2) and (r >= crowded[0]-2 and r <= crowded[0]+2):
                crowCount += 1
            else:
                for i in range(5):
                    if b == col[i][2] and g == col[i][1] and r == col[i][0]:
                        t[i] += 1
    # print(t)
    for i in range(4):
        if t[i+1] > 50*alpha:
            k = i+1
    if crowCount > 5*alpha:
        return k, 1
    else:
        return k, 0

def quickFix(threshold):
    cdef int a1 = 0
    cdef int b1 = 0
    cdef int a2 = 0
    cdef int b2 = 0
    cdef int w = 0
    cdef int h = 0
    cdef int b = 0
    cdef int r = 0
    cdef int g = 0
    cdef int t = 0

    img = wincap.get_screenshot()
    h, w = img.shape[:2]
    a = w / 206
    bb = h / 119
    a1 = int(70*a)
    b1 = int(19*bb)
    a2 = a1 + int(65 * a)
    b2 = b1 + int(19 * bb)
    # cv2.imwrite('suacan.png', img[b1:b2, a1:a2])   
    for x in range(a1, a2, 1):
        for y in range(b1, b2, 1):
            pixel = (img[y, x])
            b, g, r = pixel[0], pixel[1], pixel[2]
            if (b >= 133 and b <= 143) and (g >= 190 and g <= 200) and (r >= 250 and r <= 255):
                t += 1
                if t > threshold * alpha:
                    return 1
    return 0

def checkBroken(rodPos):
    cdef int a1 = 0
    cdef int b1 = 0
    cdef int a2 = 0
    cdef int b2 = 0
    cdef int w = 0
    cdef int h = 0
    cdef int b = 0
    cdef int r = 0
    cdef int g = 0
    cdef int t = 0

    img = wincap.get_screenshot()
    h, w = img.shape[:2]
    a = w / 206
    bb = h / 119
    if rodPos < 4:
        a1 = int((82+32*rodPos)*a)
        b1 = int(52*bb)
    else:
        a1 = int((82+32*(rodPos-3))*a)
        b1 = int(92*bb)
    a2 = a1 + int(22 * a)
    b2 = b1 + int(5 * bb)
    # cv2.imwrite('hucan.png', img[b1:b2, a1:a2])
    for x in range(a1, a2, 1):
        for y in range(b1, b2, 1):
            pixel = (img[y, x])
            b, g, r = pixel[0], pixel[1], pixel[2]
            if (r >= 240 and r <= 242) and (g >= 93 and g <= 95) and (b >= 77 and b <= 79):
                t += 1
                if t > 30 * alpha:
                    return 1
    return 0