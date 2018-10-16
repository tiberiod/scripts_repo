#!/usr/bin/bash


aws autoscaling put-scheduled-update-group-action --auto-scaling-group-name brazil-ins-dev-CMDPortal-asg-MyAsg-VBPGJPT2LTZP --scheduled-action-name brazil-ins-dev-CMDPortal-Scheduled-Stop --start-time "2018-10-16T21:30:00Z"  --recurrence "30 21 * * MON-FRI" --min-size 0 --max-size 4 --desired-capacity 0

aws autoscaling put-scheduled-update-group-action --auto-scaling-group-name brazil-ins-dev-CMDMT-asg-MyAsg-WEGN5ESZUZCR --scheduled-action-name brazil-ins-dev-CMDMT-Scheduled-Stop --start-time "2018-10-16T21:35:00Z"  --recurrence "35 21 * * MON-FRI" --min-size 0 --max-size 4 --desired-capacity 0

aws autoscaling put-scheduled-update-group-action --auto-scaling-group-name brazil-ins-dev-mbs-asg-MyAsg-3AR28KNV9ID9 --scheduled-action-name brazil-ins-dev-mbs-Scheduled-Stop --start-time "2018-10-16T21:40:00Z"  --recurrence "40 21 * * MON-FRI" --min-size 0 --max-size 2 --desired-capacity 0

aws autoscaling put-scheduled-update-group-action --auto-scaling-group-name brazil-ins-dev-esp-asg-MyAsg-18ZKW4A1ZN83P --scheduled-action-name brazil-ins-dev-esp-Scheduled-Stop --start-time "2018-10-16T21:45:00Z"  --recurrence "45 21 * * MON-FRI" --min-size 0 --max-size 2 --desired-capacity 0

aws autoscaling put-scheduled-update-group-action --auto-scaling-group-name brazil-ins-dev-MBSi-asg-MyAsg-1JF6TWSI8ZPD9 --scheduled-action-name brazil-ins-dev-MBSi-Scheduled-Stop --start-time "2018-10-16T21:50:00Z"  --recurrence "50 21 * * MON-FRI" --min-size 0 --max-size 2 --desired-capacity 0
