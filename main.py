from netfilterqueue import NetfilterQueue
from scapy.layers.inet import IP
from datetime import datetime
import json


def write_new_data(data):
    with open("testping.json", "w") as result_file:
        if(not result_writer.st_is_null()):
            json.dump(data, result_file, default=my_converter)
    
    result_writer.st_null()
    

def my_converter(o):
    if isinstance(o, datetime):
        return o.__str__()


class Result_writer():
    res_item = {
        'start':0,
        'st':{}
    }

    def st_is_null(self):
        if(len(self.res_item['st']) == 0):
            return True
        else:
            return False

    def st_null(self):
        self.res_item['st'] = {}

    def check(self, pkt):
        msg = IP(pkt.get_payload())
    
        if 'ICMP' in msg:
            if(msg.src != msg.dst):
                if(msg.src in self.res_item['st']):
                    self.res_item['st'][msg.src] += 1
                else:
                    self.res_item['st'][msg.src] = 1
            else:
                self.res_item['start'] = datetime.now().strftime("%d-%m-%Y %H:%M:%S")
                print(self.res_item)
                if(len(self.res_item['st'])!= 0):
                    write_new_data(self.res_item)
        
        pkt.accept()

result_writer = Result_writer()

nfqueue = NetfilterQueue()
nfqueue.bind(1, result_writer.check)

try:
    nfqueue.run()
except KeyboardInterrupt:
    nfqueue.unbind()
    print('')

nfqueue.unbind()