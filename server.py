import os

from flask import Flask, jsonify, send_file

from pymongo import MongoClient

from processor import process_commits

app = Flask(__name__)

client = MongoClient()
db = client.likevisu
commits = db.commits


@app.route('/')
@app.route('/<path:path>')
def serve_files(path='index.html'):
    root = os.environ.get('FLASK_ROOT', 'app')
    dest = os.path.join(app.root_path, root, path)
    if os.path.isfile(dest):
        return send_file(dest)

    root = os.environ.get('FLASK_ROOT_ALT', '.tmp')
    dest = os.path.join(app.root_path, root, path)
    if os.path.isfile(dest):
        return send_file(dest)

    from werkzeug.exceptions import NotFound
    return NotFound()


@app.route("/commits/top_authors_by_commits")
def top_authors_by_commits():
    top = commits.aggregate([
        {"$match": {'merge': False}},
        {'$group': {'_id': '$author', 'count': {'$sum': 1}}},
        {'$sort': {'count': -1}},
        {'$limit': 10},
        {'$project': {'name': '$_id', 'count': 1, '_id': 0}},
    ])

    return jsonify(top)

@app.route("/commits/top_authors_by_lines")
def top_authors_by_lines():
    top = commits.aggregate([
        {"$match": {'merge': False}},
        {'$group': {'_id': '$author', 'count': {'$sum': '$additions'}}},
        {'$sort': {'count': -1}},
        {'$limit': 10},
        {'$project': {'name': '$_id', 'count': 1, '_id': 0}},
    ])

    return jsonify(top)

@app.route("/commits/top_companies_by_commits")
def top_companies_by_commits():
    top = commits.aggregate([
        {"$match": {'merge': False}},
        {'$group': {'_id': '$company', 'count': {'$sum': 1}}},
        {'$sort': {'count': -1}},
        {'$limit': 10},
        {'$project': {'name': '$_id', 'count': 1, '_id': 0}},
    ])

    return jsonify(top)

@app.route("/commits/top_companies_by_lines")
def top_companies_by_lines():
    top = commits.aggregate([
        {"$match": {'merge': False}},
        {'$group': {'_id': '$company', 'count': {'$sum': '$additions'}}},
        {'$sort': {'count': -1}},
        {'$limit': 10},
        {'$project': {'name': '$_id', 'count': 1, '_id': 0}},
    ])

    return jsonify(top)

@app.route("/commits/by_date")
def by_date():
    query = commits.aggregate([
        {'$group': {
            '_id': {'$add': [{'$dayOfYear': '$date'}, {'$multiply': [400, {'$year': '$date'}]}]},
            'count': {'$sum': 1},
            'first': {'$min': '$date'},
        }},
    ])

    dates = {v['first'].strftime("%Y-%m-%d"): v['count'] for v in query['result']}
    return jsonify(dates)

@app.route("/commits/diffs")
def diffs():
    query = commits.aggregate([
        {'$match': {'merge': False}},
        {'$group': {
            '_id': '$tag.version',
            'additions': {'$sum': '$additions'},
            'deletions': {'$sum': '$deletions'},
            'version': {'$first': '$tag.name'},
            'version_nb': {'$first': '$tag.id'},
        }},
        {'$sort': {'version_nb': 1}},
        {'$project': {'_id': 0, 'additions': 1, 'deletions': 1, 'version': 1}},
    ])

    return jsonify(query)

@app.route("/commits/evolution")
def authors_evolution():
    query = commits.aggregate([
        {'$match': {'merge': False}},
        {'$group': {
            '_id': '$tag.version',
            'count': {'$sum': 1},
            'version': {'$first': '$tag.name'},
            'version_nb': {'$first': '$tag.id'},
        }},
        {'$sort': {'version_nb': 1}},
        {'$project': {'_id': 0, 'count': 1, 'version': 1}},
    ])

    return jsonify(query)

@app.route("/commits/authors_evolution")
def evolution():
    query = commits.aggregate([
        {'$match': {'merge': False}},
        {'$group': {
            '_id': '$tag.version',
            'authors': {'$addToSet': '$author'},
            'version': {'$first': '$tag.name'},
            'version_nb': {'$first': '$tag.id'},
        }},
        {'$sort': {'version_nb': 1}},
        {'$project': {'_id': 0, 'authors': 1, 'version': 1}},
    ])

    for row in query['result']:
        row['count'] = len(row['authors'])
        del row['authors']

    return jsonify(query)


if __name__ == "__main__":
    if False:
        process_commits(commits)
    debug = os.environ.get('FLASK_DEBUG', False)
    app.run(port=5000, debug=debug)
