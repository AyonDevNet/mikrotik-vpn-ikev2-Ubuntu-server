# MikroTik IKEv2 VPN Server with Ubuntu StrongSwan Client

This project demonstrates a complete step-by-step configuration of an **IKEv2 VPN using MikroTik RouterOS as the VPN Server** and **Ubuntu (StrongSwan) as the VPN client** using **SSL certificates** for mutual authentication.

---

## 📌 Topology
[ Ubuntu Client ]
│
│ IKEv2 (IPSec)
▼
[ MikroTik Router ]
│
[ LAN Network ]


---

## 🔐 Certificate Generation on MikroTik

Generate and sign SSL certificates on MikroTik:

### Step 1: Create Certificate Templates

```bash
/certificate add name=CA-Template common-name=192.168.10.1 subject-alt-name=IP:192.168.10.1 key-usage=key-cert-sign,crl-sign
/certificate add name=Server-Template common-name=server subject-alt-name=IP:192.168.10.1
/certificate add name=Client-Template common-name=client

###Step 2: Sign Certificates


/certificate set server trusted=yes
/certificate set client trusted=yes
/certificate export-certificate ca export-passphrase=1234567890
/certificate export-certificate client export-passphrase=1234567890
/certificate export-certificate client type=pkcs12 export-passphrase=1234567890


###Step 3: Trust and Export

/certificate set server trusted=yes
/certificate set client trusted=yes
/certificate export-certificate ca export-passphrase=1234567890
/certificate export-certificate client export-passphrase=1234567890
/certificate export-certificate client type=pkcs12 export-passphrase=1234567890


##MikroTik IPSec Configuration

/ip ipsec policy group add name=ike2-policies
/ip ipsec profile add name=ike2
/ip ipsec peer add exchange-mode=ike2 name=ike2 passive=yes profile=ike2
/ip ipsec proposal add name=ike2 pfs-group=none
/ip pool add name=ike2-pool ranges=192.168.77.2-192.168.77.254
/ip ipsec mode-config add address-pool=ike2-pool address-prefix-length=32 name=ike2-conf
/ip ipsec identity add auth-method=digital-signature certificate=ca generate-policy=port-strict \
    mode-config=ike2-conf peer=ike2 policy-template-group=ike2-policies
/ip ipsec policy add dst-address=192.168.77.0/24 group=ike2-policies proposal=ike2 \
    src-address=0.0.0.0/0 template=yes

 Ubuntu Client (StrongSwan) Configuration
Step 1: Install StrongSwan

sudo apt update
sudo apt install strongswan strongswan-pki libcharon-extra-plugins
Step 2: Import Certificates

sudo mkdir -p /etc/ipsec.d/{certs,private,cacerts}
sudo cp ca.crt /etc/ipsec.d/cacerts/
sudo openssl pkcs12 -in client.p12 -out client.key.pem -nocerts -nodes
sudo openssl pkcs12 -in client.p12 -out client.crt.pem -clcerts -nokeys
sudo cp client.crt.pem /etc/ipsec.d/certs/
sudo cp client.key.pem /etc/ipsec.d/private/
Step 3: Configure /etc/ipsec.conf

config setup
  charondebug="ike 2, knl 2, cfg 2, net 2"

conn ikev2-mikrotik
  keyexchange=ikev2
  auto=start
  type=tunnel
  leftsourceip=%config
  leftauth=pubkey
  leftcert=client.crt.pem
  right=192.168.10.1
  rightid=@server
  rightauth=pubkey
  rightsubnet=0.0.0.0/0
  ike=aes256-sha256-modp2048
  esp=aes256-sha256
Step 4: Configure /etc/ipsec.secrets


: RSA client.key.pem
Step 5: Restart and Test

sudo systemctl restart strongswan
sudo ipsec statusall
sudo journalctl -u strongswan -f
✅ Connection Testing
Ensure MikroTik allows traffic from Ubuntu IP.

Try pinging to LAN devices behind MikroTik.

Run ip route to see if VPN tunnel is the default route.

📱 Android Support
Android 7+ supports IKEv2 with certificate-based auth using:

StrongSwan VPN Client app

Import .p12 file and CA certificate

Set VPN type to IKEv2-EAP or IKEv2-Cert

🧠 Skills You’ll Learn
MikroTik certificate management

IPSec IKEv2 policy-based VPN

StrongSwan IPSec client configuration on Ubuntu

Certificate-based authentication

VPN route debugging

🧑‍💻 Author
Mohammed Ayon
GitHub: @AyonDevNet

📁 License
This project is open-source and licensed under the MIT License.





