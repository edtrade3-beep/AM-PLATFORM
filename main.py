from flask import Flask, request, jsonify
import requests
import os

app = Flask(__name__)

BOT_TOKEN = os.environ.get("BOT_TOKEN")
CHAT_ID = os.environ.get("CHAT_ID")

@app.route("/")
def home():
    return "AM Platform Telegram Webhook is running."

@app.route("/webhook", methods=["POST"])
def webhook():
    data = request.get_json(silent=True) or {}
    
    message = data.get("message", "TradingView alert received")

    telegram_url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"

    payload = {
        "chat_id": CHAT_ID,
        "text": message
    }

    response = requests.post(telegram_url, json=payload)

    return jsonify({
        "status": "sent",
        "telegram_response": response.json()
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=10000)
