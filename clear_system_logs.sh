#!/bin/bash
sudo journalctl --rotate
sudo journalctl --vacuum-time=1s
exit
