#!/usr/bin/env python3
import os
import json

from flask import Flask, jsonify, request, Response
from pymongo import MongoClient
from bson.json_util import dumps, loads
from bson.objectid import ObjectId
from base64 import b64encode, b64decode

app = Flask(__name__)

client = MongoClient("mongo:27017")

@app.route('/sync_question', methods=['GET'])
def get_question():
    query = request.args.get('after')

    if query is not None:
        documents = client.db.questions.find({"_id": {"$gt": ObjectId(query)}})
    else:
        documents = client.db.questions.find()
    
    return_data = [{
        "id": str(document["_id"]),
        "x": document["x"],
        "y": document["y"],
        "floor": document["floor"],
        # "image": b64encode(document["image"]).decode('utf-8')
    } for document in documents]
    
    return jsonify(return_data)
    

@app.route('/create_question', methods=['POST'])
def create_question():
    print("accepting create_question request")
    data = request.get_json()

    data["image"] = b64decode(data["image"])

    collection = client.db.questions
    qid = collection.insert_one(data).inserted_id

    return jsonify({
        "message": "successful",
        "id": str(qid)
    })

@app.route('/export')
def export_db():
    documents = client.db.questions.find()
    
    with open("questions.json", "w") as file:
        json.dump(json.loads(dumps(documents)), file)
    
    return jsonify({
        "message": "successful"
    })

@app.route('/image/<string:qid>', methods=['GET'])
def get_image(qid):
    document = client.db.questions.find_one({"_id": ObjectId(qid)})
    
    if document is None:
        return jsonify({'error': 'Image not found'}), 404
    
    headers = {'Content-Type': 'image/jpeg'}
    return Response(document["image"], headers=headers)

@app.route('/')
def root():
    return jsonify({
        "message": "hello"
    })

def init_db(client):
    collection = client.db.questions
    collection.delete_many({})
    
    '''
    with open("27_hku_hong-kong-university_colonial-heritage_zolima-citymag.jpg", "rb") as file:
        imgbyte = file.read()
        collection.insert_one({
            "image": imgbyte,
            "x": 1250.6396965865638,
            "y": 2192.9494311002054,
            "floor": "G"
        })
    '''

    if os.path.exists("questions.json"):
        with open("questions.json", "r") as file:
            for document in loads(file.read()):
                collection.insert_one(document)
    elif os.path.isfile("questions/question.json"):
        with open("questions/question.json", "r") as file:
            for document in json.load(file):
                print(document)
                with open(document["img_pth"], "rb") as imgfile:
                    data = {
                        "x": document["x"],
                        "y": document["y"],
                        "floor": document["floor"],
                        "image": imgfile.read()
                    }

                    collection.insert_one(data)



if __name__ == "__main__":
    init_db(client)

    
    app.run(host='0.0.0.0', port=os.environ.get("FLASK_SERVER_PORT", 9090), debug=True)
