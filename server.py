from flask import Flask, jsonify
from flask_yeoman import flask_yeoman

app = Flask(__name__)
app.register_blueprint(flask_yeoman)

if __name__ == "__main__":
    app.run(port=5000)
