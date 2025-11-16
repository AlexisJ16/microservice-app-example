#!/bin/bash
# Script para monitorear el estado de los pods en tiempo real

watch -n 2 'kubectl get pods -n microservices-ns -o wide'
