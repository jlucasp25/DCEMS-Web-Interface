from datetime import datetime
import json

import threading
import pika

import pyipmi
import pyipmi.interfaces

class Server:
    def __init__(self, ips_file, creds):
        self.machines = self.get_servers_from_file(ips_file, creds)
        self.get_status_thread = threading.Thread(name="status", target=self.run_status, args = ())
        self.change_power_thread = threading.Thread(name="change", target=self.run_change_power, args = ())

    def start_server(self):
        self.get_status_thread.start()
        self.change_power_thread.start()

    def get_servers_from_file(self, file, creds):
        machines = []
        f=open(file, "r")
        for line in f:
            ip, port= line.strip('\n').split(':')
            machine = Machine(ip, port, creds)
            machines.append(machine)
        f.close()
        return machines

    def print_jsons(self):
        for machine in self.machines:
            print(machine.make_json())

    def run_status(self):
        connection = pika.BlockingConnection(
            pika.ConnectionParameters(host='localhost'))
        channel = connection.channel()
        channel.queue_declare(queue='status_queue')
        channel.basic_qos(prefetch_count=1)
        channel.basic_consume(queue='status_queue', on_message_callback=self.on_status_requests)
        print(" [x] Awaiting status requests")
        channel.start_consuming()

    def on_status_requests(self, ch, method, props, body):
        response = self.get_all_machines_status()
        ch.basic_publish(exchange='',
                         routing_key=props.reply_to,
                         properties=pika.BasicProperties(correlation_id = \
                                                             props.correlation_id),
                         body=str(response))
        ch.basic_ack(delivery_tag=method.delivery_tag)

    def get_all_machines_status(self):
        response = ''
        for machine in self.machines:
            machine.update_power_status()
            response = response + machine.make_json()
        return response


    def run_change_power(self):
        connection = pika.BlockingConnection(
            pika.ConnectionParameters(host='localhost'))
        channel = connection.channel()
        channel.queue_declare(queue='change_power_queue')
        channel.basic_qos(prefetch_count=1)
        channel.basic_consume(queue='change_power_queue', on_message_callback=self.on_change_power)
        print(" [x] Awaiting change power requests")
        channel.start_consuming()

    def on_change_power(self, ch, method, props, body):
        machine, change_power = self.parse_change_power_request(body)
        print("%s:%s change_power:%s" %(machine.ip, machine.port, change_power))
        if machine != None:
            machine.switch_power(change_power)
            response = machine.make_json()
        else:
            response = "Machine not found"
        ch.basic_publish(exchange='',
                         routing_key=props.reply_to,
                         properties=pika.BasicProperties(correlation_id = \
                                                             props.correlation_id),
                         body=str(response))
        ch.basic_ack(delivery_tag=method.delivery_tag)

    #change power json
    #ip, port, power_change
    def parse_change_power_request(self, body):
        rcv=json.loads(body)
        for machine in self.machines:
            if machine.is_me(rcv["ip"], rcv["port"]):
                return machine, rcv['power_change']
        print('machine couldn\'t be found')
        return None, None

class Machine:
    def __init__(self, ip, port, creds):
        self.creds = creds
        self.ip= ip
        self.port= port
        self.id_info= None
        self.power_status= None
        self.lastcheck= None
        self.ipmi= None
        self.status= self.ipmi_init(creds)


    def ipmi_init(self, creds):
        # Supported interface_types for ipmitool are: 'lan' , 'lanplus', and 'serial-terminal'
        interface = pyipmi.interfaces.create_interface(interface = 'ipmitool', interface_type='lanplus')
        self.ipmi = pyipmi.create_connection(interface)
        self.ipmi.session.set_session_type_rmcp(self.ip, port=self.port)
        self.ipmi.session.set_auth_type_user(self.creds[0], self.creds[1])
        self.ipmi.target= pyipmi.Target(0x20)
        #ipmi.target.set_routing([(0x81,0x20,0),(0x20,0x82,7)])
        self.ipmi.session.establish()
        try:
            id=self.ipmi.get_device_id()
        except RuntimeError:
            print('Cant connect to IPMI on server ' + self.ip + ':' + str(self.port))
            self.id_info=None
            self.status=False
        else:
            self.id_info=id
            self.status=True
        finally:
            return self.status

    def update_power_status(self):
        if (self.status==False):
            print('Cant connect to IPMI on server ' + self.ip + ':' + str(self.port))
            return
        self.power_status = self.ipmi.get_chassis_status().power_on
        self.lastcheck=datetime.now().strftime("%d-%b-%YT%H:%M:%S")

    def switch_power(self, status):
        if (self.status == False):
            if(self.ipmi_init()==False):
                print('Cant connect to IPMI on server ' + self.ip + ':' + str(self.port))
                return
        self.update_power_status()
        if status==False or status == 'off':
            self.ipmi.chassis_control_power_down()
        elif status ==True or status == 'on':
            self.ipmi.chassis_control_power_up()
        #from here not working
        elif status=='soft':
            self.ipmi.chassis_control_soft_shutdown()
        elif status=='switch':
            self.ipmi.chassis_control_power_cycle()
        else:
            print('invalid power configuration')

    def make_json(self):
        if (self.status==False):
            return json.dumps({'ip': self.ip, 'port': self.port, 'id': None, 'power': self.power_status, 'lastcheck': self.lastcheck, 'status': self.status})
        else:
            return json.dumps({'ip': self.ip, 'port': self.port, 'id': self.id_info.device_id, 'power': self.power_status, 'lastcheck': self.lastcheck, 'status': self.status})

    def is_me(self, ip, port):
        print(self.ip + ' ' + ip + ' ' + self.port + ' ' + port)
        if(self.ip == ip and self.port == port):
            return True
        else:
            return False


def Main():
    #list of tuples with ip and port of each machine
    IPS_FILE = 'ips.txt'
    creds = ('ADMIN', 'ADMIN')

    server = Server(IPS_FILE, creds)
    server.start_server()
    # for server in servers:
    #     server.update_power_status()
    #     json = server.make_json()
    #     print(json)



if __name__ == '__main__':
    Main()
