import datetime

time = datetime.datetime.now().strftime("%d-%m-%Y %H:%M:%S")

d = {'1':1, '2':2}
d['3'] = 5
d['3']+=1
print(d)