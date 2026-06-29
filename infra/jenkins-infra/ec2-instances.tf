# ─────────────────────────────────────────────
# JENKINS MASTER
# Role: Orchestrates all pipelines and jobs
# Does NOT do build work — that is the agent's job
# ─────────────────────────────────────────────
resource "aws_instance" "jenkins_master" {
  ami                    = var.ami_id
  instance_type          = "c7i-flex.large"   
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  key_name               = var.key_pair_name

  root_block_device {
    volume_size           = 30      
    volume_type           = "gp3"   
    delete_on_termination = true
  }

  tags = {
    Name    = "${var.project_name}-jenkins-master"
    Role    = "jenkins-master"
    Project = var.project_name
  }
}

# ─────────────────────────────────────────────
# JENKINS AGENT
# Role: Runs actual build tasks — Maven, Docker, kubectl
# Kept separate so the master stays lightweight
# ─────────────────────────────────────────────
resource "aws_instance" "jenkins_agent" {
  ami                    = var.ami_id
  instance_type          = "c7i-flex.large"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  key_name               = var.key_pair_name

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name    = "${var.project_name}-jenkins-agent"
    Role    = "jenkins-agent"
    Project = var.project_name
  }
}
