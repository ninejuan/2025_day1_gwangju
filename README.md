# 3_gwangju - AWS Infrastructure as Code
---

## 배포 순서
- [ ] Github에 gj2025-repository 각 브랜치 따라서 Push
- [ ] terraform apply -auto-approve
- [ ] Bastion aws configure && kubeconfig update
- [ ] ALB 설치 매뉴얼에 따라 ALB Ingress Controller 설치 (D1)
- [ ] skills 네임스페이스 생성 (k create ns skills)
- [ ] External Secrets Operator 설치 (./install-external-secrets.sh)
- [ ] Secrets 배포 (kubectl apply -f k8s/external-secrets.yaml)
- [ ] ArgoCD 설치 및 접속 설정 (./argocd.sh)
- [ ] Argo Rollouts 설치 (./argo-rollouts.sh)
- [ ] ArgoCD Ingress 배포
- [ ] ArgoCD CLI 설치
- [ ] 애플리케이션 배포

## App 배포 후 진행
- [ ] 

## 주의사항
- AWS ID가 하드코딩된 경우가 있음. 이 경우 오류나지 않도록 주의.
- 무조건 Apply 전에 vsc search 돌릴 것.
- 가끔 eks-cluster-sg-gj2025-eks-cluster-*에 hub vpc traffic allow 조건이 없는 경우가 있음. 이 때는 SG에서 hub vpc traffic 허용하면 됨.

## Docs
### D1. ALB Ingress Controller
GitHub 문서 참고: https://github.com/sigmd-com/eks-references/tree/main/3_networking/alb_ingress_controller
IAM Policy에서 ec2:DescribeRouteTable Perm이 필요함. 그냥 wildcard perm 주던가 권한 추가하던가 알아서 하면 됩니다.