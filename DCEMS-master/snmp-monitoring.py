from easysnmp import Session, snmp_walk
import netsnmp
import subprocess
import json
import concurrent.futures
import logging
import queue
import random
import threading
import os
import time
import signal
from functools import partial
import pika
from pymongo import MongoClient
import datetime
import hashlib

UPS_MONITOR_GRANULARITY = 10
UPS_CONSUMER_GRANULATIRY = 2
NUMBER_OF_CONSUMERS = 1


class ScannedDevice:
    def __init__(self, ipAddress, port):
        self.ipAddress = ipAddress
        self.port = port


class UPS:
    def __init__(self, ipAddress, port, snmpVersion, sysDescr, sysObjectID, sysUpTimeInstance, sysContact, sysName, sysLocation, upsIdentManufacturer, upsIdentModel, upsIdentUPSSoftwareVersion, upsIdentAgentSoftwareVersion, upsIdentName, upsIdentAttachedDevices):
        self.ipAddress = ipAddress
        self.port = port
        self.snmpVersion = snmpVersion

        self.id = hashlib.sha1(
            (self.ipAddress + ':' + str(self.port)).encode('ASCII')).hexdigest()

        self.sysDescr = sysDescr
        self.sysObjectID = sysObjectID
        self.sysUpTimeInstance = sysUpTimeInstance
        self.sysContact = sysContact
        self.sysName = sysName
        self.sysLocation = sysLocation

        self.upsIdentManufacturer = upsIdentManufacturer
        self.upsIdentModel = upsIdentModel
        self.upsIdentUPSSoftwareVersion = upsIdentUPSSoftwareVersion
        self.upsIdentAgentSoftwareVersion = upsIdentAgentSoftwareVersion
        self.upsIdentName = upsIdentName
        self.upsIdentAttachedDevices = upsIdentAttachedDevices

        self.battery = UPSBatteryStatus('', '', '', '', '', '', '')

    def setBattery(self, battery):
        self.battery = battery

    def makeJson(self):
        return {'deviceId': self.id,
                'ipAddress': self.ipAddress,
                'port': self.port,
                'snmpVersion': self.snmpVersion,
                'sysDescr': self.sysDescr,
                'sysObjectID': self.sysObjectID,
                'sysUpTimeInstance': self.sysUpTimeInstance,
                'sysContact': self.sysContact,
                'sysName': self.sysName,
                'sysLocation': self.sysLocation,
                'upsIdentManufacturer': self.upsIdentManufacturer,
                'upsIdentModel': self.upsIdentModel,
                'upsIdentUPSSoftwareVersion': self.upsIdentUPSSoftwareVersion,
                'upsIdentAgentSoftwareVersion': self.upsIdentAgentSoftwareVersion,
                'upsIdentName': self.upsIdentName,
                'upsIdentAttachedDevices': self.upsIdentAttachedDevices}
        # 'battery': self.battery.makeJson()}

    def makeBatteryStatusJson(self):
        return {'deviceId': self.id,
                'ipAddress': self.ipAddress,
                'port': self.port,
                'snmpVersion': self.snmpVersion,
                'battery': self.battery.makeJson()}


class UPSBatteryStatus:
    def __init__(self, upsBatteryStatus, upsSecondsOnBattery, upsEstimatedMinutesRemaining, upsEstimatedChargeRemaining, upsBatteryVoltage, upsBatteryCurrent, upsBatteryTemperature):
        self.upsBatteryStatus = upsBatteryStatus
        self.upsSecondsOnBattery = upsSecondsOnBattery
        self.upsEstimatedMinutesRemaining = upsEstimatedMinutesRemaining
        self.upsEstimatedChargeRemaining = upsEstimatedChargeRemaining
        self.upsBatteryVoltage = upsBatteryVoltage
        self.upsBatteryCurrent = upsBatteryCurrent
        self.upsBatteryTemperature = upsBatteryTemperature

    def makeJson(self):
        return {'upsBatteryStatus': self.upsBatteryStatus,
                'upsSecondsOnBattery': self.upsSecondsOnBattery,
                'upsEstimatedMinutesRemaining': self.upsEstimatedMinutesRemaining,
                'upsEstimatedChargeRemaining': self.upsEstimatedChargeRemaining,
                'upsBatteryVoltage': self.upsBatteryVoltage,
                'upsBatteryCurrent': self.upsBatteryCurrent,
                'upsBatteryTemperature': self.upsBatteryTemperature}


def scan(firstIpAddress, lastIpAddress, port=161):
    output = subprocess.check_output(['braa', firstIpAddress + '-' + lastIpAddress + ':' + str(
        port) + ':.1.3.6.1.2.1.1.1.0/description'], stderr=subprocess.DEVNULL)

    output = output.splitlines()

    scannedDevices = []

    for device in output:
        ipAddress = device.split(b':')[1]
        ipAddress = ipAddress.decode('ASCII')

        scannedDevices.append(ScannedDevice(ipAddress, port))
        print('SNMP device found: ' + ipAddress + ':' + str(port))

    return scannedDevices


def processSystemWalkOutput(results):
    sysDescr = ''
    sysObjectID = ''
    sysUpTimeInstance = ''
    sysContact = ''
    sysName = ''
    sysLocation = ''

    for result in results:
        if('sysDescr' == result.oid):
            sysDescr = result.value
        elif('sysObjectID' == result.oid):
            sysObjectID = result.value
        elif('sysUpTimeInstance' == result.oid):
            sysUpTimeInstance = result.value
        elif('sysContact' == result.oid):
            sysContact = result.value
        elif('sysName' == result.oid):
            sysName = result.value
        elif('sysLocation' == result.oid):
            sysLocation = result.value

    return sysDescr, sysObjectID, sysUpTimeInstance, sysContact, sysName, sysLocation


def processUPSIdentWalkOutput(results):
    upsIdentManufacturer = ''
    upsIdentModel = ''
    upsIdentUPSSoftwareVersion = ''
    upsIdentAgentSoftwareVersion = ''
    upsIdentName = ''
    upsIdentAttachedDevices = ''

    for result in results:
        if('upsIdentManufacturer' == result.oid):
            upsIdentManufacturer = result.value
        elif('upsIdentModel' == result.oid):
            upsIdentModel = result.value
        elif('upsIdentUPSSoftwareVersion' == result.oid):
            upsIdentUPSSoftwareVersion = result.value
        elif('upsIdentAgentSoftwareVersion' == result.oid):
            upsIdentAgentSoftwareVersion = result.value
        elif('upsIdentName' == result.oid):
            upsIdentName = result.value
        elif('upsIdentAttachedDevices' == result.oid):
            upsIdentAttachedDevices = result.value

    return upsIdentManufacturer, upsIdentModel, upsIdentUPSSoftwareVersion, upsIdentAgentSoftwareVersion, upsIdentName, upsIdentAttachedDevices


def processUPSBatteryWalkOutput(results):
    upsBatteryStatus = ''
    upsSecondsOnBattery = ''
    upsEstimatedMinutesRemaining = ''
    upsEstimatedChargeRemaining = ''
    upsBatteryVoltage = ''
    upsBatteryCurrent = ''
    upsBatteryTemperature = ''

    for result in results:
        if('upsBatteryStatus' == result.oid):
            upsBatteryStatus = result.value
        elif('upsSecondsOnBattery' == result.oid):
            upsSecondsOnBattery = result.value
        elif('upsEstimatedMinutesRemaining' == result.oid):
            upsEstimatedMinutesRemaining = result.value
        elif('upsEstimatedChargeRemaining' == result.oid):
            upsEstimatedChargeRemaining = result.value
        elif('upsBatteryVoltage' == result.oid):
            upsBatteryVoltage = result.value
        elif('upsBatteryCurrent' == result.oid):
            upsBatteryCurrent = result.value
        elif('upsBatteryTemperature' == result.oid):
            upsBatteryTemperature = result.value

    return upsBatteryStatus, upsSecondsOnBattery, upsEstimatedMinutesRemaining, upsEstimatedChargeRemaining, upsBatteryVoltage, upsBatteryCurrent, upsBatteryTemperature


def producer(queue, event, device):
    while not event.wait(timeout=UPS_MONITOR_GRANULARITY):
        results = snmp_walk('upsBattery', hostname=device.ipAddress,
                            remote_port=device.port, community='public', version=2)

        upsBatteryStatus, upsSecondsOnBattery, upsEstimatedMinutesRemaining, upsEstimatedChargeRemaining, upsBatteryVoltage, upsBatteryCurrent, upsBatteryTemperature = processUPSBatteryWalkOutput(
            results)

        battery = UPSBatteryStatus(upsBatteryStatus, upsSecondsOnBattery, upsEstimatedMinutesRemaining,
                                   upsEstimatedChargeRemaining, upsBatteryVoltage, upsBatteryCurrent, upsBatteryTemperature)

        device.setBattery(battery)

        message = device.makeBatteryStatusJson()
        logging.info('Producer sending message: %s',
                     json.dumps(message, indent=4))
        queue.put(message)

    logging.info('Producer received event. Exiting...')


def consumer(queue, event):
    connection = pika.BlockingConnection(
        pika.ConnectionParameters('localhost'))
    channel = connection.channel()
    channel.exchange_declare(exchange='upsStatus', exchange_type='fanout')

    while not event.wait(timeout=UPS_CONSUMER_GRANULATIRY):
        while not queue.empty():
            message = queue.get()
            logging.info(
                'Consumer storing message: %s (size=%d)', json.dumps(
                    message, indent=4), queue.qsize()
            )
            channel.basic_publish(exchange='upsStatus',
                                  routing_key='', body=json.dumps(message))

    connection.close()
    logging.info('Consumer received event. Exiting...')


def RPCServer(event, channel):
    channel.queue_declare(queue='rpc_queue')

    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(queue='rpc_queue', on_message_callback=onRPCrequest)

    print(" [x] Awaiting RPC requests")
    channel.start_consuming()


def onRPCrequest(ch, method, props, body):
    request = json.loads(body)

    print("request" + json.dumps(request, indent=4))

    ch.basic_publish(exchange='',
                     routing_key=props.reply_to,
                     properties=pika.BasicProperties(
                         correlation_id=props.correlation_id),
                     body=json.dumps(request))
    ch.basic_ack(delivery_tag=method.delivery_tag)


def receiveSignal(event, channel, signalNumber, frame):
    print('Received signal: ', signalNumber)
    event.set()
    channel.stop_consuming()
    return


if __name__ == "__main__":
    os.environ['MIBS'] = 'UPS-MIB:SNMPv2-SMI'

    format = '%(asctime)s: %(message)s'
    logging.basicConfig(format=format, level=logging.INFO, datefmt='%H:%M:%S')

    scannedDevices = []

    scannedDevices = scannedDevices + \
        scan('192.168.1.1', '192.168.1.254', port=1024)
    scannedDevices = scannedDevices + \
        scan('192.168.1.1', '192.168.1.254', port=1025)

    devices = []
    for device in scannedDevices:
        print('SNMP walking ' + device.ipAddress)

        results = snmp_walk('system', hostname=device.ipAddress,
                            remote_port=device.port, community='public', version=2)
        sysDescr, sysObjectID, sysUpTimeInstance, sysContact, sysName, sysLocation = processSystemWalkOutput(
            results)

        results = snmp_walk('upsIdent', hostname=device.ipAddress,
                            remote_port=device.port, community='public', version=2)
        upsIdentManufacturer, upsIdentModel, upsIdentUPSSoftwareVersion, upsIdentAgentSoftwareVersion, upsIdentName, upsIdentAttachedDevices = processUPSIdentWalkOutput(
            results)

        results = snmp_walk('upsBattery', hostname=device.ipAddress,
                            remote_port=device.port, community='public', version=2)
        upsBatteryStatus, upsSecondsOnBattery, upsEstimatedMinutesRemaining, upsEstimatedChargeRemaining, upsBatteryVoltage, upsBatteryCurrent, upsBatteryTemperature = processUPSBatteryWalkOutput(
            results)

        battery = UPSBatteryStatus(upsBatteryStatus, upsSecondsOnBattery, upsEstimatedMinutesRemaining,
                                   upsEstimatedChargeRemaining, upsBatteryVoltage, upsBatteryCurrent, upsBatteryTemperature)

        ups = UPS(device.ipAddress, device.port, 2, sysDescr, sysObjectID, sysUpTimeInstance, sysContact, sysName, sysLocation, upsIdentManufacturer,
                  upsIdentModel, upsIdentUPSSoftwareVersion, upsIdentAgentSoftwareVersion, upsIdentName, upsIdentAttachedDevices)

        ups.setBattery(battery)

        devices.append(ups)

    client = MongoClient('localhost', 27017)
    db = client['DCEMS']
    collection = db['UPS']

    for device in devices:
        print(json.dumps(device.makeJson(), indent=4))

        post = device.makeJson()
        post['timestamp'] = datetime.datetime.utcnow().replace(
            microsecond=0).isoformat()
        postFinal = {'$set': post}

        post_id = collection.update_one({'_id': device.id},
                                        postFinal, upsert=True).upserted_id
        print('Saved ' + device.ipAddress + ':' +
              str(device.port) + ' on database')

    event = threading.Event()
    
    connection = pika.BlockingConnection(pika.ConnectionParameters(host='localhost'))
    channel = connection.channel()

    signal.signal(signal.SIGINT, partial(receiveSignal, event, channel))

    pipeline = queue.Queue(maxsize=256)
    threads = []

    # Create and start consumers threads
    for i in range(0, NUMBER_OF_CONSUMERS):

        thread = threading.Thread(name='consumer' + str(i),
                                  target=consumer,
                                  args=(pipeline, event,))
        thread.start()
        threads.append(thread)

    # Create and start devices threads for monitoring
    for device in devices:
        thread = threading.Thread(name=device.ipAddress + str(device.port),
                                  target=producer,
                                  args=(pipeline, event, device,))

        thread.start()
        threads.append(thread)

    thread = threading.Thread(name="RPCServer",
                              target=RPCServer,
                              args=(event, channel))

    thread.start()
    threads.append(thread)

    # Join all threads
    for thread in threads:
        thread.join()

    logging.info('Main thread exiting...')
