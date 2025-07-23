import socket
import sys
import time

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
addr = ('localhost', int(sys.argv[1]))
buf = "this is a ping!"

while True:
    print("pinging...", file=sys.stderr)  # 唯一修改的行
    sock.sendto(buf.encode('utf-8'), ("127.0.0.1", int(sys.argv[1])))  # 保持发送逻辑但确保bytes
    time.sleep(1)