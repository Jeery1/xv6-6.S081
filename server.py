import socket
import sys

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
addr = ('localhost', int(sys.argv[1]))
print('listening on %s port %s' % addr, file=sys.stderr)  # Python 3 的 print
sock.bind(addr)

while True:
    buf, raddr = sock.recvfrom(4096)
    print(buf.decode('utf-8'), file=sys.stderr)  # 解码 bytes 并打印
    if buf:
        sent = sock.sendto(buf, raddr)