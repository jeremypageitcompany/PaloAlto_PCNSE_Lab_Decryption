## This is to get the public ip of the machine deploying the lab, for the NSG
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}