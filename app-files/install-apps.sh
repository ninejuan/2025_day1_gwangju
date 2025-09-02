#!/bin/bash

echo "=== 2025년도 전국기능경기대회 클라우드컴퓨팅 솔루션 아키텍처 과제 ==="
echo "애플리케이션 배포를 시작합니다..."

# 1. External Secrets Operator 설치 확인
echo "1. External Secrets Operator 상태 확인 중..."
if ! kubectl get crd | grep -q "externalsecrets.external-secrets.io"; then
    echo "External Secrets Operator가 설치되지 않았습니다."
    echo "다음 명령어로 설치하세요:"
    echo "./k8s/install-external-secrets.sh"
    exit 1
fi

# 2. 기본 리소스 생성
echo "2. 기본 리소스 생성 중..."
kubectl apply -f k8s/fluentbit-rbac.yaml
kubectl apply -f k8s/external-secrets.yaml

# 2. FluentBit 배포
echo "2. FluentBit 배포 중..."
kubectl apply -f k8s/red-fluentbit.yaml
kubectl apply -f k8s/green-fluentbit.yaml

# 3. Argo Rollouts 설정
echo "3. Argo Rollouts 설정 중..."
kubectl apply -f k8s/argo-rollouts.yaml

# 4. ArgoCD 애플리케이션 배포
echo "4. ArgoCD 애플리케이션 배포 중..."
kubectl apply -f argo/red.app.yaml
kubectl apply -f argo/green.app.yaml

echo "=== 배포 완료 ==="
echo "배포 상태 확인:"
echo "kubectl get pods -n skills"
echo "kubectl get pods -n amazon-cloudwatch"
echo "kubectl get applications -n argocd"
