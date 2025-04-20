#!/bin/bash
set -euo pipefail

# -----------------------------
# Color Variables
# -----------------------------
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# -----------------------------
# Logging Functions
# -----------------------------
log_info()    { echo -e "${BLUE}[INFO] $* ${RESET}"; }
log_success() { echo -e "${GREEN}[SUCCESS] $* ${RESET}"; }
log_warn()    { echo -e "${YELLOW}[WARNING] $* ${RESET}"; }
log_error()   { echo -e "${RED}[ERROR] $* ${RESET}"; }


# -----------------------------
# Error Handler
# -----------------------------
error_exit() {
    log_error "$1"
    exit 1
}

# -----------------------------
# AWS CLI Check & Installation
# -----------------------------
check_awscli() {
    log_info "Checking if AWS CLI is installed..."

    if ! command -v aws &> /dev/null; then
        log_warn "AWS CLI not found. Installing AWS CLI..."
        install_awscli
    else
        log_success "AWS CLI is already installed."
    fi
}

install_awscli() {
    log_info "Installing AWS CLI v2 on Linux..."

    # Download and install AWS CLI v2
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" || error_exit "Failed to download AWS CLI installer."
    sudo apt-get install -y unzip &> /dev/null || error_exit "Failed to install unzip."
    unzip -q awscliv2.zip || error_exit "Failed to unzip AWS CLI installer."
    sudo ./aws/install || error_exit "Failed to install AWS CLI."

    # Verify installation
    aws --version || error_exit "AWS CLI version check failed."

    # Clean up
    rm -rf awscliv2.zip ./aws
    log_warn "Cleaning up the Files"
    log_success "AWS CLI installation successful."
}

# -----------------------------
# Wait for Instance to be Running
# -----------------------------
wait_for_instance() {
    local instance_id="$1"
    log_info "Waiting for instance $instance_id to be in running state..."

    while true; do
        state=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].State.Name' --output text)
        
        if [[ "$state" == "running" ]]; then
            log_success "Instance $instance_id is now running."
            break
        fi

        log_warn "Instance $instance_id is in state $state. Retrying..."
        sleep 10
    done
}

# -----------------------------
# Create EC2 Instance
# -----------------------------
create_ec2_instance() {
    local ami_id="$1"
    local instance_type="$2"
    local key_name="$3"
    local subnet_id="$4"
    local security_group_ids="$5"
    local instance_name="$6"

    log_info "Creating EC2 instance with the following parameters:"
    log_info "AMI ID: $ami_id"
    log_info "Instance Type: $instance_type"
    log_info "Key Name: $key_name"
    log_info "Subnet ID: $subnet_id"
    log_info "Security Group IDs: $security_group_ids"

    instance_id=$(aws ec2 run-instances \
        --image-id "$ami_id" \
        --instance-type "$instance_type" \
        --key-name "$key_name" \
        --subnet-id "$subnet_id" \
        --security-group-ids "$security_group_ids" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" \
        --query 'Instances[0].InstanceId' \
        --output text || error_exit "Failed to create EC2 instance.")

    if [[ -z "$instance_id" ]]; then
        error_exit "Failed to create EC2 instance."
    fi

    log_success "EC2 Instance $instance_id created successfully."

    # Wait for the instance to be in running state
    wait_for_instance "$instance_id"
}

# -----------------------------
# Main Function
# -----------------------------


