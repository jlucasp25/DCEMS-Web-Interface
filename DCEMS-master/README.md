# DCEMS
DCEMS
sudo pip3 install docker-compose
sudo docker-compose up
sudo docker-compose up -d (iniciar em background, sem logs no terminal)


to change power use
change_power_queue
with json
{'ip': "127.0.0.1", 'port': "623", 'power_change': "on"}
replies with json with system info
{"ip": "127.0.0.1", "port": "623", "id": 0, "power": false, "lastcheck": "02-Jun-2020T16:36:29", "status": true}

to get status
status_queue
nao recebo nada e envio varios jsons com system info
