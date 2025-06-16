#Install StrongSwan:

sudo apt update
sudo apt install strongswan strongswan-pki libcharon-extra-plugins

#Import the Certificates:
#You'll need to copy:
#ca.crt
#client.p12 (or split client.crt and client.key)


sudo mkdir -p /etc/ipsec.d/{certs,private,cacerts}
sudo cp ca.crt /etc/ipsec.d/cacerts/
sudo openssl pkcs12 -in client.p12 -out client.key.pem -nocerts -nodes
sudo openssl pkcs12 -in client.p12 -out client.crt.pem -clcerts -nokeys

sudo cp client.crt.pem /etc/ipsec.d/certs/
sudo cp client.key.pem /etc/ipsec.d/private/


# Configure /etc/ipsec.conf:

config setup
  charondebug="ike 2, knl 2, cfg 2, net 2"

conn ikev2-mikrotik
  keyexchange=ikev2
  auto=start
  type=tunnel
  leftsourceip=%config
  leftauth=pubkey
  leftcert=client.crt.pem
  right=your.vpn.server.ip
  rightid=@server
  rightauth=pubkey
  rightsubnet=0.0.0.0/0
  ike=aes256-sha256-modp2048
  esp=aes256-sha256

  #Configure /etc/ipsec.secrets:
  : RSA client.key.pem
#Then restart StrongSwan:
 
sudo systemctl restart strongswan
sudo ipsec statusall




