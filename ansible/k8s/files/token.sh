#!/bin/bash
kubeadm token create  --print-join-command > /root/token/kubernetes_join_command
sleep 10s
cat /root/token/kubernetes_join_command > /root/token/kubernetes_join_master
kubeadm init phase upload-certs --upload-certs >> /root/token/kubernetes_join_master
sed -i '2,3d' /root/token/kubernetes_join_master
sed  '$i --control-plane --certificate-key' /root/token/kubernetes_join_master  >> /root/token/kubernetes_join_master
sed -i '1,2d' /root/token/kubernetes_join_master
awk  </root/token/kubernetes_join_master 'BEGIN { RS = "" ; FS = "\n" } { gsub(/\n/, " ", $0) ; print }' >> /root/token/kubernetes_join_master
sed -i '1,2d' /root/token/kubernetes_join_master
sed -i '1d'  /root/token/kubernetes_join_master