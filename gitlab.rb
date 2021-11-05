# Lets Encrypt SSL
letsencrypt['enable'] = true                      # GitLab 10.5 and 10.6 require this option
external_url "https://gitlab.example.com"         # Must use https protocol
letsencrypt['contact_emails'] = ['melvin.v@example.com'] # Optional

# Enable GIT LFS
gitlab_rails['lfs_enabled'] = true

# Custom SSH Port
gitlab_rails['gitlab_shell_ssh_port'] = 2222

# SMTP
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.gmail.com"
gitlab_rails['smtp_port'] = 587
gitlab_rails['smtp_user_name'] = "gitlab@example.com"
gitlab_rails['smtp_password'] = "HSxxxxx3BGSUxxxx"
gitlab_rails['smtp_domain'] = "smtp.gmail.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = false
gitlab_rails['smtp_openssl_verify_mode'] = 'peer' # Can be: 'none', 'peer', 'client_once', 'fail_if_no_peer_cert', see http://api.rubyonrails.org/classes/ActionMailer/Base.html


# Backup to S3
gitlab_rails['backup_upload_connection'] = {
  'provider' => 'AWS',
  'region' => 'ap-south-1',
  # 'aws_access_key_id' => 'AKIAKIAKI',
  # 'aws_secret_access_key' => 'secret123'
  # If using an IAM Profile, don't configure aws_access_key_id & aws_secret_access_key
  'use_iam_profile' => true
}
gitlab_rails['backup_upload_remote_directory'] = 's3-bucket-name'