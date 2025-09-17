#!/usr/bin/env python3
import socket
import sys

def send_udp_message(message, host='127.0.0.1', port=1738):
    """Send a UDP message to AnyIconBar"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.sendto(message.encode('utf-8'), (host, port))
        print(f"Sent: {message}")
        sock.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python test_udp.py <message>")
        print("Examples:")
        print("  python test_udp.py red")
        print("  python test_udp.py star.fill")
        print("  python test_udp.py star.fill#red")
        print("  python test_udp.py star.fill#fff")
        print("  python test_udp.py 'star.fill#red, star.circle.fill#e20808'")
        print("  python test_udp.py quit")
        sys.exit(1)

    message = sys.argv[1]
    send_udp_message(message)