from flask import Flask, request
import pyrebase
import json
from classification import classify


__firebase_config = {
        "apiKey": "",
        "authDomain": "",
        "databaseURL": "",
        "storageBucket": ""
    }

firebase = pyrebase.initialize_app(__firebase_config)
storage = firebase.storage()

app = Flask(__name__)


@app.route('/classify', methods=['GET', 'POST'])
def classify_photo():
    print(request.args.get('key', ''))
    print(request.form['name'])
    image_name = request.form['name']
    image_path = 'images/'+image_name
    image_url = request.form['url']

    #download photo from storage
    storage.child(image_name).download(image_path)
    labels = classify(image_path)

    data = {'name': image_name, 'url': image_url, 'descriptions': labels}
    return json.dumps(data)
