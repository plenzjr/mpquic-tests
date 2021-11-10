#!/bin/bash
# SET UP FIRST
sudo ifconfig s0-eth1 up
sleep 10
# SET NIC DOWN
sudo ifconfig s0-eth1 down
sleep 5
# SET NIC UP
sudo ifconfig s0-eth1 up
