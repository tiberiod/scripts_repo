#!/usr/bin/bash

aws autoscaling delete-scheduled-action --auto-scaling-group-name brazil-ins-dev-CMDPortal-asg-MyAsg-VBPGJPT2LTZP --scheduled-action-name brazil-ins-dev-CMDPortal-Scheduled-Stop

aws autoscaling delete-scheduled-action --auto-scaling-group-name brazil-ins-dev-CMDMT-asg-MyAsg-WEGN5ESZUZCR --scheduled-action-name brazil-ins-dev-CMDMT-Scheduled-Stop

aws autoscaling delete-scheduled-action --auto-scaling-group-name brazil-ins-dev-mbs-asg-MyAsg-3AR28KNV9ID9 --scheduled-action-name brazil-ins-dev-mbs-Scheduled-Stop

aws autoscaling delete-scheduled-action --auto-scaling-group-name brazil-ins-dev-esp-asg-MyAsg-18ZKW4A1ZN83P --scheduled-action-name brazil-ins-dev-esp-Scheduled-Stop

aws autoscaling delete-scheduled-action --auto-scaling-group-name brazil-ins-dev-MBSi-asg-MyAsg-1JF6TWSI8ZPD9 --scheduled-action-name brazil-ins-dev-MBSi-Scheduled-Stop
