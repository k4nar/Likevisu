from flask import Flask, g, jsonify
from flask_yeoman import flask_yeoman

from pymongo import MongoClient

app = Flask(__name__)
app.register_blueprint(flask_yeoman)


def get_db():
    if not hasattr(g, 'db'):
        g.client = MongoClient()
        g.db = g.client.likevisu
    return g.db


@app.route("/commits/top_authors")
def top_authors():
    db = get_db()
    top = db.commits.aggregate([
        {"$match": {'merge': False}},
        {'$group': {'_id': '$author', 'count': {'$sum': 1}}},
        {'$sort': {'count': -1}},
        {'$limit': 10},
        {'$project': {'name': '$_id', 'count': 1, '_id': 0}},
    ])

    return jsonify({'key': "Top Authors", 'values': top['result']})


if __name__ == "__main__":
    app.run(port=5000, debug=True)
