#!/bin/bash

echo "Finding persistent volume information for n8n..."
echo "----------------------------------------------"

# Get PV names associated with our PVCs
echo "n8n-data-pvc is linked to:"
kubectl get pv | grep n8n-data-pvc

echo -e "\nn8n-local-files-pvc is linked to:"
kubectl get pv | grep n8n-local-files-pvc

echo -e "\nDetailed PV information:"
echo "----------------------------------------------"

# Get the PV names
DATA_PV=$(kubectl get pv -o jsonpath="{.items[?(@.spec.claimRef.name=='n8n-data-pvc')].metadata.name}")
FILES_PV=$(kubectl get pv -o jsonpath="{.items[?(@.spec.claimRef.name=='n8n-local-files-pvc')].metadata.name}")

# Display the host paths
echo "n8n data path on host:"
kubectl get pv $DATA_PV -o jsonpath="{.spec.hostPath.path}" && echo -e "\n"

echo "n8n files path on host:"
kubectl get pv $FILES_PV -o jsonpath="{.spec.hostPath.path}" && echo -e "\n"

echo "These paths on your host system contain the actual n8n data"
