
[Dynamic DNS with Google Domains. Access your local home automations on… | by Cloud Jake | Medium](https://cloud-jake.medium.com/google-domains-dynamic-dns-with-google-domains-1dd0ea45c219)

# DDClient Setup

First of all we will need to install ddclient

```
sudo apt update   
sudo apt insatll ddclient
```
After successful installation of ddclient, we can test it using

`ddclient -version`

In my situation the installed version is 3.9.1 that will need a bit modification to support bearer authorization from cloudflare. So to do it just open up /usr/sbin/ddclient using your favorite editor, ex gedit

`sudo gedit /usr/sbin/ddclient`

look for

```perl
my $headers = “X-Auth-Email: $config{$key}{‘login’}\n”;  
$headers .= “X-Auth-Key: $config{$key}{‘password’}\n”;  
$headers .= “Content-Type: application/json”;
```

underneath of

> sub nic_cloudflare_update

then replace that 3 line with

```perl
my $headers = "X-Auth-Email: $config{$key}{'login'}\n";  
$headers .= "X-Auth-Key: $config{$key}{'password'}\n";  
$headers .= "Content-Type: application/json";

```
save the file.

# Cloudflare API Token

Then we can proceed with creating API token in cloudflare.

start by visiting [https://dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens)

Press Create Token

![](https://miro.medium.com/v2/resize:fit:700/1*wbeduKsDu7XY2Jd2fRlDGg.png)

pres + Add More  
permission Zone > DNS > Read  
change Zone Resources to  
Include > All zones from an account > your Account

Continue to summary

![](https://miro.medium.com/v2/resize:fit:700/1*it1YI28mAbSZd_LgDdDM7w.png)

Create Token, then copy you secret api token to a safe place. We are going to need it later, and it will be only showed once

![](https://miro.medium.com/v2/resize:fit:700/1*7nnRO0Eptk78rr80FVV5lA.png)

# DNS Record Creation

Once the API token is created, we will continue to register the DNS under your website.

Go to [https://dash.cloudflare.com/](https://dash.cloudflare.com/)

then go to the web that you want to register, this should be on Websites tab.

![](https://miro.medium.com/v2/resize:fit:700/1*AkMRTL3c_6AFHm6J4BnagA.png)

then go to DNS > Records  
and Add Record

```
type A  
name subdomain # can be whatever you want  
ip 8.8.8.8 # this will be automatically changed later by ddclient
```

![](https://miro.medium.com/v2/resize:fit:700/1*7dLelk8xcSnihEQAYD4KBg.png)

save, and it will appear under your record

![](https://miro.medium.com/v2/resize:fit:700/1*_mmpDQL1z4oSCrXW3uTYqg.png)

now that this is done, time to set ddclient.conf

# DDClient.conf

Open` /etc/ddclient.con`f using your favorite text editor

`sudo gedit /etc/ddclient.conf`

add this line into it.

```
ssl=yes  
daemon=300  
use=web  
protocol=cloudflare  
zone=<yourdomain.com>  
login=token  
password=<api key from cloudflare>  
subdomain.yourdomain.com, sub2.yourdomain.com, sub3.yourdomain.com
```

you need to change the zone to your domain name, and password to the cloudflare API token that you save before, and change the subdomain to your created one.

Once this done, we will be ready to test.

# Test the config

Run in terminal

```bash
sudo ddclient -daemon=0 -verbose
```

This should throw bunch of stuff, and as long the setup is correct the DNS record under your domain will be pointed to your IP address

![](https://miro.medium.com/v2/resize:fit:700/1*f_elixYigMOJJDMBZR1bOg.png)

you can also check if the IP is correct by using

`sudo ddclient -query`

once all is good, we can restart ddclient service so it will periodically update automatically
`
sudo service ddclient restart`

Thanks for reading!