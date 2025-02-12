import requests


url4 = "https://nhat05027.github.io/webauto/captcha.txt"
rep4 = requests.get(url4)
captchahost = rep4.text
captchahost = captchahost.replace('\n', '')

url = f'https://botcaptcha.nhat05027.repl.co/a/uploader'

nm = 'AdminConan'


files = {'file': open('nen.jpg', 'rb')}
myobj = {'user': nm}
r = requests.post(url, files=files)
print(r.text)


# ff = [0, 1, 2, 3, 4, 5, 6, 7]
# kk = ff[0:5]
# print(kk)