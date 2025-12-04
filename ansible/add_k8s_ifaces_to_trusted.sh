#!/bin/bash

set -e

ZONE="trusted"

echo "[INFO] Adding Kubernetes & Calico interfaces to '$ZONE' zone..."

# Add Calico VXLAN interface if present
if ip link show vxlan.calico >/dev/null 2>&1; then
    echo "[INFO] Adding vxlan.calico"
    sudo firewall-cmd --permanent --zone=$ZONE --add-interface=vxlan.calico
fi

# Add all cali* interfaces (pod veth endpoints)
for iface in $(ip -o link show | awk -F': ' '/cali/{print $2}' | awk '{print $1}'); do
    echo "[INFO] Adding $iface"
    sudo firewall-cmd --permanent --zone=$ZONE --add-interface=$iface
done

# Add docker bridges (kubelet may still use them)
for iface in docker0 $(ip -o link show | awk -F': ' '/br-/{print $2}' | awk '{print $1}'); do
    if ip link show $iface >/dev/null 2>&1; then
        echo "[INFO] Adding $iface"
        sudo firewall-cmd --permanent --zone=$ZONE --add-interface=$iface
    fi
done

# Add the main NIC if needed
MAIN_IFACE="enp1s0"
if ip link show $MAIN_IFACE >/dev/null 2>&1; then
    echo "[INFO] Adding $MAIN_IFACE"
    sudo firewall-cmd --permanent --zone=$ZONE --add-interface=$MAIN_IFACE
fi

echo "[INFO] Reloading firewall..."
sudo firewall-cmd --reload

echo "[INFO] Final trusted zone configuration:"
sudo firewall-cmd --list-all --zone=$ZONE

