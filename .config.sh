#!/bin/bash
## Author : Ravikant

mobileNo=""
email="example@mail.com"
slack_webhook_url="https://hooks.slack.com/services/xxxxxxxxx/xxxxxxx/xxxxxxxxxxxxxxx"
slack_channel="<channel name>"

if [[ $1 = "<IP of Host>" ]]; then
	host="<IP of host>"
	serverName="<Name/Alias of server>"
	userName="<Mysql user Name>"
	Password="<Password of mysql user>"
	trackfile="$host.txt"
	delay_threshold="<Threshold delay value in second>"
	
fi

if [[ $1 = "<IP of Host>" ]]; then
	host="<IP of Host>"
	serverName="<Name/Alias of server>"
	userName="<Mysql user name>"
	Password="<Password of mysql user>"
	trackfile="$host.txt"
	delay_threshold="<Thereshold delay value in second>"
	
fi
