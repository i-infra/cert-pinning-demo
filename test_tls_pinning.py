import socket
import ssl
import time
import sys

hostname = sys.argv[1]
appname = hostname.split('.')[0]
# PROTOCOL_TLS_CLIENT requires valid cert chain and hostname

context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
context.load_verify_locations(f"output.{appname}/rootcrt.pem")
context.verify_mode = ssl.CERT_REQUIRED
context.load_cert_chain(certfile=f"output.{appname}/client.crt.pem", keyfile=f"output.{appname}/client.key")

with socket.create_connection((hostname, 443)) as sock:
    with context.wrap_socket(sock, server_hostname=hostname) as ssock:
        ssock.write(b"GET /wallet HTTP/1.1\r\n\r\n")
        time.sleep(0.001)
        print(ssock.version())
        print(ssock.read(8192))
