from ReadWriteMemory import ReadWriteMemory
from concurrent.futures import ThreadPoolExecutor
import time
rwm = ReadWriteMemory()
process = rwm.get_process_by_name('MEmuHeadless.exe')
process.open() 

address_list = range(0, 68719476735)
k = 0
print("go")
startT = time.time()
def go(i):
	if process.read(i) == 300:
		k += 1
		print(k)

with ThreadPoolExecutor(max_workers = 100000) as executor:
    executor.map(go, address_list)

print(f'Done: {k} result in {time.time()-startT}s')