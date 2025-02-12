#cython: language_level=3
from sys import exit
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