#
# Copyright 2017, Schuberg Philis B.V.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# author: Kristian Vlaardingerbroek
#

cis_level = input('cis_level')

title '5.2 SSH Server Configuration'

control 'cis-dil-benchmark-5.2.1' do
  title 'Ensure permissions on /etc/ssh/sshd_config are configured'
  desc  "The /etc/ssh/sshd_config file contains configuration specifications for sshd. The command below sets the owner and group of the file to root.\n\nRationale: The /etc/ssh/sshd_config file needs to be protected from unauthorized changes by nonprivileged users."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.1'
  tag level: 1

  describe file('/etc/ssh/sshd_config') do
    it { should exist }
    it { should_not be_readable.by 'group' }
    it { should_not be_writable.by 'group' }
    it { should_not be_executable.by 'group' }
    it { should_not be_readable.by 'other' }
    it { should_not be_writable.by 'other' }
    it { should_not be_executable.by 'other' }
    its('uid') { should cmp 0 }
    its('gid') { should cmp 0 }
  end
end

control 'cis-dil-benchmark-5.2.2' do
  title 'Ensure permissions on SSH private host key files are configured'
  desc  "An SSH private key is one of two files used in SSH public key authentication. In this authentication method, The possession of the private key is proof of identity. Only a private key that corresponds to a public key will be able to authenticate successfully. The private keys need to be stored and handled carefully, and no copies of the private key should be distributed.\n\nRationale: If an unauthorized user obtains the private SSH host key file, the host could be
  impersonated."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.2'
  tag level: 1

  command("find /etc/ssh -xdev -type f -name 'ssh_host_*_key'").stdout.split.each do |f|
    describe file(f) do
      it { should_not be_readable.by 'group' }
      it { should_not be_writable.by 'group' }
      it { should_not be_executable.by 'group' }
      it { should_not be_readable.by 'other' }
      it { should_not be_writable.by 'other' }
      it { should_not be_executable.by 'other' }
      its('uid') { should cmp 0 }
      its('gid') { should cmp 0 }
    end
  end
end

control 'cis-dil-benchmark-5.2.3' do
  title 'Ensure permissions on SSH public host key files are configured'
  desc  "An SSH public key is one of two files used in SSH public key authentication. In this authentication method, a public key is a key that can be used for verifying digital signatures generated using a corresponding private key. Only a public key that corresponds to a private key will be able to authenticate successfully.\n\nRationale: If a public host key file is modified by an unauthorized user, the SSH service may be compromised."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.3'
  tag level: 1

  command("find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub'").stdout.split.each do |f|
    describe file(f) do
      it { should_not be_writable.by 'group' }
      it { should_not be_executable.by 'group' }
      it { should_not be_writable.by 'other' }
      it { should_not be_executable.by 'other' }
      its('uid') { should cmp 0 }
      its('gid') { should cmp 0 }
    end
  end
end

control 'cis-dil-benchmark-5.2.4' do
  title 'Ensure SSH Protocol is set to 2'
  desc  "Older versions of SSH support two different and incompatible protocols: SSH1 and SSH2. SSH1 was the original protocol and was subject to security issues. SSH2 is more advanced and secure.\n\nRationale: SSH v1 suffers from insecurities that do not affect SSH v2."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.4'
  tag level: 1

  describe sshd_config do
    its('Protocol') { should cmp 2 }
  end
end

control 'cis-dil-benchmark-5.2.5' do
  title 'Ensure SSH LogLevel is appropriate'
  desc  "INFO level is the basic level that only records login activity of SSH users. In many situations, such as Incident Response, it is important to determine when a particular user was active on a system. The logout record can eliminate those users who disconnected, which helps narrow the field. VERBOSE level specifies that login and logout activity as well as the key fingerprint for any SSH key used for login will be logged. This information is important for SSH key management, especially in legacy environments.\n\nRationale: SSH provides several logging levels with varying amounts of verbosity. DEBUG is specifically not recommended other than strictly for debugging SSH communications since it provides so much data that it is difficult to identify important security information."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.5'
  tag level: 1

  describe sshd_config do
    its('LogLevel') { should eq('INFO').or eq('VERBOSE') }
  end
end

control 'cis-dil-benchmark-5.2.6' do
  title 'Ensure SSH X11 forwarding is disabled'
  desc  "The X11Forwarding parameter provides the ability to tunnel X11 traffic through the connection to enable remote graphic connections.\n\nRationale: Disable X11 forwarding unless there is an operational requirement to use X11 applications directly. There is a small risk that the remote X11 servers of users who are logged in via SSH with X11 forwarding could be compromised by other users on the X11 server. Note that even if X11 forwarding is disabled, users can always install their own forwarders."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.6'
  tag level: 2

  only_if('CIS level 2') do
    cis_level == 2
  end

  describe sshd_config do
    its('X11Forwarding') { should eq 'no' }
  end
end

control 'cis-dil-benchmark-5.2.7' do
  title 'Ensure SSH MaxAuthTries is set to 4 or less'
  desc  "The MaxAuthTries parameter specifies the maximum number of authentication attempts permitted per connection. When the login failure count reaches half the number, error messages will be written to the syslog file detailing the login failure.\n\nRationale: Setting the MaxAuthTries parameter to a low number will minimize the risk of successful brute force attacks to the SSH server. While the recommended setting is 4, set the number based on site policy."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.7'
  tag level: 1

  describe sshd_config do
    its('MaxAuthTries') { should cmp <= 4 }
  end
end

control 'cis-dil-benchmark-5.2.8' do
  title 'Ensure SSH IgnoreRhosts is enabled'
  desc  "The IgnoreRhosts parameter specifies that .rhosts and .shosts files will not be used in RhostsRSAAuthentication or HostbasedAuthentication.\n\nRationale: Setting this parameter forces users to enter a password when authenticating with ssh."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.8'
  tag level: 1

  describe sshd_config do
    its('IgnoreRhosts') { should eq 'yes' }
  end
end

control 'cis-dil-benchmark-5.2.9' do
  title 'Ensure SSH HostbasedAuthentication is disabled'
  desc  "The HostbasedAuthentication parameter specifies if authentication is allowed through trusted hosts via the user of .rhosts, or /etc/hosts.equiv, along with successful public key client host authentication. This option only applies to SSH Protocol Version 2.\n\nRationale: Even though the .rhosts files are ineffective if support is disabled in /etc/pam.conf, disabling the ability to use .rhosts files in SSH provides an additional layer of protection."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.9'
  tag level: 1

  describe sshd_config do
    its('HostbasedAuthentication') { should eq 'no' }
  end
end

control 'cis-dil-benchmark-5.2.10' do
  title 'Ensure SSH root login is disabled'
  desc  "The PermitRootLogin parameter specifies if the root user can log in using ssh. The default is no.\n\nRationale: Disallowing root logins over SSH requires system admins to authenticate using their own individual account, then escalating to root via sudo or su. This in turn limits opportunity for non-repudiation and provides a clear audit trail in the event of a security incident."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.10'
  tag level: 1

  describe sshd_config do
    its('PermitRootLogin') { should eq 'no' }
  end
end

control 'cis-dil-benchmark-5.2.11' do
  title 'Ensure SSH PermitEmptyPasswords is disabled'
  desc  "The PermitEmptyPasswords parameter specifies if the SSH server allows login to accounts with empty password strings.\n\nRationale: Disallowing remote shell access to accounts that have an empty password reduces the probability of unauthorized access to the system."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.11'
  tag level: 1

  describe sshd_config do
    its('PermitEmptyPasswords') { should eq 'no' }
  end
end

control 'cis-dil-benchmark-5.2.12' do
  title 'Ensure SSH PermitUserEnvironment is disabled'
  desc  "The PermitUserEnvironment option allows users to present environment options to the ssh daemon.\n\nRationale: Permitting users the ability to set environment variables through the SSH daemon could potentially allow users to bypass security controls (e.g. setting an execution path that has ssh executing trojan'd programs)"
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.12'
  tag level: 1

  describe sshd_config do
    its('PermitUserEnvironment') { should eq 'no' }
  end
end

control 'cis-dil-benchmark-5.2.13' do
  title 'Ensure only approved Ciphers are used'
  desc "This variable limits the ciphers that SSH can use during communication.\n\nRationale: Weak ciphers that are used for authentication to the cryptographic module cannot be relied upon to provide confidentiality or integrity, and system data may be compromised The DES, Triple DES, and Blowfish ciphers, as used in SSH, have a birthday bound of approximately four billion blocks, which makes it easier for remote attackers to obtain cleartext data via a birthday attack against a long-duration encrypted session, aka a 'Sweet32' attack The RC4 algorithm, as used in the TLS protocol and SSL protocol, does not properly combine state data with key data during the initialization phase, which makes it easier for remote attackers to conduct plaintext-recovery attacks against the initial bytes of a stream by sniffing network traffic that occasionally relies on keys affected by the Invariance Weakness, and then using a brute-force approach involving LSB values, aka the 'Bar Mitzvah' issue The passwords used during an SSH session encrypted with RC4 can be recovered by an attacker who is able to capture and replay the session Error handling in the SSH protocol; Client and Server, when using a block cipher algorithm in Cipher Block Chaining (CBC) mode, makes it easier for remote attackers to recover certain plaintext data from an arbitrary block of ciphertext in an SSH session via unknown vectors The mm_newkeys_from_blob function in monitor_wrap.c, when an AES-GCM cipher is used, does not properly initialize memory for a MAC context data structure, which allows remote authenticated users to bypass intended ForceCommand and login-shell restrictions via packet data that provides a crafted callback address"
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.13'
  tag level: 1

  describe sshd_config do
    its('Ciphers') { should_not be_nil }
  end

  if sshd_config.Ciphers
    describe sshd_config.Ciphers.split(',').each do
      it { should_not match /^(.*-cbc|arcfour.*|rijndael-cbc.*)$/ }
    end
  end
end

control 'cis-dil-benchmark-5.2.14' do
  title 'Ensure only approved MAC algorithms are used'
  desc  "This variable limits the types of MAC algorithms that SSH can use during communication.\n\nRationale: MD5 and 96-bit MAC algorithms are considered weak and have been shown to increase exploitability in SSH downgrade attacks. Weak algorithms continue to have a great deal of attention as a weak spot that can be exploited with expanded computing power. An attacker that breaks the algorithm could take advantage of a MiTM position to decrypt the SSH tunnel and capture credentials and information"
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.14'
  tag level: 1

  describe sshd_config do
    its('MACs') { should_not be_nil }
  end

  ALLOWED_MACS = [
    'hmac-sha2-512-etm@openssh.com',
    'hmac-sha2-256-etm@openssh.com',
    'hmac-sha2-512',
    'hmac-sha2-256',
    'curve25519-sha256@libssh.org',
    'diffie-hellman-group-exchange-sha256'
  ].freeze

  if sshd_config.MACs
    sshd_config.MACs.split(',').each do |m|
      describe m do
        it { should be_in ALLOWED_MACS }
      end
    end
  end
end

control 'cis-dil-benchmark-5.2.15' do
  title 'Ensure only strong Key Exchange algorithms are used'
  desc  "Key exchange is any method in cryptography by which cryptographic keys are exchanged between two parties, allowing use of a cryptographic algorithm. If the sender and receiver wish to exchange encrypted messages, each must be equipped to encrypt messages to be sent and decrypt messages received\n\nRationale: Key exchange methods that are considered weak should be removed. A key exchange method may be weak because too few bits are used, or the hashing algorithm is considered too weak. Using weak algorithms could expose connections to man-in-the-middle attacks"
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.15'
  tag level: 1

  describe sshd_config do
    its('kexalgorithms') { should_not be_nil }
  end

  if sshd_config.kexalgorithms
    describe sshd_config.kexalgorithms.split(',').each do
      it { should_not match /^diffie-hellman-group.*-sha1$/ }
    end
  end
end

control 'cis-dil-benchmark-5.2.16' do
  title 'Ensure SSH Idle Timeout Interval is configured'
  desc  "The two options ClientAliveInterval and ClientAliveCountMax control the timeout of ssh sessions. When the ClientAliveInterval variable is set, ssh sessions that have no activity for the specified length of time are terminated. When the ClientAliveCountMax variable is set, sshd will send client alive messages at every ClientAliveInterval interval. When the number of consecutive client alive messages are sent with no response from the client, the ssh session is terminated. For example, if the ClientAliveInterval is set to 15 seconds and the ClientAliveCountMax is set to 3, the client ssh session will be terminated after 45 seconds of idle time.\n\nRationale: Having no timeout value associated with a connection could allow an unauthorized user access to another user's ssh session (e.g. user walks away from their computer and doesn't lock the screen). Setting a timeout value at least reduces the risk of this happening. While the recommended setting is 300 seconds (5 minutes), set this timeout value based on site policy. The recommended setting for ClientAliveCountMax is 0. In this case, the client session will be terminated after 5 minutes of idle time and no keepalive messages will be sent."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.16'
  tag level: 1

  describe sshd_config do
    its('ClientAliveInterval') { should cmp <= 300 }
    its('ClientAliveCountMax') { should cmp <= 3 }
  end
end

control 'cis-dil-benchmark-5.2.17' do
  title 'Ensure SSH LoginGraceTime is set to one minute or less'
  desc  "The LoginGraceTime parameter specifies the time allowed for successful authentication to the SSH server. The longer the Grace period is the more open unauthenticated connections can exist. Like other session controls in this session the Grace Period should be limited to appropriate organizational limits to ensure the service is available for needed access.\n\nRationale: Setting the LoginGraceTime parameter to a low number will minimize the risk of successful brute force attacks to the SSH server. It will also limit the number of concurrent unauthenticated connections While the recommended setting is 60 seconds (1 Minute), set the number based on site policy."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.17'
  tag level: 1

  describe sshd_config do
    its('LoginGraceTime') { should cmp <= 60 }
  end
end

control 'cis-dil-benchmark-5.2.18' do
  title 'Ensure SSH access is limited'
  desc "There are several options available to limit which users and group can access the system via SSH. It is recommended that at least one of the following options be leveraged: AllowUsers The AllowUsers variable gives the system administrator the option of allowing specific users to ssh into the system. The list consists of space separated user names. Numeric user IDs are not recognized with this variable. If a system administrator wants to restrict user access further by only allowing the allowed users to log in from a particular host, the entry can be specified in the form of user@host. AllowGroups The AllowGroups variable gives the system administrator the option of allowing specific groups of users to ssh into the system. The list consists of space separated group names. Numeric group IDs are not recognized with this variable. DenyUsers The DenyUsers variable gives the system administrator the option of denying specific users to ssh into the system. The list consists of space separated user names. Numeric user IDs are not recognized with this variable. If a system administrator wants to restrict user access further by specifically denying a user's access from a particular host, the entry can be specified in the form of user@host. DenyGroups The DenyGroups variable gives the system administrator the option of denying specific groups of users to ssh into the system. The list consists of space separated group names. Numeric group IDs are not recognized with this variable.\n\nRationale: Restricting which users can remotely access the system via SSH will help ensure that only authorized users access the system."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.18'
  tag level: 1

  describe.one do
    %w(AllowUsers AllowGroups DenyUsers DenyGroups).each do |p|
      describe sshd_config do
        its(p) { should_not be_nil }
      end
    end
  end
end

control 'cis-dil-benchmark-5.2.19' do
  title 'Ensure SSH warning banner is configured'
  desc  "The Banner parameter specifies a file whose contents must be sent to the remote user before authentication is permitted. By default, no banner is displayed.\n\nRationale: Banners are used to warn connecting users of the particular site's policy regarding connection. Presenting a warning message prior to the normal user login may assist the prosecution of trespassers on the computer system."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.19'
  tag level: 1

  describe sshd_config do
    its('Banner') { should_not be_nil }
  end
end

control 'cis-dil-benchmark-5.2.20' do
  title 'Ensure SSH PAM is enabled'
  desc  "UsePAM Enables the Pluggable Authentication Module interface. If set to “yes” this will enable PAM authentication using ChallengeResponseAuthentication and PasswordAuthentication in addition to PAM account and session module processing for all authentication types\n\nRationale: When usePAM is set to yes, PAM runs through account and session types properly. This is important if you want to restrict access to services based off of IP, time or other factors of the account. Additionally, you can make sure users inherit certain environment variables on login or disallow access to the server"
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.20'
  tag level: 1

  describe sshd_config do
    its('UsePAM') { should eq 'yes' }
  end
end

control 'cis-dil-benchmark-5.2.21' do
  title 'Ensure SSH AllowTcpForwarding is disabled'
  desc  "SSH port forwarding is a mechanism in SSH for tunneling application ports from the client to the server, or servers to clients. It can be used for adding encryption to legacy applications, going through firewalls, and some system administrators and IT professionals use it for opening backdoors into the internal network from their home machines\n\nRationale: Leaving port forwarding enabled can expose the organization to security risks and backdoors. SSH connections are protected with strong encryption. This makes their contents invisible to most deployed network monitoring and traffic filtering solutions. This invisibility carries considerable risk potential if it is used for malicious purposes such as data exfiltration. Cybercriminals or malware could exploit SSH to hide their unauthorized communications, or to exfiltrate stolen data from the target network"
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.21'
  tag level: 2

  only_if('CIS level 2') do
    cis_level == 2
  end

  describe sshd_config do
    its('AllowTcpForwarding') { should eq 'no' }
  end
end

control 'cis-dil-benchmark-5.2.22' do
  title 'Ensure SSH MaxStartups is configured'
  desc  "The MaxStartups parameter specifies the maximum number of concurrent unauthenticated connections to the SSH daemon.\n\nRationale: To protect a system from denial of service due to a large number of pending authentication connection attempts, use the rate limiting function of MaxStartups to protect availability of sshd logins and prevent overwhelming the daemon."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.22'
  tag level: 1

  describe sshd_config do
    its('maxstartups') { should eq '10:30:60' }
  end
end

control 'cis-dil-benchmark-5.2.23' do
  title 'Ensure SSH MaxSessions is set to 4 or less'
  desc  "The MaxSessions parameter specifies the maximum number of open sessions permitted from a given connection.\n\nRationale: To protect a system from denial of service due to a large number of concurrent sessions, use the rate limiting function of MaxSessions to protect availability of sshd logins and prevent overwhelming the daemon."
  impact 1.0

  tag cis: 'distribution-independent-linux:5.2.23'
  tag level: 1

  describe sshd_config do
    its('MaxSessions') { should cmp <= 4 }
  end
end
