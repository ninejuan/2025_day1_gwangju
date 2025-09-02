#!/bin/bash

echo "=== External Secrets Operator 설치 ==="

# 1. Helm repo 추가
echo "1. Helm repo 추가 중..."
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

# 2. External Secrets Operator 설치
echo "2. External Secrets Operator 설치 중..."
helm install external-secrets external-secrets/external-secrets \
  --namespace external-secrets \
  --create-namespace \
  --set installCRDs=true \
  --set serviceAccount.create=true \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::156041424727:role/gj2025-external-secrets-role

# 3. 설치 상태 확인
echo "3. 설치 상태 확인 중..."
sleep 30 && kubectl get pods -n external-secrets
echo ""
echo "CRD 확인:"
kubectl get crd | grep external-secrets
