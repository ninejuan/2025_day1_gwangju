#!/bin/bash

echo "=== External Secrets 문제 해결 스크립트 ==="
echo "이 스크립트는 External Secrets 관련 문제를 자동으로 진단하고 해결합니다."
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

run_command() {
    local cmd="$1"
    local description="$2"
    
    print_status "$description"
    if eval "$cmd"; then
        print_success "$description 완료"
        return 0
    else
        print_error "$description 실패"
        return 1
    fi
}

check_external_secrets_operator() {
    print_status "External Secrets Operator 상태 확인 중..."
    
    local pods_ready=$(kubectl get pods -n external-secrets --no-headers 2>/dev/null | grep -c "Running")
    local total_pods=$(kubectl get pods -n external-secrets --no-headers 2>/dev/null | wc -l)
    
    if [ "$total_pods" -eq 0 ]; then
        print_error "External Secrets Operator가 설치되지 않았습니다."
        return 1
    fi
    
    if [ "$pods_ready" -eq "$total_pods" ]; then
        print_success "External Secrets Operator가 정상 작동 중입니다. (${pods_ready}/${total_pods})"
        return 0
    else
        print_warning "External Secrets Operator Pod 중 일부가 준비되지 않았습니다. (${pods_ready}/${total_pods})"
        return 1
    fi
}

check_external_secrets_resources() {
    print_status "External Secrets 리소스 상태 확인 중..."
    
    local cluster_secret_store=$(kubectl get clustersecretstore aws-secretsmanager --no-headers 2>/dev/null)
    if [ -z "$cluster_secret_store" ]; then
        print_error "ClusterSecretStore 'aws-secretsmanager'가 존재하지 않습니다."
        return 1
    fi
    
    local external_secret=$(kubectl get externalsecret db-secret -n skills --no-headers 2>/dev/null)
    if [ -z "$external_secret" ]; then
        print_error "ExternalSecret 'db-secret'이 존재하지 않습니다."
        return 1
    fi
    
    local cluster_status=$(kubectl get clustersecretstore aws-secretsmanager -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
    local external_status=$(kubectl get externalsecret db-secret -n skills -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
    
    if [ "$cluster_status" = "True" ] && [ "$external_status" = "True" ]; then
        print_success "External Secrets 리소스가 정상 작동 중입니다."
        return 0
    else
        print_warning "External Secrets 리소스에 문제가 있습니다."
        return 1
    fi
}

check_iam_permissions() {
    print_status "IAM 권한 문제 진단 중..."
    
    local pod_name=$(kubectl get pods -n external-secrets -l app.kubernetes.io/name=external-secrets --no-headers | head -1 | awk '{print $1}')
    
    if [ -n "$pod_name" ]; then
        print_status "External Secrets Pod 로그 확인 중: $pod_name"
        
        local permission_errors=$(kubectl logs "$pod_name" -n external-secrets 2>/dev/null | grep -i "access\|permission\|unauthorized\|forbidden" | tail -5)
        
        if [ -n "$permission_errors" ]; then
            print_warning "IAM 권한 관련 오류가 발견되었습니다:"
            echo "$permission_errors"
            return 1
        else
            print_success "IAM 권한 관련 오류가 발견되지 않았습니다."
            return 0
        fi
    else
        print_error "External Secrets Pod를 찾을 수 없습니다."
        return 1
    fi
}

reinstall_external_secrets_operator() {
    print_status "External Secrets Operator 재설치를 시작합니다..."
    
    print_status "기존 External Secrets Operator 제거 중..."
    helm uninstall external-secrets -n external-secrets 2>/dev/null
    
    sleep 10
    
    print_status "External Secrets Operator 재설치 중..."
    if ./app-files/k8s/install-external-secrets.sh; then
        print_success "External Secrets Operator 재설치 완료"
        
        print_status "Pod 준비 대기 중... (최대 2분)"
        local timeout=120
        local elapsed=0
        
        while [ $elapsed -lt $timeout ]; do
            if check_external_secrets_operator; then
                print_success "모든 Pod가 준비되었습니다!"
                return 0
            fi
            sleep 10
            elapsed=$((elapsed + 10))
        done
        
        print_warning "Pod 준비 시간이 초과되었습니다. 수동으로 확인해주세요."
        return 1
    else
        print_error "External Secrets Operator 재설치 실패"
        return 1
    fi
}

reapply_external_secrets_resources() {
    print_status "External Secrets 리소스 재적용을 시작합니다..."
    
    print_status "기존 External Secrets 리소스 삭제 중..."
    kubectl delete externalsecret db-secret -n skills 2>/dev/null
    kubectl delete clustersecretstore aws-secretsmanager 2>/dev/null
    
    sleep 5
    
    print_status "External Secrets 리소스 재적용 중..."
    if kubectl apply -f app-files/k8s/external-secrets.yaml; then
        print_success "External Secrets 리소스 재적용 완료"
        
        print_status "리소스 상태 확인 대기 중... (최대 1분)"
        local timeout=60
        local elapsed=0
        
        while [ $elapsed -lt $timeout ]; do
            if check_external_secrets_resources; then
                print_success "모든 리소스가 정상 작동합니다!"
                return 0
            fi
            sleep 10
            elapsed=$((elapsed + 10))
        done
        
        print_warning "리소스 상태 확인 시간이 초과되었습니다. 수동으로 확인해주세요."
        return 1
    else
        print_error "External Secrets 리소스 재적용 실패"
        return 1
    fi
}

check_iam_role() {
    print_status "IAM 역할 상태 확인 중..."
    
    local role_arn=$(terraform output -raw external_secrets_role_arn 2>/dev/null)
    
    if [ -n "$role_arn" ]; then
        print_success "IAM 역할 ARN: $role_arn"
        
        if aws iam get-role --role-name "$(basename "$role_arn")" >/dev/null 2>&1; then
            print_success "IAM 역할이 AWS에 존재합니다."
            return 0
        else
            print_error "IAM 역할이 AWS에 존재하지 않습니다."
            return 1
        fi
    else
        print_error "Terraform에서 IAM 역할 ARN을 가져올 수 없습니다."
        return 1
    fi
}

fix_external_secrets() {
    print_status "External Secrets 문제 해결을 시작합니다..."
    
    if ! check_external_secrets_operator; then
        print_warning "External Secrets Operator에 문제가 있습니다. 재설치를 시도합니다."
        if reinstall_external_secrets_operator; then
            print_success "External Secrets Operator 문제가 해결되었습니다."
        else
            print_error "External Secrets Operator 문제 해결에 실패했습니다."
            return 1
        fi
    fi
    
    if ! check_iam_role; then
        print_error "IAM 역할에 문제가 있습니다. Terraform을 다시 적용해야 합니다."
        print_status "다음 명령어를 실행하세요: terraform apply -auto-approve"
        return 1
    fi
    
    if ! check_external_secrets_resources; then
        print_warning "External Secrets 리소스에 문제가 있습니다. 재적용을 시도합니다."
        if reapply_external_secrets_resources; then
            print_success "External Secrets 리소스 문제가 해결되었습니다."
        else
            print_error "External Secrets 리소스 문제 해결에 실패했습니다."
            return 1
        fi
    fi
    
    if ! check_iam_permissions; then
        print_warning "IAM 권한 문제가 발견되었습니다."
        print_status "External Secrets Pod를 재시작합니다..."
        
        local pod_name=$(kubectl get pods -n external-secrets -l app.kubernetes.io/name=external-secrets --no-headers | head -1 | awk '{print $1}')
        if [ -n "$pod_name" ]; then
            kubectl delete pod "$pod_name" -n external-secrets
            print_success "Pod 재시작 완료. 잠시 후 상태를 확인해주세요."
        fi
    fi
    
    print_success "모든 문제 해결 시도가 완료되었습니다!"
    return 0
}

final_status_check() {
    print_status "최종 상태 확인 중..."
    
    echo ""
    echo "=== External Secrets 최종 상태 ==="
    
    echo "1. External Secrets Operator Pod 상태:"
    kubectl get pods -n external-secrets
    
    echo ""
    echo "2. ClusterSecretStore 상태:"
    kubectl get clustersecretstore
    
    echo ""
    echo "3. ExternalSecret 상태:"
    kubectl get externalsecret -n skills
    
    echo ""
    echo "4. 생성된 Kubernetes Secret:"
    kubectl get secret db-secret -n skills
    
    echo ""
    echo "=== 상태 요약 ==="
    
    if check_external_secrets_operator && check_external_secrets_resources; then
        print_success "External Secrets가 정상 작동하고 있습니다! 🎉"
    else
        print_warning "일부 문제가 남아있을 수 있습니다. 위 상태를 확인해주세요."
    fi
}

# 메인 실행
main() {
    echo "External Secrets 문제 해결을 시작합니다..."
    echo ""
    
    if ! kubectl cluster-info >/dev/null 2>&1; then
        print_error "kubectl이 클러스터에 연결할 수 없습니다. kubeconfig를 확인해주세요."
        exit 1
    fi
    
    if fix_external_secrets; then
        print_success "문제 해결이 완료되었습니다!"
    else
        print_warning "일부 문제가 해결되지 않았습니다."
    fi
    
    echo ""
    
    final_status_check
    
    echo ""
    echo "=== 스크립트 실행 완료 ==="
    echo "문제가 지속되면 수동으로 확인해주세요."
}

main "$@"
