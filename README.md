# 3_gwangju - AWS Infrastructure as Code

이 프로젝트는 3_gwangju 과제를 위한 AWS 인프라를 Terraform으로 구성한 것입니다.

## 아키텍처 개요

- **Hub VPC**: 외부 접근과 보안을 담당하는 VPC
- **Application VPC**: 애플리케이션과 데이터베이스를 호스팅하는 VPC
- **Transit Gateway**: 두 VPC 간의 통신을 위한 Transit Gateway
- **Network Firewall**: 트래픽 검사를 위한 AWS Network Firewall
- **EKS Cluster**: 컨테이너 오케스트레이션을 위한 Kubernetes 클러스터
- **RDS**: MySQL 데이터베이스
- **ECR**: 컨테이너 이미지 저장소
- **Load Balancers**: 트래픽 분산을 위한 로드 밸런서들

## 구성 요소

### 네트워킹
- Hub VPC (10.0.0.0/16)
  - Public Subnets (10.0.0.0/24, 10.0.1.0/24)
  - Private Subnets (10.0.2.0/24, 10.0.3.0/24)
  - Firewall Subnet (10.0.4.0/24)
- Application VPC (192.168.0.0/16)
  - Private Subnets (192.168.0.0/24, 192.168.1.0/24)
  - Data Subnets (192.168.2.0/24, 192.168.3.0/24)

### 보안
- Network Firewall: ifconfig.me 차단
- Bastion Host: SSH 접근용 (포트 2222)
- Security Groups: 각 서비스별 보안 그룹

### 컴퓨팅
- EKS Cluster (v1.32)
  - App Node Group (t3.medium, 2-4개 노드)
  - Addon Node Group (t3.medium, 2-3개 노드)
- RDS MySQL (db.t3.medium, 포트 3309)
- RDS Proxy

### 스토리지
- ECR Repositories (red, green)
- S3 Bucket (Helm charts 저장용)

### 로드 밸런싱
- External NLB (Hub VPC)
- Internal NLB (Application VPC)
- Internal ALB (Application VPC)

## 사용법

### 사전 요구사항
- AWS CLI 설정
- Terraform 설치
- GitHub Access Token

### 설정
1. `terraform.tfvars` 파일에서 GitHub 토큰을 설정하세요:
```hcl
github_token = "your-actual-github-token"
```

2. Terraform 초기화:
```bash
terraform init
```

3. 계획 확인:
```bash
terraform plan
```

4. 인프라 생성:
```bash
terraform apply
```

### 정리
```bash
terraform destroy
```

## 모듈 구조

```
modules/
├── vpc/                 # VPC 및 서브넷 구성
├── transit_gateway/     # Transit Gateway 구성
├── network_firewall/    # Network Firewall 구성
├── bastion/            # Bastion 호스트
├── rds/                # RDS 및 RDS Proxy
├── ecr/                # ECR 저장소
├── eks/                # EKS 클러스터
├── load_balancers/     # 로드 밸런서들
├── secrets/            # Secrets Manager
└── s3/                 # S3 버킷
```

## 출력값

주요 출력값들:
- Bastion 호스트 IP 주소
- EKS 클러스터 정보
- RDS 엔드포인트
- ECR 저장소 URL
- 로드 밸런서 DNS 이름
- Secrets Manager ARN

## 주의사항

- GitHub 토큰은 민감한 정보이므로 안전하게 관리하세요
- 프로덕션 환경에서는 더 강력한 보안 설정을 적용하세요
- 비용을 고려하여 적절한 인스턴스 타입을 선택하세요
