#!/bin/bash

echo "=== External Secrets Operator 설치 ==="

export ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

echo "1. Helm repo 추가 중..."
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

echo "2. External Secrets Operator 설치 중..."
helm install external-secrets external-secrets/external-secrets \
  --namespace skills \
  --create-namespace \
  --set installCRDs=true \
  --set serviceAccount.create=true \
  --set serviceAccount.name=external-secrets-sa \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::${ACCOUNT_ID}:role/gj2025-external-secrets-role

echo "3. 설치 상태 확인 중..."
sleep 30 && kubectl get pods -n skills
echo ""
echo "CRD 확인:"
kubectl get crd | grep external-secrets
