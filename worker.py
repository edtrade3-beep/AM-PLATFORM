import os
import time
import requests
from datetime import datetime

BOT_TOKEN = os.environ.get("BOT_TOKEN")
CHAT_ID = os.environ.get("CHAT_ID")

def send_telegram(message):
    if not BOT_TOKEN or not CHAT_ID:
        print("Missing BOT_TOKEN or CHAT_ID")
        return

    url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"

    payload = {
        "chat_id": CHAT_ID,
        "text": message
    }

    response = requests.post(url, json=payload)
    print("Telegram response:", response.text)

def scan_platform():
    # Replace this with your real platform logic later
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    message = f"✅ AM-PLATFORM cloud worker is running.\nTime: {now}"
    send_telegram(message)

while True:
    scan_platform()

    # Wait 5 minutes
    time.sleep(300)
