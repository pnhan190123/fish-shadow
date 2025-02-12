import os
from urllib.request import urlopen
from io import BytesIO
from zipfile import ZipFile
from pathlib import Path
import webbrowser
from configparser import ConfigParser

config = ConfigParser()
config.read("setup.ini")
buildName = config['build']['build']

path = ''
url = f'https://autocaucaserver.tk/v3/{buildName}.zip'


def download_and_unzip(url, extract_to):
    http_response = urlopen(url)
    zipfile = ZipFile(BytesIO(http_response.read()))
    zipfile.extractall(path=extract_to)


download_and_unzip(url, path)
webbrowser.open('realease-note.txt')
