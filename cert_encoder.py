import base64
secrettxt = ''
for cert in [('rootcrt.pem','ROOTCRT='),('client.full.pem','CLIENTCRT=')]:
    with open(cert[0], 'r') as f:
        data=f.read()
        data=str(base64.b64encode(bytes(data,'ascii')))[1:]
        secrettxt=secrettxt+cert[1]+data+'\n'

secrettxt = secrettxt[:-1]


with open('crypto_secrets','w') as w:
    w.write(secrettxt)

