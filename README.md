Deploys a MobileCoin Full-Service instance to Fly.io with key pinning (MTLS).

Every command is printed to the screen as it's run to aid in debugging and to provide a reference for future work.

This may be overwhelming, but I believe in you. (this is a first draft)

Workflow:

 > ./create_app.sh
 >
 > (enter app name when prompted)
 >
 > wait a few seconds\
 >

A successful deploy looks like this:

```
    --> Pushing image done
    Image: registry.fly.io/lunar-point-become-alone:deployment-1638071043
    Image size: 733 MB
    ==> Creating release
    Release v2 created

    You can detach the terminal anytime without stopping the deployment
    Monitoring Deployment

    v0 is being deployed
```

And can be tested like this:

```
 > python3 test_tls_pinning.py lunar-point-become-alone.fly.dev

TLSv1.3
b'HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nServer: Rocket\r\nContent-Length: 4362\r\nDate: Sun, 28 Nov 2021 03:48:39 GMT....
```

or this!

```
 > curl --cert output.lunar-point-become-alone/client.full.pem --cacert output.lunar-point-become-alone/rootcrt.pem https://lunar-point-become-alone.fly.dev/wallet

Please use json data to choose wallet commands. For example,

```

### Apply keys

 > flyctl secrets set ROOTCRT=(cat output.$NAME/rootcrt.pem|base64 --wrap=0) -a $CLIENTAPPNAME
 > flyctl secrets set CLIENTCRT=(cat output.$NAME/client.full.pem|base64 --wrap=0) -a $CLIENTAPPNAME
