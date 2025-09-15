#!/bin/bash

# FluentBit 설치 스크립트

echo "Creating amazon-cloudwatch namespace..."
kubectl create namespace amazon-cloudwatch --dry-run=client -o yaml | kubectl apply -f -

echo "Creating FluentBit service account..."
kubectl create serviceaccount fluent-bit-sa -n amazon-cloudwatch --dry-run=client -o yaml | kubectl apply -f -
kubectl annotate serviceaccount fluent-bit-sa -n amazon-cloudwatch eks.amazonaws.com/role-arn=arn:aws:iam::571480186401:role/gj2025-fluent-bit-role --overwrite

echo "Installing FluentBit RBAC..."
kubectl apply -f fluentbit-rbac.yaml

echo "Installing Red FluentBit..."
kubectl apply -f red-fluentbit.yaml

echo "Installing Green FluentBit..."
kubectl apply -f green-fluentbit.yaml

echo "FluentBit installation completed!"

echo "Checking DaemonSets status..."
kubectl get daemonset -n amazon-cloudwatch