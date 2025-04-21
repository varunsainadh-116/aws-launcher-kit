# aws-launcher-kit
A lightweight CLI-based toolkit to automate the deployment of EC2 instances using AWS CLI. This script simplifies instance instantiation, making cloud provisioning fast, repeatable, and hassle-free.
## Workflow
![img.git](Ec2_intilization.gif)

## ⚙️ Environment Setup

<div style="padding: 15px; margin: 10px 0;">
<p><strong>☁️ Run in Shell:</strong></p>

```bash
curl -O https://raw.githubusercontent.com/varunsainadh-116/aws-launcher-kit/refs/heads/main/ec2-initialization.sh
chmod +x ec2-initialization.sh
./ec2-initialization.sh

```
</div>

# You’ll be prompted to enter the following:

- ✅ AMI ID (or press Enter to use default)
- 💻 Instance Type (default: t2.micro)
- 🔑 Key Pair Name (used to SSH into the instance)
- 🌐 Subnet ID (default: provide one from your VPC)
- 🛡️ Security Group IDs
- 🏷️ Instance Name
  
# ⚙️ Features
- ✅ Checks and installs AWS CLI v2 if missing.
- ✅ Detects your Linux distro (Arch, Ubuntu/Debian, WSL).
- ✅ Automatically installs unzip if required.
- ✅ Launches your EC2 instance and waits until it’s running.
- ✅ Displays instance state and success message.

# 📌 Requirements
- A configured AWS CLI with valid credentials (aws configure)
- IAM permissions to create EC2 instances, use Key Pairs, Subnets, and Security Groups

# 💡 Pro Tips
- Make sure your default region is set in ``` ~/.aws/config ```
- If running on Arch Linux, pacman will be used for dependency management.
- Works seamlessly on Ubuntu, Debian, Arch, and WSL
